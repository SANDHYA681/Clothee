<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Message" %>
<%@ page import="dao.MessageDAO" %>
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

// Get messages
MessageDAO messageDAO = new MessageDAO();
List<Message> messages = messageDAO.getAllMessages();
int unreadCount = messageDAO.getUnreadMessageCount();

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Messages</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-dashboard.css">
</head>
<body>
    <div class="dashboard-container">
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
                    <div class="user-details">
                        <h4><%= user.getFullName() %></h4>
                        <p>Administrator</p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="menu-item">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/admin/products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    Products
                </a>
                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="menu-item">
                    <i class="fas fa-users menu-icon"></i>
                    Customers
                </a>
                <a href="<%= request.getContextPath() %>/admin/reviews.jsp" class="menu-item">
                    <i class="fas fa-star menu-icon"></i>
                    Reviews
                </a>
                <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="menu-item active">
                    <i class="fas fa-envelope menu-icon"></i>
                    Messages
                </a>
                <a href="<%= request.getContextPath() %>/admin/settings.jsp" class="menu-item">
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
                <h1 class="page-title">Message Management</h1>
                <div class="header-actions">
                    <a href="<%= request.getContextPath() %>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Filter Messages</h2>
                </div>
                <div class="filter-options" style="display: flex; gap: 10px; margin-bottom: 20px;">
                    <form action="<%= request.getContextPath() %>/admin/AdminMessageServlet" method="get" style="display: flex; gap: 10px; width: 100%;">
                        <select name="filter" class="form-control" style="flex: 1;">
                            <option value="all" <%= request.getParameter("filter") == null || "all".equals(request.getParameter("filter")) ? "selected" : "" %>>All Messages</option>
                            <option value="unread" <%= "unread".equals(request.getParameter("filter")) ? "selected" : "" %>>New Messages</option>
                            <option value="replied" <%= "replied".equals(request.getParameter("filter")) ? "selected" : "" %>>Replied Messages</option>
                        </select>
                        <button type="submit" class="btn-primary" style="padding: 10px 15px;">
                            <i class="fas fa-filter"></i> Filter
                        </button>
                    </form>
                </div>
            </div>

                <%
                // Get messages from request parameters or attributes
                String successMessage = request.getParameter("success");
                if (successMessage == null) {
                    successMessage = (String) request.getAttribute("success");
                }

                String error = request.getParameter("error");
                if (error == null) {
                    error = (String) request.getAttribute("error");
                }

                // Display success message if present
                if (successMessage != null && !successMessage.isEmpty()) {
                %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <%
                // Display error message if present
                if (error != null && !error.isEmpty()) {
                %>
                <div class="alert alert-danger">
                    <strong>Error:</strong> <%= error %>
                </div>
                <% } %>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">All Messages</h2>
                        <div class="message-stats">
                            <div class="stat-item">
                                <span class="stat-label">Total:</span>
                                <span class="stat-value"><%= messages.size() %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Unread:</span>
                                <span class="stat-value"><%= unreadCount %></span>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Name</th>
                                        <th>Email</th>
                                        <th>Subject</th>
                                        <th>Message</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% if (messages.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center">No messages found</td>
                                    </tr>
                                <% } else {
                                    for (Message msg : messages) {
                                        String statusClass = msg.isReplied() ? "status-replied" : "status-unread";
                                        String statusText = msg.isReplied() ? "Response sent" : "Awaiting response";
                                %>
                                    <tr class="<%= statusClass %>">
                                        <td><%= msg.getId() %></td>
                                        <td><%= msg.getName() %></td>
                                        <td><%= msg.getEmail() %></td>
                                        <td><%= msg.getSubject() %></td>
                                        <td><%= msg.getMessage().length() > 50 ? msg.getMessage().substring(0, 47) + "..." : msg.getMessage() %></td>
                                        <td><%= dateFormat.format(msg.getCreatedAt()) %></td>
                                        <td><span class="status <%= statusClass %>"><%= statusText %></span></td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=view&id=<%= msg.getId() %>" class="btn-view" title="View Message">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=delete&id=<%= msg.getId() %>" class="btn-delete" title="Delete Message" onclick="return confirm('Are you sure you want to delete this message?')">
                                                    <i class="fas fa-trash"></i>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                <% }
                                } %>
                                </tbody>
                            </table>
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



        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>
