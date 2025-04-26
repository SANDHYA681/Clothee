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
    <link rel="stylesheet" href="../css/admin-dashboard.css">
    <style>
        .form-container {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
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
        }

        .form-control:focus {
            border-color: #ff8800;
            outline: none;
            box-shadow: 0 0 0 2px rgba(255, 136, 0, 0.2);
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
        }

        .btn-submit {
            background-color: #ff8800;
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

        /* Category image */
        .category-image {
            margin-bottom: 20px;
            text-align: center;
        }

        .category-image img {
            max-width: 100%;
            max-height: 200px;
            border-radius: 4px;
            border: 1px solid #ddd;
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

        .image-actions {
            margin-top: 10px;
            display: flex;
            justify-content: center;
            gap: 10px;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%= request.getContextPath() %>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="user-details">
                        <h4><%= user.getFirstName() %></h4>
                        <p>Administrator</p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/admin/products.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-box"></i></span>
                    Products
                </a>
                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="menu-item active">
                    <span class="menu-icon"><i class="fas fa-tags"></i></span>
                    Categories
                </a>
                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-users"></i></span>
                    Customers
                </a>
                <a href="<%= request.getContextPath() %>/admin/reviews.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-star"></i></span>
                    Reviews
                </a>
                <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-envelope"></i></span>
                    Messages
                </a>
                <a href="<%= request.getContextPath() %>/admin/settings.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-cog"></i></span>
                    Settings
                </a>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <button id="sidebarToggle" class="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>

                <div class="header-actions">
                    <div class="search-box">
                        <input type="text" placeholder="Search...">
                        <button><i class="fas fa-search"></i></button>
                    </div>

                    <div class="notifications">
                        <button class="notification-btn">
                            <i class="fas fa-bell"></i>
                            <span class="badge">3</span>
                        </button>
                    </div>
                </div>
            </div>

            <div class="content">
                <div class="content-header">
                    <h1>Edit Category</h1>
                    <button class="btn-back" onclick="location.href='<%= request.getContextPath() %>/admin/categories.jsp'">
                        <i class="fas fa-arrow-left"></i> Back to Categories
                    </button>
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

                <div class="form-container">
                    <!-- Category Image Section -->
                    <div class="category-image">
                        <h3>Category Image</h3>
                        <% if (category.getImageUrl() != null && !category.getImageUrl().isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/<%= category.getImageUrl() %>" alt="<%= category.getName() %>">
                        <% } else { %>
                            <div class="no-image">No image uploaded</div>
                        <% } %>
                        <div class="image-actions">
                            <a href="upload-category-image.jsp?id=<%= category.getId() %>" class="btn-submit">
                                <i class="fas fa-upload"></i> <%= category.getImageUrl() != null && !category.getImageUrl().isEmpty() ? "Change Image" : "Upload Image" %>
                            </a>
                            <% if (category.getImageUrl() != null && !category.getImageUrl().isEmpty()) { %>
                                <a href="<%= request.getContextPath() %>/admin/AdminCategoryServlet?action=removeImage&id=<%= category.getId() %>" class="btn-cancel" onclick="return confirm('Are you sure you want to remove this image?')">
                                    <i class="fas fa-trash"></i> Remove Image
                                </a>
                            <% } %>
                        </div>
                    </div>

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
                            <button type="button" class="btn-cancel" onclick="location.href='<%= request.getContextPath() %>/admin/categories.jsp'">Cancel</button>
                            <button type="submit" class="btn-submit">Update Category</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>


</body>
</html>
