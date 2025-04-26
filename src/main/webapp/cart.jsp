<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.CartItem" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ include file="includes/header.jsp" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");

    // Get cart items from request attributes (set by CartServlet)
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    double cartTotal = 0.0;
    int cartItemCount = 0;

    if (request.getAttribute("cartTotal") != null) {
        cartTotal = (Double) request.getAttribute("cartTotal");
    }

    if (request.getAttribute("cartItemCount") != null) {
        cartItemCount = (Integer) request.getAttribute("cartItemCount");
    }

    // If cartItems is null, it means the user accessed this page directly
    // Redirect to CartServlet to properly load the cart
    if (cartItems == null) {
        response.sendRedirect("CartServlet?action=view");
        return;
    }

    // Get cart message if any
    String cartMessage = (String) request.getAttribute("cartMessage");
%>

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80')">
    <div class="page-header-content">
        <h1 class="page-title">SHOPPING CART</h1>
        <p class="page-subtitle">Review your items and proceed to checkout</p>
    </div>
</div>

<section class="cart-section">
    <div class="container">
        <% if (cartMessage != null) { %>
        <div class="alert alert-success" style="background-color: #ffebcc; color: #ff8800; padding: 15px; margin-bottom: 20px; border-radius: 4px; border-left: 5px solid #ff8800;">
            <i class="fas fa-check-circle" style="margin-right: 10px;"></i><%= cartMessage %>
        </div>
        <% } %>

        <% if (cartItems == null || cartItems.isEmpty()) { %>
        <div class="empty-cart">
            <i class="fas fa-shopping-cart"></i>
            <h2>Your cart is empty</h2>
            <p>Looks like you haven't added any products to your cart yet.</p>
            <a href="ProductServlet" class="btn btn-primary">Continue Shopping</a>
        </div>
        <% } else { %>
        <div class="cart-content">
            <div class="cart-items">
                <h2>Cart Items</h2>

                <div class="cart-header">
                    <div class="cart-product">Product</div>
                    <div class="cart-price">Price</div>
                    <div class="cart-quantity">Quantity</div>
                    <div class="cart-total">Total</div>
                    <div class="cart-action">Action</div>
                </div>

                <% for (CartItem cartItem : cartItems) {
                    Product product = cartItem.getProduct();
                    int quantity = cartItem.getQuantity();
                    double itemTotal = product.getPrice() * quantity;
                %>
                <div class="cart-item">
                    <div class="cart-product">
                        <div class="product-image">
                            <img src="<%= product.getImageUrl() != null ? product.getImageUrl() : "images/products/placeholder.jpg" %>" alt="<%= product.getName() %>">
                        </div>
                        <div class="product-details">
                            <h3><%= product.getName() %></h3>
                            <p class="product-category"><%= product.getCategory() %></p>
                        </div>
                    </div>

                    <div class="cart-price">
                        $<%= String.format("%.2f", product.getPrice()) %>
                    </div>

                    <div class="cart-quantity">
                        <div class="quantity-selector">
                            <a href="CartServlet?action=update&cartItemId=<%= cartItem.getId() %>&quantity=<%= quantity > 1 ? quantity - 1 : 1 %>" class="quantity-btn">-</a>
                            <input type="number" class="quantity-input" value="<%= quantity %>" min="1" max="<%= product.getStock() %>" readonly>
                            <a href="CartServlet?action=update&cartItemId=<%= cartItem.getId() %>&quantity=<%= quantity < product.getStock() ? quantity + 1 : product.getStock() %>" class="quantity-btn">+</a>
                        </div>
                    </div>

                    <div class="cart-total">
                        $<%= String.format("%.2f", itemTotal) %>
                    </div>

                    <div class="cart-action">
                        <a href="CartServlet?action=remove&cartItemId=<%= cartItem.getId() %>" class="remove-btn" title="Remove Item">
                            <i class="fas fa-trash"></i>
                        </a>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="cart-summary">
                <h2>Order Summary</h2>

                <div class="summary-item">
                    <span class="summary-label">Subtotal</span>
                    <span class="summary-value">$<%= String.format("%.2f", cartTotal) %></span>
                </div>

                <div class="summary-item">
                    <span class="summary-label">Shipping</span>
                    <span class="summary-value">$<%= String.format("%.2f", cartTotal > 50 ? 0.00 : 5.99) %></span>
                </div>

                <div class="summary-item">
                    <span class="summary-label">Tax</span>
                    <span class="summary-value">$<%= String.format("%.2f", cartTotal * 0.07) %></span>
                </div>

                <div class="summary-total">
                    <span class="summary-label">Total</span>
                    <span class="summary-value">$<%= String.format("%.2f", cartTotal + (cartTotal > 50 ? 0.00 : 5.99) + (cartTotal * 0.07)) %></span>
                </div>

                <div class="summary-actions">
                    <a href="<%=request.getContextPath()%>/CartServlet?action=checkout" class="btn btn-primary btn-block" style="font-size: 18px; padding: 15px 20px; box-shadow: 0 4px 8px rgba(255, 136, 0, 0.3); position: relative; overflow: hidden;">
                        <i class="fas fa-credit-card" style="margin-right: 10px;"></i>Proceed to Checkout
                        <span style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to right, transparent, rgba(255, 255, 255, 0.2), transparent); transform: translateX(-100%); animation: shine 2s infinite; pointer-events: none;"></span>
                    </a>
                    <style>
                        @keyframes shine {
                            100% {
                                transform: translateX(100%);
                            }
                        }
                    </style>

                    <a href="<%=request.getContextPath()%>/CartServlet?action=clear" class="btn btn-outline btn-block">Clear Cart</a>

                    <a href="<%=request.getContextPath()%>/ProductServlet" class="btn btn-link btn-block">Continue Shopping</a>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</section>

<style>
/* Cart Page Styles */
.cart-section {
    padding: 60px 0;
}

.empty-cart {
    text-align: center;
    padding: 60px 0;
}

.empty-cart i {
    font-size: 64px;
    color: #ddd;
    margin-bottom: 20px;
}

.empty-cart h2 {
    font-size: 24px;
    margin-bottom: 10px;
    color: #333;
}

.empty-cart p {
    color: #777;
    margin-bottom: 30px;
}

.cart-content {
    display: flex;
    flex-wrap: wrap;
    gap: 30px;
}

.cart-items {
    flex: 2;
    min-width: 300px;
}

.cart-summary {
    flex: 1;
    min-width: 300px;
    background-color: #f9f9f9;
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.cart-header {
    display: grid;
    grid-template-columns: 3fr 1fr 1fr 1fr 0.5fr;
    padding: 15px 0;
    border-bottom: 1px solid #eee;
    font-weight: 600;
    color: #333;
}

.cart-item {
    display: grid;
    grid-template-columns: 3fr 1fr 1fr 1fr 0.5fr;
    padding: 20px 0;
    border-bottom: 1px solid #eee;
    align-items: center;
}

.cart-product {
    display: flex;
    align-items: center;
}

.product-image {
    width: 80px;
    height: 80px;
    border-radius: 4px;
    overflow: hidden;
    margin-right: 15px;
}

.product-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.product-details h3 {
    font-size: 16px;
    margin: 0 0 5px;
    color: #333;
}

.product-category {
    font-size: 14px;
    color: #777;
    margin: 0;
}

.cart-price, .cart-total {
    font-weight: 600;
    color: #333;
}

.quantity-selector {
    display: flex;
    align-items: center;
    border: 1px solid #ddd;
    border-radius: 4px;
    overflow: hidden;
    width: 100px;
}

.quantity-btn {
    width: 30px;
    height: 30px;
    background-color: #f5f5f5;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    text-decoration: none;
    color: #333;
    font-weight: bold;
}

.quantity-input {
    width: 40px;
    height: 30px;
    border: none;
    text-align: center;
    font-weight: 600;
}

.remove-btn {
    background: none;
    border: none;
    color: #ff8800;
    cursor: pointer;
    font-size: 16px;
    text-decoration: none;
    display: inline-block;
}

.summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 15px;
    color: #555;
}

.summary-total {
    display: flex;
    justify-content: space-between;
    margin: 20px 0;
    padding-top: 20px;
    border-top: 1px solid #ddd;
    font-size: 18px;
    font-weight: 600;
    color: #333;
}

.summary-actions {
    margin-top: 30px;
}

.btn-block {
    display: block;
    width: 100%;
    margin-bottom: 10px;
    text-align: center;
}

.btn-primary {
    background-color: #ff8800;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 4px;
    font-weight: 600;
    cursor: pointer;
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
    padding: 12px 20px;
    border-radius: 4px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
}

.btn-outline:hover {
    background-color: #ff8800;
    color: white;
}

.btn-link {
    background: none;
    color: #555;
    text-decoration: none;
    padding: 12px 20px;
    display: inline-block;
    text-align: center;
}

.btn-link:hover {
    color: #ff8800;
}

@media (max-width: 768px) {
    .cart-header {
        display: none;
    }

    .cart-item {
        grid-template-columns: 1fr;
        gap: 15px;
        padding: 20px;
        margin-bottom: 20px;
        background-color: #f9f9f9;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    }

    .cart-product {
        grid-column: 1;
    }

    .cart-price, .cart-quantity, .cart-total, .cart-action {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .cart-price::before {
        content: 'Price:';
        font-weight: normal;
        color: #777;
    }

    .cart-quantity::before {
        content: 'Quantity:';
        font-weight: normal;
        color: #777;
    }

    .cart-total::before {
        content: 'Total:';
        font-weight: normal;
        color: #777;
    }

    .cart-action {
        justify-content: flex-end;
    }
}
</style>

<%@ include file="includes/footer.jsp" %>
