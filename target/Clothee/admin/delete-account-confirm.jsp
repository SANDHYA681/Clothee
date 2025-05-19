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
    <!-- No external CSS libraries used -->
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .confirmation-container {
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            width: 400px;
            max-width: 90%;
            padding: 25px;
            text-align: center;
        }

        .confirmation-icon {
            font-size: 40px;
            color: #e74c3c;
            margin-bottom: 15px;
        }

        .confirmation-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #2d4185;
        }

        .confirmation-message {
            font-size: 14px;
            color: #64748b;
            margin-bottom: 20px;
            line-height: 1.5;
        }

        .confirmation-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }

        .btn-cancel {
            padding: 10px 20px;
            background-color: #f5f5f5;
            color: #333;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-confirm {
            padding: 10px 20px;
            background-color: #4a69bd;
            color: white;
            border: none;
            border-radius: 4px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-cancel:hover {
            background-color: #e0e0e0;
        }

        .btn-confirm:hover {
            background-color: #3c5aa9;
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
