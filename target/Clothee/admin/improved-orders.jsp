<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
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

// Get orders from request attribute (set by AdminOrderServlet)
List<Order> orders = (List<Order>) request.getAttribute("orders");
if (orders == null) {
    // If orders is null, redirect to AdminOrderServlet to get the orders
    response.sendRedirect(request.getContextPath() + "/AdminOrderServlet?action=list");
    return;
}

// Get order statistics from request attributes
Integer totalOrders = (Integer) request.getAttribute("totalOrders");
Integer pendingOrders = (Integer) request.getAttribute("pendingOrders");
Integer processingOrders = (Integer) request.getAttribute("processingOrders");
Integer shippedOrders = (Integer) request.getAttribute("shippedOrders");
Integer deliveredOrders = (Integer) request.getAttribute("deliveredOrders");
Integer cancelledOrders = (Integer) request.getAttribute("cancelledOrders");

// Set default values if attributes are not set
if (totalOrders == null) totalOrders = orders.size();
if (pendingOrders == null) pendingOrders = 0;
if (processingOrders == null) processingOrders = 0;
if (shippedOrders == null) shippedOrders = 0;
if (deliveredOrders == null) deliveredOrders = 0;
if (cancelledOrders == null) cancelledOrders = 0;

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");

// Check for messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");
String message = request.getParameter("message");
String error = request.getParameter("error");

// Get current filter
String statusFilter = request.getParameter("status");
if (statusFilter == null) {
    statusFilter = "all";
}

