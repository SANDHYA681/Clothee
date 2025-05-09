<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ include file="/includes/header.jsp" %>

<%
    // Get attributes from request
    Product product = (Product) request.getAttribute("product");
    List<Product> relatedProducts = (List<Product>) request.getAttribute("relatedProducts");
    String tab = (String) request.getAttribute("tab");

    // Check if user is logged in
    User user = (User) session.getAttribute("user");

    // Get quantity parameter (if any)
    String quantityParam = request.getParameter("quantity");
    int quantity = 1;
    if (quantityParam != null && !quantityParam.isEmpty()) {
        try {
            quantity = Integer.parseInt(quantityParam);
            if (quantity < 1) quantity = 1;
            if (quantity > product.getStock()) quantity = product.getStock();
        } catch (NumberFormatException e) {
            // Ignore and use default
        }
    }
%>

<section class="product-details-section">
    <div class="container">
        <div class="breadcrumb">
            <a href="HomeServlet">Home</a>
            <span class="separator"><i class="fas fa-chevron-right"></i></span>
            <a href="ProductServlet">Products</a>
            <span class="separator"><i class="fas fa-chevron-right"></i></span>
            <a href="ProductServlet?category=<%= product.getCategory() %>"><%= product.getCategory() %></a>
            <span class="separator"><i class="fas fa-chevron-right"></i></span>
            <span><%= product.getName() %></span>
        </div>

        <div class="product-details">
            <div class="product-gallery">
                <%
                // Get all images (main + additional)
                List<String> allImages = product.getAllImages();
                %>

                <!-- Main image display -->
                <div class="product-main-image">
                    <img src="<%= request.getContextPath() %>/<%= allImages.get(0) %>" alt="<%= product.getName() %>" id="mainImage">

                    <% if (product.isFeatured()) { %>
                        <span class="product-badge badge-featured">Featured</span>
                    <% } %>
                </div>

                <!-- Image thumbnails -->
                <div class="product-thumbnails">
                    <% for (int i = 0; i < allImages.size(); i++) {
                        String imgUrl = allImages.get(i);
                    %>
                    <div class="product-thumbnail <%= i == 0 ? "active" : "" %>" onclick="changeMainImage('<%= request.getContextPath() %>/<%= imgUrl %>', this)">
                        <img src="<%= request.getContextPath() %>/<%= imgUrl %>" alt="<%= product.getName() %> - Image <%= i+1 %>">
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="product-info">
                <div class="product-category"><%= product.getCategory() %> / <%= product.getType() %></div>
                <h1 class="product-title"><%= product.getName() %></h1>

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

                <div class="product-price">
                    <span class="current-price">$<%= String.format("%.2f", product.getPrice()) %></span>
                </div>

                <div class="product-description">
                    <%= product.getDescription() %>
                </div>

                <div class="product-meta">
                    <div class="meta-item">
                        <span class="meta-label">SKU:</span>
                        <span class="meta-value">CLO-<%= product.getId() %></span>
                    </div>
                    <div class="meta-item">
                        <span class="meta-label">Category:</span>
                        <span class="meta-value"><%= product.getCategory() %></span>
                    </div>
                    <div class="meta-item">
                        <span class="meta-label">Type:</span>
                        <span class="meta-value"><%= product.getType() %></span>
                    </div>
                </div>

                <div class="product-stock">
                    <% if (product.getStock() > 10) { %>
                        <span class="in-stock"><i class="fas fa-check-circle"></i> In Stock</span>
                    <% } else if (product.getStock() > 0) { %>
                        <span class="low-stock"><i class="fas fa-exclamation-circle"></i> Only <%= product.getStock() %> left</span>
                    <% } else { %>
                        <span class="out-of-stock"><i class="fas fa-times-circle"></i> Out of Stock</span>
                    <% } %>
                </div>

                <div class="product-actions">
                    <form action="ProductDetailsServlet" method="get">
                        <input type="hidden" name="action" value="addToCart">
                        <input type="hidden" name="id" value="<%= product.getId() %>">

                        <div class="quantity-selector">
                            <button type="button" class="quantity-btn" id="decreaseQuantity" onclick="decreaseQuantity()">-</button>
                            <input type="number" name="quantity" id="quantity" class="quantity-input" value="<%= quantity %>" min="1" max="<%= product.getStock() %>" <%= product.getStock() <= 0 ? "disabled" : "" %>>
                            <button type="button" class="quantity-btn" id="increaseQuantity" onclick="increaseQuantity(<%= product.getStock() %>)">+</button>
                        </div>

                        <% if (user != null) { %>
                            <button type="submit" class="add-to-cart-btn" <%= product.getStock() <= 0 ? "disabled" : "" %>>
                                <i class="fas fa-shopping-cart"></i> Add to Cart
                            </button>
                            <!-- Wishlist button removed -->
                        <% } else { %>
                            <a href="LoginServlet?message=<%= java.net.URLEncoder.encode("Please login to add items to your cart", "UTF-8") %>&redirectUrl=<%= java.net.URLEncoder.encode("ProductDetailsServlet?id=" + product.getId(), "UTF-8") %>" class="add-to-cart-btn" style="text-decoration: none;">
                                <i class="fas fa-shopping-cart"></i> Login to Add to Cart
                            </a>
                            <!-- Wishlist button removed -->
                        <% } %>
                    </form>
                </div>

                <div class="product-share">
                    <span class="share-label">Share:</span>
                    <div class="share-links">
                        <a href="#" class="share-link"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="share-link"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="share-link"><i class="fab fa-pinterest-p"></i></a>
                        <a href="#" class="share-link"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>
            </div>
        </div>

        <div class="product-tabs">
            <div class="tabs-nav">
                <a href="ProductDetailsServlet?id=<%= product.getId() %>&tab=description" class="tab-item <%= tab == null || "description".equals(tab) ? "active" : "" %>">Description</a>
                <a href="ProductDetailsServlet?id=<%= product.getId() %>&tab=additional-info" class="tab-item <%= "additional-info".equals(tab) ? "active" : "" %>">Additional Information</a>
                <a href="ProductDetailsServlet?id=<%= product.getId() %>&tab=reviews" class="tab-item <%= "reviews".equals(tab) ? "active" : "" %>">Reviews</a>
            </div>

            <div class="tab-content <%= tab == null || "description".equals(tab) ? "active" : "" %>" id="description">
                <p><%= product.getDescription() %></p>
            </div>

            <div class="tab-content <%= "additional-info".equals(tab) ? "active" : "" %>" id="additional-info">
                <p>Additional product information:</p>
                <ul>
                    <li><strong>Material:</strong> 100% Cotton</li>
                    <li><strong>Weight:</strong> 0.5 kg</li>
                    <li><strong>Dimensions:</strong> 30 × 40 × 2 cm</li>
                    <li><strong>Color:</strong> Multiple options available</li>
                    <li><strong>Size:</strong> S, M, L, XL</li>
                </ul>
            </div>

            <div class="tab-content <%= "reviews".equals(tab) ? "active" : "" %>" id="reviews">
                <p>Customer reviews will be displayed here.</p>
                <p>Be the first to review this product!</p>
            </div>
        </div>

        <% if (relatedProducts != null && !relatedProducts.isEmpty()) { %>
            <div class="related-products">
                <div class="section-title">
                    <h2>Related Products</h2>
                </div>

                <div class="products-grid">
                    <% for (Product relatedProduct : relatedProducts) { %>
                        <div class="product-card">
                            <div class="product-image">
                                <img src="<%= request.getContextPath() %>/<%= (relatedProduct.getImageUrl() != null && !relatedProduct.getImageUrl().isEmpty()) ? relatedProduct.getImageUrl() : "images/placeholder.jpg" %>" alt="<%= relatedProduct.getName() %>">

                                <% if (relatedProduct.isFeatured()) { %>
                                    <span class="product-badge badge-featured">Featured</span>
                                <% } %>

                                <div class="product-actions">
                                    <a href="ProductDetailsServlet?id=<%= relatedProduct.getId() %>" class="btn-view">View Details</a>
                                    <form action="ProductDetailsServlet" method="get" style="display: inline;">
                                        <input type="hidden" name="action" value="addToCart">
                                        <input type="hidden" name="id" value="<%= relatedProduct.getId() %>">
                                        <input type="hidden" name="quantity" value="1">
                                        <button type="submit" class="btn-add-cart">Add to Cart</button>
                                    </form>
                                    <!-- Wishlist button removed -->
                                </div>
                            </div>

                            <div class="product-info">
                                <div class="product-category"><%= relatedProduct.getCategory() %> / <%= relatedProduct.getType() %></div>
                                <h3 class="product-name">
                                    <a href="ProductDetailsServlet?id=<%= relatedProduct.getId() %>"><%= relatedProduct.getName() %></a>
                                </h3>

                                <div class="product-price">
                                    <span class="current-price">$<%= String.format("%.2f", relatedProduct.getPrice()) %></span>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>
    </div>
</section>

<style>
/* Products Page Styles */
.product-details-section {
    padding: 60px 0;
    background-color: #f9f9f9;
}

.breadcrumb {
    display: flex;
    align-items: center;
    margin-bottom: 30px;
    font-size: 14px;
    color: #777;
}

.breadcrumb a {
    color: #777;
    text-decoration: none;
    transition: color 0.3s ease;
}

.breadcrumb a:hover {
    color: #ff6b6b;
}

.breadcrumb .separator {
    margin: 0 10px;
}

.product-details {
    display: flex;
    flex-wrap: wrap;
    gap: 40px;
    margin-bottom: 60px;
}

.product-gallery {
    flex: 1;
    min-width: 300px;
}

.product-main-image {
    width: 100%;
    height: 400px;
    border-radius: 10px;
    overflow: hidden;
    margin-bottom: 20px;
    position: relative;
    border: 1px solid #e0e0e0;
}

.product-main-image img {
    width: 100%;
    height: 100%;
    object-fit: contain;
    background-color: #fff;
}

.product-badge {
    position: absolute;
    top: 15px;
    left: 15px;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    z-index: 2;
}

.badge-featured {
    background-color: #ffc107;
    color: #333;
}

.product-thumbnails {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-top: 15px;
    justify-content: center;
}

.product-thumbnail {
    width: 80px;
    height: 80px;
    border-radius: 5px;
    overflow: hidden;
    cursor: pointer;
    border: 2px solid transparent;
    transition: all 0.3s ease;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.product-thumbnail:hover {
    transform: translateY(-3px);
    box-shadow: 0 5px 10px rgba(0,0,0,0.15);
}

.product-thumbnail.active {
    border-color: #ff6b6b;
}

.product-thumbnail img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.product-info {
    flex: 1;
    min-width: 300px;
}

.product-category {
    font-size: 14px;
    color: #777;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 10px;
}

.product-title {
    font-size: 28px;
    color: #333;
    margin-bottom: 15px;
    font-weight: 700;
}

.product-rating {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
}

.stars {
    color: #ffc107;
    margin-right: 10px;
}

.rating-count {
    font-size: 14px;
    color: #777;
}

.product-price {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
}

.current-price {
    font-size: 28px;
    font-weight: 700;
    color: #ff6b6b;
}

.original-price {
    font-size: 20px;
    color: #999;
    text-decoration: line-through;
    margin-left: 15px;
}

.product-description {
    margin-bottom: 30px;
    line-height: 1.6;
    color: #555;
}

.product-meta {
    margin-bottom: 30px;
}

.meta-item {
    display: flex;
    margin-bottom: 10px;
}

.meta-label {
    width: 120px;
    font-weight: 600;
    color: #333;
}

.meta-value {
    color: #555;
}

.product-stock {
    margin-bottom: 20px;
    font-size: 16px;
}

.in-stock {
    color: #28a745;
}

.low-stock {
    color: #ffc107;
}

.out-of-stock {
    color: #dc3545;
}

.product-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    margin-bottom: 30px;
}

.quantity-selector {
    display: flex;
    align-items: center;
    border: 1px solid #ddd;
    border-radius: 5px;
    overflow: hidden;
}

.quantity-btn {
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f5f5f5;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.quantity-btn:hover {
    background-color: #e5e5e5;
}

.quantity-input {
    width: 60px;
    height: 40px;
    border: none;
    text-align: center;
    font-size: 16px;
    font-weight: 600;
    color: #333;
}

.add-to-cart-btn {
    flex: 1;
    height: 50px;
    background-color: #ff6b6b;
    color: white;
    border: none;
    border-radius: 5px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.add-to-cart-btn:hover {
    background-color: #ff5252;
}

.add-to-cart-btn:disabled {
    background-color: #ccc;
    cursor: not-allowed;
}

.wishlist-btn {
    width: 50px;
    height: 50px;
    background-color: #f5f5f5;
    color: #ff8800;
    border: none;
    border-radius: 5px;
    font-size: 22px;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.wishlist-btn:hover {
    background-color: #ff8800;
    color: white;
    transform: translateY(-3px);
    box-shadow: 0 4px 8px rgba(255, 136, 0, 0.3);
}

.product-share {
    display: flex;
    align-items: center;
    gap: 15px;
}

.share-label {
    font-weight: 600;
    color: #333;
}

.share-links {
    display: flex;
    gap: 10px;
}

.share-link {
    width: 35px;
    height: 35px;
    background-color: #f5f5f5;
    color: #333;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    text-decoration: none;
    transition: all 0.3s ease;
}

.share-link:hover {
    background-color: #ff6b6b;
    color: white;
}

.product-tabs {
    margin-bottom: 60px;
}

.tabs-nav {
    display: flex;
    border-bottom: 1px solid #ddd;
    margin-bottom: 30px;
}

.tab-item {
    padding: 15px 30px;
    font-size: 16px;
    font-weight: 600;
    color: #777;
    cursor: pointer;
    transition: all 0.3s ease;
    border-bottom: 2px solid transparent;
    text-decoration: none;
}

.tab-item.active {
    color: #ff6b6b;
    border-bottom-color: #ff6b6b;
}

.tab-content {
    display: none;
    line-height: 1.6;
    color: #555;
}

.tab-content.active {
    display: block;
}

.related-products {
    margin-top: 60px;
}

.section-title {
    text-align: center;
    margin-bottom: 40px;
}

.section-title h2 {
    font-size: 28px;
    color: #333;
    margin-bottom: 10px;
    position: relative;
    display: inline-block;
}

.section-title h2:after {
    content: '';
    position: absolute;
    width: 50px;
    height: 3px;
    background-color: #ff6b6b;
    bottom: -10px;
    left: 50%;
    transform: translateX(-50%);
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

.btn-view, .btn-add-cart, .btn-add-wishlist {
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

.btn-add-wishlist {
    flex: 0.5;
    color: #fff;
    font-size: 18px;
    position: relative;
    z-index: 2;
}

.btn-add-wishlist:hover {
    color: #ff8800;
    transform: scale(1.2);
}

.btn-view:hover, .btn-add-cart:hover {
    background-color: rgba(255, 255, 255, 0.2);
}

@media (max-width: 992px) {
    .product-main-image {
        height: 350px;
    }
}

@media (max-width: 768px) {
    .product-details {
        gap: 30px;
    }

    .product-main-image {
        height: 300px;
    }

    .product-title {
        font-size: 24px;
    }

    .current-price {
        font-size: 24px;
    }

    .original-price {
        font-size: 18px;
    }

    .tab-item {
        padding: 10px 20px;
        font-size: 14px;
    }

    .product-thumbnails {
        justify-content: flex-start;
    }
}

@media (max-width: 576px) {
    .product-main-image {
        height: 250px;
    }

    .product-thumbnail {
        width: 60px;
        height: 60px;
    }

    .product-title {
        font-size: 20px;
    }

    .current-price {
        font-size: 20px;
    }

    .original-price {
        font-size: 16px;
    }

    .tab-item {
        padding: 8px 15px;
        font-size: 13px;
    }
}
</style>

<script>
    // Quantity selector - minimal JavaScript only for UI enhancement
    function decreaseQuantity() {
        const quantityInput = document.getElementById('quantity');
        let value = parseInt(quantityInput.value);
        if (value > 1) {
            quantityInput.value = value - 1;
        }
    }

    function increaseQuantity(max) {
        const quantityInput = document.getElementById('quantity');
        let value = parseInt(quantityInput.value);
        if (value < max) {
            quantityInput.value = value + 1;
        }
    }

    // Function to change the main image when a thumbnail is clicked
    function changeMainImage(imageUrl, thumbnailElement) {
        // Update main image
        document.getElementById('mainImage').src = imageUrl;

        // Update active thumbnail
        const thumbnails = document.querySelectorAll('.product-thumbnail');
        thumbnails.forEach(thumbnail => {
            thumbnail.classList.remove('active');
        });
        thumbnailElement.classList.add('active');
    }
</script>

<%@ include file="/includes/footer.jsp" %>
