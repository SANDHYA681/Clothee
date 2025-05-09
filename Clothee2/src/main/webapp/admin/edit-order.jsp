<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderItem" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>

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
User customer = (User) request.getAttribute("customer");

// If attributes are not set, redirect to AdminOrderServlet
if (order == null) {
    // Get order ID from request parameter
    String orderIdStr = request.getParameter("id");
    if (orderIdStr == null || orderIdStr.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=No+order+ID+provided");
        return;
    }

    try {
        // Instead of redirecting, forward to the servlet
        request.getRequestDispatcher("/AdminOrderServlet?action=showUpdateForm&id=" + orderIdStr).forward(request, response);
    } catch (Exception e) {
        // Log the error
        System.out.println("Error in edit-order.jsp: " + e.getMessage());
        e.printStackTrace();
        // Set error in session instead of URL parameter to avoid encoding issues
        session.setAttribute("errorMessage", "Error loading order: " + e.getMessage());
        response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
    }
    return;
}

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");

// Check if order is paid
boolean isPaid = false;
String paymentMethod = order != null ? order.getPaymentMethod() : null;
if (paymentMethod != null && (paymentMethod.equalsIgnoreCase("Credit Card") || paymentMethod.equalsIgnoreCase("PayPal"))) {
    isPaid = true;
}

// Get status options for dropdown - exclude Cancelled for paid orders
String[] statusOptions;
if (isPaid) {
    statusOptions = new String[]{"Processing", "Shipped", "Delivered"};
    System.out.println("Order is paid, removing Cancelled and Pending options");
} else {
    statusOptions = new String[]{"Pending", "Processing", "Shipped", "Delivered", "Cancelled"};
    System.out.println("Order is not paid, showing all status options");
}

// Check for messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");

// Clear messages after reading them
session.removeAttribute("successMessage");
session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Order - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="../css/admin-orders.css">
    <style>
        :root {
            --primary-color: #ff6b6b;
            --secondary-color: #ff8e8e;
            --dark-color: #2d3436;
            --light-color: #f9f9f9;
            --sidebar-width: 250px;
        }

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

        .form-container {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
        }

        .form-section {
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
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
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }

        .form-control:focus {
            border-color: var(--primary-color);
            outline: none;
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
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

        .action-buttons {
            display: flex;
            justify-content: flex-end;
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

        .btn-danger {
            background-color: #dc3545;
            color: white;
            border: none;
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

            .form-row {
                grid-template-columns: 1fr;
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
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Administrator</p>
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
                <h1 class="page-title">Edit Order #<%= order.getId() %></h1>
                <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back to Order Details
                </a>
            </div>

            <%
            // Check for URL parameters (different from session attributes)
            String successParam = request.getParameter("success");
            String errorParam = request.getParameter("error");

            // Display success message from either session or URL parameter
            if ((successMessage != null && !successMessage.isEmpty()) || (successParam != null && !successParam.isEmpty())) {
            %>
            <div class="alert alert-success">
                <%= successMessage != null && !successMessage.isEmpty() ? successMessage : successParam %>
            </div>
            <% } %>

            <% if ((errorMessage != null && !errorMessage.isEmpty()) || (errorParam != null && !errorParam.isEmpty())) { %>
            <div class="alert alert-danger">
                <%= errorMessage != null && !errorMessage.isEmpty() ? errorMessage : errorParam %>
            </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/AdminOrderServlet" method="post">
                <input type="hidden" name="action" value="updateOrder">
                <input type="hidden" name="orderId" value="<%= order.getId() %>">
                <!-- Add debug info to help troubleshoot -->
                <input type="hidden" name="debug" value="true">

                <div class="form-container">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i> As an administrator, you can only update the order status. Other order details cannot be modified.
                    </div>
                    <div class="form-section">
                        <h2 class="section-title">Order Information</h2>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="status" class="form-label">Status</label>
                                <select name="status" id="status" class="form-control">
                                    <% if (isPaid) { %>
                                    <!-- Note about paid orders -->
                                    <option value="" disabled>Paid orders cannot be cancelled</option>
                                    <% } %>
                                    <% for (String statusOption : statusOptions) { %>
                                        <option value="<%= statusOption %>" <%= order.getStatus().equals(statusOption) ? "selected" : "" %>><%= statusOption %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="orderDate" class="form-label">Order Date</label>
                                <input type="text" id="orderDate" class="form-control" value="<%= dateFormat.format(order.getOrderDate()) %>" readonly>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h2 class="section-title">Customer Information</h2>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="customerName" class="form-label">Customer Name</label>
                                <input type="text" id="customerName" class="form-control" value="<%= customer != null ? customer.getFirstName() + " " + customer.getLastName() : "Unknown" %>" readonly>
                            </div>
                            <div class="form-group">
                                <label for="customerEmail" class="form-label">Customer Email</label>
                                <input type="email" id="customerEmail" class="form-control" value="<%= customer != null ? customer.getEmail() : "Unknown" %>" readonly>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h2 class="section-title">Shipping Information</h2>
                        <div class="form-group">
                            <label for="shippingAddress" class="form-label">Shipping Address</label>
                            <textarea name="shippingAddress" id="shippingAddress" class="form-control" rows="3" readonly><%= order.getShippingAddress() != null ? order.getShippingAddress() : "" %></textarea>
                        </div>
                    </div>

                    <div class="form-section">
                        <h2 class="section-title">Payment Information</h2>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="paymentMethod" class="form-label">Payment Method</label>
                                <input type="text" name="paymentMethod" id="paymentMethod" class="form-control" value="<%= order.getPaymentMethod() != null ? order.getPaymentMethod() : "" %>" readonly>
                            </div>
                            <div class="form-group">
                                <label for="totalPrice" class="form-label">Total Price</label>
                                <input type="number" name="totalPrice" id="totalPrice" class="form-control" value="<%= order.getTotalPrice() %>" step="0.01" min="0" readonly>
                            </div>

                            <!-- Hidden fields to ensure all required data is submitted -->
                            <input type="hidden" name="userId" value="<%= order.getUserId() %>">
                            <% if (order.getOrderDate() != null) { %>
                            <input type="hidden" name="orderDate" value="<%= new java.sql.Timestamp(order.getOrderDate().getTime()) %>">
                            <% } %>
                        </div>
                    </div>

                    <div class="form-section">
                        <h2 class="section-title">Order Items</h2>
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
                                if (orderItems != null && !orderItems.isEmpty()) {
                                    for (OrderItem item : orderItems) {
                                        double itemTotal = item.getPrice() * item.getQuantity();
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
                        <p>Note: To modify order items, please cancel this order and create a new one.</p>
                    </div>

                    <div class="action-buttons">
                        <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
