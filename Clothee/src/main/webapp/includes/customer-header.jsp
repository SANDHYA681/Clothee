<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);

    // Get user information if logged in
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");

    // Get cart count if available
    Integer cartCount = (Integer) session.getAttribute("cartCount");
    if (cartCount == null) cartCount = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CLOTHEE - <%= pageName.replace(".jsp", "").toUpperCase() %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer-layout.css">
</head>
<body>
    <header class="header">
        <div class="container header-container">
            <!-- Logo -->
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                <span>CLOTHEE</span>
            </a>

            <!-- Navigation -->
            <nav class="navbar">
                <!-- Mobile Toggle Button -->
                <div class="mobile-toggle" id="mobileToggle">
                    <i class="fas fa-bars"></i>
                </div>

                <!-- Navigation Menu -->
                <ul class="nav-menu" id="navMenu">
                    <li class="nav-item">
                        <a href="<%=request.getContextPath()%>/index.jsp" class="nav-link <%= pageName.equals("index.jsp") ? "active" : "" %>">Home</a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=request.getContextPath()%>/ProductServlet" class="nav-link <%= pageName.contains("products") ? "active" : "" %>">Shop</a>
                    </li>
                    <% if (userRole != null && userId != null) { %>
                    <li class="nav-item">
                        <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders" class="nav-link <%= pageName.contains("orders") ? "active" : "" %>">Orders</a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="nav-link <%= pageName.equals("profile.jsp") ? "active" : "" %>">Profile</a>
                    </li>
                    <% } %>
                    <li class="nav-item">
                        <a href="<%=request.getContextPath()%>/about.jsp" class="nav-link <%= pageName.equals("about.jsp") ? "active" : "" %>">About</a>
                    </li>
                    <li class="nav-item">
                        <a href="<%=request.getContextPath()%>/contact.jsp" class="nav-link <%= pageName.equals("contact.jsp") ? "active" : "" %>">Contact</a>
                    </li>
                </ul>

                <!-- Navigation Actions -->
                <div class="nav-actions">
                    <% if (userRole != null && userId != null) { %>
                        <!-- Cart Icon -->
                        <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="nav-action" title="Shopping Cart">
                            <i class="fas fa-shopping-cart"></i>
                            <% if (cartCount > 0) { %>
                            <span class="cart-count"><%= cartCount %></span>
                            <% } %>
                        </a>

                        <!-- Dashboard Icon -->
                        <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="nav-action" title="Dashboard">
                            <i class="fas fa-tachometer-alt"></i>
                        </a>

                        <!-- Logout Button -->
                        <a href="<%=request.getContextPath()%>/LogoutServlet" class="logout-btn">
                            Logout
                        </a>
                    <% } else { %>
                        <!-- Login/Register Links -->
                        <a href="<%=request.getContextPath()%>/login.jsp" class="nav-action" title="Login">
                            <i class="fas fa-sign-in-alt"></i>
                        </a>
                        <a href="<%=request.getContextPath()%>/register.jsp" class="logout-btn">
                            Register
                        </a>
                    <% } %>
                </div>
            </nav>
        </div>
    </header>

    <main class="main-content">
        <div class="container">
            <%
            // Display success message if available
            String message = request.getParameter("message");
            if (message != null && !message.isEmpty()) {
            %>
            <div class="alert alert-success">
                <%= message %>
            </div>
            <% } %>

            <%
            // Display error message if available
            String error = request.getParameter("error");
            if (error != null && !error.isEmpty()) {
            %>
            <div class="alert alert-error">
                <%= error %>
            </div>
            <% } %>
