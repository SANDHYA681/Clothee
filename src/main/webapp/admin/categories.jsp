<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Category" %>
<%@ page import="dao.CategoryDAO" %>
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

// Get all categories
CategoryDAO categoryDAO = new CategoryDAO();
List<Category> categories = categoryDAO.getAllCategories();

// Get success or error messages from request parameters
String successMessage = request.getParameter("success");
String errorMessage = request.getParameter("error");

// Date formatter
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");

// Delete category if requested
String deleteId = request.getParameter("delete");
if (deleteId != null && !deleteId.isEmpty()) {
    int id = Integer.parseInt(deleteId);
    boolean success = categoryDAO.deleteCategory(id);
    if (success) {
        response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?message=Category+deleted+successfully");
    } else {
        response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Failed+to+delete+category");
    }
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Categories</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-dashboard.css">
    <style>
        /* Category grid layout */
        .category-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .category-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: transform 0.3s ease;
        }

        .category-card:hover {
            transform: translateY(-5px);
        }

        .category-image {
            height: 180px;
            background-color: #f5f5f5;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .category-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .category-image .no-image {
            color: #999;
            font-size: 14px;
        }

        .category-info {
            padding: 15px;
        }

        .category-name {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
            color: #333;
        }

        .category-description {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
            height: 60px;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
        }

        .category-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
        }

        /* Category thumbnail for table view */
        .category-thumbnail {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #ddd;
        }

        .no-image {
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f5f5f5;
            color: #999;
            font-size: 12px;
            border-radius: 4px;
            border: 1px dashed #ddd;
        }

        /* Buttons */
        .btn-view, .btn-edit, .btn-delete, .btn-upload {
            padding: 8px 15px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            border: none;
        }

        .btn-view {
            background-color: #e3f2fd;
            color: #0d6efd;
        }

        .btn-edit {
            background-color: #fff8e1;
            color: #ff8800;
        }

        .btn-upload {
            background-color: #e0f7fa;
            color: #00acc1;
        }

        .btn-delete {
            background-color: #ffebee;
            color: #dc3545;
        }

        .btn-view:hover {
            background-color: #0d6efd;
            color: white;
        }

        .btn-edit:hover {
            background-color: #ff8800;
            color: white;
        }

        .btn-upload:hover {
            background-color: #00acc1;
            color: white;
        }

        .btn-delete:hover {
            background-color: #dc3545;
            color: white;
        }

        .add-category-btn {
            background-color: #ff8800;
            color: white;
            padding: 10px 20px;
            border-radius: 4px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
        }

        .add-category-btn:hover {
            background-color: #e67a00;
        }

        /* Image upload button */
        .btn-upload {
            background-color: #6c757d;
            color: white;
        }

        .btn-upload:hover {
            background-color: #5a6268;
        }

        /* Image preview */
        .image-preview {
            margin: 15px 0;
            text-align: center;
            min-height: 100px;
            border: 1px dashed #ddd;
            border-radius: 4px;
            padding: 10px;
            background-color: #f9f9f9;
        }

        /* Alerts */
        .alert {
            padding: 15px;
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
                    <h1>Category Management</h1>
                    <button class="btn-add" onclick="location.href='../admin/AdminCategoryServlet?action=showAddForm'">
                        <i class="fas fa-plus"></i> Add New Category
                    </button>
                </div>

                <%
                String message = request.getParameter("message");
                String error = request.getParameter("error");
                if (message != null && !message.isEmpty()) {
                %>
                <div class="alert alert-success">
                    <%= message %>
                </div>
                <% } %>

                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= error %>
                </div>
                <% } %>

                <!-- Category Grid View -->
                <div class="category-grid">
                    <% for (Category category : categories) { %>
                    <div class="category-card">
                        <div class="category-image">
                            <% if (category.getImageUrl() != null && !category.getImageUrl().isEmpty()) { %>
                                <img src="<%= request.getContextPath() %>/<%= category.getImageUrl() %>" alt="<%= category.getName() %>">
                            <% } else { %>
                                <div class="no-image">No Image Available</div>
                            <% } %>
                        </div>
                        <div class="category-info">
                            <h3 class="category-name"><%= category.getName() %></h3>
                            <div class="category-description">
                                <%= category.getDescription() != null ? category.getDescription() : "No description available" %>
                            </div>
                            <div class="category-meta">
                                <span class="category-products"><i class="fas fa-box"></i> <%= category.getProductCount() %> Products</span>
                                <span class="category-date"><i class="fas fa-calendar-alt"></i> <%= category.getCreatedAt() != null ? dateFormat.format(category.getCreatedAt()) : "N/A" %></span>
                            </div>
                            <div class="category-actions">
                                <a href="view-category.jsp?id=<%= category.getId() %>" class="btn-view">
                                    <i class="fas fa-eye"></i> View
                                </a>
                                <a href="edit-category.jsp?id=<%= category.getId() %>" class="btn-edit">
                                    <i class="fas fa-edit"></i> Edit
                                </a>
                                <a href="upload-category-image.jsp?id=<%= category.getId() %>" class="btn-upload">
                                    <i class="fas fa-image"></i> Image
                                </a>
                                <a href="<%= request.getContextPath() %>/admin/AdminCategoryServlet?action=delete&id=<%= category.getId() %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete <%= category.getName() %>?')">
                                    <i class="fas fa-trash"></i> Delete
                                </a>
                            </div>
                        </div>
                    </div>
                    <% } %>

                    <!-- Add New Category Card -->
                    <div class="category-card" style="display: flex; align-items: center; justify-content: center;">
                        <a href="<%= request.getContextPath() %>/admin/AdminCategoryServlet?action=showAddForm" style="text-decoration: none;">
                            <div style="text-align: center; padding: 30px;">
                                <div style="font-size: 48px; color: #ff8800; margin-bottom: 15px;">
                                    <i class="fas fa-plus-circle"></i>
                                </div>
                                <h3 style="color: #333;">Add New Category</h3>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>




</body>
</html>
