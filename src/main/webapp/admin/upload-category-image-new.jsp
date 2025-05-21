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

// Get error message if any
String error = request.getParameter("error");
String message = request.getParameter("message");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Category Image - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: #f0f4f8;
        }

        .upload-container {
            width: 350px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        .header {
            padding: 20px 15px 15px;
            border-bottom: 1px solid #eee;
            text-align: center;
        }

        .header h1 {
            color: #4a69bd;
            font-size: 20px;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .back-link {
            color: #4a69bd;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            font-size: 13px;
            transition: all 0.3s ease;
            padding: 5px 10px;
            border-radius: 6px;
        }

        .back-link:hover {
            color: #3a56d4;
            background-color: #f5f7ff;
        }

        .back-link i {
            margin-right: 5px;
            font-size: 11px;
        }

        .alert {
            padding: 12px 14px;
            border-radius: 8px;
            margin: 15px auto;
            font-size: 13px;
            display: flex;
            align-items: center;
            max-width: 280px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        .alert-success {
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        .alert-success:before {
            content: '\f058';
            font-family: 'Font Awesome 5 Free';
            font-weight: 900;
            margin-right: 10px;
            color: #22c55e;
        }

        .alert-danger {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
        }

        .alert-danger:before {
            content: '\f057';
            font-family: 'Font Awesome 5 Free';
            font-weight: 900;
            margin-right: 10px;
            color: #ef4444;
        }

        .upload-section {
            padding: 20px 30px 25px;
            text-align: center;
        }

        .section-title {
            font-size: 16px;
            font-weight: 600;
            color: #4a69bd;
            margin-bottom: 15px;
            text-align: center;
            position: relative;
            display: inline-block;
        }

        .section-title:after {
            content: '';
            position: absolute;
            bottom: -6px;
            left: 50%;
            transform: translateX(-50%);
            width: 30px;
            height: 2px;
            background-color: #e0e7ff;
            border-radius: 2px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-control {
            width: 100%;
            padding: 14px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            font-size: 14px;
            transition: all 0.3s ease;
            background-color: #f8fafc;
        }

        .form-hint {
            font-size: 13px;
            color: #718096;
            margin-top: 12px;
            font-style: italic;
            line-height: 1.4;
        }

        .form-actions {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 25px;
        }

        .btn-cancel {
            background-color: #f8fafc;
            color: #4a5568;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            font-size: 13px;
            transition: all 0.3s ease;
        }

        .btn-cancel:hover {
            background-color: #edf2f7;
            border-color: #cbd5e0;
            color: #2d3748;
        }

        .btn-submit {
            background-color: #4a69bd;
            color: #fff;
            border: none;
            border-radius: 6px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            font-size: 13px;
            transition: all 0.3s ease;
        }

        .btn-submit:hover {
            background-color: #3c5aa9;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>
    <div class="upload-container">
        <div class="header">
            <h1>Upload Category Image</h1>
            <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to Categories
            </a>
        </div>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
            <% } %>

            <% if (message != null && !message.isEmpty()) { %>
            <div class="alert alert-success">
                <%= message %>
            </div>
            <% } %>

            <div class="upload-section">
                <h3 class="section-title">Select Image</h3>
                <form action="<%= request.getContextPath() %>/CategoryImageServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="categoryId" value="<%= category.getId() %>">

                    <div class="form-group">
                        <input type="file" id="categoryImage" name="categoryImage" class="form-control" accept="image/*" required>
                        <div class="form-hint">Recommended size: 800x600 pixels. Max file size: 10MB.</div>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="btn-cancel">Cancel</a>
                        <button type="submit" class="btn-submit">Upload Image</button>
                    </div>
                </form>
            </div>
        </div>
</body>
</html>
