<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get user to edit from request
    User userToEdit = (User) request.getAttribute("user");

    if (userToEdit == null) {
        response.sendRedirect(request.getContextPath() + "/admin/AdminUserServlet?error=User not found");
        return;
    }

    // Get error message if any
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-style.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <style>
        .edit-user-container {
            max-width: 800px;
            margin: 20px auto;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }

        .page-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
        }

        .form-row {
            display: flex;
            flex-wrap: wrap;
            margin: 0 -15px;
        }

        .form-group {
            padding: 0 15px;
            margin-bottom: 20px;
            flex: 1 0 50%;
        }

        .form-group.full-width {
            flex: 1 0 100%;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #333;
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-control:focus {
            border-color: #4CAF50;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.2);
            outline: none;
        }

        .form-hint {
            display: block;
            margin-top: 5px;
            font-size: 14px;
            color: #666;
        }

        .form-check {
            display: flex;
            align-items: center;
            margin-top: 10px;
        }

        .form-check-input {
            margin-right: 10px;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        .btn {
            padding: 12px 25px;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background-color: #4CAF50;
            color: white;
            border: none;
        }

        .btn-secondary {
            background-color: #f5f5f5;
            color: #333;
            border: 1px solid #ddd;
        }

        .btn-primary:hover {
            background-color: #43A047;
        }

        .btn-secondary:hover {
            background-color: #e9e9e9;
        }

        .alert {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .required::after {
            content: " *";
            color: #e74c3c;
        }

        @media (max-width: 768px) {
            .form-group {
                flex: 1 0 100%;
            }
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

            <div class="edit-user-container">
                <div class="page-header">
                    <h1 class="page-title">Edit User</h1>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-danger">
                    <%= error %>
                </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/admin/AdminUserServlet" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= userToEdit.getId() %>">

                    <div class="form-row">
                        <div class="form-group">
                            <label for="fullName" class="form-label required">Full Name</label>
                            <input type="text" id="fullName" name="fullName" class="form-control" value="<%= userToEdit.getFullName() %>" required>
                        </div>

                        <div class="form-group">
                            <label for="email" class="form-label required">Email Address</label>
                            <input type="email" id="email" name="email" class="form-control" value="<%= userToEdit.getEmail() %>" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="password" class="form-label">New Password</label>
                            <input type="password" id="password" name="password" class="form-control">
                            <span class="form-hint">Leave blank to keep current password.</span>
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">Confirm New Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone" class="form-label">Phone Number</label>
                            <input type="tel" id="phone" name="phone" class="form-control" value="<%= userToEdit.getPhone() != null ? userToEdit.getPhone() : "" %>">
                        </div>

                        <div class="form-group">
                            <label for="address" class="form-label">Address</label>
                            <input type="text" id="address" name="address" class="form-control" value="<%= userToEdit.getAddress() != null ? userToEdit.getAddress() : "" %>">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <div class="form-check">
                                <input type="checkbox" id="isAdmin" name="isAdmin" class="form-check-input" <%= userToEdit.isAdmin() ? "checked" : "" %>>
                                <label for="isAdmin" class="form-check-label">Admin User</label>
                            </div>
                            <span class="form-hint">Check this box if the user should have admin privileges.</span>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/admin/AdminUserServlet" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Update User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
