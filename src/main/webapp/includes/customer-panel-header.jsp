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

    // Get wishlist count if available
    Integer wishlistCount = (Integer) session.getAttribute("wishlistCount");
    if (wishlistCount == null) wishlistCount = 0;
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
    <!-- Customer Panel CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer-panel.css">
</head>
<body>
    <div class="customer-dashboard">
        <!-- Sidebar -->
        <aside class="customer-sidebar" id="customerSidebar">
            <div class="customer-sidebar-header">
                <a href="<%=request.getContextPath()%>/index.jsp" class="customer-sidebar-logo">
                    <span class="customer-sidebar-logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="customer-sidebar-logo-text">CLOTHEE</span>
                </a>
                <div class="customer-sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-chevron-left"></i>
                </div>
            </div>

            <div class="customer-sidebar-user">
                <div class="customer-sidebar-user-avatar">
                    <%
                    // Get user profile image from session if available
                    String profileImage = (String) session.getAttribute("userProfileImage");
                    if (profileImage != null && !profileImage.isEmpty()) {
                    %>
                        <img src="<%=request.getContextPath()%>/<%= profileImage %>" alt="<%= userName %>">
                    <% } else { %>
                        <div class="no-profile-image">
                            <i class="fas fa-user"></i>
                        </div>
                    <% } %>
                </div>
                <div class="customer-sidebar-user-name"><%= userName %></div>
                <div class="customer-sidebar-user-email"><%= userEmail %></div>
            </div>

            <div class="customer-sidebar-menu">
                <div class="customer-sidebar-heading">My Account</div>
                <ul>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="customer-sidebar-link <%= pageName.equals("dashboard.jsp") ? "active" : "" %>">
                            <span class="customer-sidebar-icon"><i class="fas fa-tachometer-alt"></i></span>
                            <span class="customer-sidebar-text">Dashboard</span>
                        </a>
                    </li>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="customer-sidebar-link <%= pageName.equals("profile.jsp") ? "active" : "" %>">
                            <span class="customer-sidebar-icon"><i class="fas fa-user"></i></span>
                            <span class="customer-sidebar-text">My Profile</span>
                        </a>
                    </li>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/addresses.jsp" class="customer-sidebar-link <%= pageName.equals("addresses.jsp") ? "active" : "" %>">
                            <span class="customer-sidebar-icon"><i class="fas fa-map-marker-alt"></i></span>
                            <span class="customer-sidebar-text">My Addresses</span>
                        </a>
                    </li>
                </ul>

                <div class="customer-sidebar-heading">Shopping</div>
                <ul>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/orders.jsp" class="customer-sidebar-link <%= pageName.equals("orders.jsp") ? "active" : "" %>">
                            <span class="customer-sidebar-icon"><i class="fas fa-shopping-bag"></i></span>
                            <span class="customer-sidebar-text">My Orders</span>
                        </a>
                    </li>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/wishlist.jsp" class="customer-sidebar-link <%= pageName.equals("wishlist.jsp") ? "active" : "" %>">
                            <span class="customer-sidebar-icon"><i class="fas fa-heart"></i></span>
                            <span class="customer-sidebar-text">Wishlist</span>
                            <% if (wishlistCount > 0) { %>
                            <span class="customer-sidebar-badge"><%= wishlistCount %></span>
                            <% } %>
                        </a>
                    </li>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/customer/reviews.jsp" class="customer-sidebar-link <%= pageName.equals("reviews.jsp") ? "active" : "" %>">
                            <span class="customer-sidebar-icon"><i class="fas fa-star"></i></span>
                            <span class="customer-sidebar-text">My Reviews</span>
                        </a>
                    </li>
                </ul>

                <div class="customer-sidebar-divider"></div>

                <ul>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/index.jsp" class="customer-sidebar-link">
                            <span class="customer-sidebar-icon"><i class="fas fa-store"></i></span>
                            <span class="customer-sidebar-text">Go to Shop</span>
                        </a>
                    </li>
                    <li class="customer-sidebar-item">
                        <a href="<%=request.getContextPath()%>/LogoutServlet" class="customer-sidebar-link">
                            <span class="customer-sidebar-icon"><i class="fas fa-sign-out-alt"></i></span>
                            <span class="customer-sidebar-text">Logout</span>
                        </a>
                    </li>
                </ul>
            </div>
        </aside>

        <!-- Main Content Wrapper -->
        <div class="customer-content-wrapper">
            <!-- Header -->
            <header class="customer-header">
                <div class="customer-header-container">
                    <div class="customer-mobile-toggle" id="mobileToggle">
                        <i class="fas fa-bars"></i>
                    </div>

                    <div class="customer-header-search">
                        <input type="text" class="customer-header-search-input" placeholder="Search products...">
                        <span class="customer-header-search-icon"><i class="fas fa-search"></i></span>
                    </div>

                    <div class="customer-header-actions">
                        <a href="<%=request.getContextPath()%>/customer/wishlist.jsp" class="customer-header-action" title="Wishlist">
                            <i class="fas fa-heart"></i>
                            <% if (wishlistCount > 0) { %>
                            <span class="customer-header-action-badge"><%= wishlistCount %></span>
                            <% } %>
                        </a>
                        <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="customer-header-action" title="Shopping Cart">
                            <i class="fas fa-shopping-cart"></i>
                            <% if (cartCount > 0) { %>
                            <span class="customer-header-action-badge"><%= cartCount %></span>
                            <% } %>
                        </a>
                        <div class="customer-header-user">
                            <div class="customer-header-user-avatar">
                                <% if (profileImage != null && !profileImage.isEmpty()) { %>
                                    <img src="<%=request.getContextPath()%>/<%= profileImage %>" alt="<%= userName %>">
                                <% } else { %>
                                    <div class="no-profile-image">
                                        <i class="fas fa-user"></i>
                                    </div>
                                <% } %>
                            </div>
                            <div class="customer-header-user-info">
                                <div class="customer-header-user-name"><%= userName %></div>
                                <div class="customer-header-user-role">Customer</div>
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Main Content -->
            <main class="customer-main-content">
