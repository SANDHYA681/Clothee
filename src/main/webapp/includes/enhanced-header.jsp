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
</head>
<body>
    <header class="site-header">
        <div class="header-container">
            <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                <span class="logo-text">CLOTHEE</span>
            </a>

            <a href="<%=request.getContextPath()%>/NavbarServlet?action=toggleMenu" class="mobile-menu-btn">
                <i class="fas fa-bars"></i>
            </a>

            <div class="nav-icons <%= (session.getAttribute("isMenuOpen") != null && (Boolean) session.getAttribute("isMenuOpen")) ? "open" : "" %>">
                <a href="<%=request.getContextPath()%>/index.jsp" class="nav-icon <%= pageName.equals("index.jsp") ? "active" : "" %>" title="Home">
                    <i class="fas fa-home"></i>
                </a>
                <a href="<%=request.getContextPath()%>/categories.jsp" class="nav-icon <%= pageName.equals("categories.jsp") ? "active" : "" %>" title="Categories">
                    <i class="fas fa-th-large"></i>
                </a>
                <a href="<%=request.getContextPath()%>/ProductServlet" class="nav-icon <%= pageName.equals("products.jsp") ? "active" : "" %>" title="Products">
                    <i class="fas fa-tshirt"></i>
                </a>
                <a href="<%=request.getContextPath()%>/about.jsp" class="nav-icon <%= pageName.equals("about.jsp") ? "active" : "" %>" title="About Us">
                    <i class="fas fa-info-circle"></i>
                </a>
                <a href="<%=request.getContextPath()%>/contact.jsp" class="nav-icon <%= pageName.equals("contact.jsp") ? "active" : "" %>" title="Contact Us">
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
                    <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="nav-icon <%= pageName.contains("admin") ? "active" : "" %>" title="Admin Dashboard">
                        <i class="fas fa-user-shield"></i>
                    </a>
                <% } else { %>
                    <a href="<%=request.getContextPath()%>/enhanced-dashboard.jsp" class="nav-icon <%= pageName.equals("enhanced-dashboard.jsp") ? "active" : "" %>" title="My Dashboard">
                        <i class="fas fa-tachometer-alt"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="nav-icon <%= pageName.equals("profile.jsp") ? "active" : "" %>" title="My Profile">
                        <i class="fas fa-user-circle"></i>
                    </a>
                <% } %>
                    <a href="<%=request.getContextPath()%>/LogoutServlet" class="nav-icon" title="Logout">
                        <i class="fas fa-sign-out-alt"></i>
                    </a>
                <% } else { %>
                    <a href="<%=request.getContextPath()%>/login.jsp" class="nav-icon <%= pageName.equals("login.jsp") ? "active" : "" %>" title="Login">
                        <i class="fas fa-sign-in-alt"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/register.jsp" class="nav-icon <%= pageName.equals("register.jsp") ? "active" : "" %>" title="Register">
                        <i class="fas fa-user-plus"></i>
                    </a>
                <% } %>

                <% if (userRole != null && userId != null && !"admin".equals(userRole)) { /* Only show cart and wishlist for logged in non-admin users */ %>
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="nav-icon <%= pageName.equals("checkout-simple.jsp") ? "active" : "" %>" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                        <span class="cart-count">
                            <%
                            // Get cart count from session
                            model.Cart cart = null;
                            int cartCount = 0;

                            if (currentSession != null) {
                                try {
                                    cart = (model.Cart) currentSession.getAttribute("cart");
                                    cartCount = (cart != null) ? cart.getItemCount() : 0;
                                } catch (Exception e) {
                                    // Initialize a new cart if there's an error
                                    cart = new model.Cart();
                                    currentSession.setAttribute("cart", cart);
                                }
                            }
                            out.print(cartCount);
                            %>
                        </span>
                    </a>
                <% } %>
            </div>
        </div>
    </header>
    <main>
