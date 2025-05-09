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

    // Get cart address
    Cart cartAddress = cartService.getCartAddress(user.getId());

    if (cartItems == null || cartItems.isEmpty()) {
        // Redirect to cart if empty
        response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
        return;
    }

    if (cartAddress == null || cartAddress.getStreet() == null || cartAddress.getStreet().isEmpty()) {
        // Redirect to address page if no address
        session.setAttribute("errorMessage", "Please provide your shipping address before proceeding to checkout.");
        response.sendRedirect(request.getContextPath() + "/CartServlet?action=viewAddress");
        return;
    }

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

<div class="checkout-message" style="background-color: #ffebcc; color: #ff8800; padding: 15px; margin: 20px auto; max-width: 1200px; border-radius: 8px; text-align: center; border-left: 5px solid #ff8800;">
    <i class="fas fa-info-circle" style="margin-right: 10px;"></i>
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
                <h2>Shipping Information</h2>

                <form action="<%=request.getContextPath()%>/CheckoutServlet" method="post">
                    <input type="hidden" name="action" value="placeOrder">

                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" value="<%= user.getFullName() %>" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" value="<%= user.getEmail() %>" required>
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone</label>
                            <input type="tel" id="phone" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="address">Address</label>
                        <input type="text" id="address" name="address" value="<%= cartAddress != null ? cartAddress.getStreet() : "" %>" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="city">City</label>
                            <input type="text" id="city" name="city" value="<%= cartAddress != null ? cartAddress.getCity() : "" %>" required>
                        </div>

                        <div class="form-group">
                            <label for="state">State</label>
                            <input type="text" id="state" name="state" value="<%= cartAddress != null ? cartAddress.getState() : "" %>" required>
                        </div>

                        <div class="form-group">
                            <label for="zipCode">Zip Code</label>
                            <input type="text" id="zipCode" name="zipCode" value="<%= cartAddress != null ? cartAddress.getZipCode() : "" %>" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="country">Country</label>
                        <input type="text" id="country" name="country" value="<%= cartAddress != null ? cartAddress.getCountry() : "" %>" required>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" style="font-size: 18px; padding: 15px 25px; box-shadow: 0 4px 8px rgba(255, 136, 0, 0.3); position: relative; overflow: hidden;">
                            <i class="fas fa-credit-card" style="margin-right: 10px;"></i>Proceed to Payment
                            <span style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to right, transparent, rgba(255, 255, 255, 0.2), transparent); transform: translateX(-100%); animation: shine 2s infinite;"></span>
                        </button>
                        <style>
                            @keyframes shine {
                                100% {
                                    transform: translateX(100%);
                                }
                            }
                        </style>
                        <a href="cart.jsp" class="btn btn-outline">
                            <i class="fas fa-arrow-left" style="margin-right: 5px;"></i>Back to Cart
                        </a>
                    </div>
                </form>
            </div>

            <div class="checkout-summary">
                <h2>Order Summary</h2>

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
.checkout-section {
    padding: 60px 0;
}

.checkout-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.checkout-form {
    flex: 3;
    min-width: 300px;
}

.checkout-summary {
    flex: 2;
    min-width: 300px;
    background-color: #f9f9f9;
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
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
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 16px;
}

.form-actions {
    margin-top: 30px;
    display: flex;
    gap: 15px;
}

.btn {
    padding: 12px 20px;
    border-radius: 4px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    text-decoration: none;
    display: inline-block;
}

.btn-primary {
    background-color: #ff8800;
    color: white;
    border: none;
    transition: all 0.3s ease;
    position: relative;
}

.btn-primary:hover {
    background-color: #ff9933;
    transform: translateY(-3px);
    box-shadow: 0 6px 12px rgba(255, 136, 0, 0.3);
}

.btn-primary:active {
    transform: translateY(1px);
    box-shadow: 0 2px 6px rgba(255, 136, 0, 0.3);
}

.btn-outline {
    background-color: transparent;
    color: #ff8800;
    border: 1px solid #ff8800;
}

.btn-outline:hover {
    background-color: #ff8800;
    color: white;
}

.order-items {
    margin-bottom: 30px;
    max-height: 300px;
    overflow-y: auto;
}

.order-item {
    display: flex;
    align-items: center;
    padding: 15px 0;
    border-bottom: 1px solid #eee;
}

.item-image {
    width: 60px;
    height: 60px;
    border-radius: 4px;
    overflow: hidden;
    margin-right: 15px;
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
}

.item-price {
    font-size: 14px;
    color: #777;
    margin: 0;
}

.item-total {
    font-weight: 600;
    color: #333;
}

.order-totals {
    padding-top: 20px;
    border-top: 1px solid #ddd;
}

.total-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    color: #555;
}

.total-final {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #ddd;
    font-size: 18px;
    font-weight: 600;
    color: #333;
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

@media (max-width: 768px) {
    .form-row {
        flex-direction: column;
        gap: 20px;
    }

    .form-actions {
        flex-direction: column;
    }

    .btn {
        width: 100%;
        text-align: center;
    }
}
</style>

<%@ include file="includes/footer.jsp" %>
