<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);

    // Get user information if logged in
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    if (userName == null) userName = "Admin User";

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
    <!-- Admin Dashboard Layout CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-dashboard-layout.css">

    <!-- Page-specific CSS -->
    <% if (pageName.equals("categories.jsp")) { %>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-categories.css">
    <% } else if (pageName.equals("products.jsp")) { %>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-products.css">
    <% } else if (pageName.equals("orders.jsp")) { %>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-orders.css">
    <% } else if (pageName.equals("customers.jsp")) { %>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-customers.css">
    <% } else if (pageName.equals("reports.jsp")) { %>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-reports.css">
    <% } else if (pageName.equals("messages.jsp")) { %>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-messages.css">
    <% } else if (pageName.equals("reviews.jsp")) { %>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-reviews.css">
    <% } %>

    <!-- Blue Theme CSS - Applied to all admin pages -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-blue-theme-all.css">
</head>
<body>
    <div class="admin-dashboard">
        <!-- Sidebar -->
        <aside class="admin-sidebar" id="adminSidebar">
            <div class="admin-sidebar-header">
                <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="admin-sidebar-logo">
                    <span class="admin-sidebar-logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="admin-sidebar-logo-text">CLOTHEE</span>
                </a>
                <div class="admin-sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-chevron-left"></i>
                </div>
            </div>

            <div class="admin-sidebar-menu">
                <div class="admin-sidebar-heading">Main</div>
                <ul>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="admin-sidebar-link <%= pageName.equals("dashboard.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-tachometer-alt"></i></span>
                            <span class="admin-sidebar-text">Dashboard</span>
                        </a>
                    </li>
                </ul>

                <div class="admin-sidebar-heading">Catalog</div>
                <ul>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/products.jsp" class="admin-sidebar-link <%= pageName.equals("products.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-box"></i></span>
                            <span class="admin-sidebar-text">Products</span>
                            <span class="admin-sidebar-badge">New</span>
                        </a>
                    </li>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/categories.jsp" class="admin-sidebar-link <%= pageName.equals("categories.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-tags"></i></span>
                            <span class="admin-sidebar-text">Categories</span>
                        </a>
                    </li>
                </ul>

                <div class="admin-sidebar-heading">Sales</div>
                <ul>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/orders.jsp" class="admin-sidebar-link <%= pageName.equals("orders.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-shopping-cart"></i></span>
                            <span class="admin-sidebar-text">Orders</span>
                        </a>
                    </li>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/customers.jsp" class="admin-sidebar-link <%= pageName.equals("customers.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-users"></i></span>
                            <span class="admin-sidebar-text">Customers</span>
                        </a>
                    </li>
                </ul>

                <div class="admin-sidebar-heading">Customer Service</div>
                <ul>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/messages.jsp" class="admin-sidebar-link <%= pageName.equals("messages.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-envelope"></i></span>
                            <span class="admin-sidebar-text">Messages</span>
                        </a>
                    </li>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/reviews.jsp" class="admin-sidebar-link <%= pageName.equals("reviews.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-star"></i></span>
                            <span class="admin-sidebar-text">Reviews</span>
                        </a>
                    </li>
                </ul>

                <div class="admin-sidebar-heading">Reports</div>
                <ul>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/reports.jsp" class="admin-sidebar-link <%= pageName.equals("reports.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-chart-bar"></i></span>
                            <span class="admin-sidebar-text">Analytics</span>
                        </a>
                    </li>
                </ul>

                <div class="admin-sidebar-divider"></div>

                <ul>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/admin/settings.jsp" class="admin-sidebar-link <%= pageName.equals("settings.jsp") ? "active" : "" %>">
                            <span class="admin-sidebar-icon"><i class="fas fa-cog"></i></span>
                            <span class="admin-sidebar-text">Settings</span>
                        </a>
                    </li>
                    <li class="admin-sidebar-item">
                        <a href="<%=request.getContextPath()%>/LogoutServlet" class="admin-sidebar-link">
                            <span class="admin-sidebar-icon"><i class="fas fa-sign-out-alt"></i></span>
                            <span class="admin-sidebar-text">Logout</span>
                        </a>
                    </li>
                </ul>
            </div>
        </aside>

        <!-- Main Content Wrapper -->
        <div class="admin-content-wrapper">
            <!-- Header -->
            <header class="admin-header">
                <div class="admin-header-container">
                    <div class="admin-mobile-toggle" id="mobileToggle">
                        <i class="fas fa-bars"></i>
                    </div>

                    <div class="admin-header-search">
                        <input type="text" class="admin-header-search-input" placeholder="Search...">
                        <span class="admin-header-search-icon"><i class="fas fa-search"></i></span>
                    </div>

                    <div class="admin-header-actions">
                        <div class="admin-header-action">
                            <i class="fas fa-bell"></i>
                            <span class="admin-header-action-badge">3</span>
                        </div>
                        <div class="admin-header-action">
                            <i class="fas fa-envelope"></i>
                            <span class="admin-header-action-badge">5</span>
                        </div>
                        <div class="admin-header-user">
                            <div class="admin-header-user-avatar">
                                <img src="<%=request.getContextPath()%>/images/avatars/admin-avatar.jpg" alt="Admin Avatar">
                            </div>
                            <div class="admin-header-user-info">
                                <div class="admin-header-user-name"><%= userName %></div>
                                <div class="admin-header-user-role">Administrator</div>
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Main Content -->
            <main class="admin-main-content">
