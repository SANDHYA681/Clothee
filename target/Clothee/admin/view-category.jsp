<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.SimpleDateFormat" %>

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

// Get category from request attribute
Category category = (Category) request.getAttribute("category");
if (category == null) {
    response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Category+not+found");
    return;
}

// No longer need products

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Category - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- No external CSS libraries used -->
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 0;
        }

        .dashboard-container {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .main-content {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
        }

        .content {
            display: flex;
            flex-direction: column;
        }

        .page-title {
            display: none;
        }

        .back-link-container {
            text-align: center;
            margin: 20px 0;
        }

        .back-link {
            color: #4a69bd;
            text-decoration: none;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
        }

        .back-link i {
            margin-right: 5px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin: 0 auto;
            max-width: 600px;
            width: 100%;
        }

        .card-header {
            background-color: #4a69bd;
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
        }

        .card-title {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
            color: #ffffff;
            text-align: center;
        }

        .card-body {
            padding: 20px;
        }

        .info-group {
            display: flex;
            margin-bottom: 15px;
            border-bottom: 1px solid #f0f0f0;
            padding-bottom: 15px;
        }

        .info-group:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .info-label {
            font-weight: 500;
            width: 150px;
            color: #555;
            font-size: 16px;
        }

        .info-value {
            flex: 1;
            color: #333;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="main-content">
            <div class="content">
                <h1 class="page-title">Category Details: <%= category.getName() %></h1>

                <div class="back-link-container">
                    <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="back-link">
                        <i class="fas fa-arrow-left"></i> Back to Categories
                    </a>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">CATEGORY INFORMATION</h2>
                    </div>
                    <div class="card-body">
                        <div class="info-group">
                            <div class="info-label">ID:</div>
                            <div class="info-value"><%= category.getId() %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Name:</div>
                            <div class="info-value"><%= category.getName() %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Description:</div>
                            <div class="info-value"><%= category.getDescription() != null ? category.getDescription() : "-" %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Created At:</div>
                            <div class="info-value"><%= category.getCreatedAt() != null ? dateFormat.format(category.getCreatedAt()) : "-" %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Product Count:</div>
                            <div class="info-value"><%= category.getProductCount() %></div>
                        </div>
                        <% if (category.getImageUrl() != null && !category.getImageUrl().isEmpty()) { %>
                        <div class="info-group">
                            <div class="info-label">Image:</div>
                            <div class="info-value">
                                <img src="<%= request.getContextPath() %>/<%= category.getImageUrl() %>?t=<%= System.currentTimeMillis() %>"
                                     alt="<%= category.getName() %>"
                                     style="max-width: 100%; max-height: 200px; border-radius: 4px;">
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
