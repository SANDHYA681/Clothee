<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        return;
    }

    // Get orders for this user
    List<Order> orders = new ArrayList<>();
    // Get orders from the session (set by OrderServlet)
    Object ordersObj = session.getAttribute("userOrders");
    if (ordersObj != null) {
        orders = (List<Order>) ordersObj;
    }

    // Get pagination info
    int currentPage = 1;
    Object currentPageObj = session.getAttribute("currentPage");
    if (currentPageObj != null) {
        currentPage = (Integer) currentPageObj;
    }

    int totalPages = 1;
    Object totalPagesObj = session.getAttribute("totalPages");
    if (totalPagesObj != null) {
        totalPages = (Integer) totalPagesObj;
    }

    // Get status filter
    String statusFilter = (String) session.getAttribute("statusFilter");
    if (statusFilter == null) {
        statusFilter = "all";
    }
    System.out.println("JSP - Status filter: " + statusFilter);

    // Format date and currency
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");

    // Get messages
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");

    // Clear messages after reading
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders - CLOTHEE</title>
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
            max-width: 1000px;
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

        .btn-cancel {
            background-color: #dc3545;
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

        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }

        .page-link {
            padding: 8px 12px;
            margin: 0 5px;
            background-color: #fff;
            color: #4a6bdf;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-decoration: none;
        }

        .page-link.active {
            background-color: #4a6bdf;
            color: white;
            border-color: #4a6bdf;
        }

        .page-link.disabled {
            color: #6c757d;
            pointer-events: none;
            cursor: default;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 class="page-title">My Orders</h1>
            <div class="nav-links">
                <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="nav-link">Cart</a>
                <a href="<%=request.getContextPath()%>/index.jsp" class="nav-link">Back to Shop</a>
            </div>
        </div>

        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success"><%= successMessage %></div>
        <% } %>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger"><%= errorMessage %></div>
        <% } %>

        <div class="filter-section">
            <h2 class="section-title">Filter Orders</h2>
            <form action="<%=request.getContextPath()%>/OrderServlet" method="get" class="filter-form">
                <input type="hidden" name="action" value="viewOrders">
                <div class="form-group">
                    <select name="status" class="form-control">
                        <option value="all" <%= "all".equals(statusFilter) ? "selected" : "" %>>All Orders</option>
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

        <% if (orders.isEmpty()) { %>
            <div class="empty-state">
                <p>You haven't placed any orders yet.</p>
                <a href="<%=request.getContextPath()%>/ProductServlet" class="btn btn-primary">Shop Now</a>
            </div>
        <% } else { %>
            <table class="orders-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Payment</th>
                        <th>Total</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Order order : orders) { %>
                    <tr>
                        <td>#<%= order.getId() %></td>
                        <td><%= dateFormat.format(order.getOrderDate()) %></td>
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
                                boolean isPaid = paymentStatus.equalsIgnoreCase("Paid") || paymentStatus.equalsIgnoreCase("Completed");
                            %>
                            <span class="badge <%= isPaid ? "badge-paid" : "badge-pending" %>">
                                <%= isPaid ? "Paid" : paymentStatus %>
                            </span>
                        </td>
                        <td><%= currencyFormat.format(order.getTotalPrice()) %></td>
                        <td>
                            <div class="action-buttons">
                                <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrder&id=<%= order.getId() %>" class="action-btn btn-view">View Details</a>
                                <%
                                // Only show cancel button if:
                                // 1. Order is in Pending or Processing status
                                // 2. Payment is NOT completed/paid
                                String paymentStatus = order.getPaymentStatus();
                                boolean isPaid = paymentStatus != null &&
                                                (paymentStatus.equalsIgnoreCase("Paid") ||
                                                 paymentStatus.equalsIgnoreCase("Completed"));

                                boolean canCancel = (order.getStatus().equalsIgnoreCase("Pending") ||
                                                    order.getStatus().equalsIgnoreCase("Processing")) &&
                                                    !isPaid;

                                if (canCancel) {
                                %>
                                <a href="<%=request.getContextPath()%>/OrderServlet?action=cancel&id=<%= order.getId() %>"
                                   class="action-btn btn-cancel"
                                   onclick="return confirm('Are you sure you want to cancel this order?')">Cancel</a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <% if (totalPages > 1) { %>
            <div class="pagination">
                <% if (currentPage > 1) { %>
                    <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders&page=<%= currentPage - 1 %>&status=<%= statusFilter %>" class="page-link">Previous</a>
                <% } else { %>
                    <span class="page-link disabled">Previous</span>
                <% } %>

                <% for (int i = 1; i <= totalPages; i++) { %>
                    <% if (i == currentPage) { %>
                        <span class="page-link active"><%= i %></span>
                    <% } else { %>
                        <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders&page=<%= i %>&status=<%= statusFilter %>" class="page-link"><%= i %></a>
                    <% } %>
                <% } %>

                <% if (currentPage < totalPages) { %>
                    <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders&page=<%= currentPage + 1 %>&status=<%= statusFilter %>" class="page-link">Next</a>
                <% } else { %>
                    <span class="page-link disabled">Next</span>
                <% } %>
            </div>
            <% } %>
        <% } %>
    </div>
</body>
</html>
