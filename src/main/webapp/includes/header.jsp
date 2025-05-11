<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CLOTHEE - <%= pageName.replace(".jsp", "").toUpperCase() %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/variables.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/custom/main.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/enhanced-header-footer.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/common.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/navbar-fix.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/profile-image.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/product-price-fix.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/product-button-fix.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/product-text-fix.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/product-badge-fix.css">

    <% if (currentPage.contains("/admin/")) { %>
    <!-- Admin specific CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-dashboard-complete.css">
    <% } else if (currentPage.contains("/customer/")) { %>
    <!-- Customer specific CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/style.css">
    <% } %>
    <style>
        /* Additional styles for the clickable icons */
        .nav-icons {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .nav-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-medium);
            background-color: var(--bg-light);
            transition: all 0.3s ease;
            text-decoration: none;
            position: relative;
        }

        .nav-icon:hover, .nav-icon.active {
            background-color: rgba(255, 136, 0, 0.1);
            color: var(--primary-color);
            transform: translateY(-2px);
        }

        .nav-icon i {
            font-size: 18px;
        }

        .cart-count {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: var(--primary-color);
            color: white;
            font-size: 10px;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid white;
        }
    </style>
</head>
<body>
    <header class="site-header">
        <div class="header-container">
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                <span class="logo-text">CLOTHEE</span>
            </a>

            <div class="nav-icons">
                <!-- Home Icon -->
                <a href="<%=request.getContextPath()%>/index.jsp" class="nav-icon <%= pageName.equals("index.jsp") ? "active" : "" %>" title="Home">
                    <i class="fas fa-home"></i>
                </a>

                <!-- Categories Icon -->
                <a href="<%=request.getContextPath()%>/categories.jsp" class="nav-icon <%= pageName.equals("categories.jsp") ? "active" : "" %>" title="Categories">
                    <i class="fas fa-th-large"></i>
                </a>

                <!-- Products Icon -->
                <a href="<%=request.getContextPath()%>/ProductServlet" class="nav-icon <%= pageName.equals("products.jsp") ? "active" : "" %>" title="Products">
                    <i class="fas fa-tshirt"></i>
                </a>

                <!-- About Icon -->
                <a href="<%=request.getContextPath()%>/about.jsp" class="nav-icon <%= pageName.equals("about.jsp") ? "active" : "" %>" title="About Us">
                    <i class="fas fa-info-circle"></i>
                </a>

                <!-- Contact Icon -->
                <a href="<%=request.getContextPath()%>/ContactServlet" class="nav-icon <%= pageName.equals("contact-new.jsp") || pageName.equals("contact.jsp") ? "active" : "" %>" title="Contact Us">
                    <i class="fas fa-envelope"></i>
                </a>

                <%-- Check if user is logged in --%>
                <%
                // Get the session without creating a new one if it doesn't exist
                HttpSession currentSession = request.getSession(false);
                String userRole = null;
                Integer userId = null;

                // Check if session exists and has user attributes
                if (currentSession != null) {
                    userRole = (String) currentSession.getAttribute("userRole");
                    userId = (Integer) currentSession.getAttribute("userId");
                }

                // Only consider user logged in if both userRole and userId are present
                if (userRole != null && userId != null) {
                    if (userRole.equals("admin")) {
                %>
                    <!-- Admin Dashboard Icon -->
                    <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="nav-icon <%= pageName.contains("admin") ? "active" : "" %>" title="Admin Dashboard">
                        <i class="fas fa-user-shield"></i>
                    </a>
                <% } else { %>
                    <!-- User Dashboard Icon -->
                    <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="nav-icon <%= pageName.equals("dashboard.jsp") ? "active" : "" %>" title="My Dashboard">
                        <i class="fas fa-tachometer-alt"></i>
                    </a>

                    <!-- User Profile Icon -->
                    <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="nav-icon <%= pageName.equals("profile.jsp") ? "active" : "" %>" title="My Profile">
                        <i class="fas fa-user-circle"></i>
                    </a>

                    <!-- Shopping Cart Icon -->
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="nav-icon <%= pageName.equals("cart.jsp") || pageName.equals("checkout-simple.jsp") ? "active" : "" %>" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>

                    <!-- Messages Icon -->
                    <a href="<%=request.getContextPath()%>/CustomerMessageServlet" class="nav-icon <%= pageName.equals("messages-view.jsp") || pageName.equals("view-message.jsp") || request.getServletPath().contains("/messages") ? "active" : "" %>" title="My Messages">
                        <i class="fas fa-envelope"></i>
                    </a>

                    <!-- Wishlist Icon removed -->
                <% } %>

                <!-- Logout Icon -->
                <a href="<%=request.getContextPath()%>/LogoutServlet" class="nav-icon" title="Logout">
                    <i class="fas fa-sign-out-alt"></i>
                </a>

                <% } else { %>
                    <!-- Login Icon -->
                    <a href="<%=request.getContextPath()%>/login.jsp" class="nav-icon <%= pageName.equals("login.jsp") ? "active" : "" %>" title="Login">
                        <i class="fas fa-sign-in-alt"></i>
                    </a>

                    <!-- Register Icon -->
                    <a href="<%=request.getContextPath()%>/register.jsp" class="nav-icon <%= pageName.equals("register.jsp") ? "active" : "" %>" title="Register">
                        <i class="fas fa-user-plus"></i>
                    </a>
                <% } %>
            </div>
        </div>
    </header>
    <main>