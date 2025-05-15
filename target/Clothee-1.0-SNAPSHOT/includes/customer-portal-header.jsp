<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);

    // Get user information if logged in
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");

    if (userName == null) userName = "Customer";
    if (userEmail == null) userEmail = "customer@example.com";

    // Redirect if not logged in
    if (userRole == null || userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=You must be logged in to access this page");
        return;
    }

    // Get cart count if available
    Integer cartCount = (Integer) session.getAttribute("cartCount");
    if (cartCount == null) cartCount = 0;

    // Wishlist functionality removed
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CLOTHEE - <%= pageName.replace(".jsp", "").toUpperCase() %></title>
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Customer Portal CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer-portal.css">
</head>
<body>
    <div class="dashboard">
        <!-- Sidebar -->
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%=request.getContextPath()%>/index.jsp" class="sidebar-logo">
                    <span class="sidebar-logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="sidebar-logo-text">CLOTHEE</span>
                </a>
                <div class="sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-chevron-left"></i>
                </div>
            </div>

            <div class="sidebar-user">
                <div class="sidebar-user-avatar">
                    <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="User Avatar">
                </div>
                <div class="sidebar-user-name"><%= userName %></div>
                <div class="sidebar-user-email"><%= userEmail %></div>
            </div>

            <div class="sidebar-menu">
                <div class="sidebar-heading">My Account</div>
                <ul>
                    <li class="sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="sidebar-link <%= pageName.equals("dashboard.jsp") ? "active" : "" %>">
                            <span class="sidebar-icon"><i class="fas fa-tachometer-alt"></i></span>
                            <span class="sidebar-text">Dashboard</span>
                        </a>
                    </li>
                    <li class="sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="sidebar-link <%= pageName.equals("profile.jsp") ? "active" : "" %>">
                            <span class="sidebar-icon"><i class="fas fa-user"></i></span>
                            <span class="sidebar-text">My Profile</span>
                        </a>
                    </li>
                    <li class="sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/addresses.jsp" class="sidebar-link <%= pageName.equals("addresses.jsp") ? "active" : "" %>">
                            <span class="sidebar-icon"><i class="fas fa-map-marker-alt"></i></span>
                            <span class="sidebar-text">My Addresses</span>
                        </a>
                    </li>
                </ul>

                <div class="sidebar-heading">Shopping</div>
                <ul>
                    <li class="sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/orders.jsp" class="sidebar-link <%= pageName.equals("orders.jsp") ? "active" : "" %>">
                            <span class="sidebar-icon"><i class="fas fa-shopping-bag"></i></span>
                            <span class="sidebar-text">My Orders</span>
                        </a>
                    </li>
                    <!-- Wishlist functionality removed -->
                    <li class="sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/reviews.jsp" class="sidebar-link <%= pageName.equals("reviews.jsp") ? "active" : "" %>">
                            <span class="sidebar-icon"><i class="fas fa-star"></i></span>
                            <span class="sidebar-text">My Reviews</span>
                        </a>
                    </li>
                </ul>

                <div class="sidebar-divider"></div>

                <ul>
                    <li class="sidebar-item">
                        <a href="<%=request.getContextPath()%>/index.jsp" class="sidebar-link">
                            <span class="sidebar-icon"><i class="fas fa-store"></i></span>
                            <span class="sidebar-text">Go to Shop</span>
                        </a>
                    </li>
                    <li class="sidebar-item">
                        <a href="<%=request.getContextPath()%>/LogoutServlet" class="sidebar-link">
                            <span class="sidebar-icon"><i class="fas fa-sign-out-alt"></i></span>
                            <span class="sidebar-text">Logout</span>
                        </a>
                    </li>
                </ul>
            </div>
        </aside>

        <!-- Main Content Wrapper -->
        <div class="content-wrapper">
            <!-- Header -->
            <header class="header">
                <div class="header-container">
                    <div class="mobile-toggle" id="mobileToggle">
                        <i class="fas fa-bars"></i>
                    </div>

                    <div class="header-search">
                        <input type="text" class="header-search-input" placeholder="Search products...">
                        <span class="header-search-icon"><i class="fas fa-search"></i></span>
                    </div>

                    <div class="header-actions">
                        <!-- Wishlist functionality removed -->
                        <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Shopping Cart">
                            <i class="fas fa-shopping-cart"></i>
                            <% if (cartCount > 0) { %>
                            <span class="header-action-badge"><%= cartCount %></span>
                            <% } %>
                        </a>
                        <div class="header-user">
                            <div class="header-user-avatar">
                                <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="User Avatar">
                            </div>
                            <div class="header-user-info">
                                <div class="header-user-name"><%= userName %></div>
                                <div class="header-user-role">Customer</div>
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Main Content -->
            <main class="main-content">
