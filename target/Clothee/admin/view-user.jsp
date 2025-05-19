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
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .view-user-container {
            width: 100%;
            max-width: 450px;
            margin: 15px auto;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
            padding: 15px;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 12px;
            position: relative;
        }

        .page-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin: 0;
            padding-bottom: 6px;
            position: relative;
            display: inline-block;
        }

        .page-title:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 40px;
            height: 2px;
            background-color: #4361ee;
            border-radius: 2px;
        }

        .user-header {
            display: flex;
            flex-direction: row;
            align-items: center;
            text-align: left;
            margin-bottom: 12px;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background-color: #f0f5ff;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            font-size: 20px;
            color: #4361ee;
            overflow: hidden;
            border: 2px solid #e0e7ff;
            box-shadow: 0 2px 4px rgba(67, 97, 238, 0.2);
            flex-shrink: 0;
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .user-info {
            flex: 1;
        }

        .user-info h2 {
            font-size: 16px;
            font-weight: 600;
            margin: 0 0 3px 0;
            color: #333;
            text-transform: capitalize;
        }

        .user-info p {
            font-size: 12px;
            color: #666;
            margin: 0 0 4px 0;
        }

        .user-role {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 10px;
            font-weight: 600;
            margin-top: 0;
            text-transform: capitalize;
            letter-spacing: 0.5px;
        }

        .role-admin {
            background-color: #4361ee;
            color: white;
        }

        .role-customer {
            background-color: #2ecc71;
            color: white;
        }

        .detail-section {
            margin-bottom: 12px;
            background-color: #f9f9fa;
            padding: 10px;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }

        .detail-section h3 {
            font-size: 14px;
            font-weight: 600;
            margin: 0 0 8px 0;
            color: #333;
            border-bottom: 1px solid #4361ee;
            padding-bottom: 5px;
            position: relative;
        }

        .detail-row {
            display: flex;
            margin-bottom: 5px;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
        }

        .detail-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        .detail-label {
            width: 90px;
            font-weight: 600;
            color: #555;
            font-size: 12px;
        }

        .detail-value {
            flex: 1;
            color: #333;
            font-size: 12px;
        }

        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 6px;
            margin-top: 12px;
            padding-top: 10px;
        }

        .btn {
            padding: 6px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
            text-align: center;
            min-width: 70px;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.1);
        }

        .btn-primary {
            background-color: #4361ee;
            color: white;
            border: none;
        }

        .btn-danger {
            background-color: #e74c3c;
            color: white;
            border: none;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
            border: none;
        }

        /* Responsive styles */
        @media (max-width: 768px) {
            .view-user-container {
                padding: 10px;
                margin: 5px;
                width: calc(100% - 10px);
            }

            .user-header {
                flex-direction: column;
                text-align: center;
            }

            .user-avatar {
                margin-right: 0;
                margin-bottom: 8px;
            }

            .detail-row {
                flex-direction: column;
            }

            .detail-label {
                width: 100%;
                margin-bottom: 2px;
            }

            .action-buttons {
                flex-wrap: wrap;
                gap: 5px;
            }

            .btn {
                flex: 1;
                min-width: 0;
                padding: 5px 8px;
                font-size: 11px;
            }
        }
    </style>
</head>
<body>

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
                            <%= userToView.getRole() != null ? userToView.getRole() : (userToView.isAdmin() ? "Admin" : "Customer") %>
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
                            <div class="detail-value"><%= userToView.getRole() != null ? userToView.getRole() : (userToView.isAdmin() ? "Admin" : "Customer") %></div>
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

                <script>
                    // Add a back button functionality
                    document.addEventListener('DOMContentLoaded', function() {
                        // Add back button to top of page
                        const pageHeader = document.querySelector('.page-header');
                        const backButton = document.createElement('a');
                        backButton.href = '<%= request.getContextPath() %>/admin/AdminUserServlet';
                        backButton.className = 'back-button';
                        backButton.innerHTML = '<i class="fas fa-arrow-left"></i>';
                        backButton.style.position = 'absolute';
                        backButton.style.left = '0';
                        backButton.style.top = '5px';
                        backButton.style.fontSize = '20px';
                        backButton.style.color = '#4361ee';
                        pageHeader.style.position = 'relative';
                        pageHeader.appendChild(backButton);
                    });
                </script>
            </div>
</body>
</html>
