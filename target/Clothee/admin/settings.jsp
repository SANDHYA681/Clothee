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

User user = (User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get unread message count
MessageDAO messageDAO = new MessageDAO();
int unreadMessages = messageDAO.getUnreadMessageCount();

// Check for messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");

// Clear messages after reading them
session.removeAttribute("successMessage");
session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-new.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-fix.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar-fix.css">
    <style>
        .settings-cards {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 30px;
            margin-bottom: 30px;
            max-width: 900px;
            margin-left: auto;
            margin-right: auto;
        }

        .settings-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
            transition: all 0.3s ease;
            min-height: 220px;
            display: flex;
            flex-direction: column;
        }

        .settings-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .settings-card-header {
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }

        .settings-card-title {
            font-size: 20px;
            font-weight: 600;
            color: #1e3a8a;
            margin: 0;
        }

        .settings-card-body {
            color: #666;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        .settings-card-body p {
            margin-bottom: 20px;
            font-size: 15px;
            line-height: 1.5;
            flex-grow: 1;
        }

        .settings-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 20px;
            background-color: #1e3a8a;
            color: white;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            margin-top: auto;
            width: 100%;
        }

        .settings-btn:hover {
            background-color: #152a66;
        }

        .settings-btn i {
            margin-right: 10px;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the new sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

        <div class="content">
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success">
                <%= successMessage %>
            </div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
            <% } %>

            <div class="content-header">
                <h1>Settings</h1>
                <div class="header-actions">
                    <a href="messages.jsp" class="header-action" title="Messages <% if (unreadMessages > 0) { %>(<%=unreadMessages%> unread)<% } %>">
                        <i class="fas fa-envelope"></i>
                        <% if (unreadMessages > 0) { %><span class="header-badge"><%= unreadMessages %></span><% } %>
                    </a>
                </div>
            </div>

            <div class="settings-cards">
                <!-- Profile Settings Card -->
                <div class="settings-card">
                    <div class="settings-card-header">
                        <h2 class="settings-card-title">Profile Settings</h2>
                    </div>
                    <div class="settings-card-body">
                        <p>Update your personal information, contact details, and profile image.</p>
                        <a href="<%= request.getContextPath() %>/admin/profile-settings.jsp" class="settings-btn">
                            <i class="fas fa-user"></i> Manage Profile
                        </a>
                    </div>
                </div>

                <!-- Security Settings Card -->
                <div class="settings-card">
                    <div class="settings-card-header">
                        <h2 class="settings-card-title">Security Settings</h2>
                    </div>
                    <div class="settings-card-body">
                        <p>Change your password and manage account security settings.</p>
                        <a href="<%= request.getContextPath() %>/admin/security-settings.jsp" class="settings-btn">
                            <i class="fas fa-lock"></i> Manage Security
                        </a>
                    </div>
                </div>


            </div>
        </div>
    </div>

    <!-- No JavaScript -->

    <!-- Include common footer scripts -->
    <jsp:include page="includes/footer-scripts.jsp" />
</body>
</html>
