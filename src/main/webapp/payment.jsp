<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Order" %>
<%@ page import="model.User" %>
<%@ page import="model.OrderItem" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.Cart" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // Get user from session
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get order from request or calculate from cart items
    Order order = (Order) request.getAttribute("order");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");

    double subtotal = 0.0;
    double shipping = 0.0;
    double tax = 0.0;
    double total = 0.0;

    if (order == null && cartItems == null) {
        response.sendRedirect("CartServlet?action=view");
        return;
    }

    if (cartItems != null) {
        // Calculate from cart items
        subtotal = (Double) request.getAttribute("subtotal");
        shipping = (Double) request.getAttribute("shipping");
        tax = (Double) request.getAttribute("tax");
        total = (Double) request.getAttribute("total");
    } else {
        // Use order total
        total = order.getTotalPrice();
        // Estimate subtotal, shipping and tax
        subtotal = total * 0.85; // Approximate
        tax = total * 0.1;
        shipping = total - subtotal - tax;
    }

    // Format currency
    DecimalFormat df = new DecimalFormat("0.00");

    // Get error message if any
    String errorMessage = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment - CLOTHEE</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/payment.css">
    <style>
        .payment-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }

        .payment-header {
            margin-bottom: 20px;
        }

        .payment-header h1 {
            color: #333;
            font-size: 24px;
            margin-bottom: 10px;
        }

        .payment-summary {
            background-color: #f9f9f9;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
        }

        .payment-summary h2 {
            color: #333;
            font-size: 18px;
            margin-bottom: 10px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .summary-row.total {
            font-weight: bold;
            border-top: 1px solid #ddd;
            padding-top: 10px;
            margin-top: 10px;
        }

        .payment-form {
            background-color: #fff;
            border-radius: 5px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .payment-form h2 {
            color: #333;
            font-size: 18px;
            margin-bottom: 15px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .card-details {
            display: flex;
            gap: 15px;
        }

        .card-details .form-group {
            flex: 1;
        }

        .btn-pay {
            background-color: #ff6600;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            width: 100%;
            margin-top: 10px;
        }

        .btn-pay:hover {
            background-color: #e55c00;
        }

        .error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }

        .payment-methods {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
        }

        .payment-method {
            flex: 1;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            text-align: center;
            cursor: pointer;
        }

        .payment-method.selected {
            border-color: #ff6600;
            background-color: #fff8f3;
        }

        .payment-method img {
            height: 30px;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>

    <div class="container">
        <div class="payment-container">
            <div class="payment-header">
                <h1>Payment</h1>
                <p>Complete your payment to place your order. Your card will be charged $<%= df.format(total) %> upon completion.</p>
            </div>

            <% if (errorMessage != null) { %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
            <% } %>

            <div class="payment-summary">
                <h2>Order Summary</h2>
                <% if (order != null) { %>
                <div class="summary-row">
                    <span>Order ID:</span>
                    <span>#<%= order.getId() %></span>
                </div>
                <% } %>
                <div class="summary-row">
                    <span>Subtotal:</span>
                    <span>$<%= df.format(subtotal) %></span>
                </div>
                <div class="summary-row">
                    <span>Shipping:</span>
                    <span>$<%= df.format(shipping) %></span>
                </div>
                <div class="summary-row">
                    <span>Tax:</span>
                    <span>$<%= df.format(tax) %></span>
                </div>
                <div class="summary-row total">
                    <span>Total:</span>
                    <span>$<%= df.format(total) %></span>
                </div>

                <!-- Coupon Code Section -->
                <div class="coupon-section" style="margin-top: 20px; padding: 15px; background-color: #f9f9f9; border-radius: 4px;">
                    <h3 style="margin-top: 0; font-size: 16px;">Have a Coupon?</h3>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" id="couponCode" placeholder="Enter coupon code" style="flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <button type="button" id="applyCoupon" style="background-color: #6c5ce7; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer;">Apply</button>
                    </div>
                    <p id="couponMessage" style="margin-top: 8px; font-size: 14px; color: #666;"></p>
                </div>

                <!-- Shipping Method Section -->
                <div class="shipping-method-section" style="margin-top: 20px; padding: 15px; background-color: #f9f9f9; border-radius: 4px;">
                    <h3 style="margin-top: 0; font-size: 16px;">Shipping Method</h3>
                    <div class="shipping-options">
                        <div class="shipping-option" style="display: flex; align-items: center; margin-bottom: 10px;">
                            <input type="radio" id="standardShipping" name="shippingMethod" value="standard" checked>
                            <label for="standardShipping" style="margin-left: 10px;">
                                <span style="font-weight: bold;">Standard Shipping</span><br>
                                <span style="font-size: 14px; color: #666;">3-5 business days</span>
                            </label>
                            <span style="margin-left: auto;"><%= shipping > 0 ? "$" + df.format(shipping) : "FREE" %></span>
                        </div>
                        <div class="shipping-option" style="display: flex; align-items: center;">
                            <input type="radio" id="expressShipping" name="shippingMethod" value="express">
                            <label for="expressShipping" style="margin-left: 10px;">
                                <span style="font-weight: bold;">Express Shipping</span><br>
                                <span style="font-size: 14px; color: #666;">1-2 business days</span>
                            </label>
                            <span style="margin-left: auto;">$<%= df.format(shipping + 10) %></span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="payment-form">
                <h2>Payment Details</h2>

                <form action="<%=request.getContextPath()%>/PaymentServlet" method="post">
                    <input type="hidden" name="action" value="process">
                    <% if (order != null) { %>
                    <input type="hidden" name="orderId" value="<%= order.getId() %>">
                    <% } %>

                    <div class="form-group">
                        <label for="paymentMethod">Payment Method</label>
                        <select id="paymentMethod" name="paymentMethod" required>
                            <%
                            List<String> paymentMethods = (List<String>) request.getAttribute("paymentMethods");
                            if (paymentMethods != null && !paymentMethods.isEmpty()) {
                                for (String method : paymentMethods) {
                            %>
                                <option value="<%= method %>"><%= method %></option>
                            <%
                                }
                            } else {
                            %>
                                <option value="Credit Card">Credit Card</option>
                                <option value="Debit Card">Debit Card</option>
                                <option value="PayPal">PayPal</option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="cardName">Name on Card</label>
                        <input type="text" id="cardName" name="cardName" placeholder="John Doe" required>
                    </div>

                    <div class="form-group">
                        <label for="cardNumber">Card Number</label>
                        <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19" required>
                    </div>

                    <div class="card-details">
                        <div class="form-group">
                            <label for="expiryDate">Expiry Date</label>
                            <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" maxlength="5" required>
                        </div>

                        <div class="form-group">
                            <label for="cvv">CVV</label>
                            <input type="text" id="cvv" name="cvv" placeholder="123" maxlength="3" required>
                        </div>
                    </div>

                    <div style="display: flex; gap: 10px;">
                        <a href="<%=request.getContextPath()%>/CheckoutServlet" class="btn-back" style="background-color: #f8f9fa; color: #333; border: 1px solid #ddd; padding: 12px 20px; border-radius: 4px; text-decoration: none; text-align: center; flex: 1;">
                            <i class="fas fa-arrow-left" style="margin-right: 5px;"></i> Back to Checkout
                        </a>
                        <button type="submit" class="btn-pay" style="flex: 2;">Pay $<%= df.format(total) %></button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
