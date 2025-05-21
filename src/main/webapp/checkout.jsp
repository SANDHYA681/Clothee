<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.Cart" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="service.CartService" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="java.util.ArrayList" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?redirectUrl=" + java.net.URLEncoder.encode("checkout.jsp", "UTF-8"));
        return;
    }

    // Initialize CartService
    CartService cartService = new CartService();

    // Get cart items directly from database
    List<CartItem> cartItems = cartService.getUserCartItems(user.getId());

    // No need to get cart address

    if (cartItems == null || cartItems.isEmpty()) {
        // Redirect to cart if empty
        response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
        return;
    }

    // Get cart address information

    // Calculate totals
    double subtotal = cartService.getCartTotal(user.getId());
    double shipping = subtotal > 50 ? 0.00 : 5.99;
    double tax = subtotal * 0.1;
    double total = subtotal + shipping + tax;

    // Get error message if any
    String errorMessage = (String) request.getAttribute("errorMessage");
%>

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80')">
    <div class="page-header-content">
        <h1 class="page-title">CHECKOUT</h1>
        <p class="page-subtitle">Complete your purchase</p>
    </div>
</div>

<div class="checkout-message">
    <i class="fas fa-info-circle"></i>
    <span>You are proceeding to checkout. Please review your order details and fill in the required information to complete your purchase.</span>
</div>

<section class="checkout-section">
    <div class="container">
        <% if (errorMessage != null) { %>
        <div class="alert alert-danger">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="checkout-content">
            <div class="checkout-form">
                <h2 class="form-title">Shipping Information</h2>

                <form action="<%=request.getContextPath()%>/CheckoutServlet" method="post">
                    <input type="hidden" name="action" value="placeOrder">

                    <div class="order-review-message">
                        <p>Please provide your shipping information and review your order details before proceeding to payment.</p>
                    </div>

                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" placeholder="Enter your full name" required>
                    </div>

                    <div class="form-group">
                        <label for="country">Country</label>
                        <input type="text" id="country" name="country" placeholder="Enter your country" required>
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="text" id="phone" name="phone" placeholder="Enter your phone number" required>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-credit-card"></i>Proceed to Payment
                        </button>
                        <a href="cart.jsp" class="btn btn-outline">
                            <i class="fas fa-arrow-left"></i>Back to Cart
                        </a>
                    </div>
                </form>
            </div>

            <div class="checkout-summary">
                <h2 class="form-title">Order Summary</h2>

                <div class="order-items">
                    <% for (CartItem item : cartItems) {
                        Product product = item.getProduct();
                        int quantity = item.getQuantity();
                        double itemTotal = product.getPrice() * quantity;
                    %>
                    <div class="order-item">
                        <div class="item-image">
                            <img src="<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
                        </div>
                        <div class="item-details">
                            <h3><%= product.getName() %></h3>
                            <p class="item-price">$<%= String.format("%.2f", product.getPrice()) %> x <%= quantity %></p>
                        </div>
                        <div class="item-total">
                            $<%= String.format("%.2f", itemTotal) %>
                        </div>
                    </div>
                    <% } %>
                </div>

                <div class="order-totals">
                    <div class="total-item">
                        <span class="total-label">Subtotal</span>
                        <span class="total-value">$<%= String.format("%.2f", subtotal) %></span>
                    </div>

                    <div class="total-item">
                        <span class="total-label">Shipping</span>
                        <span class="total-value">$<%= String.format("%.2f", shipping) %></span>
                    </div>

                    <div class="total-item">
                        <span class="total-label">Tax</span>
                        <span class="total-value">$<%= String.format("%.2f", tax) %></span>
                    </div>

                    <div class="total-final">
                        <span class="total-label">Total</span>
                        <span class="total-value">$<%= String.format("%.2f", total) %></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
/* Checkout Page Styles */
.checkout-message {
    background-color: #ffebcc;
    color: #ff8800;
    padding: 15px;
    margin: 20px auto;
    max-width: 1200px;
    border-radius: 8px;
    text-align: center;
    border-left: 5px solid #ff8800;
    box-shadow: 0 2px 8px rgba(255, 136, 0, 0.1);
}

.checkout-message i {
    margin-right: 10px;
    font-size: 18px;
}

.checkout-section {
    padding: 40px 0 60px;
}

.checkout-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
    position: relative;
    max-width: 1200px;
    margin: 0 auto;
    justify-content: space-between;
}

