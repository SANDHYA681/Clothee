<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);
    
    // Get user information if logged in
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    
    // Redirect if not admin
    if (userRole == null || !userRole.equals("admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=You must be logged in as admin to access this page");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - <%= pageName.replace(".jsp", "").toUpperCase() %></title>
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <!-- Admin Layout CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-styles.css">
</head>
<body>
    <!-- HEADER -->
    <header class="admin-header">
        <div class="container admin-header-container">
            <!-- Logo -->
            <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="admin-logo">
                <span class="admin-logo-icon"><i class="fas fa-tshirt"></i></span>
                <span>CLOTHEE Admin</span>
            </a>
            
            <!-- Navigation -->
            <nav class="admin-navbar">
                <!-- Mobile Toggle Button -->
                <div class="admin-mobile-toggle" id="adminMobileToggle">
                    <i class="fas fa-bars"></i>
                </div>
                
                <!-- Navigation Menu -->
                <ul class="admin-nav-menu" id="adminNavMenu">
                    <li class="admin-nav-item">
                        <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="admin-nav-link <%= pageName.equals("dashboard.jsp") ? "active" : "" %>">Dashboard</a>
                    </li>
                    <li class="admin-nav-item">
                        <a href="<%=request.getContextPath()%>/admin/products.jsp" class="admin-nav-link <%= pageName.equals("products.jsp") ? "active" : "" %>">Products</a>
                    </li>
                    <li class="admin-nav-item">
                        <a href="<%=request.getContextPath()%>/admin/orders.jsp" class="admin-nav-link <%= pageName.equals("orders.jsp") ? "active" : "" %>">Orders</a>
                    </li>
                    <li class="admin-nav-item">
                        <a href="<%=request.getContextPath()%>/admin/customers.jsp" class="admin-nav-link <%= pageName.equals("customers.jsp") ? "active" : "" %>">Customers</a>
                    </li>
                    <li class="admin-nav-item">
                        <a href="<%=request.getContextPath()%>/admin/categories.jsp" class="admin-nav-link <%= pageName.equals("categories.jsp") ? "active" : "" %>">Categories</a>
                    </li>
                    <li class="admin-nav-item">
                        <a href="<%=request.getContextPath()%>/admin/reports.jsp" class="admin-nav-link <%= pageName.equals("reports.jsp") ? "active" : "" %>">Reports</a>
                    </li>
                </ul>
                
                <!-- Logout Button -->
                <a href="<%=request.getContextPath()%>/LogoutServlet" class="admin-logout-btn">
                    Logout
                </a>
            </nav>
        </div>
    </header>
    
    <!-- Main Content Container -->
    <main class="admin-main-content">
        <div class="container">
