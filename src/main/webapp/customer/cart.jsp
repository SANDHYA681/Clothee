<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>
<%@ page import="model.CartItem" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dao.CartDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect("../admin/dashboard.jsp");
        return;
    }

    // Handle cart actions
    String action = request.getParameter("action");
    String productIdStr = request.getParameter("productId");
    String quantityStr = request.getParameter("quantity");

    // Get cart items from database
    CartDAO cartDAO = new CartDAO();
    List<CartItem> cartItems = cartDAO.getCartItemsByUserId(user.getId());

    // Create a map for easy access to quantities
    Map<Integer, Integer> cartQuantities = new HashMap<>();
    for (CartItem item : cartItems) {
        cartQuantities.put(item.getProductId(), item.getQuantity());
    }

    // Process cart actions
    if (action != null && productIdStr != null) {
        int productId = Integer.parseInt(productIdStr);

        if ("add".equals(action)) {
            // Add product to cart
            int quantity = 1;
            if (quantityStr != null && !quantityStr.isEmpty()) {
                quantity = Integer.parseInt(quantityStr);
            }

            // Check if product already in cart
            CartItem existingItem = cartDAO.getCartItemByUserAndProductId(user.getId(), productId);
            if (existingItem != null) {
                // Update quantity
                cartDAO.updateCartItemQuantity(existingItem.getId(), existingItem.getQuantity() + quantity);
            } else {
                // Add new item
                cartDAO.addToCart(user.getId(), productId, quantity);
            }

            // Set success message
            session.setAttribute("cartMessage", "Product added to cart successfully!");

            // Refresh cart items
            cartItems = cartDAO.getCartItemsByUserId(user.getId());
            cartQuantities.clear();
            for (CartItem item : cartItems) {
                cartQuantities.put(item.getProductId(), item.getQuantity());
            }

        } else if ("update".equals(action) && quantityStr != null) {
            // Update product quantity
            int quantity = Integer.parseInt(quantityStr);

            // Find cart item
            CartItem existingItem = cartDAO.getCartItemByUserAndProductId(user.getId(), productId);
            if (existingItem != null) {
                if (quantity > 0) {
                    // Update quantity
                    cartDAO.updateCartItemQuantity(existingItem.getId(), quantity);
                    session.setAttribute("cartMessage", "Cart updated successfully!");
                } else {
                    // Remove item
                    cartDAO.removeFromCart(existingItem.getId());
                    session.setAttribute("cartMessage", "Product removed from cart!");
                }
            }

            // Refresh cart items
            cartItems = cartDAO.getCartItemsByUserId(user.getId());
            cartQuantities.clear();
            for (CartItem item : cartItems) {
                cartQuantities.put(item.getProductId(), item.getQuantity());
            }

        } else if ("remove".equals(action)) {
            // Find cart item
            CartItem existingItem = cartDAO.getCartItemByUserAndProductId(user.getId(), productId);
            if (existingItem != null) {
                // Remove from cart
                cartDAO.removeFromCart(existingItem.getId());
                session.setAttribute("cartMessage", "Product removed from cart!");
            }

            // Refresh cart items
            cartItems = cartDAO.getCartItemsByUserId(user.getId());
            cartQuantities.clear();
            for (CartItem item : cartItems) {
                cartQuantities.put(item.getProductId(), item.getQuantity());
            }

        } else if ("clear".equals(action)) {
            // Clear entire cart
            cartDAO.clearCart(user.getId());
            session.setAttribute("cartMessage", "Cart cleared successfully!");

            // Refresh cart items
            cartItems = cartDAO.getCartItemsByUserId(user.getId());
            cartQuantities.clear();
        }

        // Redirect to avoid form resubmission
        response.sendRedirect("cart.jsp");
        return;
    }

    // Get cart message if any
    String cartMessage = (String) session.getAttribute("cartMessage");
    if (cartMessage != null) {
        session.removeAttribute("cartMessage");
    }

    // Get products in cart
    List<Product> cartProducts = new ArrayList<>();
    double totalPrice = 0.0;

    if (!cartItems.isEmpty()) {
        ProductDAO productDAO = new ProductDAO();
        for (CartItem item : cartItems) {
            Product product = item.getProduct();
            if (product == null) {
                product = productDAO.getProductById(item.getProductId());
                item.setProduct(product);
            }

            if (product != null) {
                cartProducts.add(product);
                totalPrice += product.getPrice() * item.getQuantity();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Cart - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/dashboard-pro.css">

        /* Ensure active menu item is orange */
        .sidebar-menu a.active {
            background-color: #ff8800 !important;
            color: white !important;
        }

        .sidebar-menu a.active i {
            color: white !important;
        }

        body {
            background-color: #f5f5f5;
            padding: 0;
            margin: 0;
            font-family: 'Poppins', sans-serif;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--dark-color);
            color: white;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            transition: all 0.3s ease;
        }

        .sidebar-header {
            padding: 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: white;
            margin-bottom: 10px;
        }

        .logo-icon {
            font-size: 24px;
            color: var(--primary-color);
            margin-right: 10px;
        }

        .logo-text {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 1px;
        }

        .user-info {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .user-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background-color: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 10px;
            font-size: 32px;
            overflow: hidden;
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .user-name {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .user-role {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.7);
        }

        .main-content {
            flex: 1;
            margin-left: var(--sidebar-width);
            padding: 20px;
            transition: all 0.3s ease;
        }

        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background-color: white;
            padding: 15px 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .page-title {
            font-size: 24px;
            font-weight: 600;
        }

        .header-actions {
            display: flex;
            align-items: center;
        }

        .header-action {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--light-color);
            color: var(--dark-color);
            margin-left: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .header-action:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .dashboard-section-card {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .empty-cart {
            text-align: center;
            padding: 40px 20px;
        }

        .empty-cart i {
            font-size: 48px;
            color: var(--primary-color);
            margin-bottom: 20px;
        }

        .empty-cart h3 {
            font-size: 20px;
            margin-bottom: 10px;
            color: #333;
        }

        .empty-cart p {
            font-size: 18px;
            color: #666;
            margin-bottom: 20px;
        }

        .btn {
            display: inline-block;
            background-color: var(--primary-color) !important;
            color: white !important;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn:hover {
            background-color: var(--secondary-color) !important;
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(255, 136, 0, 0.2);
        }

        .btn-secondary {
            background-color: #ff8800 !important;
        }

        .btn-secondary:hover {
            background-color: #ffa640 !important;
        }

        .btn-danger {
            background-color: #dc3545;
        }

        .btn-danger:hover {
            background-color: #c82333;
        }

        .cart-container {
            background-color: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .cart-header {
            display: grid;
            grid-template-columns: 3fr 1fr 1fr 1fr 1fr;
            padding: 15px 20px;
            background-color: #f8f9fa;
            border-bottom: 1px solid #eee;
            font-weight: 600;
            color: #333;
        }

        .cart-item {
            display: grid;
            grid-template-columns: 3fr 1fr 1fr 1fr 1fr;
            padding: 20px;
            border-bottom: 1px solid #eee;
            align-items: center;
        }

        .cart-product {
            display: flex;
            align-items: center;
        }

        .cart-product .product-image {
            width: 80px;
            height: 80px;
            border-radius: 4px;
            overflow: hidden;
            margin-right: 15px;
        }

        .cart-product .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .cart-product .product-details {
            flex-grow: 1;
        }

        .cart-product .product-name {
            font-size: 16px;
            margin: 0 0 5px;
            color: #333;
        }

        .cart-product .product-category {
            font-size: 12px;
            color: #888;
            margin: 0;
        }

        .cart-price, .cart-total {
            font-weight: 600;
            color: #333;
        }

        .cart-quantity {
            display: flex;
            justify-content: center;
        }

        .quantity-control {
            display: flex;
            align-items: center;
            border: 1px solid #ddd;
            border-radius: 4px;
            overflow: hidden;
        }

        .quantity-btn {
            width: 30px;
            height: 30px;
            background-color: #f8f9fa;
            border: none;
            cursor: pointer;
            font-size: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            text-decoration: none;
        }

        .quantity-input {
            width: 40px;
            height: 30px;
            border: none;
            border-left: 1px solid #ddd;
            border-right: 1px solid #ddd;
            text-align: center;
            font-size: 14px;
        }

        .cart-actions {
            display: flex;
            justify-content: center;
        }

        .btn-remove {
            color: #dc3545;
            font-size: 16px;
            background: none;
            border: none;
            cursor: pointer;
            transition: color 0.3s;
            text-decoration: none;
        }

        .btn-remove:hover {
            color: #c82333;
        }

        .cart-summary {
            padding: 20px;
            border-top: 1px solid #eee;
        }

        .cart-totals {
            margin-bottom: 20px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }

        .summary-row.total {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            border-bottom: none;
            padding-top: 15px;
        }

        .cart-actions {
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }

        .toggle-sidebar {
            display: none;
            position: fixed;
            top: 20px;
            left: 20px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            z-index: 100;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
            }

            .toggle-sidebar {
                display: flex;
            }
        }

        @media (max-width: 768px) {
            .cart-header, .cart-item {
                grid-template-columns: 2fr 1fr 1fr;
            }

            .cart-header div:nth-child(4),
            .cart-header div:nth-child(5),
            .cart-item div:nth-child(4),
            .cart-item div:nth-child(5) {
                display: none;
            }

            .cart-actions {
                flex-direction: column;
                gap: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() != null ? user.getProfileImage() : "default.png" %>" alt="Profile Image">
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>

        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">My Shopping Cart</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <% if (cartMessage != null) { %>
            <div class="alert alert-success">
                <%= cartMessage %>
            </div>
            <% } %>

            <div class="dashboard-section-card">
                <% if (cartProducts.isEmpty()) { %>
                    <div class="empty-cart">
                        <i class="fas fa-shopping-cart"></i>
                        <h3>Your cart is empty</h3>
                        <p>Looks like you haven't added any products to your cart yet.</p>
                        <a href="<%=request.getContextPath()%>/ProductServlet" class="btn" style="background-color: #ff8800;">Continue Shopping</a>
                    </div>
                <% } else { %>
                    <div class="cart-container">
                        <div class="cart-items">
                            <div class="cart-header">
                                <div class="cart-product">Product</div>
                                <div class="cart-price">Price</div>
                                <div class="cart-quantity">Quantity</div>
                                <div class="cart-total">Total</div>
                                <div class="cart-actions">Actions</div>
                            </div>

                            <% for (Product product : cartProducts) { %>
                                <div class="cart-item">
                                    <div class="cart-product">
                                        <div class="product-image">
                                            <img src="<%=request.getContextPath()%>/<%= product.getImageUrl() != null ? product.getImageUrl() : "images/products/placeholder.jpg" %>" alt="<%= product.getName() %>">
                                        </div>
                                        <div class="product-details">
                                            <h3 class="product-name"><%= product.getName() %></h3>
                                            <p class="product-category"><%= product.getCategory() %> / <%= product.getType() %></p>
                                        </div>
                                    </div>

                                    <div class="cart-price">$<%= String.format("%.2f", product.getPrice()) %></div>

                                    <div class="cart-quantity">
                                        <form action="cart.jsp" method="get" class="quantity-form">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="productId" value="<%= product.getId() %>">
                                            <div class="quantity-control">
                                                <a href="cart.jsp?action=update&productId=<%= product.getId() %>&quantity=<%= Math.max(1, cartQuantities.get(product.getId()) - 1) %>" class="quantity-btn minus">
                                                    <i class="fas fa-minus"></i>
                                                </a>
                                                <input type="number" name="quantity" class="quantity-input" value="<%= cartQuantities.get(product.getId()) %>" min="1" max="<%= product.getStock() %>" onchange="this.form.submit()">
                                                <a href="cart.jsp?action=update&productId=<%= product.getId() %>&quantity=<%= Math.min(product.getStock(), cartQuantities.get(product.getId()) + 1) %>" class="quantity-btn plus">
                                                    <i class="fas fa-plus"></i>
                                                </a>
                                            </div>
                                        </form>
                                    </div>

                                    <div class="cart-total">$<%= String.format("%.2f", product.getPrice() * cartQuantities.get(product.getId())) %></div>

                                    <div class="cart-actions">
                                        <a href="cart.jsp?action=remove&productId=<%= product.getId() %>" class="btn-remove" title="Remove from cart">
                                            <i class="fas fa-trash-alt"></i>
                                        </a>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <div class="cart-summary">
                            <div class="cart-totals">
                                <div class="summary-row">
                                    <span>Subtotal:</span>
                                    <span>$<%= String.format("%.2f", totalPrice) %></span>
                                </div>
                                <div class="summary-row">
                                    <span>Shipping:</span>
                                    <span>$<%= String.format("%.2f", totalPrice > 100 ? 0.00 : 10.00) %></span>
                                </div>
                                <div class="summary-row total">
                                    <span>Total:</span>
                                    <span>$<%= String.format("%.2f", totalPrice > 100 ? totalPrice : totalPrice + 10.00) %></span>
                                </div>
                            </div>

                            <div class="cart-actions">
                                <a href="<%=request.getContextPath()%>/ProductServlet" class="btn btn-secondary" style="background-color: #ff8800 !important;">Continue Shopping</a>
                                <a href="cart.jsp?action=clear" class="btn btn-danger">Clear Cart</a>
                                <a href="<%=request.getContextPath()%>/CartServlet?action=checkout" class="btn">Proceed to Checkout</a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Toggle sidebar on mobile
        const toggleSidebar = document.getElementById('toggleSidebar');
        const sidebar = document.getElementById('sidebar');

        toggleSidebar.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    </script>
</body>
</html>
