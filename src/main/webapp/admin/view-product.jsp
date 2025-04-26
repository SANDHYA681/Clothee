<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>

<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get product from request
    Product product = (Product) request.getAttribute("product");

    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Product not found");
        return;
    }

    // Format for prices
    DecimalFormat df = new DecimalFormat("#,##0.00");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Product - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-unified.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <style>
        /* Additional styles for the view product page */
        .product-container {
            margin: 20px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .page-title {
            font-size: 24px;
            font-weight: 600;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-primary {
            background-color: #4CAF50;
            color: white;
        }

        .btn-secondary {
            background-color: #2196F3;
            color: white;
        }

        .btn-danger {
            background-color: #F44336;
            color: white;
        }

        .product-details {
            display: flex;
            flex-wrap: wrap;
            gap: 30px;
            margin-top: 20px;
        }

        .product-images {
            flex: 1;
            min-width: 300px;
        }

        .product-main-image {
            width: 100%;
            height: 400px;
            object-fit: contain;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-bottom: 10px;
        }

        .product-thumbnails {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .product-thumbnail {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
        }

        .product-info {
            flex: 2;
            min-width: 300px;
        }

        .product-info-table {
            width: 100%;
            border-collapse: collapse;
        }

        .product-info-table th, .product-info-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        .product-info-table th {
            width: 150px;
            background-color: #f8f9fa;
            font-weight: 600;
        }

        .badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .badge-success {
            background-color: #d4edda;
            color: #155724;
        }

        .badge-warning {
            background-color: #fff3cd;
            color: #856404;
        }

        .badge-danger {
            background-color: #f8d7da;
            color: #721c24;
        }

        .featured-badge {
            background-color: #cce5ff;
            color: #004085;
        }

        .product-description {
            margin-top: 20px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="admin-content">

            <div class="product-container">
                <div class="page-header">
                    <h1 class="page-title">View Product</h1>
                    <div class="action-buttons">
                        <a href="<%= request.getContextPath() %>/admin/AdminProductServlet" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Products
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>" class="btn btn-primary">
                            <i class="fas fa-edit"></i> Edit Product
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=confirmDelete&id=<%= product.getId() %>" class="btn btn-danger">
                            <i class="fas fa-trash"></i> Delete Product
                        </a>
                    </div>
                </div>

                <div class="product-details">
                    <div class="product-images">
                        <img src="<%= request.getContextPath() %>/<%= product.getImageUrl() != null && !product.getImageUrl().isEmpty() ? product.getImageUrl() : "images/placeholder.jpg" %>"
                             alt="<%= product.getName() %>" class="product-main-image" id="mainImage">

                        <div class="product-thumbnails">
                            <img src="<%= request.getContextPath() %>/<%= product.getImageUrl() != null && !product.getImageUrl().isEmpty() ? product.getImageUrl() : "images/placeholder.jpg" %>"
                                 alt="<%= product.getName() %>" class="product-thumbnail" onclick="changeMainImage(this.src)">

                            <%
                            List<String> additionalImages = product.getAdditionalImages();
                            if (additionalImages != null && !additionalImages.isEmpty()) {
                                for (String imageUrl : additionalImages) {
                            %>
                            <img src="<%= request.getContextPath() %>/<%= imageUrl %>"
                                 alt="<%= product.getName() %>" class="product-thumbnail" onclick="changeMainImage(this.src)">
                            <%
                                }
                            }
                            %>
                        </div>
                    </div>

                    <div class="product-info">
                        <table class="product-info-table">
                            <tr>
                                <th>ID</th>
                                <td><%= product.getId() %></td>
                            </tr>
                            <tr>
                                <th>Name</th>
                                <td><%= product.getName() %></td>
                            </tr>
                            <tr>
                                <th>Category</th>
                                <td><%= product.getCategory() %></td>
                            </tr>
                            <tr>
                                <th>Type</th>
                                <td><%= product.getType() %></td>
                            </tr>
                            <tr>
                                <th>Price</th>
                                <td>$<%= df.format(product.getPrice()) %></td>
                            </tr>
                            <tr>
                                <th>Stock</th>
                                <td>
                                    <% if (product.getStock() > 10) { %>
                                    <span class="badge badge-success"><%= product.getStock() %></span>
                                    <% } else if (product.getStock() > 0) { %>
                                    <span class="badge badge-warning"><%= product.getStock() %></span>
                                    <% } else { %>
                                    <span class="badge badge-danger">Out of stock</span>
                                    <% } %>
                                </td>
                            </tr>
                            <tr>
                                <th>Featured</th>
                                <td>
                                    <% if (product.isFeatured()) { %>
                                    <span class="badge featured-badge">Featured</span>
                                    <% } else { %>
                                    No
                                    <% } %>
                                </td>
                            </tr>
                        </table>

                        <div class="product-description">
                            <h3>Description</h3>
                            <p><%= product.getDescription() %></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function changeMainImage(src) {
            document.getElementById('mainImage').src = src;
        }
    </script>
</body>
</html>
