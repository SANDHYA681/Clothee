<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="java.text.SimpleDateFormat" %>

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

// Get orders from request attribute
List<Order> orders = (List<Order>) request.getAttribute("orders");
if (orders == null) {
    response.sendRedirect(request.getContextPath() + "/AdminOrderServlet?action=list");
    return;
}

SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin - Orders</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
        .btn {
            display: inline-block;
            padding: 5px 10px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 3px;
            margin-right: 5px;
        }
        .btn-view {
            background-color: #2196F3;
        }
        .btn-edit {
            background-color: #FFC107;
            color: black;
        }
        .empty-message {
            text-align: center;
            padding: 20px;
            color: #666;
        }
        .filter-form {
            margin-bottom: 20px;
        }
        .filter-form select {
            padding: 5px;
            margin-right: 10px;
        }
        .filter-form button {
            padding: 5px 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .nav-links {
            margin-bottom: 20px;
        }
        .nav-links a {
            margin-right: 15px;
            color: #2196F3;
            text-decoration: none;
        }
        .stats {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 20px;
        }
        .stat-box {
            flex: 1;
            min-width: 120px;
            padding: 10px;
            background-color: #f2f2f2;
            border-radius: 5px;
            text-align: center;
        }
        .stat-box h3 {
            margin: 0;
            font-size: 14px;
            color: #666;
        }
        .stat-box p {
            margin: 5px 0 0 0;
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Order Management</h1>
        
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard.jsp">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/products.jsp">Products</a>
            <a href="<%= request.getContextPath() %>/admin/categories.jsp">Categories</a>
            <a href="<%= request.getContextPath() %>/admin/customers.jsp">Customers</a>
        </div>
        
        <div class="stats">
            <div class="stat-box">
                <h3>Total Orders</h3>
                <p><%= orders.size() %></p>
            </div>
            <div class="stat-box">
                <h3>Pending</h3>
                <p><%= orders.stream().filter(o -> "Pending".equals(o.getStatus())).count() %></p>
            </div>
            <div class="stat-box">
                <h3>Processing</h3>
                <p><%= orders.stream().filter(o -> "Processing".equals(o.getStatus())).count() %></p>
            </div>
            <div class="stat-box">
                <h3>Shipped</h3>
                <p><%= orders.stream().filter(o -> "Shipped".equals(o.getStatus())).count() %></p>
            </div>
            <div class="stat-box">
                <h3>Delivered</h3>
                <p><%= orders.stream().filter(o -> "Delivered".equals(o.getStatus())).count() %></p>
            </div>
            <div class="stat-box">
                <h3>Cancelled</h3>
                <p><%= orders.stream().filter(o -> "Cancelled".equals(o.getStatus())).count() %></p>
            </div>
        </div>
        
        <div class="filter-form">
            <form action="<%= request.getContextPath() %>/AdminOrderServlet" method="get">
                <input type="hidden" name="action" value="list">
                <select name="status">
                    <option value="all">All Orders</option>
                    <option value="Pending">Pending</option>
                    <option value="Processing">Processing</option>
                    <option value="Shipped">Shipped</option>
                    <option value="Delivered">Delivered</option>
                    <option value="Cancelled">Cancelled</option>
                </select>
                <button type="submit">Filter</button>
            </form>
        </div>
        
        <% if (orders.isEmpty()) { %>
            <div class="empty-message">
                <p>No orders found.</p>
            </div>
        <% } else { %>
            <table>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Total</th>
                    <th>Actions</th>
                </tr>
                <% for (Order order : orders) { %>
                    <tr>
                        <td><%= order.getId() %></td>
                        <td>User #<%= order.getUserId() %></td>
                        <td><%= dateFormat.format(order.getOrderDate()) %></td>
                        <td><%= order.getStatus() %></td>
                        <td>$<%= String.format("%.2f", order.getTotalPrice()) %></td>
                        <td>
                            <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="btn btn-view">View</a>
                            <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=showUpdateForm&id=<%= order.getId() %>" class="btn btn-edit">Edit</a>
                        </td>
                    </tr>
                <% } %>
            </table>
        <% } %>
    </div>
</body>
</html>
