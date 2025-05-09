<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Payment" %>
<%@ page import="model.Order" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Details - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .payment-details {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
        }
        
        .payment-details h1 {
            margin-bottom: 20px;
            color: #333;
        }
        
        .payment-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .payment-card h2 {
            margin-top: 0;
            margin-bottom: 15px;
            color: #333;
            font-size: 18px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        
        .payment-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .payment-info-item {
            margin-bottom: 10px;
        }
        
        .payment-info-label {
            font-weight: 600;
            color: #555;
            margin-bottom: 5px;
            display: block;
        }
        
        .payment-info-value {
            color: #333;
        }
        
        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
        }
        
        .status-completed {
            background-color: #e6f7e6;
            color: #2e7d32;
        }
        
        .status-pending {
            background-color: #fff8e1;
            color: #ff8f00;
        }
        
        .status-failed {
            background-color: #ffebee;
            color: #c62828;
        }
        
        .action-buttons {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }
        
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 14px;
            border: none;
            cursor: pointer;
        }
        
        .btn-secondary {
            background-color: #757575;
        }
        
        .btn-verify {
            background-color: #FF9800;
        }
        
        @media (max-width: 768px) {
            .payment-info {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="payment-details">
        <h1>Payment Details</h1>
        
        <%-- Display success message if any --%>
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <%= session.getAttribute("successMessage") %>
                <% session.removeAttribute("successMessage"); %>
            </div>
        <% } %>
        
        <%-- Display error message if any --%>
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger">
                <%= session.getAttribute("errorMessage") %>
                <% session.removeAttribute("errorMessage"); %>
            </div>
        <% } %>
        
        <%
            Payment payment = (Payment) request.getAttribute("payment");
            Order order = (Order) request.getAttribute("order");
            
            if (payment == null) {
        %>
            <div class="alert alert-danger">Payment not found.</div>
            <a href="PaymentServlet?action=history" class="btn">Back to Payment History</a>
        <% } else {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            DecimalFormat decimalFormat = new DecimalFormat("#,##0.00");
        %>
            <div class="payment-card">
                <h2>Payment Information</h2>
                <div class="payment-info">
                    <div class="payment-info-item">
                        <span class="payment-info-label">Payment ID</span>
                        <span class="payment-info-value"><%= payment.getId() %></span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">Order ID</span>
                        <span class="payment-info-value"><%= payment.getOrderId() %></span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">Payment Date</span>
                        <span class="payment-info-value"><%= payment.getPaymentDate() != null ? dateFormat.format(payment.getPaymentDate()) : "N/A" %></span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">Payment Method</span>
                        <span class="payment-info-value"><%= payment.getPaymentMethod() %></span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">Amount</span>
                        <span class="payment-info-value">$<%= decimalFormat.format(payment.getAmount()) %></span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">Status</span>
                        <span class="status status-<%= payment.getStatus().toLowerCase() %>"><%= payment.getStatus() %></span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">Card Number</span>
                        <span class="payment-info-value"><%= payment.getCardNumber() != null ? payment.getCardNumber() : "N/A" %></span>
                    </div>
                    <div class="payment-info-item">
                        <span class="payment-info-label">Transaction ID</span>
                        <span class="payment-info-value"><%= payment.getTransactionId() != null ? payment.getTransactionId() : "N/A" %></span>
                    </div>
                </div>
            </div>
            
            <% if (order != null) { %>
                <div class="payment-card">
                    <h2>Order Information</h2>
                    <div class="payment-info">
                        <div class="payment-info-item">
                            <span class="payment-info-label">Order Date</span>
                            <span class="payment-info-value"><%= order.getOrderDate() != null ? dateFormat.format(order.getOrderDate()) : "N/A" %></span>
                        </div>
                        <div class="payment-info-item">
                            <span class="payment-info-label">Order Status</span>
                            <span class="payment-info-value"><%= order.getStatus() %></span>
                        </div>
                        <div class="payment-info-item">
                            <span class="payment-info-label">Total Amount</span>
                            <span class="payment-info-value">$<%= decimalFormat.format(order.getTotalAmount()) %></span>
                        </div>
                    </div>
                </div>
            <% } %>
            
            <div class="action-buttons">
                <a href="PaymentServlet?action=history" class="btn btn-secondary">Back to Payment History</a>
                <a href="OrderServlet?action=viewOrder&orderId=<%= payment.getOrderId() %>" class="btn">View Order</a>
                <% if (!"Completed".equals(payment.getStatus())) { %>
                    <a href="PaymentServlet?action=verify&paymentId=<%= payment.getId() %>" class="btn btn-verify">Verify Payment</a>
                <% } %>
            </div>
        <% } %>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
</body>
</html>
