<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.MessageDAO" %>

<%
// Get the current user from session
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Check if user is admin
if (!currentUser.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get the current page to highlight the active menu item
String currentPage = request.getRequestURI();
String contextPath = request.getContextPath();

// Get unread message count
MessageDAO messageDAO = new MessageDAO();
int unreadMessages = messageDAO.getUnreadMessageCount();
%>

<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <a href="<%= contextPath %>/index.jsp" class="logo">
            <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
            <span class="logo-text">CLOTHEE</span>
        </a>
        <div class="user-info">
            <div class="user-avatar">
                <%
                    // Debug information
                    System.out.println("sidebar-new.jsp - User ID: " + currentUser.getId());
                    System.out.println("sidebar-new.jsp - User Name: " + currentUser.getFirstName() + " " + currentUser.getLastName());
                    System.out.println("sidebar-new.jsp - Profile Image: " + currentUser.getProfileImage());

                    if (currentUser.getProfileImage() != null && !currentUser.getProfileImage().isEmpty()) {
                        String imagePath = contextPath + "/" + currentUser.getProfileImage();
                        System.out.println("sidebar-new.jsp - Full Image Path: " + imagePath);
                %>
                    <img src="<%= contextPath %>/<%= currentUser.getProfileImage() %>" alt="<%= currentUser.getFirstName() %>" onerror="this.src='<%= contextPath %>/images/admin/profile-placeholder.png'">
                <% } else { %>
                    <img src="<%= contextPath %>/images/admin/profile-placeholder.png" alt="Admin" onerror="this.src='<%= contextPath %>/images/admin/profile-placeholder.png'">
                <% } %>
            </div>
            <div class="user-details">
                <h4><%= currentUser.getFirstName() %></h4>
                <p class="user-role">Administrator</p>
            </div>
        </div>
    </div>
    <div class="sidebar-menu">
        <a href="<%= contextPath %>/admin/dashboard.jsp" class="menu-item <%= currentPage.contains("/admin/dashboard.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
            Dashboard
        </a>
        <a href="<%= contextPath %>/admin/products.jsp" class="menu-item <%= currentPage.contains("/admin/products.jsp") || currentPage.contains("/admin/add-product.jsp") || currentPage.contains("/admin/edit-product.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-box"></i></span>
            Products
        </a>
        <a href="<%= contextPath %>/admin/categories.jsp" class="menu-item <%= currentPage.contains("/admin/categories.jsp") || currentPage.contains("/admin/add-category.jsp") || currentPage.contains("/admin/edit-category.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-tag"></i></span>
            Categories
        </a>
        <a href="<%= contextPath %>/admin/orders.jsp" class="menu-item <%= currentPage.contains("/admin/orders.jsp") || currentPage.contains("/admin/view-order.jsp") || currentPage.contains("/admin/edit-order.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
            Orders
        </a>
        <a href="<%= contextPath %>/AdminUserServlet" class="menu-item <%= currentPage.contains("/AdminUserServlet") || currentPage.contains("/admin/customers.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-users"></i></span>
            Customers
        </a>
        <a href="<%= contextPath %>/admin/AdminReviewServlet" class="menu-item <%= currentPage.contains("/AdminReviewServlet") || currentPage.contains("/admin/reviews.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-star"></i></span>
            Reviews
        </a>
        <a href="<%= contextPath %>/admin/messages.jsp" class="menu-item <%= currentPage.contains("/admin/messages.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-envelope"></i></span>
            Messages
            <% if (unreadMessages > 0) { %>
                <span class="badge"><%= unreadMessages %></span>
            <% } %>
        </a>
        <a href="<%= contextPath %>/admin/settings.jsp" class="menu-item <%= currentPage.contains("/admin/settings.jsp") ? "active" : "" %>">
            <span class="menu-icon"><i class="fas fa-cog"></i></span>
            Settings
        </a>
        <a href="<%= contextPath %>/LogoutServlet" class="menu-item">
            <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span>
            Logout
        </a>
    </div>
</div>

<!-- Mobile Menu Toggle Button -->
<button class="mobile-menu-toggle" id="mobile-menu-toggle">
    <i class="fas fa-bars"></i>
</button>
