<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);

    // Get user information from session
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");

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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/modern-navbar.css">
</head>
<body>
    <!-- Modern Navbar -->
    <nav class="navbar">
        <div class="navbar-container">
            <!-- Logo -->
            <a href="<%=request.getContextPath()%>/index.jsp" class="navbar-logo">
                <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                <span>CLOTHEE</span>
            </a>

            <!-- Desktop Navigation Links -->
            <ul class="navbar-links">
                <li class="nav-item">
                    <a href="<%=request.getContextPath()%>/index.jsp" class="nav-link <%= pageName.equals("index.jsp") ? "active" : "" %>">
                        <i class="fas fa-home"></i> Home
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=request.getContextPath()%>/categories.jsp" class="nav-link <%= pageName.equals("categories.jsp") ? "active" : "" %>">
                        <i class="fas fa-th-large"></i> Categories
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="nav-link <%= pageName.equals("products.jsp") ? "active" : "" %>">
                        <i class="fas fa-tshirt"></i> Products
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=request.getContextPath()%>/about.jsp" class="nav-link <%= pageName.equals("about.jsp") ? "active" : "" %>">
                        <i class="fas fa-info-circle"></i> About
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%=request.getContextPath()%>/contact.jsp" class="nav-link <%= pageName.equals("contact.jsp") ? "active" : "" %>">
                        <i class="fas fa-envelope"></i> Contact
                    </a>
                </li>
            </ul>

            <!-- Search Bar -->
            <div class="navbar-search">
                <i class="fas fa-search search-icon"></i>
                <input type="text" class="search-input" placeholder="Search products...">
            </div>

            <!-- Action Icons -->
            <div class="navbar-actions">
                <% if (userRole != null && userId != null) { %>
                    <!-- Cart Icon -->
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="action-icon <%= pageName.equals("cart.jsp") ? "active" : "" %>" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                        <% if (cartCount > 0) { %>
                            <span class="badge"><%= cartCount %></span>
                        <% } %>
                    </a>

                    <!-- Wishlist Icon removed -->

                    <% if (userRole.equals("admin")) { %>
                        <!-- Admin Dashboard Icon -->
                        <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="action-icon <%= pageName.contains("admin") ? "active" : "" %>" title="Admin Dashboard">
                            <i class="fas fa-user-shield"></i>
                        </a>
                    <% } else { %>
                        <!-- User Dashboard Icon -->
                        <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="action-icon <%= pageName.equals("dashboard.jsp") ? "active" : "" %>" title="My Dashboard">
                            <i class="fas fa-tachometer-alt"></i>
                        </a>
                    <% } %>

                    <!-- User Menu -->
                    <div class="user-menu">
                        <div class="user-menu-toggle">
                            <div class="user-avatar">
                                <img src="<%=request.getContextPath()%>/images/avatars/default.png" alt="<%= userName %>">
                            </div>
                            <span class="user-name"><%= userName %></span>
                            <i class="fas fa-chevron-down"></i>
                        </div>

                        <div class="user-menu-dropdown">
                            <% if (userRole.equals("admin")) { %>
                                <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="user-menu-item">
                                    <i class="fas fa-tachometer-alt"></i> Dashboard
                                </a>
                                <a href="<%=request.getContextPath()%>/admin/profile.jsp" class="user-menu-item">
                                    <i class="fas fa-user"></i> Profile
                                </a>
                                <a href="<%=request.getContextPath()%>/admin/settings.jsp" class="user-menu-item">
                                    <i class="fas fa-cog"></i> Settings
                                </a>
                            <% } else { %>
                                <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="user-menu-item">
                                    <i class="fas fa-tachometer-alt"></i> Dashboard
                                </a>
                                <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="user-menu-item">
                                    <i class="fas fa-user"></i> Profile
                                </a>
                                <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders" class="user-menu-item">
                                    <i class="fas fa-box"></i> My Orders
                                </a>
                                <!-- Wishlist menu item removed -->
                            <% } %>

                            <div class="user-menu-divider"></div>

                            <a href="<%=request.getContextPath()%>/LogoutServlet" class="user-menu-item">
                                <i class="fas fa-sign-out-alt"></i> Logout
                            </a>
                        </div>
                    </div>
                <% } else { %>
                    <!-- Login/Register Buttons for Guest Users -->
                    <a href="<%=request.getContextPath()%>/login.jsp" class="action-icon" title="Login">
                        <i class="fas fa-sign-in-alt"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/register.jsp" class="action-icon" title="Register">
                        <i class="fas fa-user-plus"></i>
                    </a>
                <% } %>
            </div>

            <!-- Mobile Menu Toggle -->
            <button class="mobile-toggle" id="mobileToggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>

        <!-- Mobile Navigation Menu -->
        <div class="navbar-mobile" id="mobileMenu">
            <!-- Mobile Search -->
            <div class="mobile-search">
                <i class="fas fa-search mobile-search-icon"></i>
                <input type="text" class="mobile-search-input" placeholder="Search products...">
            </div>

            <!-- Mobile Links -->
            <ul class="mobile-links">
                <li class="mobile-item">
                    <a href="<%=request.getContextPath()%>/index.jsp" class="mobile-link <%= pageName.equals("index.jsp") ? "active" : "" %>">
                        <i class="fas fa-home"></i> Home
                    </a>
                </li>
                <li class="mobile-item">
                    <a href="<%=request.getContextPath()%>/categories.jsp" class="mobile-link <%= pageName.equals("categories.jsp") ? "active" : "" %>">
                        <i class="fas fa-th-large"></i> Categories
                    </a>
                </li>
                <li class="mobile-item">
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="mobile-link <%= pageName.equals("products.jsp") ? "active" : "" %>">
                        <i class="fas fa-tshirt"></i> Products
                    </a>
                </li>
                <li class="mobile-item">
                    <a href="<%=request.getContextPath()%>/about.jsp" class="mobile-link <%= pageName.equals("about.jsp") ? "active" : "" %>">
                        <i class="fas fa-info-circle"></i> About
                    </a>
                </li>
                <li class="mobile-item">
                    <a href="<%=request.getContextPath()%>/contact.jsp" class="mobile-link <%= pageName.equals("contact.jsp") ? "active" : "" %>">
                        <i class="fas fa-envelope"></i> Contact
                    </a>
                </li>

                <div class="mobile-divider"></div>

                <% if (userRole != null && userId != null) { %>
                    <li class="mobile-item">
                        <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="mobile-link <%= pageName.equals("cart.jsp") ? "active" : "" %>">
                            <i class="fas fa-shopping-cart"></i> Shopping Cart
                            <% if (cartCount > 0) { %>
                                <span class="badge"><%= cartCount %></span>
                            <% } %>
                        </a>
                    </li>
                    <!-- Mobile wishlist item removed -->

                    <% if (userRole.equals("admin")) { %>
                        <li class="mobile-item">
                            <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="mobile-link <%= pageName.contains("admin") ? "active" : "" %>">
                                <i class="fas fa-user-shield"></i> Admin Dashboard
                            </a>
                        </li>
                        <li class="mobile-item">
                            <a href="<%=request.getContextPath()%>/admin/profile.jsp" class="mobile-link">
                                <i class="fas fa-user"></i> Profile
                            </a>
                        </li>
                        <li class="mobile-item">
                            <a href="<%=request.getContextPath()%>/admin/settings.jsp" class="mobile-link">
                                <i class="fas fa-cog"></i> Settings
                            </a>
                        </li>
                    <% } else { %>
                        <li class="mobile-item">
                            <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="mobile-link <%= pageName.equals("dashboard.jsp") ? "active" : "" %>">
                                <i class="fas fa-tachometer-alt"></i> Dashboard
                            </a>
                        </li>
                        <li class="mobile-item">
                            <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="mobile-link">
                                <i class="fas fa-user"></i> Profile
                            </a>
                        </li>
                        <li class="mobile-item">
                            <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders" class="mobile-link">
                                <i class="fas fa-box"></i> My Orders
                            </a>
                        </li>
                    <% } %>

                    <div class="mobile-divider"></div>

                    <li class="mobile-item">
                        <a href="<%=request.getContextPath()%>/LogoutServlet" class="mobile-link">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                    </li>
                <% } else { %>
                    <li class="mobile-item">
                        <a href="<%=request.getContextPath()%>/login.jsp" class="mobile-link">
                            <i class="fas fa-sign-in-alt"></i> Login
                        </a>
                    </li>
                    <li class="mobile-item">
                        <a href="<%=request.getContextPath()%>/register.jsp" class="mobile-link">
                            <i class="fas fa-user-plus"></i> Register
                        </a>
                    </li>
                <% } %>
            </ul>
        </div>
    </nav>

    <!-- JavaScript for Mobile Menu Toggle -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const mobileToggle = document.getElementById('mobileToggle');
            const mobileMenu = document.getElementById('mobileMenu');

            mobileToggle.addEventListener('click', function() {
                mobileMenu.classList.toggle('active');

                // Change icon based on menu state
                const icon = mobileToggle.querySelector('i');
                if (mobileMenu.classList.contains('active')) {
                    icon.classList.remove('fa-bars');
                    icon.classList.add('fa-times');
                } else {
                    icon.classList.remove('fa-times');
                    icon.classList.add('fa-bars');
                }
            });

            // Add scroll event to change navbar appearance
            window.addEventListener('scroll', function() {
                const navbar = document.querySelector('.navbar');
                if (window.scrollY > 50) {
                    navbar.classList.add('scrolled');
                } else {
                    navbar.classList.remove('scrolled');
                }
            });
        });
    </script>
</body>
</html>
