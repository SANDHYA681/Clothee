<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>
<%@ page import="service.ProductService" %>
<%@ page import="java.util.List" %>

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

// Get products
ProductService productService = new ProductService();
List<Product> products = productService.getAllProducts();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test View/Edit Product</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .btn {
            display: inline-block;
            padding: 5px 10px;
            margin-right: 5px;
            text-decoration: none;
            border-radius: 3px;
        }
        .btn-view {
            background-color: #007bff;
            color: white;
        }
        .btn-edit {
            background-color: #28a745;
            color: white;
        }
        .success {
            color: green;
            font-weight: bold;
        }
        .error {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1>Test View/Edit Product</h1>
    
    <% if (request.getParameter("success") != null) { %>
        <p class="success"><%= request.getParameter("success") %></p>
    <% } %>
    
    <% if (request.getParameter("error") != null) { %>
        <p class="error"><%= request.getParameter("error") %></p>
    <% } %>
    
    <p><a href="<%= request.getContextPath() %>/admin/products.jsp">Back to Products</a></p>
    
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% for (Product product : products) { %>
                <tr>
                    <td><%= product.getId() %></td>
                    <td><%= product.getName() %></td>
                    <td><%= product.getCategory() %></td>
                    <td>$<%= String.format("%.2f", product.getPrice()) %></td>
                    <td><%= product.getStock() %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=view&id=<%= product.getId() %>" class="btn btn-view">View</a>
                        <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>" class="btn btn-edit">Edit</a>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
</body>
</html>
