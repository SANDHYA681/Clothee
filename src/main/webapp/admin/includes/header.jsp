<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.MessageDAO" %>
<%
    // Get user from session
    User headerUser = (User) session.getAttribute("user");
    if (headerUser == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    if (!headerUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    String userName = headerUser.getFullName();
    String userRole = headerUser.getRole();
    // Don't use a default profile image - only show an image if the user has uploaded one
    String userImage = headerUser.getProfileImage();

    // Get unread message count
    MessageDAO messageDAO = new MessageDAO();
    int unreadMessages = messageDAO.getUnreadMessageCount();

    // Get current page name for title
    String uri = request.getRequestURI();
    String pageName = uri.substring(uri.lastIndexOf("/") + 1);
    pageName = pageName.replace(".jsp", "");
    pageName = pageName.replace("-", " ");

    // Capitalize first letter of each word
    String[] words = pageName.split(" ");
    StringBuilder titleCase = new StringBuilder();
    for (String word : words) {
        if (word.length() > 0) {
            titleCase.append(Character.toUpperCase(word.charAt(0)))
                    .append(word.substring(1))
                    .append(" ");
        }
    }

    String pageTitle = titleCase.toString().trim();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - CLOTHEE Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-blue.css">
    <!-- Unified Blue Theme CSS - Applied to all admin pages -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <!-- Profile image CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/profile-image.css">
</head>
<body>
    <div class="admin-container">
        <!-- Include sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="admin-main" id="main">
            <!-- Header -->
            <div class="admin-header">
                <button id="sidebarToggle" class="admin-btn admin-btn-sm">
                    <i class="fas fa-bars"></i>
                </button>
                <h1 class="admin-title"><%= pageTitle %></h1>
                <div class="admin-header-actions">
                    <a href="<%= request.getContextPath() %>/index.jsp" class="admin-btn admin-btn-sm admin-btn-outline-primary" target="_blank">
                        <i class="fas fa-store"></i> View Store
                    </a>
                    <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="admin-btn admin-btn-sm admin-btn-outline-primary">
                        <i class="fas fa-envelope"></i> Messages
                        <% if (unreadMessages > 0) { %>
                            <span class="admin-badge"><%= unreadMessages %></span>
                        <% } %>
                    </a>
                    <a href="<%= request.getContextPath() %>/admin/profile.jsp" class="admin-btn admin-btn-sm admin-btn-outline-primary">
                        <i class="fas fa-user"></i> Profile
                    </a>
                </div>
            </div>

            <!-- Success/Error Messages -->
            <%
            String successMessage = request.getParameter("success");
            if (successMessage == null) {
                successMessage = (String) session.getAttribute("successMessage");
                session.removeAttribute("successMessage");
            }

            String errorMessage = request.getParameter("error");
            if (errorMessage == null) {
                errorMessage = (String) session.getAttribute("errorMessage");
                session.removeAttribute("errorMessage");
            }
            %>

            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="admin-alert admin-alert-success">
                <i class="fas fa-check-circle"></i> <%= successMessage %>
            </div>
            <% } %>

            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="admin-alert admin-alert-danger">
                <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
            </div>
            <% } %>
