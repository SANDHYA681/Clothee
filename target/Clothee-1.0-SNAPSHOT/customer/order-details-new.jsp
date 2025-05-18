<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect("../admin/dashboard.jsp");
        return;
    }

    // Get order from request
    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
        return;
    }

    // Get shipping information
    model.Shipping shipping = (model.Shipping) request.getAttribute("shipping");

    // Get navigation info
    Integer currentOrderIndex = (Integer) request.getAttribute("currentOrderIndex");
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Boolean hasPrevious = (Boolean) request.getAttribute("hasPrevious");
    Boolean hasNext = (Boolean) request.getAttribute("hasNext");

    // Default values if attributes are not set
    if (currentOrderIndex == null) currentOrderIndex = 0;
    if (totalOrders == null) totalOrders = 1;
    if (hasPrevious == null) hasPrevious = false;
    if (hasNext == null) hasNext = false;

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy");
    String orderDate = dateFormat.format(order.getOrderDate());
%>
<%
    String currentPage = request.getRequestURI();
    String pageName = currentPage.substring(currentPage.lastIndexOf("/") + 1);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order #ORD-<%= order.getId() %> - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/variables.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/custom/main.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/enhanced-header-footer.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/common.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/navbar-fix.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/order-details.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/order-page.css">
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
            background-color: rgba(0, 0, 0, 0.1);
            color: #000000;
            transform: translateY(-2px);
        }

        .nav-icon i {
            font-size: 18px;
        }

        /* Info section styles */
        .info-section {
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }

        .info-section:last-child {
            margin-bottom: 0;
            padding-bottom: 0;
            border-bottom: none;
        }

        .info-title {
            font-size: 14px;
            font-weight: 600;
            color: #666;
            margin-bottom: 8px;
        }

        .info-content {
            font-size: 16px;
            color: #333;
            line-height: 1.5;
        }

        .cart-count {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: #000000;
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

        /* Adjust main content to account for header */
        main {
            padding-top: 20px;
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
                <a href="<%=request.getContextPath()%>/index.jsp" class="nav-icon" title="Home">
                    <i class="fas fa-home"></i>
                </a>

                <!-- Categories Icon -->
                <a href="<%=request.getContextPath()%>/categories.jsp" class="nav-icon" title="Categories">
                    <i class="fas fa-th-large"></i>
                </a>

                <!-- Products Icon -->
                <a href="<%=request.getContextPath()%>/ProductServlet" class="nav-icon" title="Products">
                    <i class="fas fa-tshirt"></i>
                </a>

                <!-- About Icon -->
                <a href="<%=request.getContextPath()%>/about.jsp" class="nav-icon" title="About Us">
                    <i class="fas fa-info-circle"></i>
                </a>

                <!-- Contact Icon -->
                <a href="<%=request.getContextPath()%>/ContactServlet" class="nav-icon" title="Contact Us">
                    <i class="fas fa-envelope"></i>
                </a>

                <!-- User Dashboard Icon -->
                <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="nav-icon <%= pageName.equals("dashboard.jsp") ? "active" : "" %>" title="My Dashboard">
                    <i class="fas fa-tachometer-alt"></i>
                </a>

                <!-- User Profile Icon -->
                <a href="<%=request.getContextPath()%>/customer/profile.jsp" class="nav-icon <%= pageName.equals("profile.jsp") ? "active" : "" %>" title="My Profile">
                    <i class="fas fa-user-circle"></i>
                </a>

                <!-- Shopping Cart Icon -->
                <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="nav-icon <%= pageName.equals("cart.jsp") ? "active" : "" %>" title="Shopping Cart">
                    <i class="fas fa-shopping-cart"></i>
                </a>

                <!-- Logout Icon -->
                <a href="<%=request.getContextPath()%>/LogoutServlet" class="nav-icon" title="Logout">
                    <i class="fas fa-sign-out-alt"></i>
                </a>
            </div>
        </div>
    </header>
    <main>

            <div class="order-details-container">
                <!-- Order Header -->
                <div class="order-header">
                    <div>
                        <h1 class="order-title">Order Details</h1>
                        <p class="order-subtitle">Check the status and information about your order</p>
                    </div>
                    <div class="order-meta">
                        <div class="order-number">Order #ORD-<%= order.getId() %></div>
                        <div class="order-date">Placed on <%= orderDate %></div>
                        <span class="status-badge <%= order.getStatus().toLowerCase() %>">
                            <%= order.getStatus() %>
                        </span>
                    </div>
                </div>

                <!-- Order Items -->
                <div class="order-card">
                    <div class="order-card-header">
                        <span><i class="fas fa-box"></i> Order Items</span>
                    </div>
                    <div class="order-card-body">
                        <div class="order-items">
                            <%
                            List<OrderItem> orderItems = order.getOrderItems();
                            if (orderItems != null && !orderItems.isEmpty()) {
                                for (OrderItem item : orderItems) {
                            %>
                            <div class="order-item">
                                <div class="item-image">
                                    <img src="<%= item.getImageUrl() != null ? item.getImageUrl() : "../images/products/placeholder.jpg" %>" alt="<%= item.getProductName() %>">
                                </div>
                                <div class="item-details">
                                    <div class="item-name"><%= item.getProductName() %></div>
                                    <div class="item-price">$<%= String.format("%.2f", item.getPrice()) %> x <%= item.getQuantity() %></div>
                                </div>
                                <div class="item-total">
                                    $<%= String.format("%.2f", item.getPrice() * item.getQuantity()) %>
                                </div>
                            </div>
                            <%
                                }
                            } else {
                            %>
                            <div class="empty-state">
                                <p>No items found for this order.</p>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Order Summary -->
                <div class="order-card">
                    <div class="order-card-header">
                        <span><i class="fas fa-receipt"></i> Order Summary</span>
                    </div>
                    <div class="order-card-body">
                        <div class="order-summary">
                            <div class="summary-row">
                                <div class="summary-label">Subtotal</div>
                                <div class="summary-value">$<%= String.format("%.2f", order.getTotalPrice() * 0.93) %></div>
                            </div>
                            <div class="summary-row">
                                <div class="summary-label">Shipping</div>
                                <div class="summary-value">$<%= String.format("%.2f", order.getTotalPrice() * 0.07) %></div>
                            </div>
                            <div class="summary-row total">
                                <div class="summary-label">Total</div>
                                <div class="summary-value">$<%= String.format("%.2f", order.getTotalPrice()) %></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Order Information -->
                <div class="order-card">
                    <div class="order-card-header">
                        <span><i class="fas fa-info-circle"></i> Order Information</span>
                    </div>
                    <div class="order-card-body">
                        <div class="info-section">
                            <h3 class="info-title">Shipping Address</h3>
                            <div class="info-content">
                                <% if (shipping != null && shipping.getShippingAddress() != null && !shipping.getShippingAddress().isEmpty()) { %>
                                    <%= shipping.getShippingAddress() %>
                                <% } else { %>
                                    No shipping address available
                                <% } %>
                            </div>
                        </div>

                        <div class="info-section">
                            <h3 class="info-title">Shipping Status</h3>
                            <div class="info-content">
                                <% if (shipping != null && shipping.getShippingStatus() != null) { %>
                                    <span class="status-badge <%= shipping.getShippingStatus().toLowerCase() %>">
                                        <%= shipping.getShippingStatus() %>
                                    </span>
                                <% } else { %>
                                    <span class="status-badge processing">Processing</span>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Order Timeline -->
                <div class="order-card">
                    <div class="order-card-header">
                        <span><i class="fas fa-clock"></i> Order Timeline</span>
                    </div>
                    <div class="order-card-body">
                        <div class="order-timeline">
                            <div class="timeline-track"></div>

                            <div class="timeline-item">
                                <div class="timeline-dot active">
                                    <i class="fas fa-check"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Order Placed</div>
                                    <div class="timeline-date"><%= orderDate %></div>
                                    <div class="timeline-description">Your order has been placed successfully.</div>
                                </div>
                            </div>

                            <div class="timeline-item">
                                <div class="timeline-dot <%= order.getStatus().equalsIgnoreCase("Processing") || order.getStatus().equalsIgnoreCase("Shipped") || order.getStatus().equalsIgnoreCase("Delivered") ? "active" : "" %>">
                                    <i class="fas fa-cog"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Processing</div>
                                    <div class="timeline-description">Your order is being processed.</div>
                                </div>
                            </div>

                            <div class="timeline-item">
                                <div class="timeline-dot <%= order.getStatus().equalsIgnoreCase("Shipped") || order.getStatus().equalsIgnoreCase("Delivered") ? "active" : "" %>">
                                    <i class="fas fa-truck"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Shipped</div>
                                    <div class="timeline-description">Your order has been shipped.</div>
                                </div>
                            </div>

                            <div class="timeline-item">
                                <div class="timeline-dot <%= order.getStatus().equalsIgnoreCase("Delivered") ? "active" : "" %>">
                                    <i class="fas fa-home"></i>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Delivered</div>
                                    <div class="timeline-description">Your order has been delivered.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="action-buttons">
                    <div class="btn-row">
                        <% if (hasPrevious) { %>
                            <a href="<%=request.getContextPath()%>/OrderServlet?action=prevOrder&id=<%= order.getId() %>" class="btn btn-outline">
                                <i class="fas fa-chevron-left"></i> Previous Order
                            </a>
                        <% } else { %>
                            <button class="btn btn-outline disabled" disabled>
                                <i class="fas fa-chevron-left"></i> Previous Order
                            </button>
                        <% } %>

                        <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders" class="btn btn-outline">
                            <i class="fas fa-list"></i> All Orders
                        </a>

                        <% if (hasNext) { %>
                            <a href="<%=request.getContextPath()%>/OrderServlet?action=nextOrder&id=<%= order.getId() %>" class="btn btn-outline">
                                Next Order <i class="fas fa-chevron-right"></i>
                            </a>
                        <% } else { %>
                            <button class="btn btn-outline disabled" disabled>
                                Next Order <i class="fas fa-chevron-right"></i>
                            </button>
                        <% } %>
                    </div>

                    <div class="order-navigation">
                        <span>Order <%= currentOrderIndex + 1 %> of <%= totalOrders %></span>
                    </div>


                </div>
            </div>
        </div>
    </div>

    <footer class="site-footer">
        <div class="container">
            <div class="footer-container">
                <div class="footer-section footer-about">
                    <h3 class="footer-title">About CLOTHEE</h3>
                    <p>CLOTHEE is your one-stop destination for trendy and affordable fashion. We offer a wide range of clothing for men, women, and children.</p>
                </div>

                <div class="footer-section footer-links">
                    <h3 class="footer-title">Quick Links</h3>
                    <ul>
                        <li><a href="<%=request.getContextPath()%>/index.jsp">Home</a></li>
                        <li><a href="<%=request.getContextPath()%>/about.jsp">About Us</a></li>
                        <li><a href="<%=request.getContextPath()%>/contact.jsp">Contact Us</a></li>
                        <li><a href="<%=request.getContextPath()%>/login.jsp">Login</a></li>
                        <li><a href="<%=request.getContextPath()%>/register.jsp">Register</a></li>
                    </ul>
                </div>

                <div class="footer-section footer-contact">
                    <h3 class="footer-title">Contact Us</h3>
                    <p><i class="fas fa-map-marker-alt"></i> 123 Fashion Street, City, Country</p>
                    <p><i class="fas fa-phone"></i> +1 234 567 8901</p>
                    <p><i class="fas fa-envelope"></i> info@clothee.com</p>
                </div>

                <div class="footer-section footer-social">
                    <h3 class="footer-title">Follow Us</h3>
                    <div class="social-icons">
                        <a href="#" class="social-icon" title="Facebook"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-icon" title="Twitter"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-icon" title="Instagram"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-icon" title="Pinterest"><i class="fab fa-pinterest-p"></i></a>
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <p>&copy; <%= new java.util.Date().getYear() + 1900 %> CLOTHEE. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        // Mobile menu toggle
        document.addEventListener('DOMContentLoaded', function() {
            const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
            const navIcons = document.querySelector('.nav-icons');

            if (mobileMenuBtn) {
                mobileMenuBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    navIcons.classList.toggle('open');
                });
            }
        });
    </script>
</body>
</html>
