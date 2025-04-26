<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Check if user is logged in and is an admin - this check is also done in the servlet
// but we keep it here as a safety measure
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User currentUser = (User) userObj;
if (!currentUser.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get users from request attribute (set by servlet)
List<User> users = (List<User>) request.getAttribute("users");
if (users == null) {
    // If users not in request, redirect to the servlet to get the data
    response.sendRedirect(request.getContextPath() + "/AdminUserServlet");
    return;
}

// Get messages from request attributes
String successMessage = (String) request.getAttribute("successMessage");
String errorMessage = (String) request.getAttribute("errorMessage");

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Customers</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-customers-enhanced.css">
    <!-- Action buttons fix - must be loaded last to override other styles -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/action-buttons-fix.css">
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
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <h3 class="user-name"><%= currentUser.getFirstName() %> <%= currentUser.getLastName() %></h3>
                    <p class="user-role">Administrator</p>
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
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/AdminUserServlet" class="menu-item active">
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
                <h1 class="page-title">Customer Management</h1>
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

            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success">
                <%= successMessage %>
            </div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
            <% } %>

            <!-- Customer Statistics -->
            <div class="customer-stats">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value"><%= users.size() %></div>
                        <div class="stat-label">Total Customers</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">
                            <%
                            int adminCount = 0;
                            for (User user : users) {
                                if (user.isAdmin()) adminCount++;
                            }
                            %>
                            <%= adminCount %>
                        </div>
                        <div class="stat-label">Administrators</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-user-check"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">
                            <%
                            int regularCount = 0;
                            for (User user : users) {
                                if (!user.isAdmin()) regularCount++;
                            }
                            %>
                            <%= regularCount %>
                        </div>
                        <div class="stat-label">Regular Customers</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">
                            <%
                            int newCustomers = 0;
                            long thirtyDaysInMillis = 30L * 24 * 60 * 60 * 1000;
                            long currentTimeMillis = System.currentTimeMillis();
                            for (User user : users) {
                                if (user.getCreatedAt() != null &&
                                    (currentTimeMillis - user.getCreatedAt().getTime()) <= thirtyDaysInMillis) {
                                    newCustomers++;
                                }
                            }
                            %>
                            <%= newCustomers %>
                        </div>
                        <div class="stat-label">New (Last 30 Days)</div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">All Customers</h2>
                    <a href="<%= request.getContextPath() %>/AdminUserServlet?action=showAddForm" class="btn-add">
                        <i class="fas fa-plus"></i> Add New Customer
                    </a>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Role</th>
                                    <th>Created At</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (User user : users) { %>
                                <tr>
                                    <td><%= user.getId() %></td>
                                    <td>
                                        <div style="display: flex; align-items: center;">
                                            <div style="width: 40px; height: 40px; border-radius: 50%; background-color: #e0e7ff; display: flex; align-items: center; justify-content: center; margin-right: 10px; color: #4361ee; font-weight: 600;">
                                                <%= user.getFirstName().substring(0, 1).toUpperCase() %><%= user.getLastName().substring(0, 1).toUpperCase() %>
                                            </div>
                                            <div>
                                                <%= user.getFirstName() %> <%= user.getLastName() %>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= user.getEmail() %></td>
                                    <td><%= user.getPhone() != null ? user.getPhone() : "-" %></td>
                                    <td>
                                        <% if (user.isAdmin()) { %>
                                            <span class="badge admin">Admin</span>
                                        <% } else { %>
                                            <span class="badge customer">Customer</span>
                                        <% } %>
                                    </td>
                                    <td><%= user.getCreatedAt() != null ? dateFormat.format(user.getCreatedAt()) : "-" %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="<%= request.getContextPath() %>/AdminUserServlet?action=view&id=<%= user.getId() %>" class="btn-view" title="View">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <% if (!user.isAdmin()) { %>
                                                <a href="<%= request.getContextPath() %>/AdminUserServlet?action=showEditForm&id=<%= user.getId() %>" class="btn-edit" title="Edit">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                            <% } %>
                                            <% if (user.getId() != currentUser.getId()) { %>
                                                <a href="<%= request.getContextPath() %>/AdminUserServlet?action=delete&id=<%= user.getId() %>" class="btn-delete" title="Delete" onclick="return confirm('Are you sure you want to delete this customer? This action cannot be undone.');">
                                                    <i class="fas fa-trash"></i>
                                                </a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Toggle sidebar on mobile
        const toggleSidebar = document.getElementById('toggleSidebar');
        const sidebar = document.getElementById('sidebar');

        toggleSidebar.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    </script>
</body>
</html>
