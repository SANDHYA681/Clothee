<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="service.UserService" %>

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

// Get user ID to delete
String userIdStr = request.getParameter("id");
if (userIdStr == null || userIdStr.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/admin/customers.jsp?error=Invalid+user+ID");
    return;
}

int userId = Integer.parseInt(userIdStr);

// Don't allow deleting the current user
if (userId == currentUser.getId()) {
    response.sendRedirect(request.getContextPath() + "/admin/customers.jsp?error=Cannot+delete+your+own+account");
    return;
}

// Get user to delete
UserService userService = new UserService();
User userToDelete = userService.getUserById(userId);

if (userToDelete == null) {
    response.sendRedirect(request.getContextPath() + "/admin/customers.jsp?error=User+not+found");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirm Delete Customer - CLOTHEE Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin.css">
    <link rel="stylesheet" href="../css/confirm-delete.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
</head>
<body>
    <div class="confirm-delete-container">
        <div class="confirm-delete-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>

        <h1 class="confirm-delete-title">Confirm Customer Deletion</h1>

        <p class="confirm-delete-message">
            You are about to delete the following customer. This action cannot be undone.
            All associated data (orders, reviews, etc.) will remain in the system but will no longer be associated with this user.
        </p>

        <div class="confirm-delete-details">
            <p><strong>ID:</strong> <%= userToDelete.getId() %></p>
            <p><strong>Name:</strong> <%= userToDelete.getFirstName() %> <%= userToDelete.getLastName() %></p>
            <p><strong>Email:</strong> <%= userToDelete.getEmail() %></p>
            <p><strong>Role:</strong> <%= userToDelete.isAdmin() ? "Admin" : "Customer" %></p>
        </div>

        <div class="confirm-delete-actions">
            <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="btn btn-secondary">
                Cancel
            </a>

            <form action="<%= request.getContextPath() %>/AdminUserServlet" method="get">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%= userToDelete.getId() %>">
                <button type="submit" class="btn btn-danger">
                    Delete Customer
                </button>
            </form>
        </div>
    </div>
</body>
</html>
