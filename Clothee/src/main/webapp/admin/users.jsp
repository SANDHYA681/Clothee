<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get users from request
    List<User> users = (List<User>) request.getAttribute("users");

    // If users is null, redirect to AdminUserServlet
    if (users == null) {
        response.sendRedirect(request.getContextPath() + "/admin/AdminUserServlet");
        return;
    }

    // Get success and error messages
    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");

    // Date formatter
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-unified.css">
    <style>
        /* Additional styles for the users page */
        .users-container {
            margin: 20px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .page-title {
            font-size: 24px;
            font-weight: 600;
        }

        .add-user-btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }

        .users-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .users-table th, .users-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        .users-table th {
            background-color: #f8f9fa;
            font-weight: 600;
        }

        .users-table tr:hover {
            background-color: #f1f1f1;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }

        .action-btn {
            padding: 6px 10px;
            margin-right: 5px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
        }

        .edit-btn {
            background-color: #2196F3;
            color: white;
        }

        .delete-btn {
            background-color: #F44336;
            color: white;
        }

        .view-btn {
            background-color: #607D8B;
            color: white;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .badge-admin {
            background-color: #cce5ff;
            color: #004085;
        }

        .badge-user {
            background-color: #d4edda;
            color: #155724;
        }

        /* Empty state styles */
        .empty-state {
            padding: 40px 20px;
            text-align: center;
        }

        .empty-state i {
            color: #ddd;
            margin-bottom: 15px;
        }

        .empty-state p {
            font-size: 18px;
            color: #777;
            margin-bottom: 20px;
        }

        .text-center {
            text-align: center;
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

            <div class="users-container">
                <div class="page-header">
                    <h1 class="page-title">Manage Users</h1>
                    <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=showAddForm" class="add-user-btn">
                        <i class="fas fa-plus"></i> Add New User
                    </a>
                </div>

                <!-- Display success message if any -->
                <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success" id="successAlert">
                    <%= successMessage %>
                </div>
                <% } %>

                <!-- Display error message if any -->
                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger" id="errorAlert">
                    <%= errorMessage %>
                </div>
                <% } %>

                <!-- Users table -->
                <% if (users.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-users fa-3x"></i>
                    <p>No users found</p>
                    <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=showAddForm" class="add-user-btn">
                        <i class="fas fa-plus"></i> Add New User
                    </a>
                </div>
                <% } else { %>
                <table class="users-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (User u : users) { %>
                        <tr>
                            <td><%= u.getId() %></td>
                            <td><%= u.getFullName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                            <td>
                                <% if (u.isAdmin()) { %>
                                <span class="badge badge-admin">Admin</span>
                                <% } else { %>
                                <span class="badge badge-user">Customer</span>
                                <% } %>
                            </td>
                            <td><%= u.getCreatedAt() != null ? dateFormat.format(u.getCreatedAt()) : "-" %></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=view&id=<%= u.getId() %>" class="action-btn view-btn">
                                    <i class="fas fa-eye"></i> View
                                </a>
                                <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=showEditForm&id=<%= u.getId() %>" class="action-btn edit-btn">
                                    <i class="fas fa-edit"></i> Edit
                                </a>
                                <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=confirmDelete&id=<%= u.getId() %>" class="action-btn delete-btn">
                                    <i class="fas fa-trash"></i> Delete
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
