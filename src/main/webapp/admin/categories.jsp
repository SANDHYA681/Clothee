<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
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

// Initialize error message
String errorMessage = null;

// Get all categories
CategoryDAO categoryDAO = new CategoryDAO();
List<Category> categories = null;
try {
    categories = categoryDAO.getAllCategories();
    System.out.println("Categories retrieved: " + (categories != null ? categories.size() : "null"));
} catch (Exception e) {
    System.out.println("Error retrieving categories: " + e.getMessage());
    e.printStackTrace();
    errorMessage = "Error retrieving categories: " + e.getMessage();
}

if (categories == null) {
    categories = new ArrayList<>();
}

// Get success or error messages from request parameters
String successMessage = request.getParameter("success");
if (errorMessage == null) {
    errorMessage = request.getParameter("error");
}

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
    <link rel="stylesheet" href="../css/admin-categories-enhanced.css">
    <style>
        /* Custom styles for category management */

        /* Custom styles for category thumbnail in table view */
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

        /* Alert styles are now in admin-blue-theme-all.css */
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
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <% if (user.getProfileImage().startsWith("images/")) { %>
                                <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } %>
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="Default Profile Image">
                        <% } %>
                    </div>
                    <div class="user-details">
                        <h4><%= user.getFullName() %></h4>
                        <p><%= user.getRole() %></p>
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

                <!-- Header actions area -->
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
                if (message != null && !message.isEmpty()) {
                %>
                <div class="alert alert-success">
                    <%= message %>
                </div>
                <% } %>

                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
                <% } else if (request.getParameter("error") != null && !request.getParameter("error").isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= request.getParameter("error") %>
                </div>
                <% } %>

                <!-- Category Grid View -->
                <div class="category-grid">
                    <% if (categories.isEmpty()) { %>
                    <div class="no-categories-message" style="grid-column: span 3; text-align: center; padding: 30px; background-color: #f9f9f9; border-radius: 5px;">
                        <i class="fas fa-info-circle" style="font-size: 48px; color: #6c757d; margin-bottom: 20px;"></i>
                        <h3>No Categories Found</h3>
                        <p>There are no categories in the system yet. Click the "Add New Category" button to create your first category.</p>

                        <div style="margin-top: 20px;">
                            <a href="<%= request.getContextPath() %>/admin/AdminCategoryServlet?action=showAddForm" class="btn-primary" style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 4px; margin-right: 10px;">
                                <i class="fas fa-plus"></i> Add New Category
                            </a>

                        </div>
                    </div>
                    <% } %>

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
                                <a href="<%= request.getContextPath() %>/CategoryServlet?action=view&id=<%= category.getId() %>" class="btn-view">
                                    <i class="fas fa-eye"></i> View
                                </a>
                                <a href="<%= request.getContextPath() %>/CategoryServlet?action=showEdit&id=<%= category.getId() %>" class="btn-edit">
                                    <i class="fas fa-edit"></i> Edit
                                </a>
                                <a href="<%= request.getContextPath() %>/admin/upload-category-image.jsp?id=<%= category.getId() %>" class="btn-upload">
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
