<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
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

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
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
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #ddd;
        }
        
        .page-title {
            font-size: 24px;
            color: #333;
        }
        
        .filter-form {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .filter-title {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .filter-row {
            display: flex;
            gap: 10px;
        }
        
        .filter-select {
            flex: 1;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .filter-button {
            padding: 8px 16px;
            background-color: #4a6bdf;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            background-color: #fff;
            border-radius: 5px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .orders-table th,
        .orders-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        .orders-table th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .pending {
            background-color: #ffc107;
            color: #333;
        }
        
        .processing {
            background-color: #17a2b8;
            color: white;
        }
        
        .shipped {
            background-color: #6f42c1;
            color: white;
        }
        
        .delivered {
            background-color: #28a745;
            color: white;
        }
        
        .cancelled {
            background-color: #dc3545;
            color: white;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn-view {
            padding: 4px 8px;
            background-color: #17a2b8;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            font-size: 12px;
        }
        
        .btn-cancel {
            padding: 4px 8px;
            background-color: #dc3545;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            font-size: 12px;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .empty-state p {
            margin-bottom: 20px;
            color: #6c757d;
        }
        
        .btn-primary {
            padding: 8px 16px;
            background-color: #4a6bdf;
            color: white;
            border: none;
            border-radius: 4px;
            text-decoration: none;
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
        
        .nav-links {
            margin-bottom: 20px;
        }
        
        .nav-link {
            display: inline-block;
            margin-right: 10px;
            color: #4a6bdf;
            text-decoration: none;
        }
        
        .nav-link:hover {
            text-decoration: underline;
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
        
        <div class="filter-form">
            <div class="filter-title">Filter Orders</div>
            <form action="<%=request.getContextPath()%>/OrderServlet" method="get">
                <input type="hidden" name="action" value="viewOrders">
                <div class="filter-row">
                    <select name="status" class="filter-select">
                        <option value="all" <%= "all".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>All Orders</option>
                        <option value="Pending" <%= "Pending".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Pending</option>
                        <option value="Processing" <%= "Processing".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Processing</option>
                        <option value="Shipped" <%= "Shipped".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Shipped</option>
                        <option value="Delivered" <%= "Delivered".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Delivered</option>
                        <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Cancelled</option>
                    </select>
                    <button type="submit" class="filter-button">Filter</button>
                </div>
            </form>
        </div>

        <% if (orders.isEmpty()) { %>
            <div class="empty-state">
                <p>You haven't placed any orders yet.</p>
                <a href="<%=request.getContextPath()%>/ProductServlet" class="btn-primary">Shop Now</a>
            </div>
        <% } else { %>
            <table class="orders-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Total</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Order order : orders) { %>
                    <tr>
                        <td>#ORD-<%= order.getId() %></td>
                        <td><%= dateFormat.format(order.getOrderDate()) %></td>
                        <td>
                            <span class="badge <%= order.getStatus().toLowerCase() %>">
                                <%= order.getStatus() %>
                            </span>
                        </td>
                        <td>$<%= String.format("%.2f", order.getTotalPrice()) %></td>
                        <td>
                            <div class="action-buttons">
                                <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrder&id=<%= order.getId() %>" class="btn-view">View Details</a>
                                <% if (order.getStatus().equalsIgnoreCase("Processing") || order.getStatus().equalsIgnoreCase("Pending")) { %>
                                <a href="<%=request.getContextPath()%>/OrderServlet?action=cancel&id=<%= order.getId() %>" class="btn-cancel" onclick="return confirm('Are you sure you want to cancel this order?')">Cancel</a>
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
