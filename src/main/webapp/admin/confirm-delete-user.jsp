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
    <title>Confirm Delete - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-style.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <style>
        .confirm-delete-container {
            max-width: 600px;
            margin: 50px auto;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
            text-align: center;
        }

        .confirm-delete-icon {
            font-size: 60px;
            color: #e74c3c;
            margin-bottom: 20px;
        }

        .confirm-delete-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }

        .confirm-delete-message {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .user-details {
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
            text-align: left;
        }

        .user-name {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
            color: #333;
        }

        .user-email {
            font-size: 16px;
            color: #666;
            margin-bottom: 5px;
        }

        .user-role {
            font-size: 14px;
            font-weight: 500;
            color: #333;
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            margin-top: 5px;
        }

        .role-admin {
            background-color: #cce5ff;
            color: #004085;
        }

        .role-customer {
            background-color: #d4edda;
            color: #155724;
        }

        .confirm-delete-actions {
            display: flex;
            justify-content: center;
            gap: 20px;
        }

        .btn {
            padding: 12px 25px;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-danger {
            background-color: #e74c3c;
            color: white;
            border: none;
        }

        .btn-secondary {
            background-color: #95a5a6;
            color: white;
            border: none;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Include admin sidebar -->
        <%@ include file="includes/sidebar.jsp" %>

        <div class="admin-content">
            <!-- Include admin header -->
            <%@ include file="includes/header.jsp" %>

            <div class="confirm-delete-container">
                <div class="confirm-delete-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>

                <h1 class="confirm-delete-title">Confirm Delete</h1>

                <p class="confirm-delete-message">
                    Are you sure you want to delete this user? This action cannot be undone.
                </p>

                <div class="user-details">
                    <h3 class="user-name"><%= userToDelete.getFullName() %></h3>
                    <p class="user-email"><%= userToDelete.getEmail() %></p>
                    <span class="user-role <%= userToDelete.isAdmin() ? "role-admin" : "role-customer" %>">
                        <%= userToDelete.isAdmin() ? "Admin" : "Customer" %>
                    </span>
                </div>

                <div class="confirm-delete-actions">
                    <a href="<%= request.getContextPath() %>/admin/AdminUserServlet" class="btn btn-secondary">
                        Cancel
                    </a>

                    <form action="<%= request.getContextPath() %>/admin/AdminUserServlet" method="post">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= userToDelete.getId() %>">
                        <button type="submit" class="btn btn-danger">
                            Delete User
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
