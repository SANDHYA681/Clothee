<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

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

// Get error message if any
String error = (String) request.getAttribute("error");
String categoryName = (String) request.getAttribute("categoryName");
String categoryDescription = (String) request.getAttribute("categoryDescription");

// Set default values if not provided
if (categoryName == null) categoryName = "";
if (categoryDescription == null) categoryDescription = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Category</title>
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
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }
        
        h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
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
        }
        
        .form-control:focus {
            border-color: #4a6bdf;
            outline: none;
            box-shadow: 0 0 0 2px rgba(74, 107, 223, 0.2);
        }
        
        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 30px;
        }
        
        .btn-cancel {
            background-color: #f5f5f5;
            color: #333;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-submit {
            background-color: #4a6bdf;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
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
        
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #4a6bdf;
            text-decoration: none;
            font-weight: 500;
        }
        
        .form-note {
            margin-top: 20px;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 4px;
            font-size: 14px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="back-link">← Back to Categories</a>
        
        <h1>Add New Category</h1>
        
        <% if (error != null) { %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
        <% } %>
        
        <form action="<%= request.getContextPath() %>/admin/AdminCategoryServlet" method="post">
            <input type="hidden" name="action" value="add">
            
            <div class="form-group">
                <label for="name">Category Name</label>
                <input type="text" id="name" name="name" class="form-control" value="<%= categoryName %>" required>
            </div>
            
            <div class="form-group">
                <label for="description">Description</label>
                <textarea id="description" name="description" class="form-control"><%= categoryDescription %></textarea>
            </div>
            
            <div class="form-actions">
                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="btn-cancel">Cancel</a>
                <button type="submit" class="btn-submit">Add Category</button>
            </div>
        </form>
        
        <div class="form-note">
            <p>You can upload an image for this category after creating it.</p>
        </div>
    </div>
</body>
</html>
