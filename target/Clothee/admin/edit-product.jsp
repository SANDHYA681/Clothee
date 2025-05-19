<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ page import="model.Category" %>
<%-- Removed direct DAO imports to follow MVC pattern --%>

<%
// Check if user is logged in and is an admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User user = (User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get product from request attribute (set by AdminProductServlet)
Product product = (Product) request.getAttribute("product");

if (product == null) {
    response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product not found");
    return;
}

// Get categories from request attribute
List<Category> categories = (List<Category>) request.getAttribute("categories");
if (categories == null) {
    categories = new ArrayList<>();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - Admin Dashboard</title>
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
                    <h1>Edit Product</h1>
                    <a href="<%= request.getContextPath() %>/admin/AdminProductServlet" class="btn-back">
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
                <% if (request.getAttribute("error") != null) { %>
                <div class="compact-alert compact-alert-danger">
                    <%= request.getAttribute("error") %>
                </div>
                <% } %>

                <div class="compact-form-container">
                    <div class="form-grid">
                        <div>
                            <div class="compact-product-image-container">
                                <div class="compact-product-image">
                                    <img src="<%= request.getContextPath() %>/<%= (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) ? product.getImageUrl() : "images/placeholder.jpg" %>?t=<%= System.currentTimeMillis() %>" alt="<%= product.getName() %>">
                                    <div class="compact-product-image-overlay">
                                        <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=showImageForm&id=<%= product.getId() %>" class="compact-btn-change-image">
                                            <i class="fas fa-camera"></i> Change
                                        </a>
                                    </div>
                                </div>
                                <small>Click to change image</small>
                            </div>

                            <div class="compact-form-group">
                                <label for="category" class="compact-form-label">Category</label>
                                <select id="category" name="category" class="compact-form-control" form="productForm" required>
                                    <option value="">Select Category</option>
                                    <option value="All" <%= "All".equals(product.getCategory()) ? "selected" : "" %>>All Categories</option>
                                    <%
                                    if (categories != null && !categories.isEmpty()) {
                                        for (Category category : categories) {
                                    %>
                                    <option value="<%= category.getName() %>" <%= category.getName().equals(product.getCategory()) ? "selected" : "" %>><%= category.getName() %></option>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <option value="Men" <%= "Men".equals(product.getCategory()) ? "selected" : "" %>>Men</option>
                                    <option value="Women" <%= "Women".equals(product.getCategory()) ? "selected" : "" %>>Women</option>
                                    <option value="Kids" <%= "Kids".equals(product.getCategory()) ? "selected" : "" %>>Kids</option>
                                    <%
                                    }
                                    %>
                                </select>
                            </div>

                            <div class="compact-form-group">
                                <label for="type" class="compact-form-label">Type</label>
                                <input type="text" id="type" name="type" class="compact-form-control" value="<%= product.getType() %>" form="productForm" required>
                            </div>

                            <div class="compact-form-group">
                                <div class="compact-checkbox-group">
                                    <input type="checkbox" id="featured" name="featured" value="true" <%= product.isFeatured() ? "checked" : "" %> form="productForm">
                                    <label for="featured" class="compact-form-label">Featured Product</label>
                                </div>
                            </div>
                        </div>

                        <div>
                            <form id="productForm" action="<%= request.getContextPath() %>/admin/AdminProductServlet" method="post">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= product.getId() %>">

                                <div class="compact-form-row">
                                    <div class="compact-form-group">
                                        <label for="name" class="compact-form-label">Product Name</label>
                                        <input type="text" id="name" name="name" class="compact-form-control" value="<%= product.getName() %>" required>
                                    </div>

                                    <div class="compact-form-group">
                                        <label for="price" class="compact-form-label">Price ($)</label>
                                        <input type="number" id="price" name="price" class="compact-form-control" step="0.01" min="0" value="<%= product.getPrice() %>" required>
                                    </div>
                                </div>

                                <div class="compact-form-row">
                                    <div class="compact-form-group">
                                        <label for="stock" class="compact-form-label">Stock</label>
                                        <input type="number" id="stock" name="stock" class="compact-form-control" min="0" value="<%= product.getStock() %>" required>
                                    </div>

                                    <div class="compact-form-group">
                                        <label for="imageUrl" class="compact-form-label">Image URL</label>
                                        <input type="text" id="imageUrl" name="imageUrl" class="compact-form-control" value="<%= product.getImageUrl() != null ? product.getImageUrl() : "" %>">
                                    </div>
                                </div>

                                <div class="compact-form-group">
                                    <label for="description" class="compact-form-label">Description</label>
                                    <textarea id="description" name="description" class="compact-form-control textarea" required><%= product.getDescription() %></textarea>
                                </div>

                                <div class="compact-form-actions">
                                    <a href="<%= request.getContextPath() %>/admin/AdminProductServlet" class="compact-btn-cancel">Cancel</a>
                                    <button type="submit" class="compact-btn-submit">Update Product</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--
    MVC Implementation Notes:

    1. Image Upload:
       - Instead of using a JavaScript modal, we use a separate page for image uploads
       - The "Change Image" link redirects to AdminProductServlet with showImageForm action
       - The servlet forwards to upload-product-image.jsp
       - The image upload form submits directly to ImageServlet
       - After processing, ImageServlet redirects back to the edit page

    2. Form Validation:
       - All form validation happens in the servlet (controller)
       - Error messages are passed back to the view via request attributes

    3. Alert Messages:
       - Instead of JavaScript alerts, we use JSP conditionals to display messages
       - Messages are stored in request/session attributes

    4. No JavaScript is used in this implementation:
       - All functionality is handled through server-side processing
       - State is maintained through the server session
       - Complete page refreshes are used instead of dynamic updates
    -->
</body>
</html>
