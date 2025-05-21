<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="dao.MessageDAO" %>

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

// Get unread message count
MessageDAO messageDAO = new MessageDAO();
int unreadMessages = messageDAO.getUnreadMessageCount();

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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-new.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-fix.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-customers-new.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the new sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

        <div class="content">
            <div class="content-header">
                <h1>Customer Management</h1>
                <div class="header-actions">
                    <a href="messages.jsp" class="header-action" title="Messages <% if (unreadMessages > 0) { %>(<%=unreadMessages%> unread)<% } %>">
                        <i class="fas fa-envelope"></i>
                        <% if (unreadMessages > 0) { %><span class="header-badge"><%= unreadMessages %></span><% } %>
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
            <div class="stats-cards">
                <div class="stats-card">
                    <div class="stats-card-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stats-card-content">
                        <div class="stats-card-value"><%= users.size() %></div>
                        <div class="stats-card-label">Total Customers</div>
                    </div>
                </div>

                <div class="stats-card">
                    <div class="stats-card-icon">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="stats-card-content">
                        <div class="stats-card-value">
                            <%
                            int adminCount = 0;
                            for (User user : users) {
                                if (user.isAdmin()) adminCount++;
                            }
                            %>
                            <%= adminCount %>
                        </div>
                        <div class="stats-card-label">Administrators</div>
                    </div>
                </div>

                <div class="stats-card">
                    <div class="stats-card-icon">
                        <i class="fas fa-user-check"></i>
                    </div>
                    <div class="stats-card-content">
                        <div class="stats-card-value">
                            <%
                            int regularCount = 0;
                            for (User user : users) {
                                if (!user.isAdmin()) regularCount++;
                            }
                            %>
                            <%= regularCount %>
                        </div>
                        <div class="stats-card-label">Regular Customers</div>
                    </div>
                </div>

                <div class="stats-card">
                    <div class="stats-card-icon">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                    <div class="stats-card-content">
                        <div class="stats-card-value">
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
                        <div class="stats-card-label">New (Last 30 Days)</div>
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
                                    <th>NAME</th>
                                    <th>EMAIL</th>
                                    <th>PHONE</th>
                                    <th>ROLE</th>
                                    <th>CREATED AT</th>
                                    <th>ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (User user : users) { %>
                                <tr>
                                    <td><%= user.getId() %></td>
                                    <td>
                                        <div style="display: flex; align-items: center;">
                                            <div style="width: 24px; height: 24px; border-radius: 50%; background-color: #e0e7ff; display: flex; align-items: center; justify-content: center; margin-right: 6px; color: #4361ee; font-weight: 600; font-size: 10px;">
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
                                            <span class="badge admin"><%= user.getRole() != null ? user.getRole() : "Admin" %></span>
                                        <% } else { %>
                                            <span class="badge customer"><%= user.getRole() != null ? user.getRole() : "User" %></span>
                                        <% } %>
                                    </td>
                                    <td><%= user.getCreatedAt() != null ? dateFormat.format(user.getCreatedAt()) : "-" %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="<%= request.getContextPath() %>/AdminUserServlet?action=view&id=<%= user.getId() %>" class="btn-view" title="View">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="<%= request.getContextPath() %>/AdminUserServlet?action=edit&id=<%= user.getId() %>" class="btn-edit" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <% if (user.getId() != currentUser.getId() && !user.isAdmin()) { %>
                                                <a href="<%= request.getContextPath() %>/AdminUserServlet?action=showDeleteConfirmation&id=<%= user.getId() %>" class="btn-delete" title="Delete">
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

    <!-- Include common footer scripts -->
    <jsp:include page="includes/footer-scripts.jsp" />
</body>
</html>
