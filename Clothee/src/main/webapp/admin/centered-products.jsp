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

// Get success and error messages
String successMessage = request.getParameter("success");
String errorMessage = request.getParameter("error");

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
    <title>Product Management</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }

        body {
            background-color: #f5f5f5;
            color: #333;
            line-height: 1.6;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 1000px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .header {
            text-align: center;
            padding: 20px;
            background-color: #f8f9fa;
            border-bottom: 1px solid #eee;
        }

        h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 15px;
        }

        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 15px;
        }

        .btn {
            display: inline-block;
            padding: 8px 16px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }

        .content {
            padding: 20px;
        }

        .alert {
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            text-align: center;
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

        .table-container {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
            position: sticky;
            top: 0;
        }

        /* No hover effects */

        .product-image {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #ddd;
        }

        .image-container {
            position: relative;
            width: 60px;
            height: 60px;
        }

        .image-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background-color: rgba(0, 0, 0, 0.7);
            color: white;
            text-align: center;
            padding: 2px;
            font-size: 10px;
            cursor: pointer;
            text-decoration: none;
            display: block;
        }

        .image-overlay:hover {
            background-color: rgba(0, 0, 0, 0.9);
        }

        .badge {
            display: inline-block;
            padding: 3px 6px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
        }

        .badge-featured {
            background-color: #28a745;
            color: white;
            font-weight: bold;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        .badge-normal {
            background-color: #6c757d;
            color: white;
        }

        .action-icons {
            display: flex;
            gap: 8px;
            justify-content: center;
        }

        .action-icon {
            display: inline-block;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
            margin: 0 5px;
            padding: 3px 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .view-icon {
            color: white;
            background-color: #17a2b8;
            border-color: #17a2b8;
        }

        .edit-icon {
            color: white;
            background-color: #ffc107;
            border-color: #ffc107;
        }

        .delete-icon {
            color: white;
            background-color: #dc3545;
            border-color: #dc3545;
        }

        .empty-state {
            text-align: center;
            padding: 40px 0;
            color: #6c757d;
        }

        .empty-icon {
            font-size: 48px;
            margin-bottom: 10px;
            color: #adb5bd;
        }

        /* Center align specific columns */
        td:nth-child(1), /* ID */
        td:nth-child(5), /* Price */
        td:nth-child(6), /* Stock */
        td:nth-child(7), /* Featured */
        td:nth-child(8), /* Actions */
        th:nth-child(1),
        th:nth-child(5),
        th:nth-child(6),
        th:nth-child(7),
        th:nth-child(8) {
            text-align: center;
        }

        /* Make the table more compact */
        @media (max-width: 768px) {
            th, td {
                padding: 8px 10px;
                font-size: 14px;
            }

            .product-image,
            .image-container {
                width: 50px;
                height: 50px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Product Management</h1>
            <div class="action-buttons">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="btn" style="background-color: #4361ee;">Back to Dashboard</a>
                <a href="<%= request.getContextPath() %>/admin/upload-product-image.jsp" class="btn">Upload Images</a>
                <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=showAddForm" class="btn">Add New Product</a>
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

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Image</th>
                            <th>Name</th>
                            <th>Category</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Featured</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (products.isEmpty()) { %>
                            <tr>
                                <td colspan="8">
                                    <div class="empty-state">
                                        <div class="empty-icon">📦</div>
                                        <p>No products found</p>
                                        <p>Click "Add New Product" to create your first product</p>
                                    </div>
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Product product : products) { %>
                                <tr>
                                    <td><%= product.getId() %></td>
                                    <td>
                                        <div class="image-container">
                                            <img src="<%= request.getContextPath() %>/<%= (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) ? product.getImageUrl() : "images/placeholder.jpg" %>"
                                                 alt="<%= product.getName() %>" class="product-image">
                                            <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>" class="image-overlay">
                                                Change
                                            </a>
                                        </div>
                                    </td>
                                    <td><%= product.getName() %></td>
                                    <td><%= product.getCategory() %> / <%= product.getType() != null ? product.getType() : "" %></td>
                                    <td>$<%= String.format("%.2f", product.getPrice()) %></td>
                                    <td><%= product.getStock() %></td>
                                    <td>
                                        <% if (product.isFeatured()) { %>
                                            <span class="badge badge-featured">Featured</span>
                                        <% } else { %>
                                            <span class="badge badge-normal">No</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="action-icons">
                                            <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=view&id=<%= product.getId() %>"
                                               class="action-icon view-icon" title="View">View</a>
                                            <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>"
                                               class="action-icon edit-icon" title="Edit">Edit</a>
                                            <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=confirmDelete&id=<%= product.getId() %>"
                                               class="action-icon delete-icon" title="Delete">Delete</a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
