<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.MessageDAO" %>

<%
// Check if user is logged in and is an admin
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

// Get user to delete from request attribute
User userToDelete = (User) request.getAttribute("userToDelete");
if (userToDelete == null) {
    response.sendRedirect(request.getContextPath() + "/AdminUserServlet");
    return;
}

// Get unread message count
MessageDAO messageDAO = new MessageDAO();
int unreadMessages = messageDAO.getUnreadMessageCount();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirm Delete User - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-new.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-fix.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar-fix.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-delete-confirmation.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the new sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

        <div class="content">
            <div class="content-header">
                <h1>Confirm Delete User</h1>
                <div class="header-actions">
                    <a href="messages.jsp" class="header-action" title="Messages <% if (unreadMessages > 0) { %>(<%=unreadMessages%> unread)<% } %>">
                        <i class="fas fa-envelope"></i>
                        <% if (unreadMessages > 0) { %><span class="header-badge"><%= unreadMessages %></span><% } %>
                    </a>
                </div>
            </div>

            <div class="confirmation-container">
                <div class="confirmation-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <h2 class="confirmation-title">Delete User</h2>
                <p class="confirmation-message">
                    Are you sure you want to delete this user? This action cannot be undone.
                </p>

                <div class="user-info">
                    <table class="user-table">
                        <tr>
                            <td class="label-cell">Name:</td>
                            <td class="value-cell"><%= userToDelete.getFirstName() %> <%= userToDelete.getLastName() %></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Email:</td>
                            <td class="value-cell"><%= userToDelete.getEmail() %></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Role:</td>
                            <td class="value-cell"><%= userToDelete.isAdmin() ? "Administrator" : "Customer" %></td>
                        </tr>
                        <tr>
                            <td class="label-cell">User ID:</td>
                            <td class="value-cell">#<%= userToDelete.getId() %></td>
                        </tr>
                    </table>
                </div>

                <div class="confirmation-actions">
                    <a href="<%= request.getContextPath() %>/AdminUserServlet" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                    <a href="<%= request.getContextPath() %>/AdminUserServlet?action=delete&id=<%= userToDelete.getId() %>" class="btn btn-danger">
                        <i class="fas fa-trash-alt"></i> Delete User
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Include common footer scripts -->
    <jsp:include page="includes/footer-scripts.jsp" />
</body>
</html>
