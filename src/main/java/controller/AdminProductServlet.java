package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Category;
import model.Product;
import model.User;
import service.CategoryService;
import service.ProductService;

/**
 * Servlet implementation class AdminProductServlet
 */
// Servlet mapping defined in web.xml
public class AdminProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductService productService;
    private CategoryService categoryService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminProductServlet() {
        super();
        productService = new ProductService();
        categoryService = new CategoryService();
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
                showAddProductForm(request, response);
                break;
            case "showEditForm":
                showEditProductForm(request, response);
                break;
            case "view":
                viewProduct(request, response);
                break;
            case "confirmDelete":
                confirmDeleteProduct(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            default:
                listProducts(request, response);
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
                addProduct(request, response);
                break;
            case "update":
                updateProduct(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            default:
                listProducts(request, response);
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get all products without filtering
        List<Product> products = productService.getAllProducts();

        // Set products in request and forward to JSP
        request.setAttribute("products", products);
        request.getRequestDispatcher("/admin/centered-products.jsp").forward(request, response);
    }

    private void showAddProductForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            System.out.println("AdminProductServlet - Showing add product form");
            // Get all categories for the dropdown
            List<Category> categories = categoryService.getAllCategories();
            System.out.println("AdminProductServlet - Retrieved " + categories.size() + " categories");
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/admin/simple-add-product.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("Error in showAddProductForm: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Failed to load add product form");
        }
    }

    private void showEditProductForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idStr = request.getParameter("id");
            System.out.println("Edit Product Form - Received ID: " + idStr);

            if (idStr == null || idStr.trim().isEmpty()) {
                System.out.println("Edit Product Form - ID is null or empty");
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Invalid product ID");
                return;
            }

            int id;
            try {
                id = Integer.parseInt(idStr);
                System.out.println("Edit Product Form - Parsed ID: " + id);
            } catch (NumberFormatException e) {
                System.out.println("Edit Product Form - Error parsing ID: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Invalid product ID format");
                return;
            }

            // Get the product
            Product product = productService.getProductById(id);
            if (product == null) {
                System.out.println("Edit Product Form - Product not found with ID: " + id);
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product not found");
                return;
            }
            System.out.println("Edit Product Form - Found product: " + product.getName());

            try {
                // Get all categories for the dropdown
                List<Category> categories = categoryService.getAllCategories();
                System.out.println("Edit Product Form - Retrieved " + categories.size() + " categories");

                request.setAttribute("product", product);
                request.setAttribute("categories", categories);

                // Set context path for CSS and JS files
                request.setAttribute("contextPath", request.getContextPath());

                System.out.println("Edit Product Form - Forwarding to clean-edit-product.jsp");
                request.getRequestDispatcher("/admin/clean-edit-product.jsp").forward(request, response);
            } catch (Exception e) {
                System.out.println("Edit Product Form - Error preparing form data: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Error preparing edit form");
            }
        } catch (Exception e) {
            System.out.println("Error in showEditProductForm: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=An error occurred while loading the edit form");
        }
    }

    /**
     * View a product
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws ServletException
     * @throws IOException
     */
    private void viewProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idStr = request.getParameter("id");
            System.out.println("View Product - Received ID: " + idStr);

            if (idStr == null || idStr.isEmpty()) {
                System.out.println("View Product - ID is null or empty");
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product ID is required");
                return;
            }

            int id;
            try {
                id = Integer.parseInt(idStr);
                System.out.println("View Product - Parsed ID: " + id);
            } catch (NumberFormatException e) {
                System.out.println("View Product - Error parsing ID: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Invalid product ID format");
                return;
            }

            // Get the product
            Product product = productService.getProductById(id);
            if (product == null) {
                System.out.println("View Product - Product not found with ID: " + id);
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product not found");
                return;
            }
            System.out.println("View Product - Found product: " + product.getName());

            request.setAttribute("product", product);

            // Set context path for CSS and JS files
            request.setAttribute("contextPath", request.getContextPath());

            System.out.println("View Product - Forwarding to view-product.jsp");
            try {
                request.getRequestDispatcher("/admin/view-product.jsp").forward(request, response);
            } catch (Exception e) {
                System.out.println("Error forwarding to view-product.jsp: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Error+displaying+product+details");
            }
        } catch (Exception e) {
            System.out.println("Error in viewProduct: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=An error occurred while viewing the product");
        }
    }

    /**
     * Show confirmation page before deleting a product
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws ServletException
     * @throws IOException
     */
    private void confirmDeleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idStr = request.getParameter("id");
            System.out.println("Confirm Delete Product - Received ID: " + idStr);

            if (idStr == null || idStr.isEmpty()) {
                System.out.println("Confirm Delete Product - ID is null or empty");
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product ID is required");
                return;
            }

            int id;
            try {
                id = Integer.parseInt(idStr);
                System.out.println("Confirm Delete Product - Parsed ID: " + id);
            } catch (NumberFormatException e) {
                System.out.println("Confirm Delete Product - Error parsing ID: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Invalid product ID format");
                return;
            }

            // Get the product
            Product product = productService.getProductById(id);
            if (product == null) {
                System.out.println("Confirm Delete Product - Product not found with ID: " + id);
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product not found");
                return;
            }
            System.out.println("Confirm Delete Product - Found product: " + product.getName());

            // Set the product in the request
            request.setAttribute("product", product);

            System.out.println("Confirm Delete Product - Forwarding to confirm-delete-product.jsp");
            try {
                request.getRequestDispatcher("/admin/confirm-delete-product.jsp").forward(request, response);
            } catch (Exception e) {
                System.out.println("Error forwarding to confirm-delete-product.jsp: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Error displaying delete confirmation");
            }
        } catch (Exception e) {
            System.out.println("Error in confirmDeleteProduct: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=An error occurred while preparing to delete the product");
        }
    }

    private void addProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get form data
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stock");
        String category = request.getParameter("category");
        String type = request.getParameter("type");
        String imageUrl = request.getParameter("imageUrl");
        String featuredStr = request.getParameter("featured");

        System.out.println("AdminProductServlet - Adding product: " + name);
        System.out.println("AdminProductServlet - Featured parameter: " + featuredStr);

        // Validate required fields
        if (name == null || name.trim().isEmpty() ||
            priceStr == null || priceStr.trim().isEmpty() ||
            stockStr == null || stockStr.trim().isEmpty() ||
            category == null || category.trim().isEmpty()) {

            // Get all categories for the dropdown
            List<Category> categories = categoryService.getAllCategories();
            request.setAttribute("categories", categories);
            request.setAttribute("error", "Required fields are missing");
            request.getRequestDispatcher("/admin/simple-add-product.jsp").forward(request, response);
            return;
        }

        try {
            double price = Double.parseDouble(priceStr);
            int stock = Integer.parseInt(stockStr);

            // Handle featured parameter - if featuredStr is "true", set featured to true, otherwise false
            boolean featured = "true".equals(featuredStr);
            System.out.println("AdminProductServlet - Featured parameter value: " + featuredStr);
            System.out.println("AdminProductServlet - Featured flag set to: " + featured);

            // Create product object
            Product product = new Product();
            product.setName(name);
            product.setDescription(description);
            product.setPrice(price);
            product.setStock(stock);
            product.setCategory(category);
            product.setType(type);
            product.setImageUrl(imageUrl);
            product.setFeatured(featured);
            product.setCreatedAt(new Timestamp(new Date().getTime()));
            product.setUpdatedAt(new Timestamp(new Date().getTime()));

            System.out.println("AdminProductServlet - Product object created with featured = " + product.isFeatured());

            // Add product to database
            boolean success = productService.addProduct(product);
            System.out.println("AdminProductServlet - Product added successfully: " + success);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?success=Product added successfully");
            } else {
                // Get all categories for the dropdown
                List<Category> categories = categoryService.getAllCategories();
                request.setAttribute("categories", categories);
                request.setAttribute("error", "Failed to add product");
                request.getRequestDispatcher("/admin/simple-add-product.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            System.out.println("AdminProductServlet - Error parsing numeric values: " + e.getMessage());
            // Get all categories for the dropdown
            List<Category> categories = categoryService.getAllCategories();
            request.setAttribute("categories", categories);
            request.setAttribute("error", "Invalid price or stock value");
            request.getRequestDispatcher("/admin/simple-add-product.jsp").forward(request, response);
        }
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get form data
            String idStr = request.getParameter("id");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stock");
            String category = request.getParameter("category");
            String type = request.getParameter("type");
            String imageUrl = request.getParameter("imageUrl");
            String featuredStr = request.getParameter("featured");

            System.out.println("Update Product - Received parameters:");
            System.out.println("  ID: " + idStr);
            System.out.println("  Name: " + name);
            System.out.println("  Price: " + priceStr);
            System.out.println("  Stock: " + stockStr);
            System.out.println("  Category: " + category);

            // Validate required fields
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product ID is missing");
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                System.out.println("Error parsing product ID: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Invalid product ID format");
                return;
            }

            // Get the existing product first
            Product existingProduct = productService.getProductById(productId);
            if (existingProduct == null) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product not found");
                return;
            }

            // Check other required fields
            if (name == null || name.trim().isEmpty() ||
                priceStr == null || priceStr.trim().isEmpty() ||
                stockStr == null || stockStr.trim().isEmpty() ||
                category == null || category.trim().isEmpty()) {

                // Get categories for the form
                List<Category> categories = categoryService.getAllCategories();

                request.setAttribute("product", existingProduct);
                request.setAttribute("categories", categories);
                request.setAttribute("error", "Required fields are missing");
                request.getRequestDispatcher("/admin/edit-product.jsp").forward(request, response);
                return;
            }

            try {
                double price = Double.parseDouble(priceStr);
                int stock = Integer.parseInt(stockStr);

                // Handle featured parameter - if featuredStr is "true", set featured to true, otherwise false
                boolean featured = "true".equals(featuredStr);
                System.out.println("Update Product - Featured parameter value: " + featuredStr);
                System.out.println("Update Product - Featured flag set to: " + featured);

                // Create product object
                Product product = new Product();
                product.setId(productId);
                product.setName(name);
                product.setDescription(description);
                product.setPrice(price);
                product.setStock(stock);
                product.setCategory(category);
                product.setType(type);
                product.setImageUrl(imageUrl);
                product.setFeatured(featured);
                product.setUpdatedAt(new Timestamp(new Date().getTime()));
                // Preserve creation date
                product.setCreatedAt(existingProduct.getCreatedAt());

                System.out.println("Updating product with ID: " + productId);
                // Update product in database
                boolean success = productService.updateProduct(product);
                System.out.println("Update result: " + (success ? "Success" : "Failed"));

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?success=Product updated successfully");
                } else {
                    // Get categories for the form
                    List<Category> categories = categoryService.getAllCategories();

                    request.setAttribute("product", product);
                    request.setAttribute("categories", categories);
                    request.setAttribute("error", "Failed to update product");
                    request.getRequestDispatcher("/admin/clean-edit-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                System.out.println("Error parsing numeric values: " + e.getMessage());
                // Get categories for the form
                List<Category> categories = categoryService.getAllCategories();

                request.setAttribute("product", existingProduct);
                request.setAttribute("categories", categories);
                request.setAttribute("error", "Invalid price or stock value");
                request.getRequestDispatcher("/admin/clean-edit-product.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("Error in updateProduct: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=An error occurred while updating the product");
        }
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idStr = request.getParameter("id");

            System.out.println("Delete Product - Received ID: " + idStr);

            if (idStr == null || idStr.trim().isEmpty()) {
                System.out.println("Delete Product - ID is null or empty");
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Invalid product ID");
                return;
            }

            int id;
            try {
                id = Integer.parseInt(idStr);
                System.out.println("Delete Product - Parsed ID: " + id);
            } catch (NumberFormatException e) {
                System.out.println("Delete Product - Error parsing ID: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Invalid product ID format");
                return;
            }

            // Check if product exists
            Product product = productService.getProductById(id);
            if (product == null) {
                System.out.println("Delete Product - Product not found with ID: " + id);
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product not found");
                return;
            }

            System.out.println("Delete Product - Found product: " + product.getName());

            try {
                boolean success = productService.deleteProduct(id);
                System.out.println("Delete Product - Delete operation result: " + (success ? "Success" : "Failed"));

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?success=Product deleted successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Failed to delete product. It may be referenced in orders.");
                }
            } catch (Exception e) {
                System.out.println("Delete Product - Error during deletion: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Database error while deleting the product: " + e.getMessage());
            }
        } catch (Exception e) {
            System.out.println("Error in deleteProduct: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=An error occurred while deleting the product");
        }
    }
}
