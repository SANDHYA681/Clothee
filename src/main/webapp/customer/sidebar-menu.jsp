<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<div class="sidebar-menu">
    <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="menu-item <%= request.getRequestURI().contains("dashboard.jsp") ? "active" : "" %>">
        <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard
    </a>
    <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="menu-item <%= request.getRequestURI().contains("profile.jsp") ? "active" : "" %>">
        <span class="menu-icon"><i class="fas fa-user"></i></span> My Profile
    </a>
    <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders" class="menu-item <%= request.getRequestURI().contains("orders.jsp") ? "active" : "" %>">
        <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span> My Orders
    </a>
    <!-- Wishlist link removed -->
    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="menu-item <%= request.getRequestURI().contains("cart.jsp") ? "active" : "" %>">
        <span class="menu-icon"><i class="fas fa-shopping-cart"></i></span> My Cart
    </a>
    <a href="<%=request.getContextPath()%>/ProductServlet" class="menu-item <%= request.getRequestURI().contains("products") ? "active" : "" %>">
        <span class="menu-icon"><i class="fas fa-tshirt"></i></span> Shop Products
    </a>
    <!-- Payment Methods link removed -->
    <a href="<%=request.getContextPath()%>/customer/reviews.jsp" class="menu-item <%= request.getRequestURI().contains("reviews.jsp") ? "active" : "" %>">
        <span class="menu-icon"><i class="fas fa-star"></i></span> My Reviews
    </a>
    <a href="<%=request.getContextPath()%>/messages" class="menu-item <%= request.getRequestURI().contains("messages-view.jsp") || request.getRequestURI().contains("view-message.jsp") || request.getServletPath().contains("/messages") ? "active" : "" %>">
        <span class="menu-icon"><i class="fas fa-envelope"></i></span> My Messages
    </a>
    <!-- My Addresses link removed -->
    <!-- Dashboard Settings link removed -->
    <a href="<%=request.getContextPath()%>/LoginServlet?action=logout" class="menu-item">
        <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span> Logout
    </a>
</div>
