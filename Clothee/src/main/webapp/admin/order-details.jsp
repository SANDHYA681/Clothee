<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderItem" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.UserDAO" %>

<%
// Check if user is logged in and is an admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User user = (User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get order from request attribute (set by AdminOrderServlet)
Order order = (Order) request.getAttribute("order");
List<OrderItem> orderItems = (List<OrderItem>) request.getAttribute("orderItems");
if (orderItems == null) {
    orderItems = new ArrayList<>();
    System.out.println("order-details.jsp: orderItems is null, using empty list");
}
User customer = (User) request.getAttribute("customer");
if (customer == null) {
    System.out.println("order-details.jsp: customer is null");
}
String customerName = (String) request.getAttribute("customerName");

// If attributes are not set, try to get the order directly from the database
if (order == null) {
    // Get order ID from request parameter
    String orderIdStr = request.getParameter("id");
    if (orderIdStr == null || orderIdStr.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=No+order+ID+provided");
        return;
    }

    try {
        int orderId = Integer.parseInt(orderIdStr);
        System.out.println("order-details.jsp: Getting order from database with ID: " + orderId);
        OrderDAO orderDAO = new OrderDAO();
        order = orderDAO.getOrderById(orderId);

        if (order == null) {
            System.out.println("order-details.jsp: Order not found in database");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Order+not+found");
            return;
        }
        System.out.println("order-details.jsp: Order found in database: " + order.getId());

        // Get order items if not already set
        if (orderItems == null || orderItems.isEmpty()) {
            try {
                System.out.println("order-details.jsp: Getting order items from database");
                orderItems = orderDAO.getOrderItemsByOrderId(orderId);
                if (orderItems == null) {
                    orderItems = new ArrayList<>();
                    System.out.println("order-details.jsp: orderItems is null after retrieval, using empty list");
                } else {
                    System.out.println("order-details.jsp: Retrieved " + orderItems.size() + " order items");
                }
            } catch (Exception e) {
                System.out.println("Error getting order items: " + e.getMessage());
                e.printStackTrace();
                orderItems = new ArrayList<>();
            }
        }

        // Get customer if not already set
        if (customer == null && order.getUserId() > 0) {
            System.out.println("order-details.jsp: Getting customer from database with ID: " + order.getUserId());
            UserDAO userDAO = new UserDAO();
            customer = userDAO.getUserById(order.getUserId());
            if (customer != null) {
                System.out.println("order-details.jsp: Customer found: " + customer.getFullName());
                customerName = customer.getFullName();
            } else {
                System.out.println("order-details.jsp: Customer not found");
                customerName = "Unknown Customer";
            }
        }
    } catch (NumberFormatException e) {
        System.out.println("Error parsing order ID: " + e.getMessage());
        response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Invalid+order+ID");
        return;
    } catch (Exception e) {
        System.out.println("Error getting order details: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Error+viewing+order");
        return;
    }
}

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");

// Check for messages from request attributes first (set by AdminOrderServlet)
String successMessage = (String) request.getAttribute("success");
String errorMessage = (String) request.getAttribute("error");

// If not found in request attributes, check session
if (successMessage == null) {
    successMessage = (String) session.getAttribute("successMessage");
    session.removeAttribute("successMessage");
}

if (errorMessage == null) {
    errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("errorMessage");
}

// Also check request parameters
if (successMessage == null) {
    successMessage = request.getParameter("success");
}

if (errorMessage == null) {
    errorMessage = request.getParameter("error");
}

System.out.println("order-details.jsp: Order ID: " + (order != null ? order.getId() : "null"));
System.out.println("order-details.jsp: Order Items: " + (orderItems != null ? orderItems.size() : "null"));
System.out.println("order-details.jsp: Customer: " + (customer != null ? customer.getFullName() : "null"));
System.out.println("order-details.jsp: Success Message: " + successMessage);
System.out.println("order-details.jsp: Error Message: " + errorMessage);

