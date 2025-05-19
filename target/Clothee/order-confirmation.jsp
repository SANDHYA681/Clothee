<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Order" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="includes/header.jsp" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get order from request
    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
        return;
    }

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy");
    String orderDate = dateFormat.format(order.getOrderDate());

    // Get order message if any
    String orderMessage = (String) session.getAttribute("orderMessage");
    if (orderMessage != null) {
        session.removeAttribute("orderMessage");
    }
%>

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80')">
    <div class="page-header-content">
        <h1 class="page-title">ORDER CONFIRMATION</h1>
        <p class="page-subtitle">Thank you for your purchase!</p>
    </div>
</div>

<section class="confirmation-section">
    <div class="container">
        <% if (orderMessage != null) { %>
        <div class="alert alert-success">
            <%= orderMessage %>
        </div>
        <% } %>

        <div class="confirmation-content">
            <div class="confirmation-header">
                <i class="fas fa-check-circle"></i>
                <h2>Your Order Has Been Placed!</h2>
                <p>Thank you for shopping with us. We'll send you a confirmation email shortly.</p>
            </div>

            <div class="order-details">
                <div class="order-info">
                    <h3>Order Information</h3>

                    <div class="info-item">
                        <span class="info-label">Order Number:</span>
                        <span class="info-value">#<%= order.getId() %></span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Order Date:</span>
                        <span class="info-value"><%= orderDate %></span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Order Status:</span>
                        <span class="info-value status-<%= order.getStatus().toLowerCase() %>"><%= order.getStatus() %></span>
                    </div>



                    <div class="info-item">
                        <span class="info-label">Payment Status:</span>
                        <span class="info-value status-completed">Completed</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Shipping Status:</span>
                        <span class="info-value status-processing">Processing</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Shipping Address:</span>
                        <span class="info-value"><%= request.getAttribute("shippingAddress") != null ? (String)request.getAttribute("shippingAddress") : "Not specified" %></span>
                    </div>
                </div>

                <div class="order-summary">
                    <h3>Order Summary</h3>

                    <div class="summary-item">
                        <span class="summary-label">Subtotal:</span>
                        <span class="summary-value">$<%= String.format("%.2f", request.getAttribute("orderSubtotal") != null ? (Double)request.getAttribute("orderSubtotal") : order.getTotalAmount() * 0.93) %></span>
                    </div>

                    <div class="summary-item">
                        <span class="summary-label">Shipping:</span>
                        <span class="summary-value">$<%= String.format("%.2f", request.getAttribute("orderShipping") != null ? (Double)request.getAttribute("orderShipping") : (order.getTotalAmount() > 50 ? 0.00 : 5.99)) %></span>
                    </div>

                    <div class="summary-item">
                        <span class="summary-label">Tax:</span>
                        <span class="summary-value">$<%= String.format("%.2f", request.getAttribute("orderTax") != null ? (Double)request.getAttribute("orderTax") : order.getTotalAmount() * 0.07) %></span>
                    </div>

                    <div class="summary-total">
                        <span class="summary-label">Total:</span>
                        <span class="summary-value">$<%= String.format("%.2f", request.getAttribute("orderTotal") != null ? (Double)request.getAttribute("orderTotal") : order.getTotalAmount()) %></span>
                    </div>
                </div>
            </div>

            <div class="confirmation-actions">
                <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders" class="btn btn-primary">View My Orders</a>
                <a href="<%=request.getContextPath()%>/ProductServlet" class="btn btn-outline">Continue Shopping</a>
            </div>
        </div>
    </div>
</section>

<link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/order-page.css">
<style>
/* Order Confirmation Page Styles */
.confirmation-section {
    padding: 60px 0;
}

.confirmation-content {
    max-width: 800px;
    margin: 0 auto;
}

.confirmation-header {
    text-align: center;
    margin-bottom: 40px;
}

.confirmation-header i {
    font-size: 64px;
    color: var(--primary-color);
    margin-bottom: 20px;
}

.confirmation-header h2 {
    font-size: 28px;
    margin-bottom: 10px;
    color: var(--text-color);
}

.confirmation-header p {
    color: var(--text-light);
}

.order-details {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
    margin-bottom: 40px;
}

.order-info, .order-summary {
    flex: 1;
    min-width: 300px;
    padding: 30px;
    background-color: var(--background-color);
    border-radius: var(--border-radius-md);
    box-shadow: var(--shadow-md);
}

.order-info h3, .order-summary h3 {
    font-size: 20px;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid var(--border-color);
    color: var(--text-color);
}

.info-item {
    margin-bottom: 15px;
}

.info-label {
    font-weight: 600;
    color: var(--text-light);
    display: block;
    margin-bottom: 5px;
}

.info-value {
    color: var(--text-color);
}

.status-pending {
    color: var(--warning-color);
}

.status-processing {
    color: var(--primary-color);
}

.status-shipped {
    color: var(--info-color);
}

.status-delivered {
    color: var(--success-color);
}

.status-cancelled {
    color: var(--danger-color);
}

.summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    color: var(--text-light);
}

.summary-total {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid var(--border-color);
    font-size: 18px;
    font-weight: 600;
    color: var(--text-color);
}

.confirmation-actions {
    display: flex;
    justify-content: center;
    gap: 20px;
}

.btn {
    padding: 12px 20px;
    border-radius: var(--border-radius-sm);
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition);
    text-decoration: none;
    display: inline-block;
}

.btn-primary {
    background-color: var(--primary-color);
    color: white;
    border: none;
}

.btn-primary:hover {
    background-color: var(--primary-dark);
    transform: translateY(-3px);
    box-shadow: var(--shadow-md);
}

.btn-outline {
    background-color: transparent;
    color: var(--primary-color);
    border: 1px solid var(--primary-color);
}

.btn-outline:hover {
    background-color: var(--primary-color);
    color: white;
}

.alert {
    padding: 15px;
    margin-bottom: 20px;
    border-radius: var(--border-radius-sm);
}

.alert-success {
    background-color: rgba(255, 136, 0, 0.1);
    color: var(--primary-color);
    border: 1px solid rgba(255, 136, 0, 0.3);
}

@media (max-width: 768px) {
    .confirmation-actions {
        flex-direction: column;
    }

    .btn {
        width: 100%;
        text-align: center;
        margin-bottom: 10px;
    }
}
</style>

<%@ include file="includes/footer.jsp" %>
