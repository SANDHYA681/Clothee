<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>

<%
// Check if user is logged in and is admin
User user = (User) session.getAttribute("user");
if (user == null || !user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

// Get product from request attribute
Product product = (Product) request.getAttribute("product");

// Get products from request attribute (for dropdown)
List<Product> products = (List<Product>) request.getAttribute("products");

// Get success or error messages if any
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");

// Clear messages from session after displaying
if (successMessage != null) {
    session.removeAttribute("successMessage");
}
if (errorMessage != null) {
    session.removeAttribute("errorMessage");
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Product Image - CLOTHEE Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/main.css">
    <style>
        .upload-container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .btn-container {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
        }

        .btn-primary {
            background-color: #4a6bdf;
            color: white;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
            text-decoration: none;
        }

        .alert {
            padding: 10px 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <% if (user.getProfileImage().startsWith("images/")) { %>
                                <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } %>
                        <% } else { %>
                            <div class="no-profile-image">
                                <i class="fas fa-user"></i>
                            </div>
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Admin</p>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Upload Product Image</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/admin/products.jsp" class="header-action" title="Back to Products">
                        <i class="fas fa-arrow-left"></i>
                    </a>
                </div>
            </div>

            <div class="content">
                <% if (successMessage != null) { %>
                    <div class="alert alert-success">
                        <%= successMessage %>
                    </div>
                <% } %>

                <% if (errorMessage != null) { %>
                    <div class="alert alert-danger">
                        <%= errorMessage %>
                    </div>
                <% } %>

                <div class="upload-container">
                    <form action="<%=request.getContextPath()%>/ImageServlet" method="post" enctype="multipart/form-data">
                        <% if (product != null) { %>
                            <input type="hidden" name="productId" value="<%= product.getId() %>">

                            <div class="form-group">
                                <label class="form-label">Product:</label>
                                <input type="text" class="form-control" value="<%= product.getName() %>" readonly>
                            </div>
                        <% } else if (products != null && !products.isEmpty()) { %>
                            <div class="form-group">
                                <label class="form-label" for="productId">Select Product:</label>
                                <select name="productId" id="productId" class="form-control" required>
                                    <option value="">-- Select a product --</option>
                                    <% for (Product p : products) { %>
                                        <option value="<%= p.getId() %>"><%= p.getName() %></option>
                                    <% } %>
                                </select>
                            </div>
                        <% } %>

                        <div class="form-group">
                            <label class="form-label" for="productImage">Select a product image:</label>
                            <input type="file" id="productImage" name="productImage" class="form-control" accept="image/*" required>
                            <small>Supported formats: JPG, JPEG, PNG, GIF. Max size: 5MB.</small>
                        </div>

                        <div class="btn-container">
                            <a href="<%=request.getContextPath()%>/admin/products.jsp" class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-primary">Upload Image</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
