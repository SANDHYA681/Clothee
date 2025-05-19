<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get user to delete from request
    User userToDelete = (User) request.getAttribute("userToDelete");

    if (userToDelete == null) {
        response.sendRedirect(request.getContextPath() + "/admin/AdminUserServlet?error=User not found");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirm Delete User</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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

        .confirm-box {
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            width: 400px;
            max-width: 90%;
            overflow: hidden;
        }

        .confirm-content {
            padding: 25px;
            text-align: center;
        }

        .warning-icon {
            color: #e74c3c;
            font-size: 40px;
            margin-bottom: 15px;
        }

        .confirm-title {
            color: #2d4185;
            font-size: 20px;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .confirm-message {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 20px;
            line-height: 1.5;
        }

        .user-info {
            background-color: #f8fafc;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 20px;
            text-align: left;
        }

        .user-name {
            color: #1e293b;
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .user-email {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 5px;
        }

        .user-role {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            background-color: #e0f2fe;
            color: #0369a1;
        }

        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            border: none;
            text-decoration: none;
            display: inline-block;
        }

        .btn-cancel {
            background-color: #f5f5f5;
            color: #333;
            border: 1px solid #ddd;
        }

        .btn-cancel:hover {
            background-color: #e0e0e0;
        }

        .btn-delete {
            background-color: #4a69bd;
            color: white;
        }

        .btn-delete:hover {
            background-color: #3c5aa9;
        }
    </style>
</head>
<body>
    <!-- Header removed as requested -->

    <div class="confirm-box">
        <div class="confirm-content">
            <div class="warning-icon">⚠️</div>

            <h2 class="confirm-title">Confirm Delete</h2>

            <p class="confirm-message">
                Are you sure you want to delete this user? This action cannot be undone.
            </p>

            <div class="user-info">
                <div class="user-name"><%= userToDelete.getFullName() %></div>
                <div class="user-email"><%= userToDelete.getEmail() %></div>
                <div class="user-role">
                    <%= userToDelete.isAdmin() ? "Admin" : "Customer" %>
                </div>
            </div>

            <div class="action-buttons">
                <a href="<%= request.getContextPath() %>/admin/AdminUserServlet" class="btn btn-cancel">
                    Cancel
                </a>

                <form action="<%= request.getContextPath() %>/admin/AdminUserServlet" method="post" style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= userToDelete.getId() %>">
                    <button type="submit" class="btn btn-delete">
                        Delete User
                    </button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
