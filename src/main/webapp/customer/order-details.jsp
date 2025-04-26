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

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Details - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/orange-sidebar.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/order-page.css">
    <style>
        body {
            background-color: #f5f5f5;
            padding: 0;
            margin: 0;
            font-family: 'Poppins', sans-serif;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--dark-color);
            color: white;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            transition: all 0.3s ease;
        }

        .sidebar-header {
            padding: 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: white;
            margin-bottom: 10px;
        }

        .logo-icon {
            font-size: 24px;
            color: var(--primary-color);
            margin-right: 10px;
        }

        .logo-text {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 1px;
        }

        .user-info {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .user-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background-color: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 10px;
            font-size: 32px;
            overflow: hidden;
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .user-name {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .user-email {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.7);
        }

        .main-content {
            flex: 1;
            margin-left: var(--sidebar-width);
            padding: 20px;
            transition: all 0.3s ease;
        }

        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background-color: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .dashboard-section-card {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }

        .order-details-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }

        .order-id {
            font-size: 18px;
            font-weight: 600;
        }

        .order-date {
            color: #666;
        }

        .order-status {
            margin-top: 10px;
        }

        .badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .badge.processing {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }

        .badge.shipped {
            background-color: rgba(255, 136, 0, 0.1);
            color: #ff8800;
        }

        .badge.delivered {
            background-color: rgba(25, 135, 84, 0.1);
            color: #198754;
        }

        .badge.cancelled {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }

        .order-details-section {
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }

        .order-items {
            margin-bottom: 30px;
        }

        .order-item {
            display: flex;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid #eee;
        }

        .order-item:last-child {
            border-bottom: none;
        }

        .item-image {
            width: 80px;
            height: 80px;
            border-radius: 5px;
            overflow: hidden;
            margin-right: 15px;
        }

        .item-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .item-details {
            flex: 1;
        }

        .item-name {
            font-weight: 500;
            margin-bottom: 5px;
        }

        .item-price {
            color: #666;
            font-size: 14px;
        }

        .item-quantity {
            color: #666;
            font-size: 14px;
        }

        .item-total {
            font-weight: 600;
            color: var(--primary-color);
        }

        .order-summary {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .summary-row:last-child {
            margin-bottom: 0;
            padding-top: 10px;
            border-top: 1px solid #eee;
            font-weight: 600;
        }

        .summary-label {
            color: #666;
        }

        .summary-value {
            font-weight: 500;
        }

        .shipping-address, .payment-method {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .address-line, .payment-info {
            margin-bottom: 5px;
            color: #666;
        }

        .btn {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }

        .btn-primary:hover {
            background-color: var(--secondary-color);
        }

        .btn-outline {
            border: 1px solid var(--primary-color);
            color: var(--primary-color);
            background-color: transparent;
        }

        .btn-outline:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .toggle-sidebar {
            display: none;
            position: fixed;
            top: 20px;
            left: 20px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            z-index: 100;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
            }

            .toggle-sidebar {
                display: flex;
            }
        }

        /* Header actions styling */
        .header-action {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--light-color);
            color: var(--dark-color);
            margin-left: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .header-action:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .header-actions {
            display: flex;
        }

        /* Action buttons styling */
        .action-buttons {
            margin-top: 30px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .navigation-buttons {
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }

        .order-actions {
            display: flex;
            justify-content: flex-end;
        }

        .order-navigation-info {
            text-align: center;
            margin: 10px 0;
            color: #666;
            font-size: 14px;
        }

        .btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        @media (max-width: 768px) {
            .navigation-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default.png" alt="<%= user.getFullName() %>">
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Order Details</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <!-- Wishlist icon removed -->
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="Back to Shop">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-section-card">
                <div class="order-details-header">
                    <div>
                        <div class="order-id">Order #ORD-<%= order.getId() %></div>
                        <div class="order-date">Placed on <%= dateFormat.format(order.getOrderDate()) %></div>
                    </div>
                    <div class="order-status">
                        <span class="badge <%= order.getStatus().toLowerCase() %>">
                            <%= order.getStatus() %>
                        </span>
                    </div>
                </div>

                <div class="order-details-section">
                    <h2 class="section-title">Order Items</h2>
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

                <div class="order-details-section">
                    <h2 class="section-title">Order Summary</h2>
                    <div class="order-summary">
                        <div class="summary-row">
                            <div class="summary-label">Subtotal</div>
                            <div class="summary-value">$<%= String.format("%.2f", order.getTotalPrice() * 0.93) %></div>
                        </div>
                        <div class="summary-row">
                            <div class="summary-label">Shipping</div>
                            <div class="summary-value">$<%= String.format("%.2f", order.getTotalPrice() * 0.07) %></div>
                        </div>
                        <div class="summary-row">
                            <div class="summary-label">Total</div>
                            <div class="summary-value">$<%= String.format("%.2f", order.getTotalPrice()) %></div>
                        </div>
                    </div>
                </div>

                <div class="order-details-section">
                    <h2 class="section-title">Shipping Address</h2>
                    <div class="shipping-address">
                        <div class="address-line"><%= order.getShippingAddress() != null ? order.getShippingAddress() : "No shipping address provided" %></div>
                    </div>
                </div>

                <div class="order-details-section">
                    <h2 class="section-title">Payment Method</h2>
                    <div class="payment-method">
                        <div class="payment-info"><%= order.getPaymentMethod() != null ? order.getPaymentMethod() : "No payment method provided" %></div>
                    </div>
                </div>

                <div class="action-buttons">
                    <div class="navigation-buttons">
                        <% if (hasPrevious) { %>
                            <a href="<%=request.getContextPath()%>/OrderServlet?action=prevOrder&id=<%= order.getId() %>" class="btn btn-outline"><i class="fas fa-chevron-left"></i> Previous Order</a>
                        <% } else { %>
                            <button class="btn btn-outline disabled" disabled><i class="fas fa-chevron-left"></i> Previous Order</button>
                        <% } %>

                        <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders" class="btn btn-outline"><i class="fas fa-list"></i> All Orders</a>

                        <% if (hasNext) { %>
                            <a href="<%=request.getContextPath()%>/OrderServlet?action=nextOrder&id=<%= order.getId() %>" class="btn btn-outline">Next Order <i class="fas fa-chevron-right"></i></a>
                        <% } else { %>
                            <button class="btn btn-outline disabled" disabled>Next Order <i class="fas fa-chevron-right"></i></button>
                        <% } %>
                    </div>

                    <div class="order-navigation-info">
                        <span>Order <%= currentOrderIndex + 1 %> of <%= totalOrders %></span>
                    </div>

                    <div class="order-actions">
                        <% if (order.getStatus().equalsIgnoreCase("Processing") || order.getStatus().equalsIgnoreCase("Pending")) { %>
                        <a href="<%=request.getContextPath()%>/OrderServlet?action=cancel&id=<%= order.getId() %>" class="btn btn-primary" onclick="return confirm('Are you sure you want to cancel this order?')">Cancel Order</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Toggle sidebar on mobile
        const toggleSidebar = document.getElementById('toggleSidebar');
        const sidebar = document.getElementById('sidebar');

        toggleSidebar.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    </script>
</body>
</html>
