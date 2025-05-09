package controller;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.CategoryDAO;
import model.Category;
import model.User;

/**
 * Servlet implementation class AdminCategoryServlet
 */
// Servlet mapping defined in web.xml
public class AdminCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CategoryDAO categoryDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminCategoryServlet() {
        super();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "showAddForm":
                showAddCategoryForm(request, response);
                break;
            case "delete":
                deleteCategory(request, response);
                break;
            case "removeImage":
                removeCategoryImage(request, response);
                break;
            default:
                listCategories(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                addCategory(request, response);
                break;
            case "update":
                updateCategory(request, response);
                break;
            default:
                listCategories(request, response);
        }
    }

    private void listCategories(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }

    private void showAddCategoryForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/simple-add-category.jsp").forward(request, response);
    }

    private void addCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("\n===== ADMIN CATEGORY SERVLET - ADD CATEGORY =====");

        // Test database connection first
        boolean connectionOk = util.DBConnection.testConnection();
        System.out.println("Database connection test: " + (connectionOk ? "OK" : "FAILED"));

        if (!connectionOk) {
            request.setAttribute("error", "Database connection failed. Please try again later.");
            request.getRequestDispatcher("/admin/simple-add-category.jsp").forward(request, response);
            return;
        }

        String name = request.getParameter("name");
        String description = request.getParameter("description");

        System.out.println("Category name: " + name);
        System.out.println("Category description: " + description);

        if (name == null || name.trim().isEmpty()) {
            System.out.println("Category name is empty or null");
            request.setAttribute("error", "Category name is required");
            request.getRequestDispatcher("/admin/simple-add-category.jsp").forward(request, response);
            return;
        }

        // Check if category with this name already exists
        try {
            System.out.println("Checking if category exists: " + name);
            boolean exists = categoryDAO.categoryExists(name);
            System.out.println("Category exists check result: " + exists);

            if (exists) {
                System.out.println("Category already exists: " + name);
                request.setAttribute("error", "A category with name '" + name + "' already exists");
                request.setAttribute("categoryName", name);
                request.setAttribute("categoryDescription", description);
                request.getRequestDispatcher("/admin/simple-add-category.jsp").forward(request, response);
                return;
            }
        } catch (Exception e) {
            System.out.println("Error checking if category exists: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error checking category existence: " + e.getMessage());
            request.setAttribute("categoryName", name);
            request.setAttribute("categoryDescription", description);
            request.getRequestDispatcher("/admin/simple-add-category.jsp").forward(request, response);
            return;
        }

        try {
            System.out.println("Creating category object");
            Category category = new Category();
            category.setName(name);
            category.setDescription(description);
            category.setImageUrl(null); // Initialize imageUrl to null

            System.out.println("Calling categoryDAO.addCategory");
            boolean success = categoryDAO.addCategory(category);
            System.out.println("Add category result: " + success);

            if (success) {
                System.out.println("Category added successfully: " + category.getId());
                response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?action=list&message=Category+added+successfully");
            } else {
                System.out.println("Failed to add category: " + category.getName());
                request.setAttribute("error", "Failed to add category. Database operation returned false.");
                request.setAttribute("categoryName", name);
                request.setAttribute("categoryDescription", description);
                request.getRequestDispatcher("/admin/simple-add-category.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("Exception adding category: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error adding category: " + e.getMessage());
            request.setAttribute("categoryName", name);
            request.setAttribute("categoryDescription", description);
            request.getRequestDispatcher("/admin/simple-add-category.jsp").forward(request, response);
        }
    }

    private void updateCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");

        if (idStr == null || name == null || name.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Invalid+category+data");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            // Get the current category to check if name is being changed
            Category currentCategory = categoryDAO.getCategoryById(id);
            if (currentCategory == null) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Category+not+found");
                return;
            }

            // Only check for existing category if the name is being changed
            if (!currentCategory.getName().equals(name) && categoryDAO.categoryExists(name)) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=A+category+with+name+'"+name+"'+already+exists");
                return;
            }

            Category category = new Category();
            category.setId(id);
            category.setName(name);
            category.setDescription(description);
            // Preserve the image URL if it exists
            if (currentCategory.getImageUrl() != null) {
                category.setImageUrl(currentCategory.getImageUrl());
            }

            boolean success = categoryDAO.updateCategory(category);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?message=Category+updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Failed+to+update+category");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Invalid+category+ID");
        }
    }

    private void deleteCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Invalid+category+ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            boolean success = categoryDAO.deleteCategory(id);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?message=Category+deleted+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Failed+to+delete+category");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Invalid+category+ID");
        }
    }

    /**
     * Remove the image from a category
     */
    private void removeCategoryImage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Invalid+category+ID");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);

            // Set the image URL to null
            boolean success = categoryDAO.updateCategoryImage(id, null);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/edit-category.jsp?id=" + id + "&success=Image+removed+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/edit-category.jsp?id=" + id + "&error=Failed+to+remove+image");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Invalid+category+ID");
        }
    }
}
