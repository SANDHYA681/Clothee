<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirm Account Deletion - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin.css">
    <style>
        .confirmation-container {
            max-width: 600px;
            margin: 50px auto;
            background-color: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        
        .confirmation-icon {
            font-size: 60px;
            color: #ff6b6b;
            margin-bottom: 20px;
        }
        
        .confirmation-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }
        
        .confirmation-message {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .confirmation-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
        }
        
        .btn-cancel {
            padding: 12px 25px;
            background-color: #f5f5f5;
            color: #333;
            border: none;
            border-radius: 5px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
        }
        
        .btn-confirm {
            padding: 12px 25px;
            background-color: #ff6b6b;
            color: white;
            border: none;
            border-radius: 5px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
        }
        
        .btn-cancel:hover {
            background-color: #e9e9e9;
        }
        
        .btn-confirm:hover {
            background-color: #ff5252;
        }
    </style>
</head>
<body>
    <div class="confirmation-container">
        <div class="confirmation-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h1 class="confirmation-title">Confirm Account Deletion</h1>
        <p class="confirmation-message">
            Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed from our system.
        </p>
        <div class="confirmation-actions">
            <a href="dashboard.jsp" class="btn-cancel">Cancel</a>
            <form action="../UserDeleteServlet" method="post" style="display: inline;">
                <input type="hidden" name="userId" value="<%= currentUser.getId() %>">
                <button type="submit" class="btn-confirm">Delete Account</button>
            </form>
        </div>
    </div>
</body>
</html>