.checkout-form, .checkout-summary {
    flex: 1;
    min-width: 300px;
    max-width: 48%;
    padding: 30px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.checkout-summary {
    position: sticky;
    top: 20px;
    align-self: flex-start;
    margin-left: auto;
}

.form-title {
    margin-bottom: 25px;
    padding-bottom: 12px;
    border-bottom: 2px solid #ff8800;
    color: #333;
    font-size: 22px;
    font-weight: 600;
}

.order-review-message {
    background-color: #fcfcfc;
    padding: 15px;
    border-radius: 6px;
    margin-bottom: 25px;
}

.order-review-message p {
    margin: 0;
    color: #555;
}

.form-group {
    margin-bottom: 20px;
}

.form-row {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
}

.form-row .form-group {
    flex: 1;
    margin-bottom: 0;
}

label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #333;
}

input[type="text"],
input[type="email"],
input[type="tel"] {
    width: 100%;
    padding: 14px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 16px;
    transition: border-color 0.3s, box-shadow 0.3s;
    background-color: #fcfcfc;
}

input[type="text"]:focus,
input[type="email"]:focus,
input[type="tel"]:focus {
    outline: none;
    border-color: #ff8800;
    box-shadow: 0 0 0 3px rgba(255, 136, 0, 0.1);
    background-color: #fff;
}

.form-actions {
    margin-top: 30px;
    display: flex;
    gap: 15px;
    padding: 20px;
    background-color: #fcfcfc;
    border-radius: 6px;
    border-top: 1px solid #ddd;
}

.btn {
    padding: 14px 24px;
    border-radius: 6px;
    font-weight: 600;
    font-size: 16px;
    cursor: pointer;
    transition: all 0.3s;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 160px;
}

.btn i {
    margin-right: 10px;
}

.btn-primary {
    background-color: #ff8800;
    color: white;
    border: none;
    box-shadow: 0 4px 8px rgba(255, 136, 0, 0.2);
    position: relative;
    overflow: hidden;
}

.btn-primary:hover {
    background-color: #ff9933;
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(255, 136, 0, 0.3);
}

.btn-primary:active {
    transform: translateY(1px);
    box-shadow: 0 2px 6px rgba(255, 136, 0, 0.3);
}

.btn-outline {
    background-color: transparent;
    color: #555;
    border: 1px solid #ddd;
}

.btn-outline:hover {
    background-color: #f5f5f5;
    color: #333;
    border-color: #ccc;
}

.order-items {
    margin-bottom: 30px;
    max-height: 350px;
    overflow-y: auto;
    padding-right: 10px;
}

.order-items::-webkit-scrollbar {
    width: 6px;
}

.order-items::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 10px;
}

.order-items::-webkit-scrollbar-thumb {
    background: #ddd;
    border-radius: 10px;
}

.order-items::-webkit-scrollbar-thumb:hover {
    background: #ccc;
}

.order-item {
    display: flex;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #eee;
    transition: background-color 0.2s;
}

.order-item:hover {
    background-color: #fcfcfc;
}

.item-image {
    width: 70px;
    height: 70px;
    border-radius: 6px;
    overflow: hidden;
    margin-right: 15px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.item-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.item-details {
    flex: 1;
}

.item-details h3 {
    font-size: 16px;
    margin: 0 0 5px;
    color: #333;
    font-weight: 600;
}

.item-price {
    font-size: 14px;
    color: #777;
    margin: 0;
}

.item-total {
    font-weight: 600;
    color: #333;
    font-size: 16px;
}

.order-totals {
    padding: 20px;
    border-top: 1px solid #ddd;
    background-color: #fcfcfc;
    border-radius: 6px;
    margin-top: 20px;
}

.total-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 12px;
    color: #555;
    font-size: 15px;
}

.total-final {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
    padding-top: 15px;
    border-top: 2px solid #ddd;
    font-size: 20px;
    font-weight: 700;
    color: #ff8800;
}

.alert {
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 4px;
}

.alert-danger {
    background-color: #ffebcc;
    color: #ff8800;
    border: 1px solid #ffcc80;
}

@media (max-width: 992px) {
    .checkout-content {
        flex-direction: column;
    }

    .checkout-form,
    .checkout-summary {
        max-width: 100%;
        margin: 0 auto 30px;
    }

    .checkout-summary {
        position: static;
        margin-top: 30px;
    }
}

@media (max-width: 768px) {
    .checkout-message {
        margin: 15px;
    }

    .checkout-section {
        padding: 30px 15px;
    }

    .form-row {
        flex-direction: column;
        gap: 20px;
    }

    .form-actions {
        flex-direction: column;
        gap: 15px;
    }

    .btn {
        width: 100%;
        text-align: center;
    }

    .order-item {
        flex-wrap: wrap;
    }

    .item-image {
        margin-bottom: 10px;
    }

    .item-total {
        width: 100%;
        text-align: right;
        margin-top: 10px;
    }
}
</style>

<%@ include file="includes/footer.jsp" %>
