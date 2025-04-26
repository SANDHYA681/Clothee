<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get user to view from request
    User userToView = (User) request.getAttribute("userToView");

    if (userToView == null) {
        response.sendRedirect(request.getContextPath() + "/admin/AdminUserServlet?error=User not found");
        return;
    }

    // Date formatter
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View User - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-style.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <style>
        .view-user-container {
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

        .user-header {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
        }

        .user-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background-color: #f5f5f5;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 20px;
            font-size: 40px;
            color: #aaa;
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }

        .user-info h2 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 5px;
            color: #333;
        }

        .user-info p {
            font-size: 16px;
            color: #666;
            margin-bottom: 5px;
        }

        .user-role {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
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

        .user-details {
            margin-top: 30px;
        }

        .detail-section {
            margin-bottom: 30px;
        }

        .detail-section h3 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .detail-row {
            display: flex;
            margin-bottom: 15px;
        }

        .detail-label {
            width: 150px;
            font-weight: 500;
            color: #666;
        }

        .detail-value {
            flex: 1;
            color: #333;
        }

        .action-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background-color: #2196F3;
            color: white;
            border: none;
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

            <div class="view-user-container">
                <div class="page-header">
                    <h1 class="page-title">User Details</h1>
                </div>

                <div class="user-header">
                    <div class="user-avatar">
                        <% if (userToView.getProfileImage() != null && !userToView.getProfileImage().isEmpty()) { %>
                        <img src="<%= request.getContextPath() %>/<%= userToView.getProfileImage() %>" alt="<%= userToView.getFullName() %>">
                        <% } else { %>
                        <i class="fas fa-user"></i>
                        <% } %>
                    </div>

                    <div class="user-info">
                        <h2><%= userToView.getFullName() %></h2>
                        <p><%= userToView.getEmail() %></p>
                        <span class="user-role <%= userToView.isAdmin() ? "role-admin" : "role-customer" %>">
                            <%= userToView.isAdmin() ? "Admin" : "Customer" %>
                        </span>
                    </div>
                </div>

                <div class="user-details">
                    <div class="detail-section">
                        <h3>Personal Information</h3>

                        <div class="detail-row">
                            <div class="detail-label">Full Name</div>
                            <div class="detail-value"><%= userToView.getFullName() %></div>
                        </div>

                        <div class="detail-row">
                            <div class="detail-label">Email</div>
                            <div class="detail-value"><%= userToView.getEmail() %></div>
                        </div>

                        <div class="detail-row">
                            <div class="detail-label">Phone</div>
                            <div class="detail-value"><%= userToView.getPhone() != null && !userToView.getPhone().isEmpty() ? userToView.getPhone() : "Not provided" %></div>
                        </div>

                        <div class="detail-row">
                            <div class="detail-label">Address</div>
                            <div class="detail-value"><%= userToView.getAddress() != null && !userToView.getAddress().isEmpty() ? userToView.getAddress() : "Not provided" %></div>
                        </div>
                    </div>

                    <div class="detail-section">
                        <h3>Account Information</h3>

                        <div class="detail-row">
                            <div class="detail-label">User ID</div>
                            <div class="detail-value"><%= userToView.getId() %></div>
                        </div>

                        <div class="detail-row">
                            <div class="detail-label">Role</div>
                            <div class="detail-value"><%= userToView.isAdmin() ? "Admin" : "Customer" %></div>
                        </div>

                        <div class="detail-row">
                            <div class="detail-label">Created</div>
                            <div class="detail-value"><%= userToView.getCreatedAt() != null ? dateFormat.format(userToView.getCreatedAt()) : "Unknown" %></div>
                        </div>

                        <div class="detail-row">
                            <div class="detail-label">Last Updated</div>
                            <div class="detail-value"><%= userToView.getUpdatedAt() != null ? dateFormat.format(userToView.getUpdatedAt()) : "Never" %></div>
                        </div>
                    </div>
                </div>

                <div class="action-buttons">
                    <a href="<%= request.getContextPath() %>/admin/AdminUserServlet" class="btn btn-secondary">
                        Back to Users
                    </a>

                    <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=showEditForm&id=<%= userToView.getId() %>" class="btn btn-primary">
                        Edit User
                    </a>

                    <% if (userToView.getId() != user.getId()) { %>
                    <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=confirmDelete&id=<%= userToView.getId() %>" class="btn btn-danger">
                        Delete User
                    </a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
