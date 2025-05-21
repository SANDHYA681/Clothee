<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page errorPage="/error.jsp" %>

<%
    try {
        // Include header
        request.getRequestDispatcher("/includes/header.jsp").include(request, response);

        // Get attributes from request
        Product product = (Product) request.getAttribute("product");
        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/ProductServlet");
            return;
        }

        List<Product> relatedProducts = (List<Product>) request.getAttribute("relatedProducts");
        if (relatedProducts == null) {
            relatedProducts = new ArrayList<>();
        }

        String tab = (String) request.getAttribute("tab");
        if (tab == null) {
            tab = "description";
        }

        // Check if user is logged in
        User user = (User) session.getAttribute("user");

        // Get reviews from request attributes
        List<Review> reviews = (List<Review>) request.getAttribute("reviews");
        if (reviews == null) {
            reviews = new ArrayList<>();
        }

        // Get average rating from request attributes
        double avgRating = 0;
        if (request.getAttribute("avgRating") != null) {
            avgRating = (Double) request.getAttribute("avgRating");
        }

        // Check if user has already reviewed this product
        boolean hasReviewed = false;
        if (request.getAttribute("hasReviewed") != null) {
            hasReviewed = (Boolean) request.getAttribute("hasReviewed");
        }

        // Get user review if any
        Review userReview = null;
        if (request.getAttribute("userReview") != null) {
            userReview = (Review) request.getAttribute("userReview");
        }

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");

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
        <div class="breadcrumb-container">
            <div class="breadcrumb">
                <a href="HomeServlet">Home</a>
                <span class="separator"><i class="fas fa-chevron-right"></i></span>
                <a href="ProductServlet">Products</a>
                <span class="separator"><i class="fas fa-chevron-right"></i></span>
                <a href="ProductServlet?category=<%= product.getCategory() %>"><%= product.getCategory() %></a>
                <span class="separator"><i class="fas fa-chevron-right"></i></span>
                <span><%= product.getName() %></span>
            </div>
            <% if (user != null && user.isAdmin()) { %>
            <div class="back-to-dashboard">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="dashboard-btn">
                    <i class="fas fa-tachometer-alt"></i> Back To Dashboard
                </a>
            </div>
            <% } %>
        </div>

        <div class="product-details">
            <div class="product-gallery">
                <%
                // Get all images (main + additional)
                List<String> allImages = new ArrayList<>();
                try {
                    if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) {
                        allImages.add(product.getImageUrl());
                    } else {
                        allImages.add("images/products/placeholder.jpg");
                    }

                    // Add additional images if available
                    List<String> additionalImages = product.getAdditionalImages();
                    if (additionalImages != null && !additionalImages.isEmpty()) {
                        for (String img : additionalImages) {
                            if (img != null && !img.isEmpty() && !img.equals(product.getImageUrl())) {
                                allImages.add(img);
                            }
                        }
                    }

                    // Ensure we have at least one image
                    if (allImages.isEmpty()) {
                        allImages.add("images/products/placeholder.jpg");
                    }
                } catch (Exception e) {
                    System.out.println("Error getting product images: " + e.getMessage());
                    e.printStackTrace();
                    allImages.add("images/products/placeholder.jpg");
                }
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
                    <%
                    try {
                        for (int i = 0; i < allImages.size(); i++) {
                            String imgUrl = allImages.get(i);
                    %>
                    <div class="product-thumbnail <%= i == 0 ? "active" : "" %>" onclick="changeMainImage('<%= request.getContextPath() %>/<%= imgUrl %>', this)">
                        <img src="<%= request.getContextPath() %>/<%= imgUrl %>" alt="<%= product.getName() %> - Image <%= i+1 %>">
                    </div>
                    <%
                        }
                    } catch (Exception e) {
                        System.out.println("Error displaying image thumbnails: " + e.getMessage());
                        e.printStackTrace();
                    }
                    %>
                </div>
            </div>

            <div class="product-info">
                <div class="product-category"><%= product.getCategory() %> / <%= product.getType() %></div>
                <h1 class="product-title"><%= product.getName() %></h1>

                <div class="product-rating">
                    <div class="stars">
                        <%
                        // Display actual average rating
                        int fullStars = (int) Math.floor(avgRating);
                        boolean hasHalfStar = avgRating - fullStars >= 0.5;

                        for (int i = 1; i <= 5; i++) {
                            if (i <= fullStars) {
                        %>
                            <i class="fas fa-star"></i>
                        <% } else if (i == fullStars + 1 && hasHalfStar) { %>
                            <i class="fas fa-star-half-alt"></i>
                        <% } else { %>
                            <i class="far fa-star"></i>
                        <% } } %>
                    </div>
                    <span class="rating-count"><%= reviews.size() %> <%= reviews.size() == 1 ? "review" : "reviews" %></span>
                </div>

                <div class="product-price">
                    <span class="current-price">$<%= String.format("%.2f", product.getPrice()) %></span>
                </div>

                <div class="product-description">
                    <h3>Product Description</h3>
                    <p><%= product.getDescription() %></p>
                </div>

                <div class="product-details-row">
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
                </div>

                <form action="ProductDetailsServlet" method="get" class="product-actions-form">
                    <input type="hidden" name="action" value="addToCart">
                    <input type="hidden" name="id" value="<%= product.getId() %>">

                    <div class="product-actions">
                        <div class="quantity-selector">
                            <button type="button" class="quantity-btn" id="decreaseQuantity" onclick="decreaseQuantity()">-</button>
                            <input type="number" name="quantity" id="quantity" class="quantity-input" value="<%= quantity %>" min="1" max="<%= product.getStock() %>" <%= product.getStock() <= 0 ? "disabled" : "" %>>
                            <button type="button" class="quantity-btn" id="increaseQuantity" onclick="increaseQuantity(<%= product.getStock() %>)">+</button>
                        </div>

                        <% if (user != null && !user.isAdmin()) { %>
                            <button type="submit" class="add-to-cart-btn" <%= product.getStock() <= 0 ? "disabled" : "" %>>
                                <i class="fas fa-shopping-cart"></i> Add to Cart
                            </button>
                        <% } else if (user != null && user.isAdmin()) { %>
                            <div class="admin-notice">
                                <i class="fas fa-info-circle"></i> Admin users cannot add products to cart
                            </div>
                        <% } else { %>
                            <a href="LoginServlet?message=<%= java.net.URLEncoder.encode("Please login to add items to your cart", "UTF-8") %>&redirectUrl=<%= java.net.URLEncoder.encode("ProductDetailsServlet?id=" + product.getId(), "UTF-8") %>" class="add-to-cart-btn">
                                <i class="fas fa-shopping-cart"></i> Login to Add
                            </a>
                        <% } %>
                    </div>
                </form>

                <div class="product-additional-actions">
                    <div class="product-review-action">
                        <% if (user != null && !user.isAdmin()) { %>
                            <% if (hasReviewed) { %>
                                <a href="ReviewServlet?action=edit&reviewId=<%= userReview.getId() %>" class="btn-write-review">
                                    <i class="fas fa-edit"></i> Edit Your Review
                                </a>
                            <% } else { %>
                                <a href="ReviewServlet?action=add&productId=<%= product.getId() %>" class="btn-write-review">
                                    <i class="fas fa-star"></i> Write a Review
                                </a>
                            <% } %>
                        <% } else if (user == null) { %>
                            <a href="LoginServlet?message=<%= java.net.URLEncoder.encode("Please login to write a review", "UTF-8") %>&redirectUrl=<%= java.net.URLEncoder.encode("ProductDetailsServlet?id=" + product.getId() + "&tab=reviews", "UTF-8") %>" class="btn-write-review">
                                <i class="fas fa-star"></i> Login to Write a Review
                            </a>
                        <% } %>

                        <a href="ProductDetailsServlet?id=<%= product.getId() %>&tab=reviews" class="view-reviews-link">
                            <i class="fas fa-comments"></i> View <%= reviews.size() %> <%= reviews.size() == 1 ? "Review" : "Reviews" %>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="product-tabs">
            <div class="tabs-nav">
                <a href="ProductDetailsServlet?id=<%= product.getId() %>&tab=description" class="tab-item <%= tab == null || "description".equals(tab) ? "active" : "" %>">Description</a>
                <a href="ProductDetailsServlet?id=<%= product.getId() %>&tab=additional-info" class="tab-item <%= "additional-info".equals(tab) ? "active" : "" %>">Additional Information</a>
                <a href="ProductDetailsServlet?id=<%= product.getId() %>&tab=reviews" class="tab-item <%= "reviews".equals(tab) ? "active" : "" %>">Reviews <span class="review-count-badge"><%= reviews.size() %></span></a>
            </div>

            <div class="tab-content <%= tab == null || "description".equals(tab) ? "active" : "" %>" id="description">
                <h3>Product Description</h3>
                <p><%= product.getDescription() %></p>
            </div>

            <div class="tab-content <%= "additional-info".equals(tab) ? "active" : "" %>" id="additional-info">
                <h3>Additional Information</h3>
                <ul>
                    <li><strong>Material:</strong> <span>100% Cotton</span></li>
                    <li><strong>Weight:</strong> <span>0.5 kg</span></li>
                    <li><strong>Dimensions:</strong> <span>30 × 40 × 2 cm</span></li>
                    <li><strong>Color:</strong> <span>Multiple options available</span></li>
                    <li><strong>Size:</strong> <span>S, M, L, XL</span></li>
                </ul>
            </div>

            <div class="tab-content <%= "reviews".equals(tab) ? "active" : "" %>" id="reviews">
                <%
                String message = request.getParameter("message");
                String error = request.getParameter("error");
                if (message != null && !message.isEmpty()) {
                %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i> <%= message.replace("+", " ") %>
                    </div>
                <% } %>

                <% if (error != null && !error.isEmpty()) { %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i> <%= error.replace("+", " ") %>
                    </div>
                <% } %>

                <div class="reviews-summary">
                    <div class="average-rating">
                        <div class="rating-number"><%= String.format("%.1f", avgRating) %></div>
                        <div class="rating-stars">
                            <%
                            // Display average rating stars
                            for (int i = 1; i <= 5; i++) {
                                if (i <= Math.floor(avgRating)) {
                            %>
                                <i class="fas fa-star"></i>
                            <% } else if (i == Math.floor(avgRating) + 1 && avgRating - Math.floor(avgRating) >= 0.5) { %>
                                <i class="fas fa-star-half-alt"></i>
                            <% } else { %>
                                <i class="far fa-star"></i>
                            <% } } %>
                        </div>
                        <div class="rating-count"><%= reviews.size() %> <%= reviews.size() == 1 ? "review" : "reviews" %></div>
                    </div>
                </div>

                <% if (user != null && !user.isAdmin()) { %>
                    <div class="review-form-container">
                        <% if (hasReviewed) { %>
                            <div class="review-form-header">
                                <h3>Your Review</h3>
                                <p>You've already reviewed this product. You can edit your review below.</p>
                            </div>
                            <form action="ReviewServlet" method="post" class="review-form">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="reviewId" value="<%= userReview.getId() %>">
                                <input type="hidden" name="productId" value="<%= product.getId() %>">

                                <div class="rating-input">
                                    <label class="rating-label">Your Rating</label>
                                    <div class="star-rating">
                                        <input type="radio" id="star5" name="rating" value="5" <%= userReview.getRating() == 5 ? "checked" : "" %> required>
                                        <label for="star5" title="5 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star4" name="rating" value="4" <%= userReview.getRating() == 4 ? "checked" : "" %>>
                                        <label for="star4" title="4 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star3" name="rating" value="3" <%= userReview.getRating() == 3 ? "checked" : "" %>>
                                        <label for="star3" title="3 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star2" name="rating" value="2" <%= userReview.getRating() == 2 ? "checked" : "" %>>
                                        <label for="star2" title="2 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star1" name="rating" value="1" <%= userReview.getRating() == 1 ? "checked" : "" %>>
                                        <label for="star1" title="1 star"><i class="fas fa-star"></i></label>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="comment" class="form-label">Your Review</label>
                                    <textarea id="comment" name="comment" class="form-control" required><%= userReview.getComment() %></textarea>
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn-submit-review">Update Review</button>
                                    <a href="ReviewServlet?action=delete&reviewId=<%= userReview.getId() %>&productId=<%= product.getId() %>" class="btn-delete-review" onclick="return confirm('Are you sure you want to delete this review?')">Delete Review</a>
                                </div>
                            </form>
                        <% } else { %>
                            <div class="review-form-header">
                                <h3>Write a Review</h3>
                                <p>Share your thoughts about this product with other customers</p>
                            </div>
                            <form action="ReviewServlet" method="post" class="review-form">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="productId" value="<%= product.getId() %>">

                                <div class="rating-input">
                                    <label class="rating-label">Your Rating</label>
                                    <div class="star-rating">
                                        <input type="radio" id="star5" name="rating" value="5" required>
                                        <label for="star5" title="5 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star4" name="rating" value="4">
                                        <label for="star4" title="4 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star3" name="rating" value="3">
                                        <label for="star3" title="3 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star2" name="rating" value="2">
                                        <label for="star2" title="2 stars"><i class="fas fa-star"></i></label>

                                        <input type="radio" id="star1" name="rating" value="1">
                                        <label for="star1" title="1 star"><i class="fas fa-star"></i></label>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="comment" class="form-label">Your Review</label>
                                    <textarea id="comment" name="comment" class="form-control" required placeholder="What did you like or dislike about this product? How was the quality? Would you recommend it to others?"></textarea>
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn-submit-review">Submit Review</button>
                                </div>
                            </form>
                        <% } %>
                    </div>
                <% } else if (user == null) { %>
                    <div class="login-to-review">
                        <div class="login-to-review-icon">
                            <i class="fas fa-user-circle"></i>
                        </div>
                        <h3>Please login to write a review</h3>
                        <p>Share your thoughts about this product with other customers</p>
                        <a href="LoginServlet?message=<%= java.net.URLEncoder.encode("Please login to write a review", "UTF-8") %>&redirectUrl=<%= java.net.URLEncoder.encode("ProductDetailsServlet?id=" + product.getId() + "&tab=reviews", "UTF-8") %>" class="btn-login-review">Login to Write a Review</a>
                    </div>
                <% } %>

                <div class="reviews-divider">
                    <span>Customer Reviews</span>
                </div>

                <% if (reviews != null && !reviews.isEmpty()) { %>
                    <div class="reviews-list">
                        <% for (Review review : reviews) { %>
                            <div class="review-item">
                                <div class="review-header">
                                    <div class="reviewer-info">
                                        <div class="reviewer-avatar">
                                            <%
                                            // Get the user's profile image
                                            String reviewerImage = "images/avatars/default.png";
                                            try {
                                                // Use the user object from the review if available
                                                User reviewUser = review.getUser();
                                                if (reviewUser != null && reviewUser.getProfileImage() != null && !reviewUser.getProfileImage().isEmpty()) {
                                                    reviewerImage = reviewUser.getProfileImage();
                                                }
                                            } catch (Exception e) {
                                                System.out.println("Error getting reviewer profile image: " + e.getMessage());
                                            }
                                            %>
                                            <img src="<%= reviewerImage %>" alt="<%= review.getUserName() %>">
                                        </div>
                                        <div class="reviewer-name">
                                            <%= review.getUserName() %>
                                            <% if (user != null && user.getId() == review.getUserId()) { %>
                                                <span class="reviewer-badge">You</span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="review-date"><%= review.getReviewDate() != null ? dateFormat.format(review.getReviewDate()) : "Unknown date" %></div>
                                </div>

                                <div class="review-rating">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <i class="fas fa-star <%= (review.getRating() > 0 && i <= review.getRating()) ? "filled" : "" %>"></i>
                                    <% } %>
                                </div>

                                <div class="review-content">
                                    <p><%= review.getComment() != null ? review.getComment() : "No comment provided" %></p>
                                </div>

                                <% if (user != null && (user.getId() == review.getUserId() || user.isAdmin())) { %>
                                    <div class="review-actions">
                                        <% if (user.getId() == review.getUserId()) { %>
                                            <a href="ReviewServlet?action=edit&reviewId=<%= review.getId() %>" class="review-action-link">Edit</a>
                                        <% } %>
                                        <a href="ReviewServlet?action=delete&reviewId=<%= review.getId() %>&productId=<%= product.getId() %>" class="review-action-link" onclick="return confirm('Are you sure you want to delete this review?')">Delete</a>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="no-reviews">
                        <div class="no-reviews-icon">
                            <i class="fas fa-star"></i>
                        </div>
                        <h3>There are no reviews yet for this product</h3>
                        <p>Be the first to share your thoughts and help other customers make informed decisions!</p>
                    </div>
                <% } %>
            </div>
        </div>

        <% if (relatedProducts != null && !relatedProducts.isEmpty()) { %>
            <div class="related-products-section">
                <div class="section-title">
                    <h2>Related Products</h2>
                </div>

                <div class="products-grid">
                    <% for (Product relatedProduct : relatedProducts) { %>
                        <div class="product-card">
                            <div class="product-image">
                                <img src="<%= request.getContextPath() %>/<%= (relatedProduct.getImageUrl() != null && !relatedProduct.getImageUrl().isEmpty()) ? relatedProduct.getImageUrl() : "images/placeholder.jpg" %>" alt="<%= relatedProduct.getName() %>">

                                <% if (relatedProduct.isFeatured()) { %>
                                    <span class="product-badge badge-featured" style="background-color: #ffffff; color: #000000; border: 1px solid #000000; font-weight: bold; padding: 5px 10px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);">Featured</span>
                                <% } %>

                                <div class="product-actions">
                                    <a href="ProductDetailsServlet?id=<%= relatedProduct.getId() %>" class="btn-view">View Details</a>
                                    <% if (user != null && !user.isAdmin()) { %>
                                        <form action="ProductDetailsServlet" method="get" style="display: inline;">
                                            <input type="hidden" name="action" value="addToCart">
                                            <input type="hidden" name="id" value="<%= relatedProduct.getId() %>">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="btn-add-cart">Add to Cart</button>
                                        </form>
                                        <!-- Wishlist button removed -->
                                    <% } %>
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
/* Tab Content Styles */
.tab-content {
    display: none;
}

.tab-content.active {
    display: block;
}

/* Product Description Styles */
.product-description {
    margin: 25px 0;
    width: 100%;
}

.product-description h3 {
    font-weight: 600;
    color: #333;
}

.product-description p {
    white-space: pre-line;
    font-size: 16px;
    line-height: 1.8;
    color: #333;
    margin-top: 15px;
}

/* Reviews Styles */
.product-additional-actions {
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 30px;
    background-color: #f5f5f5;
    padding: 15px 20px;
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    max-width: 500px;
    margin-left: auto;
    margin-right: auto;
}

.product-review-action {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 15px;
    flex-wrap: wrap;
    width: 100%;
}

.btn-write-review {
    display: inline-flex;
    align-items: center;
    padding: 10px 15px;
    background-color: #ffffff;
    color: #000000;
    border: 1px solid #000000;
    border-radius: 4px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    font-size: 14px;
}

.btn-write-review:hover {
    background-color: #000000;
    color: #ffffff;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn-write-review i {
    margin-right: 8px;
}

.view-reviews-link {
    display: inline-flex;
    align-items: center;
    color: #555;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    font-size: 14px;
}

.view-reviews-link:hover {
    color: #000000;
    transform: translateY(-2px);
}

.view-reviews-link i {
    margin-right: 8px;
}

.review-count-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 20px;
    height: 20px;
    padding: 0 6px;
    background-color: #ff6b6b;
    color: white;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 600;
    margin-left: 5px;
}

.reviews-summary {
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 30px auto;
    padding: 25px;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    background-color: #ffffff;
    max-width: 500px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.reviews-summary:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

.average-rating {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.rating-number {
    font-size: 48px;
    font-weight: 700;
    color: #333;
    line-height: 1;
    margin-bottom: 10px;
}

.rating-stars {
    color: #ffc107;
    font-size: 24px;
    margin-bottom: 10px;
}

.rating-count {
    color: #555;
    font-size: 16px;
    font-weight: 500;
}

.btn-review {
    display: inline-flex;
    align-items: center;
    padding: 12px 25px;
    background-color: #ff6b6b;
    color: white;
    border-radius: 4px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    font-size: 16px;
}

.btn-review:hover {
    background-color: #ff5252;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn-review::before {
    content: '\f005'; /* Star icon */
    font-family: 'Font Awesome 5 Free';
    font-weight: 900;
    margin-right: 10px;
}

.reviews-list {
    margin: 25px auto;
    max-width: 600px;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.review-item {
    background-color: #ffffff;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    border: 1px solid #e0e0e0;
    width: 100%;
    max-width: 500px;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.review-item:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

.review-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.reviewer-info {
    display: flex;
    align-items: center;
}

.reviewer-avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    overflow: hidden;
    margin-right: 10px;
    border: 1px solid #e0e0e0;
}

.reviewer-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.reviewer-name {
    font-weight: 600;
    color: #333;
    font-size: 14px;
}

.reviewer-badge {
    display: inline-block;
    background-color: #000000;
    color: white;
    font-size: 10px;
    padding: 2px 6px;
    border-radius: 10px;
    margin-left: 6px;
    vertical-align: middle;
}

.review-date {
    color: #777;
    font-size: 13px;
    font-style: italic;
}

.review-rating {
    margin-bottom: 10px;
    color: #ddd;
    font-size: 16px;
}

.review-rating .filled {
    color: #ffc107;
}

.review-content p {
    margin: 0;
    line-height: 1.6;
    color: #444;
    font-size: 13px;
}

.review-actions {
    margin-top: 10px;
    text-align: right;
}

.review-action-link {
    color: #777;
    margin-left: 10px;
    text-decoration: none;
    font-size: 12px;
    transition: color 0.3s ease;
}

.review-action-link:hover {
    color: #000000;
}

.no-reviews {
    text-align: center;
    padding: 25px;
    background-color: #ffffff;
    border-radius: 8px;
    color: #555;
    border: 1px solid #e0e0e0;
    margin: 25px auto;
    max-width: 500px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.no-reviews:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

.no-reviews-icon {
    font-size: 24px;
    color: #000000;
    margin-bottom: 10px;
    opacity: 0.6;
}

.no-reviews h3 {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 8px;
    color: #333;
}

.no-reviews p {
    font-size: 14px;
    line-height: 1.5;
    margin-bottom: 0;
    max-width: 280px;
    margin-left: auto;
    margin-right: auto;
    color: #555;
}

.btn-review-large {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 15px 30px;
    background-color: #ff6b6b;
    color: white;
    border-radius: 4px;
    text-decoration: none;
    font-weight: 600;
    font-size: 18px;
    transition: all 0.3s ease;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.btn-review-large:hover {
    background-color: #ff5252;
    transform: translateY(-3px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}

.btn-review-large::before {
    content: '\f005'; /* Star icon */
    font-family: 'Font Awesome 5 Free';
    font-weight: 900;
    margin-right: 10px;
    font-size: 20px;
}

/* Review Form Styles */
.review-form-container {
    background-color: #f9f9f9;
    border-radius: 8px;
    padding: 20px;
    margin: 20px auto;
    border: 1px solid #eee;
    max-width: 500px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.review-form-header {
    margin-bottom: 15px;
    text-align: center;
}

.review-form-header h3 {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin-bottom: 5px;
}

.review-form-header p {
    color: #777;
    font-size: 14px;
    margin-bottom: 0;
}

.review-form .form-group {
    margin-bottom: 15px;
}

.review-form .form-label {
    display: block;
    font-weight: 500;
    margin-bottom: 5px;
    color: #333;
    font-size: 14px;
}

.review-form .form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-family: inherit;
    font-size: 14px;
    resize: vertical;
    min-height: 80px;
}

.review-form .form-control:focus {
    border-color: #ff6b6b;
    outline: none;
    box-shadow: 0 0 0 2px rgba(255, 107, 107, 0.2);
}

.review-form .form-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.btn-submit-review {
    padding: 8px 15px;
    background-color: #000000;
    color: white;
    border: none;
    border-radius: 4px;
    font-family: inherit;
    font-weight: 500;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
}

.btn-submit-review:hover {
    background-color: #333;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn-submit-review::before {
    content: '\f164'; /* Thumbs up icon */
    font-family: 'Font Awesome 5 Free';
    font-weight: 900;
    margin-right: 8px;
}

.btn-delete-review {
    padding: 8px 15px;
    background-color: transparent;
    color: #e74c3c;
    border: 1px solid #e74c3c;
    border-radius: 4px;
    font-family: inherit;
    font-weight: 500;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
}

.btn-delete-review:hover {
    background-color: #e74c3c;
    color: white;
}

.btn-delete-review::before {
    content: '\f2ed'; /* Trash icon */
    font-family: 'Font Awesome 5 Free';
    font-weight: 900;
    margin-right: 8px;
}

/* Login to Review Styles */
.login-to-review {
    background-color: #ffffff;
    border-radius: 8px;
    padding: 25px;
    margin: 25px auto;
    text-align: center;
    border: 1px solid #e0e0e0;
    max-width: 500px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.login-to-review:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

.login-to-review-icon {
    font-size: 24px;
    color: #000000;
    margin-bottom: 10px;
    opacity: 0.7;
}

.login-to-review h3 {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin-bottom: 8px;
}

.login-to-review p {
    color: #555;
    margin-bottom: 12px;
    font-size: 14px;
    line-height: 1.5;
}

.btn-login-review {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 10px 20px;
    background-color: #000000;
    color: white;
    border-radius: 4px;
    text-decoration: none;
    font-weight: 600;
    transition: all 0.3s ease;
    font-size: 14px;
    border: none;
    min-width: 180px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-login-review:hover {
    background-color: #333;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.btn-login-review::before {
    content: '\f2f6'; /* Sign in icon */
    font-family: 'Font Awesome 5 Free';
    font-weight: 900;
    margin-right: 10px;
    font-size: 14px;
}

/* Reviews Divider */
.reviews-divider {
    display: flex;
    align-items: center;
    margin: 30px auto;
    color: #333;
    max-width: 600px;
}

.reviews-divider::before,
.reviews-divider::after {
    content: "";
    flex: 1;
    border-bottom: 2px solid #e0e0e0;
}

.reviews-divider span {
    padding: 0 20px;
    font-weight: 600;
    font-size: 16px;
    text-transform: uppercase;
    letter-spacing: 1px;
}

/* Star Rating Input */
.rating-input {
    margin-bottom: 15px;
}

.rating-label {
    display: block;
    font-weight: 500;
    margin-bottom: 5px;
    color: #333;
    font-size: 14px;
}

.star-rating {
    display: flex;
    flex-direction: row-reverse;
    justify-content: flex-end;
}

.star-rating input {
    display: none;
}

.star-rating label {
    cursor: pointer;
    font-size: 24px;
    color: #ddd;
    padding: 0 3px;
    transition: all 0.2s ease;
}

.star-rating label:hover,
.star-rating label:hover ~ label,
.star-rating input:checked ~ label {
    color: #ffb700;
}

.star-rating label:hover,
.star-rating label:hover ~ label {
    transform: scale(1.1);
}

/* Alert Messages */
.alert {
    padding: 15px;
    border-radius: 4px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
}

.alert i {
    margin-right: 10px;
    font-size: 18px;
}

.alert-success {
    background-color: #d4edda;
    color: #155724;
    border-left: 4px solid #28a745;
}

.alert-danger {
    background-color: #f8d7da;
    color: #721c24;
    border-left: 4px solid #dc3545;
}

.no-reviews p:first-child {
    font-size: 18px;
    margin-bottom: 10px;
}

/* Products Page Styles */
.product-details-section {
    padding: 60px 0;
    background-color: #f9f9f9;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

.breadcrumb-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    flex-wrap: wrap;
}

.breadcrumb {
    display: flex;
    align-items: center;
    font-size: 14px;
    color: #777;
    flex-wrap: wrap;
}

.breadcrumb a {
    color: #777;
    text-decoration: none;
    transition: color 0.3s ease;
}

.breadcrumb a:hover {
    color: #000000;
}

.breadcrumb .separator {
    margin: 0 10px;
}

.product-details {
    display: flex;
    flex-wrap: wrap;
    gap: 40px;
    margin-bottom: 60px;
    align-items: flex-start;
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
}

.product-gallery {
    flex: 1;
    min-width: 300px;
    max-width: 45%;
    position: relative;
    padding-right: 30px;
}

.product-main-image {
    width: 100%;
    height: 450px;
    border-radius: 10px;
    overflow: hidden;
    margin-bottom: 20px;
    position: relative;
    border: 1px solid #e0e0e0;
    background-color: #fff;
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
    border-radius: 5px;
    font-size: 12px;
    font-weight: 600;
    z-index: 2;
    background-color: #ffffff;
    color: #000000;
    border: 1px solid #000000;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}

.product-thumbnails {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-top: 15px;
    justify-content: flex-start;
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
    border-color: #000000;
}

.product-thumbnail img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.product-info {
    flex: 1;
    min-width: 300px;
    max-width: 50%;
    padding-left: 30px;
}

.product-card .product-info {
    padding: 15px;
    min-width: auto;
    max-width: 100%;
    display: flex;
    flex-direction: column;
    flex: 1;
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
    color: #000000;
    font-weight: bold;
    font-size: 24px;
}

.current-price {
    font-size: 28px;
    font-weight: 700;
    color: #000000;
}

.product-description {
    padding: 25px;
    background-color: #f9f9f9;
    border-radius: 8px;
    margin: 25px 0 30px 0;
    border-left: 4px solid #000000;
    box-shadow: 0 3px 10px rgba(0,0,0,0.1);
    width: 100%;
}

.product-description h3 {
    margin-top: 0;
    color: #333;
    font-size: 22px;
    margin-bottom: 15px;
    border-bottom: 2px solid #000000;
    padding-bottom: 10px;
    font-weight: 600;
}

.product-description p {
    line-height: 1.9;
    color: #333;
    font-size: 16px;
    font-weight: 400;
    white-space: pre-line;
}

.product-details-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    flex-wrap: wrap;
    gap: 20px;
}

.product-meta {
    flex: 1;
    min-width: 250px;
    background-color: #f5f5f5;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.meta-item {
    display: flex;
    margin-bottom: 10px;
}

.meta-item:last-child {
    margin-bottom: 0;
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
    padding: 10px 15px;
    font-size: 16px;
    background-color: #f5f5f5;
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 600;
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

.product-actions-form {
    width: 100%;
    max-width: 400px;
    margin: 0 auto 30px auto;
}

.product-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
    justify-content: center;
}

.quantity-selector {
    display: flex;
    align-items: center;
    border: 1px solid #ddd;
    border-radius: 5px;
    overflow: hidden;
    margin-bottom: 10px;
    width: 100px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}

.quantity-btn {
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f5f5f5;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s ease;
    font-size: 14px;
}

.quantity-btn:hover {
    background-color: #e5e5e5;
}

.quantity-input {
    width: 40px;
    height: 30px;
    border: none;
    text-align: center;
    font-size: 14px;
    font-weight: 600;
    color: #333;
}

.add-to-cart-btn {
    flex: 1;
    height: 36px;
    background-color: #ffffff;
    color: #000000;
    border: 1px solid #000000;
    border-radius: 5px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    text-decoration: none;
    padding: 0 15px;
    min-width: 160px;
}

.add-to-cart-btn:hover {
    background-color: #000000;
    color: #ffffff;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.add-to-cart-btn:disabled {
    background-color: #f5f5f5;
    color: #999;
    border-color: #ddd;
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
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



.product-tabs {
    margin-top: 40px;
    margin-bottom: 60px;
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
}

.tabs-nav {
    display: flex;
    border-bottom: 2px solid #eee;
    margin-bottom: 30px;
}

.tab-item {
    padding: 15px 25px;
    font-size: 16px;
    font-weight: 600;
    color: #555;
    cursor: pointer;
    transition: all 0.3s ease;
    border-bottom: 2px solid transparent;
    text-decoration: none;
    position: relative;
}

.tab-item:hover {
    color: #000000;
}

.tab-item.active {
    color: #000000;
    border-bottom-color: #000000;
}

.review-count-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 20px;
    height: 20px;
    padding: 0 6px;
    background-color: #000000;
    color: white;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 600;
    margin-left: 5px;
}

.tab-content {
    display: none;
    line-height: 1.6;
    color: #555;
    padding: 30px;
    background-color: #ffffff;
    border-radius: 8px;
    margin-bottom: 30px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    max-width: 800px;
    margin-left: auto;
    margin-right: auto;
    border: 1px solid #e0e0e0;
}

.tab-content.active {
    display: block;
}

.tab-content h3 {
    margin-top: 0;
    color: #333;
    font-size: 24px;
    margin-bottom: 20px;
    border-bottom: 2px solid #000000;
    padding-bottom: 12px;
    font-weight: 600;
}

.tab-content p {
    line-height: 1.9;
    color: #333;
    font-size: 16px;
    max-width: 800px;
    margin: 0 auto;
}

.tab-content ul {
    list-style-type: none;
    padding: 0;
    margin: 0;
}

.tab-content li {
    padding: 10px 0;
    border-bottom: 1px solid #eee;
}

.tab-content li:last-child {
    border-bottom: none;
}

.tab-content li strong {
    display: inline-block;
    width: 120px;
    color: #333;
}

.tab-content li span {
    color: #555;
}

.related-products-section {
    margin-top: 60px;
    margin-bottom: 60px;
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
    padding: 30px;
    background-color: #f5f5f5;
    border-radius: 10px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.05);
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
    background-color: #000000;
    bottom: -10px;
    left: 50%;
    transform: translateX(-50%);
}

.products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 25px;
    margin-left: auto;
    margin-right: auto;
}

.product-card {
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
    transition: transform 0.3s, box-shadow 0.3s;
    display: flex;
    flex-direction: column;
    height: 100%;
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
    .product-details {
        flex-direction: column;
        align-items: center;
    }

    .product-gallery,
    .product-info {
        max-width: 100%;
        width: 100%;
        padding: 0;
    }

    .product-main-image {
        height: 400px;
    }

    .product-description,
    .tab-content {
        max-width: 100%;
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

    .tab-item {
        padding: 10px 15px;
        font-size: 14px;
    }

    .product-thumbnails {
        justify-content: center;
    }

    .tab-content {
        padding: 20px;
    }

    .tab-content h3 {
        font-size: 20px;
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
    // Quantity selector for product quantity input
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
        try {
            // Update main image
            var mainImage = document.getElementById('mainImage');
            if (mainImage) {
                mainImage.src = imageUrl || '<%= request.getContextPath() %>/images/products/placeholder.jpg';
            }

            // Update active thumbnail
            if (thumbnailElement) {
                var thumbnails = document.querySelectorAll('.product-thumbnail');
                if (thumbnails) {
                    for (var i = 0; i < thumbnails.length; i++) {
                        thumbnails[i].classList.remove('active');
                    }
                }
                thumbnailElement.classList.add('active');
            }
        } catch (e) {
            console.error('Error changing main image:', e);
        }
    }
</script>

<style>
    /* Admin Notice */
    .admin-notice {
        background-color: #f8f9fa;
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 8px 12px;
        margin: 5px 0;
        color: #6c757d;
        font-size: 13px;
        display: flex;
        align-items: center;
        max-width: 200px;
    }

    .admin-notice i {
        margin-right: 6px;
        color: #000000;
        font-size: 14px;
    }

    /* Back to Dashboard Button */
    .back-to-dashboard {
        margin-left: auto;
    }

    .dashboard-btn {
        display: inline-flex;
        align-items: center;
        padding: 8px 15px;
        background-color: #ffffff;
        color: #000000;
        border: 1px solid #000000;
        border-radius: 5px;
        font-weight: bold;
        text-decoration: none;
        transition: all 0.3s ease;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    }

    .dashboard-btn:hover {
        background-color: #000000;
        color: #ffffff;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
    }

    .dashboard-btn i {
        margin-right: 8px;
    }
</style>

<%
    // Close the try block from the beginning of the page
    } catch (Exception e) {
        System.out.println("Unexpected error in product-details.jsp: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("errorMessage", "An error occurred while displaying the product details. Please try again.");
        request.getRequestDispatcher("/error.jsp").forward(request, response);
        return;
    }
%>

<%@ include file="/includes/footer.jsp" %>
