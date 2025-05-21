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
        <div class="cart-message">
            <i class="fas fa-check-circle"></i><%= cartMessage %>
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
                <h2 class="form-title">Cart Items</h2>

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
                            <img src="<%= request.getContextPath() %>/<%= product.getImageUrl() != null ? product.getImageUrl() : "images/products/placeholder.jpg" %>" alt="<%= product.getName() %>">
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
                <h2 class="form-title">Order Summary</h2>

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
                    <a href="<%=request.getContextPath()%>/CartServlet?action=checkout" class="btn btn-primary btn-block">
                        <i class="fas fa-credit-card"></i>Proceed to Checkout
                    </a>

                    <div class="secondary-actions">
                        <a href="<%=request.getContextPath()%>/CartServlet?action=clear" class="btn btn-outline">Clear Cart</a>
                        <a href="<%=request.getContextPath()%>/ProductServlet" class="btn btn-outline">Continue Shopping</a>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</section>

<style>
/* Cart Page Styles */
.cart-message {
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

.cart-message i {
    margin-right: 10px;
    font-size: 18px;
}

.cart-section {
    padding: 40px 0 60px;
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
    position: relative;
    max-width: 1200px;
    margin: 0 auto;
    justify-content: space-between;
}

.cart-items, .cart-summary {
    flex: 1;
    min-width: 300px;
    max-width: 48%;
    padding: 30px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.cart-summary {
    position: sticky;
    top: 20px;
    align-self: flex-start;
    margin-left: auto;
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
    width: 70px;
    height: 70px;
    border-radius: 6px;
    overflow: hidden;
    margin-right: 15px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
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
    font-weight: 600;
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
    margin-bottom: 12px;
    color: #555;
    font-size: 15px;
    padding: 8px 0;
}

.summary-total {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
    padding-top: 15px;
    border-top: 2px solid #ddd;
    font-size: 20px;
    font-weight: 700;
    color: #ff8800;
}

.summary-actions {
    margin-top: 30px;
    padding: 20px;
    background-color: #fcfcfc;
    border-radius: 6px;
    border-top: 1px solid #ddd;
}

.form-title {
    margin-bottom: 25px;
    padding-bottom: 12px;
    border-bottom: 2px solid #ff8800;
    color: #333;
    font-size: 22px;
    font-weight: 600;
}

.btn-block {
    display: block;
    width: 100%;
    margin-bottom: 20px;
    text-align: center;
}

.secondary-actions {
    display: flex;
    gap: 15px;
    margin-top: 15px;
}

.secondary-actions .btn {
    flex: 1;
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

@media (max-width: 992px) {
    .cart-content {
        flex-direction: column;
    }

    .cart-items,
    .cart-summary {
        max-width: 100%;
        margin: 0 auto 30px;
    }

    .cart-summary {
        position: static;
        margin-top: 30px;
    }
}

@media (max-width: 768px) {
    .cart-message {
        margin: 15px;
    }

    .cart-section {
        padding: 30px 15px;
    }

    .cart-header {
        display: none;
    }

    .cart-item {
        grid-template-columns: 1fr;
        gap: 15px;
        padding: 20px;
        margin-bottom: 20px;
        background-color: #fcfcfc;
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

    .secondary-actions {
        flex-direction: column;
        gap: 15px;
    }
}
</style>

<%@ include file="includes/footer.jsp" %>
