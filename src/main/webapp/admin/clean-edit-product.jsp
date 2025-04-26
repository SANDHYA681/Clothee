<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ page import="model.Category" %>

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
    <title>Edit Product</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }

        h1 {
            color: #333;
            margin-bottom: 20px;
            text-align: center;
        }

        .alert {
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .form-group {
            margin-bottom: 15px;
        }

        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }

        input[type="text"],
        input[type="number"],
        textarea,
        select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        textarea {
            min-height: 100px;
            resize: vertical;
        }

        .form-row {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
        }

        .form-row .form-group {
            flex: 1;
            margin-bottom: 0;
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 10px;
        }

        .checkbox-group input {
            margin: 0;
        }

        .checkbox-group label {
            margin-bottom: 0;
            font-weight: normal;
        }

        .btn-group {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }

        .btn {
            padding: 8px 16px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            border: none;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-primary {
            background-color: #007bff;
            color: white;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .product-image {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 4px;
            margin-bottom: 10px;
            border: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Edit Product</h1>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getParameter("error") %>
            </div>
        <% } %>

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">
                <%= request.getParameter("success") %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/admin/AdminProductServlet" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= product.getId() %>">

            <div class="form-row">
                <div class="form-group">
                    <label for="name">Product Name</label>
                    <input type="text" id="name" name="name" value="<%= product.getName() %>" required>
                </div>

                <div class="form-group">
                    <label for="price">Price ($)</label>
                    <input type="number" id="price" name="price" step="0.01" min="0" value="<%= product.getPrice() %>" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="category">Category</label>
                    <select id="category" name="category" required>
                        <option value="">Select Category</option>
                        <option value="All" <%= "All".equals(product.getCategory()) ? "selected" : "" %>>All Categories</option>
                        <% for (Category category : categories) { %>
                            <option value="<%= category.getName() %>" <%= category.getName().equals(product.getCategory()) ? "selected" : "" %>><%= category.getName() %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="stock">Stock</label>
                    <input type="number" id="stock" name="stock" min="0" value="<%= product.getStock() %>" required>
                </div>
            </div>

            <div class="form-group">
                <label for="type">Type</label>
                <input type="text" id="type" name="type" value="<%= product.getType() != null ? product.getType() : "" %>">
            </div>

            <div class="form-group">
                <label for="description">Description</label>
                <textarea id="description" name="description"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
            </div>

            <div class="form-group">
                <label for="imageUrl">Image URL</label>
                <input type="text" id="imageUrl" name="imageUrl" value="<%= product.getImageUrl() != null ? product.getImageUrl() : "" %>">
                <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                    <img src="<%= request.getContextPath() %>/<%= product.getImageUrl() %>" alt="<%= product.getName() %>" class="product-image">
                <% } %>
            </div>

            <div class="checkbox-group">
                <!-- Hidden field to ensure featured parameter is always sent -->
                <input type="hidden" name="featured" value="false">
                <!-- Checkbox will override the hidden field when checked -->
                <input type="checkbox" id="featured" name="featured" value="true" <%= product.isFeatured() ? "checked" : "" %>>
                <label for="featured">Featured Product</label>
            </div>

            <div class="btn-group">
                <a href="<%= request.getContextPath() %>/admin/AdminProductServlet" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">Update Product</button>
            </div>
        </form>
    </div>
</body>
</html>
