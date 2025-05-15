<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Cart" %>
<%@ page import="model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="service.CartService" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // Get user from session
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get cart address from request
    Cart cartAddress = (Cart) request.getAttribute("cartAddress");

    // Get cart items and total
    CartService cartService = new CartService();
    List<CartItem> cartItems = cartService.getUserCartItems(user.getId());
    double cartTotal = cartService.getCartTotal(user.getId());

    // Format currency
    DecimalFormat df = new DecimalFormat("0.00");

    // Get messages
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");

    // Clear messages from session
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - Address - CLOTHEE</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .checkout-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
        }

        .checkout-form {
            flex: 1;
            min-width: 300px;
        }

        .checkout-summary {
            width: 300px;
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 5px;
        }

        .checkout-steps {
            display: flex;
            margin-bottom: 20px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }

        .checkout-step {
            flex: 1;
            text-align: center;
            padding: 10px;
            position: relative;
        }

        .checkout-step.active {
            font-weight: bold;
            color: #ff6600;
        }

        .checkout-step.active::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 100%;
            height: 3px;
            background-color: #ff6600;
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

        .btn-continue {
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

        .btn-continue:hover {
            background-color: #e55c00;
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

        .alert {
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>

    <div class="container">
        <div class="checkout-container">
            <div class="checkout-form">
                <h1>Checkout</h1>

                <div class="checkout-steps">
                    <div class="checkout-step active">1. Address</div>
                    <div class="checkout-step">2. Payment</div>
                    <div class="checkout-step">3. Confirmation</div>
                </div>

                <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
                <% } %>

                <h2>Shipping Address</h2>

                <form action="CartServlet" method="post">
                    <input type="hidden" name="action" value="updateAddress">
                    <input type="hidden" name="checkout" value="true">

                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" value="<%= cartAddress != null && cartAddress.getFullName() != null ? cartAddress.getFullName() : user.getFirstName() + " " + user.getLastName() %>" required>
                    </div>



                    <div class="form-group">
                        <label for="country">Country</label>
                        <input type="text" id="country" name="country" value="<%= cartAddress != null && cartAddress.getCountry() != null ? cartAddress.getCountry() : "" %>" required>
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="text" id="phone" name="phone" value="<%= cartAddress != null && cartAddress.getPhone() != null ? cartAddress.getPhone() : "" %>" required>
                    </div>

                    <button type="submit" class="btn-continue">Continue to Payment</button>
                </form>
            </div>

            <div class="checkout-summary">
                <h2>Order Summary</h2>

                <div class="summary-items">
                    <% for (CartItem item : cartItems) { %>
                    <div class="summary-item">
                        <div class="summary-row">
                            <span><%= item.getProduct().getName() %> x <%= item.getQuantity() %></span>
                            <span>$<%= df.format(item.getProduct().getPrice() * item.getQuantity()) %></span>
                        </div>
                    </div>
                    <% } %>
                </div>

                <div class="summary-row">
                    <span>Subtotal:</span>
                    <span>$<%= df.format(cartTotal) %></span>
                </div>

                <div class="summary-row">
                    <span>Shipping:</span>
                    <span>$<%= df.format(5.99) %></span>
                </div>

                <div class="summary-row">
                    <span>Tax:</span>
                    <span>$<%= df.format(cartTotal * 0.1) %></span>
                </div>

                <div class="summary-row total">
                    <span>Total:</span>
                    <span>$<%= df.format(cartTotal + 5.99 + (cartTotal * 0.1)) %></span>
                </div>
            </div>
        </div>
    </div>

   <%@ include file="includes/footer.jsp" %>

</body>
</html>
