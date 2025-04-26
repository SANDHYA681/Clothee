<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ include file="/includes/header.jsp" %>

<%
    // Get products from request
    List<Product> products = (List<Product>) request.getAttribute("products");

    // Get user from session
    User user = (User) session.getAttribute("user");

    // Get category from request
    String category = request.getParameter("category");
    if (category == null) {
        category = "All Products";
    }
%>
    if (category != null) {
        if ("Men".equals(category)) {
            bannerImage = "https://images.unsplash.com/photo-1516257984-b1b4d707412e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80";
            pageTitle = "Men's Collection";
            pageSubtitle = "Stylish and comfortable clothing for men";
        } else if ("Women".equals(category)) {
            bannerImage = "https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80";
            pageTitle = "Women's Collection";
            pageSubtitle = "Elegant and fashionable clothing for women";
        } else if ("Kids".equals(category)) {
            bannerImage = "https://images.unsplash.com/photo-1519457431-44ccd64a579b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80";
            pageTitle = "Kids' Collection";
            pageSubtitle = "Comfortable and durable clothing for children";
        } else if ("Accessories".equals(category)) {
            bannerImage = "https://images.unsplash.com/photo-1523206489230-c012c64b2b48?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80";
            pageTitle = "Accessories";
            pageSubtitle = "Complete your look with our stylish accessories";
        }
    }

    // Set search-specific title
    if (searchKeyword != null && !searchKeyword.isEmpty()) {
        pageTitle = "Search Results";
        pageSubtitle = "Results for \"" + searchKeyword + "\"";
    }
%>

<div class="page-header" style="background-image: url('<%= bannerImage %>')">
    <div class="page-header-content">
        <h1 class="page-title"><%= pageTitle.toUpperCase() %></h1>
        <p class="page-subtitle"><%= pageSubtitle %></p>
    </div>
</div>

