<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Category" %>
<%@ page import="dao.CategoryDAO" %>

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

// Get category ID from request
String categoryIdStr = request.getParameter("id");
if (categoryIdStr == null || categoryIdStr.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Category+ID+is+required");
    return;
}

int categoryId;
try {
    categoryId = Integer.parseInt(categoryIdStr);
} catch (NumberFormatException e) {
    response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Invalid+category+ID");
    return;
}

// Get category from database
CategoryDAO categoryDAO = new CategoryDAO();
Category category = categoryDAO.getCategoryById(categoryId);

if (category == null) {
    response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Category+not+found");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Category - Admin Dashboard</title>
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
            max-width: 500px;
            margin: 0 auto;
        }

        .content {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .content-header {
            background-color: #fff;
            padding: 20px;
            border-bottom: 1px solid #eee;
            text-align: center;
        }

        .content-header h1 {
            color: #2d4185;
            font-size: 24px;
            margin: 0 0 15px 0;
            font-weight: 600;
        }

        .back-link {
            color: #4a69bd;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            font-size: 14px;
        }

        .back-link i {
            margin-right: 5px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #333;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }

        .form-control:focus {
            border-color: #4a69bd;
            outline: none;
            box-shadow: 0 0 0 2px rgba(74, 105, 189, 0.2);
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        .form-actions {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 20px;
        }

        .btn-cancel {
            background-color: #f5f5f5;
            color: #333;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-cancel:hover {
            background-color: #e0e0e0;
        }

        .btn-submit {
            background-color: #4a69bd;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-submit:hover {
            background-color: #3c5aa9;
        }

        .alert {
            padding: 10px 15px;
            border-radius: 4px;
            margin-bottom: 20px;
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

        /* Category image */
        .category-image-section {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #fff;
            border-bottom: 1px solid #eee;
            text-align: center;
        }

        .section-title {
            font-size: 16px;
            font-weight: 600;
            color: #2d4185;
            margin-bottom: 15px;
            text-align: center;
        }

        .category-image {
            margin-bottom: 20px;
            text-align: center;
        }

        .category-image img {
            max-width: 100%;
            max-height: 200px;
            border-radius: 4px;
        }

        .no-image {
            width: 100%;
            height: 150px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f5f5f5;
            color: #999;
            font-size: 14px;
            border-radius: 4px;
            border: 1px dashed #ddd;
        }

        /* Form section styling */
        .form-section {
            padding: 15px;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="main-content">
            <div class="content">
                <div class="content-header">
                    <h1>Edit Category</h1>
                    <a href="<%= request.getContextPath() %>/admin/AdminCategoryServlet" class="back-link">
                        <i class="fas fa-arrow-left"></i> Back to Categories
                    </a>
                </div>

                <%
                String error = request.getParameter("error");
                String message = request.getParameter("message");
                if (error != null && !error.isEmpty()) {
                %>
                <div class="alert alert-danger">
                    <%= error %>
                </div>
                <% } %>

                <% if (message != null && !message.isEmpty()) { %>
                <div class="alert alert-success">
                    <%= message %>
                </div>
                <% } %>

                <!-- Category Image Section -->
                <div class="category-image-section">
                    <h3 class="section-title">Category Image</h3>
                    <div class="category-image">
                        <% if (category.getImageUrl() != null && !category.getImageUrl().isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/<%= category.getImageUrl() %>?t=<%= System.currentTimeMillis() %>" alt="<%= category.getName() %>">
                        <% } else { %>
                            <div class="no-image">No image uploaded</div>
                        <% } %>
                    </div>
                </div>

                <!-- Form Section -->
                <div class="form-section">
                    <form action="<%= request.getContextPath() %>/admin/AdminCategoryServlet" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" value="<%= category.getId() %>">

                        <div class="form-group">
                            <label for="name" class="form-label">Category Name</label>
                            <input type="text" id="name" name="name" class="form-control" value="<%= category.getName() %>" required>
                        </div>

                        <div class="form-group">
                            <label for="description" class="form-label">Description</label>
                            <textarea id="description" name="description" class="form-control"><%= category.getDescription() != null ? category.getDescription() : "" %></textarea>
                        </div>

                        <div class="form-actions">
                            <a href="<%= request.getContextPath() %>/admin/AdminCategoryServlet" class="btn-cancel">Cancel</a>
                            <button type="submit" class="btn-submit">Update Category</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
