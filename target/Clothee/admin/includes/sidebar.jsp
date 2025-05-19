<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.MessageDAO" %>
<%
    // Get current page name
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);

    // Get user from session
    User currentUser = (User) session.getAttribute("user");
    String userRole = currentUser != null ? currentUser.getRole() : "";
    boolean isAdmin = currentUser != null && currentUser.isAdmin();

    if (!isAdmin) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }

    // Get unread message count
    MessageDAO messageDAO = new MessageDAO();
    int unreadMessages = messageDAO.getUnreadMessageCount();
%>

<div class="admin-sidebar" id="sidebar">
    <div class="admin-logo">
        CLOTHEE <span>Admin</span>
    </div>

    <div class="admin-user">
        <div class="admin-user-avatar">
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
        <div class="admin-user-name"><%= currentUser.getFullName() %></div>
        <div class="admin-user-role">Admin</div>
    </div>

    <div class="admin-menu">
        <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="admin-menu-item <%= pageName.equals("dashboard.jsp") ? "active" : "" %>">
            <i class="fas fa-tachometer-alt admin-menu-icon"></i>
            <span>Dashboard</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/products.jsp" class="admin-menu-item <%= pageName.equals("products.jsp") || pageName.equals("add-product.jsp") || pageName.equals("edit-product.jsp") || pageName.equals("view-product.jsp") || pageName.equals("delete-product.jsp") ? "active" : "" %>">
            <i class="fas fa-box admin-menu-icon"></i>
            <span>Products</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="admin-menu-item <%= pageName.equals("categories.jsp") || pageName.equals("add-category.jsp") || pageName.equals("edit-category.jsp") || pageName.equals("view-category.jsp") || pageName.equals("delete-category.jsp") ? "active" : "" %>">
            <i class="fas fa-tag admin-menu-icon"></i>
            <span>Categories</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="admin-menu-item <%= pageName.equals("orders.jsp") || pageName.equals("view-order.jsp") || pageName.equals("edit-order.jsp") || pageName.equals("delete-order.jsp") ? "active" : "" %>">
            <i class="fas fa-shopping-bag admin-menu-icon"></i>
            <span>Orders</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="admin-menu-item <%= pageName.equals("customers.jsp") || pageName.equals("add-customer.jsp") || pageName.equals("edit-customer.jsp") || pageName.equals("view-customer.jsp") || pageName.equals("delete-customer.jsp") ? "active" : "" %>">
            <i class="fas fa-user admin-menu-icon"></i>
            <span>Customers</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/reviews.jsp" class="admin-menu-item <%= pageName.equals("reviews.jsp") || pageName.equals("view-review.jsp") || pageName.equals("edit-review.jsp") || pageName.equals("delete-review.jsp") ? "active" : "" %>">
            <i class="fas fa-star admin-menu-icon"></i>
            <span>Reviews</span>
        </a>
        <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="admin-menu-item <%= pageName.equals("messages.jsp") || pageName.equals("view-message.jsp") || pageName.equals("reply-message.jsp") ? "active" : "" %>">
            <i class="fas fa-envelope admin-menu-icon"></i>
            <span>Messages</span>
            <% if (unreadMessages > 0) { %>
                <span class="admin-badge"><%= unreadMessages %></span>
            <% } %>
        </a>
        <a href="<%= request.getContextPath() %>/admin/settings.jsp" class="admin-menu-item <%= pageName.equals("settings.jsp") || pageName.equals("profile-settings.jsp") || pageName.equals("security-settings.jsp") ? "active" : "" %>">
            <i class="fas fa-cog admin-menu-icon"></i>
            <span>Settings</span>
        </a>
        <a href="<%= request.getContextPath() %>/LogoutServlet" class="admin-menu-item">
            <i class="fas fa-sign-out-alt admin-menu-icon"></i>
            <span>Logout</span>
        </a>
    </div>
</div>
