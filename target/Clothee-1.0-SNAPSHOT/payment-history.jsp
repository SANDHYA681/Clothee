<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Payment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment History - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .payment-history {
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
        }
        
        .payment-history h1 {
            margin-bottom: 20px;
            color: #333;
        }
        
        .payment-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        .payment-table th, .payment-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        .payment-table th {
            background-color: #f8f8f8;
            font-weight: 600;
        }
        
        .payment-table tr:hover {
            background-color: #f5f5f5;
        }
        
        .status {
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
        
        .action-btn {
            display: inline-block;
            padding: 6px 12px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 14px;
            margin-right: 5px;
        }
        
        .action-btn.view {
            background-color: #2196F3;
        }
        
        .action-btn.verify {
            background-color: #FF9800;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 0;
        }
        
        .empty-state i {
            font-size: 48px;
            color: #ddd;
            margin-bottom: 15px;
        }
        
        .empty-state p {
            color: #777;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="payment-history">
        <h1>Payment History</h1>
        
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
            List<Payment> payments = (List<Payment>) request.getAttribute("payments");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            DecimalFormat decimalFormat = new DecimalFormat("#,##0.00");
            
            if (payments == null || payments.isEmpty()) {
        %>
            <div class="empty-state">
                <i class="fas fa-receipt"></i>
                <p>You don't have any payment history yet.</p>
            </div>
        <% } else { %>
            <table class="payment-table">
                <thead>
                    <tr>
                        <th>Payment ID</th>
                        <th>Order ID</th>
                        <th>Date</th>
                        <th>Method</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Payment payment : payments) { %>
                        <tr>
                            <td><%= payment.getId() %></td>
                            <td><%= payment.getOrderId() %></td>
                            <td><%= payment.getPaymentDate() != null ? dateFormat.format(payment.getPaymentDate()) : "N/A" %></td>
                            <td><%= payment.getPaymentMethod() %></td>
                            <td>$<%= decimalFormat.format(payment.getAmount()) %></td>
                            <td>
                                <span class="status status-<%= payment.getStatus().toLowerCase() %>">
                                    <%= payment.getStatus() %>
                                </span>
                            </td>
                            <td>
                                <a href="PaymentServlet?action=details&paymentId=<%= payment.getId() %>" class="action-btn view">View</a>
                                <% if (!"Completed".equals(payment.getStatus())) { %>
                                    <a href="PaymentServlet?action=verify&paymentId=<%= payment.getId() %>" class="action-btn verify">Verify</a>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
        
        <div>
            <a href="OrderServlet" class="btn">Back to Orders</a>
        </div>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
</body>
</html>
