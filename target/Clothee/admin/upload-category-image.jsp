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
    <link rel="stylesheet" href="../css/admin-dashboard.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 0;
            height: 100vh;
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .dashboard-container {
            display: flex;
            justify-content: center;
            align-items: center;
            width: 100%;
            max-width: 1200px;
        }

        .main-content {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .content {
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            position: relative;
            z-index: 10;
            width: 350px;
        }

        .content-header {
            background-color: #fff;
            padding: 20px 15px 15px;
            border-bottom: 1px solid #eee;
            text-align: center;
            position: relative;
        }

        .content-header h1 {
            color: #4a69bd;
            font-size: 20px;
            margin: 0 0 15px 0;
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

        .category-info {
            padding: 24px 20px;
            text-align: center;
            border-bottom: 1px solid #eee;
            margin-bottom: 0;
            background-color: #fcfdff;
        }

        .category-name {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 6px;
            color: #333;
        }

        .category-description {
            color: #666;
            margin-bottom: 0;
            font-size: 15px;
            line-height: 1.4;
        }

        .current-image-section {
            padding: 28px 20px;
            text-align: center;
            border-bottom: 1px solid #eee;
            background-color: #fafbfd;
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

        .current-image {
            margin: 20px auto 15px;
            text-align: center;
            max-width: 280px;
        }

        .current-image img {
            max-width: 100%;
            max-height: 160px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            border: 1px solid #f0f0f0;
        }

        .no-image {
            width: 100%;
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8f9fa;
            color: #aaa;
            font-size: 13px;
            border-radius: 8px;
            border: 1px dashed #ddd;
            margin: 0 auto;
            max-width: 280px;
        }

        .upload-section {
            padding: 20px 25px 25px;
            text-align: center;
            background-color: #fff;
            width: 100%;
        }

        .form-group {
            margin-bottom: 15px;
            width: 100%;
            position: relative;
        }

        .form-label {
            display: block;
            margin-bottom: 12px;
            font-weight: 500;
            color: #333;
        }

        .form-control {
            width: 100%;
            padding: 14px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
            transition: all 0.3s ease;
            background-color: #f8fafc;
        }

        .form-control:focus {
            border-color: #4a69bd;
            outline: none;
            box-shadow: 0 0 0 3px rgba(74, 105, 189, 0.1);
            background-color: #fff;
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
            gap: 15px;
            margin-top: 25px;
            width: 100%;
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

        .alert {
            padding: 12px 14px;
            border-radius: 8px;
            margin: 0 auto 15px;
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
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="main-content">
            <div class="content">
                <div class="content-header">
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
        </div>
    </div>
</body>
</html>
