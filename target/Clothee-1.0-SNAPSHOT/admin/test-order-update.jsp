<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="util.DBConnection" %>

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

// Get order ID and new status from request parameters
String orderIdStr = request.getParameter("orderId");
String newStatus = request.getParameter("newStatus");
boolean updatePerformed = false;
String updateResult = "";

// If order ID and new status are provided, update the order status directly in the database
if (orderIdStr != null && !orderIdStr.isEmpty() && newStatus != null && !newStatus.isEmpty()) {
    try {
        int orderId = Integer.parseInt(orderIdStr);
        
        // Update the order status directly in the database
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Update the order status
            String query = "UPDATE orders SET status = ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, newStatus);
                stmt.setInt(2, orderId);
                
                int rowsAffected = stmt.executeUpdate();
                updatePerformed = true;
                updateResult = "Order status update result: " + (rowsAffected > 0 ? "Success" : "Failed") + " (rows affected: " + rowsAffected + ")";
                
                if (rowsAffected > 0) {
                    // Also update the shipping status
                    String shippingQuery = "UPDATE shipping SET shipping_status = ? WHERE order_id = ?";
                    try (PreparedStatement shippingStmt = conn.prepareStatement(shippingQuery)) {
                        shippingStmt.setString(1, newStatus);
                        shippingStmt.setInt(2, orderId);
                        int shippingRowsAffected = shippingStmt.executeUpdate();
                        updateResult += "<br>Shipping status update result: " + (shippingRowsAffected > 0 ? "Success" : "No shipping record found") + " (rows affected: " + shippingRowsAffected + ")";
                    }
                    
                    conn.commit();
                } else {
                    conn.rollback();
                }
            }
        } catch (Exception e) {
            updateResult = "Error updating order status: " + e.getMessage();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    // Ignore
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception e) {
                    // Ignore
                }
            }
        }
    } catch (NumberFormatException e) {
        updateResult = "Invalid order ID: " + e.getMessage();
    }
}

// Get current order status from the database
String currentStatus = "Unknown";
if (orderIdStr != null && !orderIdStr.isEmpty()) {
    try {
        int orderId = Integer.parseInt(orderIdStr);
        
        // Get the current order status from the database
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT status FROM orders WHERE id = ?")) {
            stmt.setInt(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    currentStatus = rs.getString("status");
                } else {
                    currentStatus = "Order not found";
                }
            }
        } catch (Exception e) {
            currentStatus = "Error getting order status: " + e.getMessage();
        }
    } catch (NumberFormatException e) {
        currentStatus = "Invalid order ID: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Order Update</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <style>
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
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
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .btn {
            padding: 10px 20px;
            border-radius: 5px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }
        .btn-primary {
            background-color: #4361ee;
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
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        .alert-warning {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Test Order Update</h1>
        
        <div class="card">
            <h2>Current Order Status</h2>
            <p>Order ID: <%= orderIdStr != null ? orderIdStr : "Not specified" %></p>
            <p>Current Status: <%= currentStatus %></p>
        </div>
        
        <div class="card">
            <h2>Update Order Status</h2>
            <form action="<%= request.getContextPath() %>/admin/test-order-update.jsp" method="get">
                <div class="form-group">
                    <label for="orderId" class="form-label">Order ID</label>
                    <input type="text" id="orderId" name="orderId" class="form-control" value="<%= orderIdStr != null ? orderIdStr : "" %>" required>
                </div>
                <div class="form-group">
                    <label for="newStatus" class="form-label">New Status</label>
                    <select name="newStatus" id="newStatus" class="form-control" required>
                        <option value="">Select Status</option>
                        <option value="Pending">Pending</option>
                        <option value="Processing">Processing</option>
                        <option value="Shipped">Shipped</option>
                        <option value="Delivered">Delivered</option>
                        <option value="Cancelled">Cancelled</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Update Status</button>
            </form>
        </div>
        
        <% if (updatePerformed) { %>
        <div class="alert <%= updateResult.contains("Success") ? "alert-success" : "alert-danger" %>">
            <%= updateResult %>
        </div>
        <% } %>
        
        <div class="card">
            <h2>Instructions</h2>
            <p>This page allows you to test updating an order's status directly in the database. Follow these steps:</p>
            <ol>
                <li>Enter the Order ID of the order you want to update</li>
                <li>Select the new status from the dropdown</li>
                <li>Click "Update Status" to update the order status directly in the database</li>
                <li>Check the result message to see if the update was successful</li>
                <li>Refresh the page to see the updated status</li>
            </ol>
            <p>If the update is successful but the status doesn't change when viewing the order in the admin panel, there may be an issue with the admin panel's code.</p>
        </div>
        
        <div class="card">
            <h2>Links</h2>
            <p><a href="<%= request.getContextPath() %>/admin/orders.jsp">Back to Orders</a></p>
            <% if (orderIdStr != null && !orderIdStr.isEmpty()) { %>
            <p><a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= orderIdStr %>">View Order #<%= orderIdStr %></a></p>
            <% } %>
        </div>
    </div>
</body>
</html>