// Clear messages after reading them
session.removeAttribute("successMessage");
session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Orders</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }

        body {
            background-color: #f5f5f5;
            color: #333;
            line-height: 1.6;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }

        .page-title {
            font-size: 24px;
            color: #333;
        }

        .nav-links {
            display: flex;
            gap: 15px;
        }

        .nav-link {
            color: #4a6bdf;
            text-decoration: none;
            padding: 5px 10px;
            border-radius: 4px;
        }

        .nav-link:hover {
            background-color: #f0f0f0;
        }

        .filter-section {
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 18px;
            margin-bottom: 15px;
            color: #333;
            font-weight: bold;
        }

        .filter-form {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .form-group {
            flex: 1;
        }

        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
        }

        .btn-primary {
            background-color: #4a6bdf;
            color: white;
        }

        .stats-section {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 20px;
        }

        .stat-card {
            flex: 1;
            min-width: 150px;
            background-color: #fff;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            text-align: center;
            border-left: 4px solid #4a6bdf;
        }

        .stat-title {
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
        }

        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }

        .stat-pending {
            border-left-color: #ffc107;
        }

        .stat-processing {
            border-left-color: #17a2b8;
        }

        .stat-shipped {
            border-left-color: #6f42c1;
        }

        .stat-delivered {
            border-left-color: #28a745;
        }

        .stat-cancelled {
            border-left-color: #dc3545;
        }

        .orders-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .orders-table th,
        .orders-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        .orders-table th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
        }

        .orders-table tbody tr:hover {
            background-color: #f9f9f9;
        }

        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }

        .badge-pending {
            background-color: #ffc107;
            color: #333;
        }

        .badge-processing {
            background-color: #17a2b8;
            color: white;
        }

        .badge-shipped {
            background-color: #6f42c1;
            color: white;
        }

        .badge-delivered {
            background-color: #28a745;
            color: white;
        }

        .badge-cancelled {
            background-color: #dc3545;
            color: white;
        }

        .badge-paid {
            background-color: #28a745;
            color: white;
        }

        .action-buttons {
            display: flex;
            gap: 5px;
        }

        .action-btn {
            padding: 5px 10px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 12px;
            color: white;
        }

        .btn-view {
            background-color: #17a2b8;
        }

        .btn-edit {
            background-color: #ffc107;
            color: #333;
        }

        .alert {
            padding: 12px 15px;
            border-radius: 4px;
            margin-bottom: 20px;
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

        .empty-state {
            text-align: center;
            padding: 40px;
            color: #6c757d;
        }

        .customer-link {
            color: #4a6bdf;
            text-decoration: none;
        }

        .customer-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 class="page-title">Order Management</h1>
            <div class="nav-links">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="<%= request.getContextPath() %>/admin/products.jsp" class="nav-link">Products</a>
                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="nav-link">Categories</a>
                <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="nav-link">Customers</a>
                <a href="<%= request.getContextPath() %>/index.jsp" class="nav-link">View Store</a>
            </div>
        </div>

        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger"><%= errorMessage %></div>
        <% } %>

        <% if (message != null && !message.isEmpty()) { %>
            <div class="alert alert-success"><%= message %></div>
        <% } %>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger"><%= error %></div>
        <% } %>

        <div class="filter-section">
            <h2 class="section-title">Filter Orders</h2>
            <form action="<%= request.getContextPath() %>/AdminOrderServlet" method="get" class="filter-form">
                <input type="hidden" name="action" value="list">
                <div class="form-group">
                    <select name="status" class="form-control">
                        <option value="all" <%= "all".equals(statusFilter) ? "selected" : "" %>>All Statuses</option>
                        <option value="Pending" <%= "Pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                        <option value="Processing" <%= "Processing".equals(statusFilter) ? "selected" : "" %>>Processing</option>
                        <option value="Shipped" <%= "Shipped".equals(statusFilter) ? "selected" : "" %>>Shipped</option>
                        <option value="Delivered" <%= "Delivered".equals(statusFilter) ? "selected" : "" %>>Delivered</option>
                        <option value="Cancelled" <%= "Cancelled".equals(statusFilter) ? "selected" : "" %>>Cancelled</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Filter</button>
            </form>
        </div>

        <div class="stats-section">
            <div class="stat-card">
                <div class="stat-title">Total Orders</div>
                <div class="stat-value"><%= totalOrders %></div>
            </div>
            <div class="stat-card stat-pending">
                <div class="stat-title">Pending</div>
                <div class="stat-value"><%= pendingOrders %></div>
            </div>
            <div class="stat-card stat-processing">
                <div class="stat-title">Processing</div>
                <div class="stat-value"><%= processingOrders %></div>
            </div>
            <div class="stat-card stat-shipped">
                <div class="stat-title">Shipped</div>
                <div class="stat-value"><%= shippedOrders %></div>
            </div>
            <div class="stat-card stat-delivered">
                <div class="stat-title">Delivered</div>
                <div class="stat-value"><%= deliveredOrders %></div>
            </div>
            <div class="stat-card stat-cancelled">
                <div class="stat-title">Cancelled</div>
                <div class="stat-value"><%= cancelledOrders %></div>
            </div>
        </div>

        <% if (orders.isEmpty()) { %>
            <div class="empty-state">
                <p>No orders found matching your criteria.</p>
            </div>
        <% } else { %>
            <table class="orders-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Customer</th>
                        <th>Date</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Payment</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Order order : orders) { %>
                        <tr>
                            <td>#<%= order.getId() %></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/AdminUserServlet?action=view&id=<%= order.getUserId() %>" class="customer-link">
                                    Customer #<%= order.getUserId() %>
                                </a>
                            </td>
                            <td><%= dateFormat.format(order.getOrderDate()) %></td>
                            <td><%= currencyFormat.format(order.getTotalPrice()) %></td>
                            <td>
                                <%
                                    String statusClass = "badge-pending";
                                    if (order.getStatus().equalsIgnoreCase("Processing")) {
                                        statusClass = "badge-processing";
                                    } else if (order.getStatus().equalsIgnoreCase("Shipped")) {
                                        statusClass = "badge-shipped";
                                    } else if (order.getStatus().equalsIgnoreCase("Delivered")) {
                                        statusClass = "badge-delivered";
                                    } else if (order.getStatus().equalsIgnoreCase("Cancelled")) {
                                        statusClass = "badge-cancelled";
                                    }
                                %>
                                <span class="badge <%= statusClass %>"><%= order.getStatus() %></span>
                            </td>
                            <td>
                                <%
                                    String paymentStatus = order.getPaymentStatus();
                                    if (paymentStatus == null) {
                                        paymentStatus = "Pending";
                                    }
                                %>
                                <span class="badge <%= paymentStatus.equalsIgnoreCase("Paid") || paymentStatus.equalsIgnoreCase("Completed") ? "badge-paid" : "badge-pending" %>">
                                    <%= paymentStatus.equalsIgnoreCase("Completed") ? "Paid" : paymentStatus %>
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="action-btn btn-view">View</a>
                                    <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=showUpdateForm&id=<%= order.getId() %>" class="action-btn btn-edit">Update</a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</body>
</html>
