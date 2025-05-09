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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-categories-enhanced.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <div class="no-profile-image">
                                <i class="fas fa-user"></i>
                            </div>
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFullName() %></h3>
                    <p class="user-role"><%= user.getRole() %></p>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}dashboard.jsp" class="menu-item">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    Dashboard
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    Products
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}categories.jsp" class="menu-item active">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/AdminUserServlet" class="menu-item">
                    <i class="fas fa-users menu-icon"></i>
                    Customers
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}reviews.jsp" class="menu-item">
                    <i class="fas fa-star menu-icon"></i>
                    Reviews
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}messages.jsp" class="menu-item">
                    <i class="fas fa-envelope menu-icon"></i>
                    Messages
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}settings.jsp" class="menu-item">
                    <i class="fas fa-cog menu-icon"></i>
                    Settings
                </a>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="menu-item">
                    <i class="fas fa-sign-out-alt menu-icon"></i>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Category Management</h1>
                <div class="header-actions">
                    <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}notifications.jsp" class="header-action" title="Notifications">
                        <i class="fas fa-bell"></i>
                    </a>
                    <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}messages.jsp" class="header-action" title="Messages">
                        <i class="fas fa-envelope"></i>
                    </a>
                    <a href="<%= request.getContextPath() %>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <div class="content">
                <div class="content-header">
                    <h1>Category Details: <%= category.getName() %></h1>
                    <div>
                        <button class="btn-edit" onclick="location.href='../admin/CategoryServlet?action=edit&id=<%= category.getId() %>'">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn-back" onclick="location.href='categories.jsp'">
                            <i class="fas fa-arrow-left"></i> Back to Categories
                        </button>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Category Information</h2>
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
                    </div>
                </div>


            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });
    </script>
</body>
</html>
