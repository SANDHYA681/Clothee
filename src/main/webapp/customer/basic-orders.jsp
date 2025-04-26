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
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

// Get orders from session
List<Order> orders = (List<Order>) session.getAttribute("userOrders");
if (orders == null) {
    orders = new ArrayList<>();
}

SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Orders</title>
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
        .btn-cancel {
            background-color: #f44336;
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
    </style>
</head>
<body>
    <div class="container">
        <h1>My Orders</h1>
        
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
            <a href="<%= request.getContextPath() %>/CartServlet?action=view">Cart</a>
        </div>
        
        <div class="filter-form">
            <form action="<%= request.getContextPath() %>/OrderServlet" method="get">
                <input type="hidden" name="action" value="viewOrders">
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
                <p>You don't have any orders yet.</p>
            </div>
        <% } else { %>
            <table>
                <tr>
                    <th>Order ID</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Total</th>
                    <th>Actions</th>
                </tr>
                <% for (Order order : orders) { %>
                    <tr>
                        <td><%= order.getId() %></td>
                        <td><%= dateFormat.format(order.getOrderDate()) %></td>
                        <td><%= order.getStatus() %></td>
                        <td>$<%= String.format("%.2f", order.getTotalPrice()) %></td>
                        <td>
                            <a href="<%= request.getContextPath() %>/OrderServlet?action=viewOrder&id=<%= order.getId() %>" class="btn btn-view">View</a>
                            <% if (order.getStatus().equals("Pending") || order.getStatus().equals("Processing")) { %>
                                <a href="<%= request.getContextPath() %>/OrderServlet?action=cancel&id=<%= order.getId() %>" class="btn btn-cancel" onclick="return confirm('Are you sure you want to cancel this order?')">Cancel</a>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
            </table>
        <% } %>
    </div>
</body>
</html>
