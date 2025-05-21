<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="dao.ProductDAO" %>

<%
// Check if user is logged in and is admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

model.User user = (model.User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get product from request attribute or parameter
Product product = (Product) request.getAttribute("product");
List<Product> products = (List<Product>) request.getAttribute("products");

// If accessed directly, get product ID from request parameter
String productIdParam = request.getParameter("id");
int productId = 0;

// If product is null and productIdParam is not null, get product from database
if (product == null && productIdParam != null && !productIdParam.isEmpty()) {
    try {
        productId = Integer.parseInt(productIdParam);
        ProductDAO productDAO = new ProductDAO();
        product = productDAO.getProductById(productId);
    } catch (Exception e) {
        // Invalid product ID or error getting product
        e.printStackTrace();
    }
}

// If products is null, get all products from database
if (products == null) {
    ProductDAO productDAO = new ProductDAO();
    products = productDAO.getAllProducts();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Product Image - Admin Dashboard</title>
    <link rel="stylesheet" href="../css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="../css/admin/admin-compact-forms.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="main-content">
            <!-- Header removed as requested -->

            <div class="content">
                <div class="content-header">
                    <a href="products.jsp" class="btn-add">
                        <i class="fas fa-arrow-left"></i> Back to Products
                    </a>
                </div>

                <% if (request.getParameter("success") != null && request.getParameter("success").equals("true")) { %>
                    <div class="compact-alert compact-alert-success">
                        <%= request.getParameter("message") %>
                    </div>
                <% } %>

                <% if (request.getParameter("error") != null && request.getParameter("error").equals("true")) { %>
                    <div class="compact-alert compact-alert-danger">
                        <%= request.getParameter("message") %>
                    </div>
                <% } %>

                <div class="compact-upload-container">
                    <form action="../ImageServlet" method="post" enctype="multipart/form-data" id="uploadForm">
                        <% if (product != null) { %>
                            <input type="hidden" name="productId" value="<%= product.getId() %>">
                            <input type="hidden" name="category" value="<%= product.getCategory() %>">
                            <input type="hidden" name="type" value="<%= product.getType() %>">
                            <input type="hidden" name="returnUrl" value="/admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>">

                            <div class="compact-form-group">
                                <label class="compact-form-label">Product Name</label>
                                <input type="text" class="compact-form-control" value="<%= product.getName() %>" readonly>
                            </div>

                            <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                <div class="compact-current-image">
                                    <h4>Current Image</h4>
                                    <img src="../<%= product.getImageUrl() %>?t=<%= System.currentTimeMillis() %>" alt="<%= product.getName() %>">
                                </div>
                            <% } %>
                        <% } else { %>
                            <div class="compact-form-group">
                                <label for="productId" class="compact-form-label">Select Product</label>
                                <form action="../admin/AdminProductServlet" method="get">
                                    <input type="hidden" name="action" value="showImageForm">
                                    <select name="id" id="productId" class="compact-form-control" required>
                                        <option value="">-- Select Product --</option>
                                        <%
                                        if (products != null) {
                                            for (Product p : products) {
                                        %>
                                            <option value="<%= p.getId() %>"><%= p.getName() %></option>
                                        <%
                                            }
                                        }
                                        %>
                                    </select>
                                    <button type="submit" class="compact-btn-submit" style="margin-top: 10px;">
                                        <i class="fas fa-check"></i> Select Product
                                    </button>
                                </form>
                            </div>
                        <% } %>

                        <div class="compact-form-group">
                            <label for="productImage" class="compact-form-label">Upload Image</label>
                            <small>Select an image file (JPG, PNG, or GIF)</small>
                            <input type="file" id="productImage" name="productImage" accept="image/*" required class="compact-form-control">
                            <div class="compact-image-preview">
                                <div class="compact-image-preview-placeholder">
                                    <i class="fas fa-cloud-upload-alt"></i>
                                    <p>Select an image file</p>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="compact-btn-submit">
                            <i class="fas fa-cloud-upload-alt"></i> Upload Image
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!--
    MVC Implementation Notes:

    This page follows the MVC pattern by:
    1. Model: Using the Product object passed from the controller
    2. View: Displaying the product details and image upload form
    3. Controller: Using ImageServlet to handle the image upload

    No JavaScript is used - all actions are handled through server-side processing:
    - The form submits directly to ImageServlet
    - After processing, ImageServlet redirects back to the edit page
    - All validation and processing happens on the server
    -->
</body>
</html>
