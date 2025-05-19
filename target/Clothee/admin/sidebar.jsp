<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.MessageDAO" %>
<%
    // Get current page name
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);

    // Get user from session
    User currentUser = null;

    // Get the user from the session
    Object userObj = session.getAttribute("user");
    if (userObj != null && userObj instanceof User) {
        currentUser = (User) userObj;
    }
    String userRole = currentUser != null ? currentUser.getRole() : "";
    boolean isAdmin = currentUser != null && currentUser.isAdmin();

    if (!isAdmin) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    // Get unread message count
    int unreadMessages = 0;
    try {
        MessageDAO messageDAO = new MessageDAO();
        unreadMessages = messageDAO.getUnreadMessageCount();
    } catch (Exception e) {
        System.out.println("Error getting unread message count: " + e.getMessage());
    }
%>

<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <a href="../index.jsp" class="logo">
            <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
            <span class="logo-text">CLOTHEE</span>
        </a>
        <div class="user-info">
            <div class="user-avatar">
                <% if (currentUser.getProfileImage() != null && !currentUser.getProfileImage().isEmpty()) { %>
                    <% if (currentUser.getProfileImage().startsWith("images/")) { %>
                        <img src="<%=request.getContextPath()%>/<%= currentUser.getProfileImage() %>" alt="<%= currentUser.getFullName() %>">
                    <% } else { %>
                        <img src="<%=request.getContextPath()%>/images/avatars/<%= currentUser.getProfileImage() %>" alt="<%= currentUser.getFullName() %>">
                    <% } %>
                <% } else { %>
                    <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="Default Profile Image">
                <% } %>
            </div>
            <h3 class="user-name"><%= currentUser.getFullName() %></h3>
            <p class="user-role"><%= currentUser.getRole() %></p>
        </div>
    </div>

    <div class="sidebar-menu">
        <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="menu-item <%= pageName.equals("dashboard.jsp") ? "active" : "" %>">
            <i class="fas fa-tachometer-alt menu-icon"></i>
            Dashboard
        </a>
        <a href="<%= request.getContextPath() %>/admin/products.jsp" class="menu-item <%= pageName.equals("products.jsp") ? "active" : "" %>">
            <i class="fas fa-box menu-icon"></i>
            Products
        </a>
        <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="menu-item <%= pageName.equals("categories.jsp") ? "active" : "" %>">
            <i class="fas fa-tags menu-icon"></i>
            Categories
        </a>
        <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="menu-item <%= pageName.equals("orders.jsp") ? "active" : "" %>">
            <i class="fas fa-shopping-bag menu-icon"></i>
            Orders
        </a>
        <a href="<%= request.getContextPath() %>/AdminUserServlet" class="menu-item <%= pageName.equals("customers.jsp") ? "active" : "" %>">
            <i class="fas fa-users menu-icon"></i>
            Customers
        </a>
        <a href="<%= request.getContextPath() %>/admin/reviews.jsp" class="menu-item <%= pageName.equals("reviews.jsp") ? "active" : "" %>">
            <i class="fas fa-star menu-icon"></i>
            Reviews
        </a>
        <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="menu-item <%= pageName.equals("messages.jsp") ? "active" : "" %>">
            <i class="fas fa-envelope menu-icon"></i>
            Messages
            <% if (unreadMessages > 0) { %>
                <span class="badge"><%= unreadMessages %></span>
            <% } %>
        </a>
        <a href="<%= request.getContextPath() %>/admin/settings.jsp" class="menu-item <%= pageName.equals("settings.jsp") ? "active" : "" %>">
            <i class="fas fa-cog menu-icon"></i>
            Settings
        </a>
        <a href="<%= request.getContextPath() %>/LogoutServlet" class="menu-item">
            <i class="fas fa-sign-out-alt menu-icon"></i>
            Logout
        </a>
    </div>
</div>
