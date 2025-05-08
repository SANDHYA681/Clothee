<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ include file="/includes/header.jsp" %>

<%
    // Get user from request attribute
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect("LoginServlet");
        return;
    }
    
    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect("admin/dashboard.jsp");
        return;
    }
%>

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');">
    <div class="page-header-content">
        <h1 class="page-title">CUSTOMER DASHBOARD</h1>
        <p class="page-subtitle">Welcome back, <%= user.getFirstName() %>!</p>
    </div>
</div>

<section class="dashboard-section">
    <div class="container">
        <div class="dashboard-wrapper">
            <div class="dashboard-sidebar">
                <div class="user-profile">
                    <div class="profile-image">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <img src="images/user-placeholder.jpg" alt="<%= user.getFullName() %>">
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFullName() %></h3>
                    <p class="user-email"><%= user.getEmail() %></p>
                </div>

                <ul class="dashboard-menu">
                    <li class="active"><a href="UserServlet?action=dashboard"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                    <li><a href="UserServlet?action=profile"><i class="fas fa-user"></i> My Profile</a></li>
                    <li><a href="OrderServlet?action=history"><i class="fas fa-shopping-bag"></i> My Orders</a></li>
                    <li><a href="WishlistServlet"><i class="fas fa-heart"></i> Wishlist</a></li>
                    <li><a href="CartServlet"><i class="fas fa-shopping-cart"></i> My Cart</a></li>
                    <li><a href="ProductServlet"><i class="fas fa-tshirt"></i> Shop Products</a></li>
                    <li><a href="AddressServlet"><i class="fas fa-map-marker-alt"></i> My Addresses</a></li>
                    <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </div>

            <div class="dashboard-content">
                <div class="dashboard-header">
                    <h2>Dashboard</h2>
                    <p>Welcome to your customer dashboard. Here you can manage your orders, profile, and more.</p>
                </div>

                <div class="dashboard-stats">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-shopping-bag"></i>
                        </div>
                        <div class="stat-info">
                            <h3>0</h3>
                            <p>Orders</p>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-heart"></i>
                        </div>
                        <div class="stat-info">
                            <h3>0</h3>
                            <p>Wishlist Items</p>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-shopping-cart"></i>
                        </div>
                        <div class="stat-info">
                            <h3>0</h3>
                            <p>Cart Items</p>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-star"></i>
                        </div>
                        <div class="stat-info">
                            <h3>0</h3>
                            <p>Reviews</p>
                        </div>
                    </div>
                </div>

                <div class="dashboard-sections">
                    <div class="dashboard-section-card">
                        <h3>Recent Orders</h3>
                        <div class="empty-state">
                            <i class="fas fa-shopping-bag"></i>
                            <p>You haven't placed any orders yet.</p>
                            <a href="ProductServlet" class="btn btn-primary">Shop Now</a>
                        </div>
                    </div>

                    <div class="dashboard-section-card">
                        <h3>Recently Viewed</h3>
                        <div class="empty-state">
                            <i class="fas fa-eye"></i>
                            <p>No recently viewed products.</p>
                            <a href="ProductServlet" class="btn btn-primary">Browse Products</a>
                        </div>
                    </div>
                </div>

                <div class="shop-categories-section">
                    <h3>Shop by Category</h3>
                    <div class="category-cards">
                        <a href="ProductServlet?category=Men" class="category-card">
                            <div class="category-image" style="background-image: url('https://images.unsplash.com/photo-1516257984-b1b4d707412e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');"></div>
                            <h4>Men</h4>
                        </a>
                        <a href="ProductServlet?category=Women" class="category-card">
                            <div class="category-image" style="background-image: url('https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');"></div>
                            <h4>Women</h4>
                        </a>
                        <a href="ProductServlet?category=Kids" class="category-card">
                            <div class="category-image" style="background-image: url('https://images.unsplash.com/photo-1519457431-44ccd64a579b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');"></div>
                            <h4>Kids</h4>
                        </a>
                        <a href="ProductServlet?category=Accessories" class="category-card">
                            <div class="category-image" style="background-image: url('https://images.unsplash.com/photo-1523206489230-c012c64b2b48?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');"></div>
                            <h4>Accessories</h4>
                        </a>
                    </div>
                </div>

                <div class="featured-products-section">
                    <h3>Featured Products</h3>
                    <div class="featured-products-slider">
                        <div class="product-card">
                            <div class="product-image">
                                <img src="images/products/placeholder.jpg" alt="Men's T-Shirt">
                                <div class="product-actions">
                                    <a href="ProductServlet?action=view&id=1" class="btn-view">View Details</a>
                                    <a href="CartServlet?action=add&productId=1&quantity=1" class="btn-add-cart">Add to Cart</a>
                                </div>
                                <span class="badge featured">Featured</span>
                            </div>
                            <div class="product-info">
                                <h3 class="product-name">Men's T-Shirt</h3>
                                <p class="product-category">Men / T-Shirts</p>
                                <div class="product-price">$29.99</div>
                                <div class="product-rating">
                                    <div class="stars">
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="far fa-star"></i>
                                    </div>
                                    <span class="rating-count">12 reviews</span>
                                </div>
                            </div>
                        </div>

                        <div class="product-card">
                            <div class="product-image">
                                <img src="images/products/placeholder.jpg" alt="Women's Dress">
                                <div class="product-actions">
                                    <a href="ProductServlet?action=view&id=2" class="btn-view">View Details</a>
                                    <a href="CartServlet?action=add&productId=2&quantity=1" class="btn-add-cart">Add to Cart</a>
                                </div>
                                <span class="badge featured">Featured</span>
                            </div>
                            <div class="product-info">
                                <h3 class="product-name">Women's Dress</h3>
                                <p class="product-category">Women / Dresses</p>
                                <div class="product-price">$59.99</div>
                                <div class="product-rating">
                                    <div class="stars">
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                    </div>
                                    <span class="rating-count">18 reviews</span>
                                </div>
                            </div>
                        </div>

                        <div class="product-card">
                            <div class="product-image">
                                <img src="images/products/placeholder.jpg" alt="Sunglasses">
                                <div class="product-actions">
                                    <a href="ProductServlet?action=view&id=8" class="btn-view">View Details</a>
                                    <a href="CartServlet?action=add&productId=8&quantity=1" class="btn-add-cart">Add to Cart</a>
                                </div>
                                <span class="badge featured">Featured</span>
                            </div>
                            <div class="product-info">
                                <h3 class="product-name">Sunglasses</h3>
                                <p class="product-category">Accessories / Eyewear</p>
                                <div class="product-price">$29.99</div>
                                <div class="product-rating">
                                    <div class="stars">
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="far fa-star"></i>
                                    </div>
                                    <span class="rating-count">9 reviews</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="view-all-products">
                        <a href="ProductServlet" class="btn btn-primary">View All Products</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
    .dashboard-section {
        padding: 40px 0;
    }

    .dashboard-wrapper {
        display: flex;
        gap: 30px;
    }

    .dashboard-sidebar {
        width: 280px;
        flex-shrink: 0;
    }

    .dashboard-content {
        flex-grow: 1;
    }

    .user-profile {
        background-color: #fff;
        border-radius: 8px;
        padding: 20px;
        text-align: center;
        margin-bottom: 20px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    .profile-image {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        overflow: hidden;
        margin: 0 auto 15px;
        border: 3px solid #4a6bdf;
    }

    .profile-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .user-name {
        font-size: 18px;
        margin-bottom: 5px;
        color: #333;
    }

    .user-email {
        font-size: 14px;
        color: #666;
        margin-bottom: 0;
    }

    .dashboard-menu {
        background-color: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .dashboard-menu li {
        border-bottom: 1px solid #eee;
    }

    .dashboard-menu li:last-child {
        border-bottom: none;
    }

    .dashboard-menu a {
        display: block;
        padding: 15px 20px;
        color: #333;
        text-decoration: none;
        transition: all 0.3s;
    }

    .dashboard-menu a i {
        margin-right: 10px;
        color: #4a6bdf;
    }

    .dashboard-menu li.active a,
    .dashboard-menu a:hover {
        background-color: #f8f9fa;
        color: #4a6bdf;
    }

    .dashboard-header {
        margin-bottom: 30px;
    }

    .dashboard-header h2 {
        font-size: 24px;
        margin-bottom: 10px;
        color: #333;
    }

    .dashboard-header p {
        color: #666;
        margin-bottom: 0;
    }

    .dashboard-stats {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }

    .stat-card {
        background-color: #fff;
        border-radius: 8px;
        padding: 20px;
        display: flex;
        align-items: center;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    .stat-icon {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background-color: #4a6bdf;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 15px;
    }

    .stat-icon i {
        font-size: 20px;
        color: #fff;
    }

    .stat-info h3 {
        font-size: 24px;
        margin-bottom: 5px;
        color: #333;
    }

    .stat-info p {
        font-size: 14px;
        color: #666;
        margin-bottom: 0;
    }

    .dashboard-sections {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 20px;
    }

    .dashboard-section-card {
        background-color: #fff;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    .dashboard-section-card h3 {
        font-size: 18px;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 1px solid #eee;
        color: #333;
    }

    .empty-state {
        text-align: center;
        padding: 30px 0;
    }

    .empty-state i {
        font-size: 40px;
        color: #ddd;
        margin-bottom: 15px;
    }

    .empty-state p {
        color: #888;
        margin-bottom: 15px;
    }

    .btn-primary {
        background-color: #4a6bdf;
        color: #fff;
        border: none;
        padding: 8px 15px;
        border-radius: 4px;
        text-decoration: none;
        transition: background-color 0.3s;
    }

    .btn-primary:hover {
        background-color: #3a5bce;
    }

    /* Shop by Category Styles */
    .shop-categories-section {
        margin-top: 30px;
    }

    .shop-categories-section h3 {
        font-size: 20px;
        margin-bottom: 20px;
        color: #333;
    }

    .category-cards {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 20px;
    }

    .category-card {
        display: block;
        text-decoration: none;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
        transition: transform 0.3s, box-shadow 0.3s;
    }

    .category-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    }

    .category-image {
        height: 150px;
        background-size: cover;
        background-position: center;
    }

    .category-card h4 {
        padding: 15px;
        margin: 0;
        text-align: center;
        color: #333;
        font-size: 16px;
        background-color: #fff;
    }

    /* Featured Products Styles */
    .featured-products-section {
        margin-top: 30px;
    }

    .featured-products-section h3 {
        font-size: 20px;
        margin-bottom: 20px;
        color: #333;
    }

    .featured-products-slider {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 20px;
        margin-bottom: 20px;
    }

    .product-card {
        background-color: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
        transition: transform 0.3s, box-shadow 0.3s;
    }

    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    }

    .product-image {
        position: relative;
        height: 200px;
        overflow: hidden;
    }

    .product-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .product-actions {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        gap: 10px;
        opacity: 0;
        transition: opacity 0.3s;
    }

    .product-image:hover .product-actions {
        opacity: 1;
    }

    .btn-view, .btn-add-cart {
        padding: 8px 15px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 14px;
        transition: all 0.3s;
    }

    .btn-view {
        background-color: #fff;
        color: #333;
    }

    .btn-add-cart {
        background-color: #4a6bdf;
        color: #fff;
    }

    .badge {
        position: absolute;
        top: 10px;
        right: 10px;
        padding: 5px 10px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
    }

    .badge.featured {
        background-color: #4a6bdf;
        color: #fff;
    }

    .product-info {
        padding: 15px;
    }

    .product-name {
        font-size: 16px;
        margin-bottom: 5px;
        color: #333;
    }

    .product-category {
        font-size: 12px;
        color: #666;
        margin-bottom: 10px;
    }

    .product-price {
        font-size: 18px;
        font-weight: 600;
        color: #4a6bdf;
        margin-bottom: 10px;
    }

    .product-rating {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .stars {
        color: #ffc107;
    }

    .rating-count {
        font-size: 12px;
        color: #666;
    }

    .view-all-products {
        text-align: center;
        margin-top: 20px;
    }
</style>

<%@ include file="/includes/footer.jsp" %>