<section class="products-section">
    <div class="container">
        <div class="products-wrapper">
            <!-- Sidebar with filters -->
            <div class="products-sidebar">
                <div class="sidebar-widget">
                    <h3 class="widget-title">Categories</h3>
                    <ul class="category-list">
                        <li><a href="ProductServlet" class="<%= category == null ? "active" : "" %>">All Products</a></li>
                        <li><a href="ProductServlet?category=Men" class="<%= "Men".equals(category) ? "active" : "" %>">Men</a></li>
                        <li><a href="ProductServlet?category=Women" class="<%= "Women".equals(category) ? "active" : "" %>">Women</a></li>
                        <li><a href="ProductServlet?category=Kids" class="<%= "Kids".equals(category) ? "active" : "" %>">Kids</a></li>
                        <li><a href="ProductServlet?category=Accessories" class="<%= "Accessories".equals(category) ? "active" : "" %>">Accessories</a></li>
                    </ul>
                </div>

                <div class="sidebar-widget">
                    <h3 class="widget-title">Price Range</h3>
                    <div class="price-filter">
                        <form action="ProductServlet" method="get">
                            <% if (category != null) { %>
                            <input type="hidden" name="category" value="<%= category %>">
                            <% } %>
                            <% if (searchKeyword != null) { %>
                            <input type="hidden" name="search" value="<%= searchKeyword %>">
                            <% } %>

                            <div class="price-options">
                                <label class="radio-container">
                                    <input type="radio" name="price" value="all" <%= priceRange == null || "all".equals(priceRange) ? "checked" : "" %>>
                                    <span class="checkmark"></span>
                                    All Prices
                                </label>
                                <label class="radio-container">
                                    <input type="radio" name="price" value="0-25" <%= "0-25".equals(priceRange) ? "checked" : "" %>>
                                    <span class="checkmark"></span>
                                    Under $25
                                </label>
                                <label class="radio-container">
                                    <input type="radio" name="price" value="25-50" <%= "25-50".equals(priceRange) ? "checked" : "" %>>
                                    <span class="checkmark"></span>
                                    $25 - $50
                                </label>
                                <label class="radio-container">
                                    <input type="radio" name="price" value="50-100" <%= "50-100".equals(priceRange) ? "checked" : "" %>>
                                    <span class="checkmark"></span>
                                    $50 - $100
                                </label>
                                <label class="radio-container">
                                    <input type="radio" name="price" value="100+" <%= "100+".equals(priceRange) ? "checked" : "" %>>
                                    <span class="checkmark"></span>
                                    Over $100
                                </label>
                            </div>

                            <button type="submit" class="btn btn-filter">Apply Filter</button>
                        </form>
                    </div>
                </div>

                <div class="sidebar-widget">
                    <h3 class="widget-title">Sort By</h3>
                    <form action="ProductServlet" method="get">
                        <% if (category != null) { %>
                        <input type="hidden" name="category" value="<%= category %>">
                        <% } %>
                        <% if (searchKeyword != null) { %>
                        <input type="hidden" name="search" value="<%= searchKeyword %>">
                        <% } %>
                        <% if (priceRange != null) { %>
                        <input type="hidden" name="price" value="<%= priceRange %>">
                        <% } %>

                        <div class="sort-options">
                            <select name="sort" class="sort-select">
                                <option value="" disabled>Select sorting option</option>
                                <option value="featured" <%= "featured".equals(sortBy) ? "selected" : "" %>>Featured</option>
                                <option value="price-low" <%= "price-low".equals(sortBy) ? "selected" : "" %>>Price: Low to High</option>
                                <option value="price-high" <%= "price-high".equals(sortBy) ? "selected" : "" %>>Price: High to Low</option>
                                <option value="newest" <%= "newest".equals(sortBy) ? "selected" : "" %>>Newest</option>
                            </select>
                            <button type="submit" class="btn btn-filter" style="margin-top: 10px;">Apply Sort</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Main content with products -->
            <div class="products-content">
                <!-- Search bar -->
                <div class="search-container">
                    <form action="ProductServlet" method="get" class="search-form">
                        <input type="text" name="search" placeholder="Search products..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                        <button type="submit" class="search-btn"><i class="fas fa-search"></i></button>
                    </form>
                </div>

                <!-- Products count and active filters -->
                <div class="products-header">
                    <div class="products-count">
                        <p>Showing <%= products != null ? products.size() : 0 %> products</p>
                    </div>

                    <div class="active-filters">
                        <% if (category != null) { %>
                        <div class="filter-tag">
                            Category: <%= category %>
                            <a href="ProductServlet<%= searchKeyword != null ? "?search=" + searchKeyword : "" %>" class="remove-filter"><i class="fas fa-times"></i></a>
                        </div>
                        <% } %>

                        <% if (priceRange != null && !"all".equals(priceRange)) { %>
                        <div class="filter-tag">
                            Price: <%= priceRange %>
                            <a href="ProductServlet?<%= category != null ? "category=" + category : "" %><%= searchKeyword != null ? "&search=" + searchKeyword : "" %>" class="remove-filter"><i class="fas fa-times"></i></a>
                        </div>
                        <% } %>

                        <% if (searchKeyword != null) { %>
                        <div class="filter-tag">
                            Search: <%= searchKeyword %>
                            <a href="ProductServlet<%= category != null ? "?category=" + category : "" %>" class="remove-filter"><i class="fas fa-times"></i></a>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Products grid -->
                <div class="products-grid">
                    <% if (products == null || products.isEmpty()) { %>
                    <div class="no-products">
                        <i class="fas fa-search"></i>
                        <h3>No products found</h3>
                        <p>Try adjusting your search or filter to find what you're looking for.</p>
                        <a href="ProductServlet" class="btn btn-primary">View All Products</a>
                    </div>
                    <% } else { %>
                        <% for (Product product : products) { %>
                        <div class="product-card">
                            <div class="product-image">
                                <img src="<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
                                <div class="product-actions">
                                    <a href="ProductDetailsServlet?id=<%= product.getId() %>" class="btn-view">View Details</a>
                                    <% if (session.getAttribute("userId") != null) { %>
                                    <form action="CartServlet" method="get" style="display: inline;">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="productId" value="<%= product.getId() %>">
                                        <input type="hidden" name="quantity" value="1">
                                        <button type="submit" class="btn-add-cart">Add to Cart</button>
                                    </form>
                                    <% } else { %>
                                    <a href="login.jsp?redirectUrl=<%= java.net.URLEncoder.encode("ProductServlet", "UTF-8") %>" class="btn-add-cart">Add to Cart</a>
                                    <% } %>
                                </div>
                                <% if (product.isFeatured()) { %>
                                <span class="badge featured">Featured</span>
                                <% } %>
                            </div>
                            <div class="product-info">
                                <h3 class="product-name"><%= product.getName() %></h3>
                                <p class="product-category"><%= product.getCategory() %></p>
                                <div class="product-price">$<%= String.format("%.2f", product.getPrice()) %></div>
                                <div class="product-rating">
                                    <div class="stars">
                                        <%
                                        // Simulate random ratings between 3 and 5 stars
                                        int stars = 3 + (int)(Math.random() * 3);
                                        for (int i = 1; i <= 5; i++) {
                                            if (i <= stars) {
                                        %>
                                        <i class="fas fa-star"></i>
                                        <% } else { %>
                                        <i class="far fa-star"></i>
                                        <% } } %>
                                    </div>
                                    <span class="rating-count"><%= 5 + (int)(Math.random() * 20) %> reviews</span>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
/* Products Page Styles */
.products-section {
    padding: 40px 0;
}

.products-wrapper {
    display: flex;
    gap: 30px;
}

.products-sidebar {
    width: 280px;
    flex-shrink: 0;
}

.products-content {
    flex-grow: 1;
}

.sidebar-widget {
    margin-bottom: 30px;
    padding: 20px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.widget-title {
    font-size: 18px;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid #eee;
    color: #333;
}

.category-list {
    list-style: none;
    padding: 0;
    margin: 0;
}

.category-list li {
    margin-bottom: 10px;
}

.category-list a {
    display: block;
    padding: 8px 0;
    color: #666;
    text-decoration: none;
    transition: all 0.3s;
}

.category-list a:hover, .category-list a.active {
    color: #4a6bdf;
    padding-left: 5px;
}

.price-filter, .sort-options {
    margin-top: 15px;
}

.price-options {
    margin-bottom: 15px;
}

.radio-container {
    display: block;
    position: relative;
    padding-left: 30px;
    margin-bottom: 12px;
    cursor: pointer;
    font-size: 14px;
    color: #666;
}

.radio-container input {
    position: absolute;
    opacity: 0;
    cursor: pointer;
}

.checkmark {
    position: absolute;
    top: 0;
    left: 0;
    height: 18px;
    width: 18px;
    background-color: #eee;
    border-radius: 50%;
}

.radio-container:hover input ~ .checkmark {
    background-color: #ccc;
}

.radio-container input:checked ~ .checkmark {
    background-color: #4a6bdf;
}

.checkmark:after {
    content: "";
    position: absolute;
    display: none;
}

.radio-container input:checked ~ .checkmark:after {
    display: block;
}

.radio-container .checkmark:after {
    top: 6px;
    left: 6px;
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: white;
}

.btn-filter {
    width: 100%;
    padding: 10px;
    background-color: #4a6bdf;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s;
}

.btn-filter:hover {
    background-color: #3a5bce;
}

.sort-select {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    background-color: #fff;
    color: #333;
}

.search-container {
    margin-bottom: 20px;
}

.search-form {
    display: flex;
    border: 1px solid #ddd;
    border-radius: 4px;
    overflow: hidden;
}

.search-form input {
    flex-grow: 1;
    padding: 12px 15px;
    border: none;
    outline: none;
}

.search-btn {
    padding: 0 15px;
    background-color: #4a6bdf;
    color: white;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s;
}

.search-btn:hover {
    background-color: #3a5bce;
}

.products-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #eee;
}

.products-count {
    color: #666;
}

.active-filters {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.filter-tag {
    display: inline-flex;
    align-items: center;
    padding: 5px 10px;
    background-color: #f5f5f5;
    border-radius: 20px;
    font-size: 12px;
    color: #666;
}

.remove-filter {
    margin-left: 5px;
    color: #999;
    text-decoration: none;
}

.remove-filter:hover {
    color: #ff6b6b;
}

.products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 25px;
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
    transition: transform 0.5s;
}

.product-card:hover .product-image img {
    transform: scale(1.05);
}

.product-actions {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    display: flex;
    padding: 10px;
    background-color: rgba(0, 0, 0, 0.7);
}

.btn-view, .btn-add-cart {
    flex: 1;
    padding: 8px 12px;
    text-align: center;
    color: #fff;
    background-color: transparent;
    border: none;
    cursor: pointer;
    font-size: 14px;
    transition: background-color 0.3s;
    text-decoration: none;
}

.btn-view:hover, .btn-add-cart:hover {
    background-color: rgba(255, 255, 255, 0.2);
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
    margin: 0 0 5px;
    color: #333;
}

.product-category {
    font-size: 12px;
    color: #888;
    margin: 0 0 10px;
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
}

.stars {
    color: #ffc107;
    margin-right: 5px;
}

.rating-count {
    font-size: 12px;
    color: #888;
}

.no-products {
    grid-column: 1 / -1;
    padding: 50px 0;
    text-align: center;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.no-products i {
    font-size: 48px;
    color: #ddd;
    margin-bottom: 15px;
}

.no-products h3 {
    font-size: 20px;
    margin-bottom: 10px;
    color: #333;
}

.no-products p {
    color: #666;
    margin-bottom: 20px;
}

.btn-primary {
    display: inline-block;
    padding: 10px 20px;
    background-color: #4a6bdf;
    color: white;
    border: none;
    border-radius: 4px;
    text-decoration: none;
    transition: background-color 0.3s;
}

.btn-primary:hover {
    background-color: #3a5bce;
}

@media (max-width: 992px) {
    .products-wrapper {
        flex-direction: column;
    }

    .products-sidebar {
        width: 100%;
    }
}
</style>

<%@ include file="/includes/footer.jsp" %>
