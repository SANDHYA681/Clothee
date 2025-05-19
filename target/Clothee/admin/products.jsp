<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>

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

// Get success and error messages from both request parameters and session attributes
String successMessage = null;
String errorMessage = null;

// Check for success=true parameter
if (request.getParameter("success") != null && request.getParameter("success").equals("true")) {
    successMessage = request.getParameter("message");
}

// Check for error=true parameter
if (request.getParameter("error") != null && request.getParameter("error").equals("true")) {
    errorMessage = request.getParameter("message");
}

// Check session attributes as well
String sessionSuccessMessage = (String) session.getAttribute("successMessage");
String sessionErrorMessage = (String) session.getAttribute("errorMessage");

// Use session messages if available
if (sessionSuccessMessage != null) {
    successMessage = sessionSuccessMessage;
    session.removeAttribute("successMessage");
}

if (sessionErrorMessage != null) {
    errorMessage = sessionErrorMessage;
    session.removeAttribute("errorMessage");
}

// Get products from request attribute or redirect to AdminProductServlet
List<Product> products = (List<Product>) request.getAttribute("products");

// If products is null, redirect to AdminProductServlet
if (products == null) {
    response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Management - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin/admin-products-modern.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="main-content">
            <div class="header">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="back-button">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>

                <div class="header-actions">
                    <a href="upload-product-image.jsp" class="btn-add">
                        <i class="fas fa-image"></i> Upload Images
                    </a>
                    <a href="../admin/AdminProductServlet?action=showAddForm" class="btn-add">
                        <i class="fas fa-plus"></i> Add New Product
                    </a>
                </div>
            </div>

            <div class="content">
                <div class="content-header">
                    <h1>Product Management</h1>
                </div>

                <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success" id="successAlert">
                    <i class="fas fa-check-circle"></i> <%= successMessage %>
                </div>
                <% } %>
                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger" id="errorAlert">
                    <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
                </div>
                <% } %>



                <div class="products-section">
                    <div class="products-header">
                        <h2>Products</h2>
                    </div>

                    <div class="products-body">
                        <% if (products.isEmpty()) { %>
                            <div class="empty-state">
                                <i class="fas fa-box-open"></i>
                                <p>No products found</p>
                                <a href="../admin/AdminProductServlet?action=showAddForm" class="btn-add">
                                    <i class="fas fa-plus"></i> Add New Product
                                </a>
                            </div>
                        <% } else { %>
                            <table class="products-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Image</th>
                                        <th>Product</th>
                                        <th>Category</th>
                                        <th>Price</th>
                                        <th>Stock</th>
                                        <th>Featured</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Product product : products) { %>
                                    <tr>
                                        <td><%= product.getId() %></td>
                                        <td>
                                            <div class="product-image">
                                                <img src="<%= request.getContextPath() %>/<%= (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) ? product.getImageUrl() : "images/placeholder.jpg" %>" alt="<%= product.getName() %>">
                                                <div class="product-image-overlay">
                                                    <a href="../admin/AdminProductServlet?action=showImageForm&id=<%= product.getId() %>" class="btn-change-image">
                                                        <i class="fas fa-camera"></i> Change
                                                    </a>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="product-name"><%= product.getName() %></div>
                                        </td>
                                        <td>
                                            <div class="product-category"><%= product.getCategory() %> / <%= product.getType() %></div>
                                        </td>
                                        <td>
                                            <div class="product-price">$<%= String.format("%.2f", product.getPrice()) %></div>
                                        </td>
                                        <td>
                                            <div class="product-stock"><%= product.getStock() %></div>
                                        </td>
                                        <td>
                                            <% if (product.isFeatured()) { %>
                                                <span class="badge featured">
                                                    <i class="fas fa-star"></i> Yes
                                                </span>
                                                <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=toggleFeatured&id=<%= product.getId() %>" class="toggle-featured remove">
                                                    <i class="far fa-star"></i> Remove
                                                </a>
                                            <% } else { %>
                                                <span class="badge not-featured">
                                                    <i class="far fa-star"></i> No
                                                </span>
                                                <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=toggleFeatured&id=<%= product.getId() %>" class="toggle-featured add">
                                                    <i class="fas fa-star"></i> Set
                                                </a>
                                            <% } %>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="../admin/AdminProductServlet?action=view&id=<%= product.getId() %>" class="action-btn view" title="View">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <a href="../admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>" class="action-btn edit" title="Edit">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <a href="upload-product-image.jsp?id=<%= product.getId() %>" class="action-btn image" title="Upload Image">
                                                    <i class="fas fa-image"></i>
                                                </a>
                                                <a href="../admin/AdminProductServlet?action=confirmDelete&id=<%= product.getId() %>" class="action-btn delete" title="Delete">
                                                    <i class="fas fa-trash-alt"></i>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>


</body>
</html>
