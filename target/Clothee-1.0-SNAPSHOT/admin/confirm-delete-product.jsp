<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>

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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirm Delete - Admin Dashboard</title>
    <!-- No external CSS libraries -->
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .dashboard-container {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .admin-content {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .confirm-delete-container {
            max-width: 600px;
            width: 90%;
            background-color: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            padding: 40px;
            text-align: center;
            animation: fadeIn 0.5s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .confirm-delete-icon {
            font-size: 70px;
            color: #e74c3c;
            margin-bottom: 25px;
            animation: pulse 1.5s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        .confirm-delete-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 20px;
            color: #333;
        }

        .confirm-delete-message {
            font-size: 18px;
            color: #555;
            margin-bottom: 35px;
            line-height: 1.6;
        }

        .product-details {
            background-color: #f9f9f9;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 35px;
            text-align: left;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
        }

        .product-image {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border-radius: 8px;
            margin-right: 25px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .product-info {
            flex: 1;
        }

        .product-name {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }

        .product-category {
            font-size: 16px;
            color: #777;
            margin-bottom: 8px;
        }

        .product-price {
            font-size: 20px;
            font-weight: 700;
            color: #e74c3c;
        }

        .confirm-delete-actions {
            display: flex;
            justify-content: center;
            gap: 25px;
        }

        .btn {
            padding: 14px 30px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;

            border: none;
        }

        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }

        .btn-secondary {
            background-color: #7f8c8d;
            color: white;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="admin-content">

            <div class="confirm-delete-container">
                <div class="confirm-delete-icon">
                    !
                </div>

                <h1 class="confirm-delete-title">Confirm Delete</h1>

                <p class="confirm-delete-message">
                    Are you sure you want to delete this product? This action cannot be undone.
                </p>

                <div class="product-details">
                    <img src="<%= request.getContextPath() %>/<%= (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) ? product.getImageUrl() : "images/placeholder.jpg" %>"
                         alt="<%= product.getName() %>" class="product-image">

                    <div class="product-info">
                        <h3 class="product-name"><%= product.getName() %></h3>
                        <p class="product-category"><%= product.getCategory() %> / <%= product.getType() %></p>
                        <p class="product-price">$<%= String.format("%.2f", product.getPrice()) %></p>
                    </div>
                </div>

                <div class="confirm-delete-actions">
                    <a href="<%= request.getContextPath() %>/admin/AdminProductServlet" class="btn btn-secondary">
                        Cancel
                    </a>

                    <form action="<%= request.getContextPath() %>/admin/AdminProductServlet" method="post">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= product.getId() %>">
                        <button type="submit" class="btn btn-danger">
                            Delete Product
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
