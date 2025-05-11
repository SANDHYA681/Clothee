<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.OrderDAO" %>
<%@ page import="model.User" %>
<%@ page import="java.util.Date" %>

<%
    // Check if user is logged in and is an admin
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Initialize variables
    String message = null;
    int updatedOrders = 0;
    boolean success = false;

    // Check if the form was submitted
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            // Create OrderDAO and run the fix function
            OrderDAO orderDAO = new OrderDAO();
            updatedOrders = orderDAO.updatePaidPendingOrders();
            
            if (updatedOrders > 0) {
                message = "Successfully updated " + updatedOrders + " orders from 'Pending' to 'Processing' status.";
                success = true;
            } else {
                message = "No orders needed to be updated. All paid orders already have the correct status.";
                success = true;
            }
        } catch (Exception e) {
            message = "Error updating orders: " + e.getMessage();
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fix Order Status - Admin</title>
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <!-- Admin Dashboard CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-dashboard-layout.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-blue-theme-all.css">
    
    <style>
        .fix-orders-container {
            max-width: 800px;
            margin: 30px auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }
        
        .fix-orders-header {
            margin-bottom: 25px;
            text-align: center;
        }
        
        .fix-orders-header h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 10px;
        }
        
        .fix-orders-header p {
            color: #666;
            line-height: 1.5;
        }
        
        .alert {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }
        
        .alert i {
            margin-right: 10px;
            font-size: 18px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        
        .fix-orders-form {
            margin-top: 20px;
            text-align: center;
        }
        
        .btn-fix {
            background-color: #4361ee;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .btn-fix:hover {
            background-color: #3a56d4;
        }
        
        .btn-back {
            display: inline-block;
            margin-top: 20px;
            color: #4361ee;
            text-decoration: none;
        }
        
        .btn-back:hover {
            text-decoration: underline;
        }
        
        .explanation {
            margin-top: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 4px;
            border-left: 4px solid #4361ee;
        }
        
        .explanation h2 {
            font-size: 18px;
            margin-bottom: 10px;
            color: #333;
        }
        
        .explanation p {
            color: #666;
            line-height: 1.6;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="admin-dashboard">
        <!-- Include the admin sidebar -->
        <jsp:include page="includes/sidebar.jsp" />
        
        <div class="admin-content">
            <!-- Include the admin header -->
            <jsp:include page="includes/header.jsp" />
            
            <div class="fix-orders-container">
                <div class="fix-orders-header">
                    <h1>Fix Order Status Tool</h1>
                    <p>This tool updates all paid orders with "Pending" status to "Processing" status.</p>
                </div>
                
                <% if (message != null) { %>
                <div class="alert <%= success ? "alert-success" : "alert-danger" %>">
                    <i class="fas <%= success ? "fa-check-circle" : "fa-exclamation-circle" %>"></i>
                    <%= message %>
                </div>
                <% } %>
                
                <form action="fix-order-status.jsp" method="post" class="fix-orders-form">
                    <button type="submit" class="btn-fix">
                        <i class="fas fa-sync-alt"></i> Fix Order Status
                    </button>
                </form>
                
                <div class="explanation">
                    <h2>What This Tool Does</h2>
                    <p>When customers pay for orders using Credit Card or PayPal, the orders should automatically be marked as "Processing" instead of "Pending". However, due to a system issue, some paid orders may still show as "Pending" in the database.</p>
                    <p>This tool runs a database update to correct the status of all paid orders, changing them from "Pending" to "Processing" to accurately reflect their payment status.</p>
                    <p><strong>Note:</strong> This tool only needs to be run once to fix existing orders. Future orders should be correctly marked as "Processing" after payment.</p>
                </div>
                
                <div style="text-align: center; margin-top: 20px;">
                    <a href="<%=request.getContextPath()%>/admin/orders.jsp" class="btn-back">
                        <i class="fas fa-arrow-left"></i> Back to Orders
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