// Get status options for dropdown
String[] statusOptions = {"Pending", "Processing", "Shipped", "Delivered", "Cancelled"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Details - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-orders-blue.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-action-buttons.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-compact.css">

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
        }

        .user-name {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .user-role {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.7);
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            text-decoration: none;
            color: rgba(255, 255, 255, 0.7);
            transition: all 0.3s ease;
        }

        .menu-item:hover {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .menu-item.active {
            background-color: var(--primary-color);
            color: white;
        }

        .menu-icon {
            margin-right: 15px;
            width: 20px;
            text-align: center;
        }

        .main-content {
            flex: 1;
            margin-left: var(--sidebar-width);
            padding: 20px;
            transition: all 0.3s ease;
        }

        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .page-title {
            font-size: 24px;
            font-weight: 600;
        }

        .btn-back {
            display: inline-flex;
            align-items: center;
            padding: 8px 16px;
            background-color: var(--light-color);
            color: var(--dark-color);
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
        }

        .btn-back i {
            margin-right: 8px;
        }

        .order-details {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }

        .order-id {
            font-size: 20px;
            font-weight: 600;
        }

        .order-status {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
        }

        .status-pending {
            background-color: rgba(255, 165, 2, 0.1);
            color: #ffa502;
        }

        .status-processing {
            background-color: rgba(78, 205, 196, 0.1);
            color: #4ecdc4;
        }

        .status-shipped {
            background-color: rgba(74, 105, 189, 0.1);
            color: #4a69bd;
        }

        .status-delivered {
            background-color: rgba(46, 213, 115, 0.1);
            color: #2ed573;
        }

        .status-cancelled {
            background-color: rgba(255, 107, 107, 0.1);
            color: #ff6b6b;
        }

        .order-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .info-group {
            margin-bottom: 15px;
        }

        .info-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
        }

        .info-value {
            font-weight: 500;
        }

        .order-items {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
        }

        .items-table th, .items-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        .items-table th {
            font-weight: 500;
            color: #666;
            background-color: #f9f9f9;
        }

        .items-table tr:last-child td {
            border-bottom: none;
        }

        .product-info {
            display: flex;
            align-items: center;
        }

        .product-image {
            width: 50px;
            height: 50px;
            border-radius: 5px;
            margin-right: 10px;
            object-fit: cover;
        }

        .order-summary {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .summary-label {
            color: #666;
        }

        .summary-value {
            font-weight: 500;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #eee;
        }

        .total-label {
            font-size: 18px;
            font-weight: 600;
        }

        .total-value {
            font-size: 18px;
            font-weight: 600;
            color: var(--primary-color);
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 5px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
        }

        .btn-primary {
            background-color: var(--primary-color);
            color: white;
            border: none;
        }

        .btn-secondary {
            background-color: var(--light-color);
            color: var(--dark-color);
            border: none;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
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
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <div class="no-profile-image">
                                <i class="fas fa-user"></i>
                            </div>
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFullName() %></h3>
                    <p class="user-role">Admin</p>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/admin/products.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-box"></i></span>
                    Products
                </a>
                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tags"></i></span>
                    Categories
                </a>
                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="menu-item active">
                    <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-users"></i></span>
                    Customers
                </a>
                <a href="<%= request.getContextPath() %>/admin/reviews.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-star"></i></span>
                    Reviews
                </a>
                <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-envelope"></i></span>
                    Messages
                </a>
                <a href="<%= request.getContextPath() %>/admin/settings.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-cog"></i></span>
                    Settings
                </a>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="content-header">
                <h1 class="page-title">Order Details</h1>
                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back to Orders
                </a>
            </div>

            <%
            // Get success, error, and info messages from request parameters and session
            String successMessage = request.getParameter("success");
            String errorMessage = request.getParameter("error");
            String infoMessage = (String) session.getAttribute("infoMessage");

            // Clear session messages after displaying
            if (session.getAttribute("successMessage") != null) {
                successMessage = (String) session.getAttribute("successMessage");
                session.removeAttribute("successMessage");
            }

            if (session.getAttribute("errorMessage") != null) {
                errorMessage = (String) session.getAttribute("errorMessage");
                session.removeAttribute("errorMessage");
            }

            if (successMessage != null && !successMessage.isEmpty()) {
            %>
            <div class="alert alert-success">
                <%= successMessage %>
            </div>
            <% } %>

            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
            <% } %>

            <% if (infoMessage != null && !infoMessage.isEmpty()) { %>
            <div class="alert alert-info" style="background-color: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb;">
                <i class="fas fa-info-circle"></i> <%= infoMessage %>
            </div>
            <%
               // Clear the info message after displaying
               session.removeAttribute("infoMessage");
            } %>

            <% if (order.getStatus() != null && order.getStatus().equalsIgnoreCase("Delivered")) { %>
            <div class="alert alert-info" style="background-color: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb;">
                <i class="fas fa-info-circle"></i> This order has been delivered and cannot be edited.
            </div>
            <% } %>

            <div class="order-details">
                <div class="order-header">
                    <h2 class="order-id">Order #<%= order.getId() %></h2>
                    <div class="order-status status-<%= order.getStatus().toLowerCase() %>">
                        <%= order.getStatus() %>
                    </div>
                </div>

                <div class="order-info">
                    <div>
                        <div class="info-group">
                            <div class="info-label">Order Date</div>
                            <div class="info-value"><%= order.getOrderDate() != null ? dateFormat.format(order.getOrderDate()) : "Not available" %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Payment Method</div>
                            <div class="info-value"><%= order.getPaymentMethod() != null ? order.getPaymentMethod() : "Not specified" %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Payment Status</div>
                            <div class="info-value">
                                <%
                                // Determine payment status based on payment method
                                String paymentMethod = order.getPaymentMethod();
                                boolean isPaid = paymentMethod != null && (paymentMethod.equalsIgnoreCase("Credit Card") || paymentMethod.equalsIgnoreCase("PayPal"));
                                String paymentStatus = isPaid ? "Paid" : "Pending";
                                if (order.getStatus().equalsIgnoreCase("Cancelled")) {
                                    paymentStatus = "Cancelled";
                                }
                                %>
                                <span class="badge badge-<%= paymentStatus.toLowerCase() %>" style="padding: 5px 10px; border-radius: 4px; font-size: 12px; font-weight: 500; background-color: <%= isPaid ? "#4ecdc4" : "#ffa502" %>; color: white;"><%= paymentStatus %></span>
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="info-group">
                            <div class="info-label">Customer</div>
                            <div class="info-value">
                                <% if (customer != null) { %>
                                    <%= customer.getFirstName() + " " + customer.getLastName() %>
                                <% } else { %>
                                    Unknown
                                <% } %>
                            </div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Email</div>
                            <div class="info-value">
                                <% if (customer != null) { %>
                                    <%= customer.getEmail() %>
                                <% } else { %>
                                    Unknown
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="info-group">
                            <div class="info-label">Shipping Address</div>
                            <div class="info-value"><%= order.getShippingAddress() != null ? order.getShippingAddress() : "Not specified" %></div>
                        </div>
                    </div>
                </div>

                <form action="<%= request.getContextPath() %>/AdminOrderServlet" method="post">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" name="id" value="<%= order.getId() %>">
                    <!-- Add orderId parameter for backward compatibility -->
                    <input type="hidden" name="orderId" value="<%= order.getId() %>">

                    <div class="form-group">
                        <label for="status" class="form-label">Update Status</label>
                        <select name="status" id="status" class="form-control">
                            <% for (String statusOption : statusOptions) { %>
                                <option value="<%= statusOption %>" <%= order.getStatus() != null && order.getStatus().equals(statusOption) ? "selected" : "" %>><%= statusOption %></option>
                            <% } %>
                        </select>
                    </div>

                    <%
                    // Check if order has been paid
                    boolean isPaid = false;
                    String paymentMethod = order.getPaymentMethod();
                    if (paymentMethod != null && (paymentMethod.equalsIgnoreCase("Credit Card") || paymentMethod.equalsIgnoreCase("PayPal"))) {
                        isPaid = true;
                    }
                    %>
                    <div class="action-buttons">
                        <% if (!order.getStatus().equalsIgnoreCase("Delivered")) { %>
                        <button type="submit" class="btn btn-primary">Update Status</button>
                        <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=showUpdateForm&id=<%= order.getId() %>" class="btn btn-secondary">Edit Order</a>
                        <% if (!isPaid) { %>
                        <a href="#" onclick="confirmDelete(<%= order.getId() %>)" class="btn btn-danger">Delete Order</a>
                        <% } else { %>
                        <span class="payment-info"><i class="fas fa-info-circle"></i> Cannot delete paid orders</span>
                        <% } %>
                        <% } else { %>
                        <span class="payment-info" style="display: block; margin-bottom: 10px;"><i class="fas fa-check-circle"></i> This order has been delivered and cannot be modified.</span>
                        <% } %>
                    </div>
                </form>
            </div>

            <div class="order-items">
                <h2>Order Items</h2>
                <table class="items-table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        double subtotal = 0;
                        // Try to get order items from the order object if the orderItems list is empty
                        if (orderItems == null || orderItems.isEmpty()) {
                            if (order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
                                orderItems = order.getOrderItems();
                                System.out.println("Using order items from order object: " + orderItems.size());
                            }
                        }

                        if (orderItems != null && !orderItems.isEmpty()) {
                            for (OrderItem item : orderItems) {
                                double itemTotal = item.getPrice() * item.getQuantity();
                                subtotal += itemTotal;
                        %>
                        <tr>
                            <td>
                                <div class="product-info">
                                    <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                                        <img src="../<%= item.getImageUrl() %>" alt="<%= item.getProductName() %>" class="product-image">
                                    <% } else { %>
                                        <div class="product-image" style="background-color: #f5f5f5; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-image" style="color: #ccc;"></i>
                                        </div>
                                    <% } %>
                                    <div><%= item.getProductName() %></div>
                                </div>
                            </td>
                            <td><%= currencyFormat.format(item.getPrice()) %></td>
                            <td><%= item.getQuantity() %></td>
                            <td><%= currencyFormat.format(itemTotal) %></td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="4" style="text-align: center;">No items found for this order</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="order-summary">
                <h2>Order Summary</h2>
                <div class="summary-row">
                    <div class="summary-label">Subtotal</div>
                    <div class="summary-value"><%= currencyFormat.format(subtotal) %></div>
                </div>
                <div class="summary-row">
                    <div class="summary-label">Shipping</div>
                    <div class="summary-value">$0.00</div>
                </div>
                <div class="summary-row">
                    <div class="summary-label">Tax</div>
                    <div class="summary-value"><%= currencyFormat.format(subtotal * 0.1) %></div>
                </div>
                <div class="total-row">
                    <div class="total-label">Total</div>
                    <div class="total-value"><%= currencyFormat.format(order.getTotalPrice()) %></div>
                </div>
            </div>
        </div>
    </div>
    <script>
        // Function to confirm order deletion
        function confirmDelete(orderId) {
            if (confirm("Are you sure you want to delete this order? This action cannot be undone.")) {
                window.location.href = "<%= request.getContextPath() %>/AdminOrderServlet?action=delete&id=" + orderId;
            }
        }
    </script>
</body>
</html>
