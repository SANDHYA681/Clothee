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
import dao.ProductDAO;
import model.Category;
import model.Product;
import model.User;

/**
 * Servlet implementation class CategoryServlet
 */
// Servlet mapping defined in web.xml
public class CategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CategoryDAO categoryDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public CategoryServlet() {
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
            case "list":
                listCategories(request, response);
                break;
            case "view":
                viewCategory(request, response);
                break;
            case "showAdd":
                showAddForm(request, response);
                break;
            case "showEdit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteCategory(request, response);
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

    private void listCategories(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("categories", categoryDAO.getAllCategories());
        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }

    private void viewCategory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int categoryId = Integer.parseInt(request.getParameter("id"));
        Category category = categoryDAO.getCategoryById(categoryId);

        if (category != null) {
            request.setAttribute("category", category);

            // Set base URL for navigation
            String baseUrl = request.getContextPath() + "/admin/";
            request.setAttribute("baseUrl", baseUrl);

            request.getRequestDispatcher("/admin/view-category.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?error=Category+not+found");
        }
    }

    private void addCategory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String description = request.getParameter("description");

        Category category = new Category();
        category.setName(name);
        category.setDescription(description);

        boolean success = categoryDAO.addCategory(category);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?message=Category+added+successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?error=Failed+to+add+category");
        }
    }

    private void updateCategory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int categoryId = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("name");
        String description = request.getParameter("description");

        Category category = new Category();
        category.setId(categoryId);
        category.setName(name);
        category.setDescription(description);

        boolean success = categoryDAO.updateCategory(category);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?message=Category+updated+successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?error=Failed+to+update+category");
        }
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/admin/add-category.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int categoryId = Integer.parseInt(request.getParameter("id"));
            Category category = categoryDAO.getCategoryById(categoryId);

            if (category != null) {
                // Set category in request
                request.setAttribute("category", category);

                // Set base URL for navigation
                String baseUrl = request.getContextPath() + "/admin/";
                request.setAttribute("baseUrl", baseUrl);

                // Set context path for CSS and JS files
                request.setAttribute("contextPath", request.getContextPath());

                // Forward to edit page
                request.getRequestDispatcher("/admin/edit-category.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?error=Category+not+found");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?error=Invalid+category+ID");
        } catch (Exception e) {
            System.out.println("Error showing edit form: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?error=Error+showing+edit+form");
        }
    }

    private void deleteCategory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int categoryId = Integer.parseInt(request.getParameter("id"));
        boolean success = categoryDAO.deleteCategory(categoryId);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?message=Category+deleted+successfully");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/AdminCategoryServlet?error=Failed+to+delete+category");
        }
    }
}
