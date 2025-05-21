<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Slide" %>
<%@ page import="model.Category" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ include file="/includes/header.jsp" %>
<link rel="stylesheet" type="text/css" href="css/style.css">

<%
// Display success message if available
String message = request.getParameter("message");
if (message != null && !message.isEmpty()) {
%>
<<<<<<< HEAD
<div class="notification notification-success" style="margin: 10px auto; max-width: 800px; text-align: center;">
=======
<div class="success-notification" style="margin: 10px auto; max-width: 800px; text-align: center;">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
    <%= message %>
</div>
<% } %>

<%
    // Get slides from request attribute (set by HomeServlet)
    List<Slide> slides = (List<Slide>) request.getAttribute("slides");
    Integer currentSlideIndex = (Integer) request.getAttribute("currentSlide");

    // Default slide if not set by servlet
    Slide mainSlide;
    if (slides != null && !slides.isEmpty() && currentSlideIndex != null) {
        mainSlide = slides.get(currentSlideIndex);
    } else {
        // Fallback slide if HomeServlet didn't set the attributes
        mainSlide = new Slide(
            "images/hero-clothes.jpg",
            "Elevate Your Style",
            "Discover the latest trends in fashion and express yourself with our premium collection of clothing and accessories.",
            "ProductServlet?category=new",
            "Shop Now",
            "ProductServlet?category=sale",
            "View Sale"
        );
    }

    // Initialize date formatter for product display
%>

<!-- Admin Login Banner -->
<% if (session.getAttribute("userRole") == null) { %>
<div style="background-color: #4a6bdf; color: white; padding: 10px 0; text-align: center;">
    <div style="display: flex; justify-content: center; align-items: center; gap: 20px;">
        <div style="display: flex; align-items: center; gap: 10px;">
            <span class="icon icon-user-shield" style="font-size: 18px;"></span>
            <span>Admin? <a href="admin-login.jsp" style="color: white; text-decoration: underline; font-weight: bold;">Login here</a></span>
        </div>
        <div style="display: flex; align-items: center; gap: 10px;">
            <span class="icon icon-user-plus" style="font-size: 18px;"></span>
            <span>New user? <a href="register.jsp" style="color: white; text-decoration: underline; font-weight: bold;">Register here</a></span>
        </div>
    </div>
</div>
<% } %>

<!-- Hero Section with Single Image -->
<section class="hero-slider">
    <div class="slider-container">
        <div class="slide active">
            <div class="slide-bg" style="background-image: url('<%=request.getContextPath()%>/<%= mainSlide.getImageUrl().startsWith("/") ? mainSlide.getImageUrl().substring(1) : mainSlide.getImageUrl() %>');"></div>
            <div class="slide-overlay"></div>
            <div class="slide-content">
                <div class="slide-text-container">
                    <h1 class="slide-title"><%= mainSlide.getTitle() %></h1>
                    <p class="slide-subtitle"><%= mainSlide.getSubtitle() %></p>
                    <div class="slide-buttons">
<<<<<<< HEAD
                        <a href="<%= slide.getPrimaryButtonUrl() %>" class="button button-primary"><%= slide.getPrimaryButtonText() %></a>
                        <% if (slide.getSecondaryButtonUrl() != null && slide.getSecondaryButtonText() != null) { %>
                        <a href="<%= slide.getSecondaryButtonUrl() %>" class="button button-outline-primary"><%= slide.getSecondaryButtonText() %></a>
=======
                        <a href="<%= mainSlide.getPrimaryButtonUrl() %>" class="action-button primary-button"><%= mainSlide.getPrimaryButtonText() %></a>
                        <% if (mainSlide.getSecondaryButtonUrl() != null && mainSlide.getSecondaryButtonText() != null) { %>
                        <a href="<%= mainSlide.getSecondaryButtonUrl() %>" class="action-button outline-primary-button"><%= mainSlide.getSecondaryButtonText() %></a>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
<<<<<<< HEAD
        <%
            }
        }
        %>
        <a href="index.jsp?slide=prev" class="slider-arrow prev"><span class="icon icon-chevron-left"></span></a>
        <a href="index.jsp?slide=next" class="slider-arrow next"><span class="icon icon-chevron-right"></span></a>
        <div class="slider-dots">
            <%
            if (slides != null) {
                for (int i = 0; i < slides.size(); i++) {
            %>
            <a href="index.jsp?slide=<%= i %>" class="dot <%= i == currentSlide ? "active" : "" %>" data-slide="<%= i %>"></a>
            <%
                }
            }
            %>
        </div>
=======
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
    </div>
</section>

<!-- Features Section with Modern Design -->
<section class="features">
<<<<<<< HEAD
    <div class="layout-container">
=======
    <div class="page-container">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        <div class="features-grid">
            <div class="feature-item">
                <div class="feature-icon">
                    <div class="icon-circle">
                        <span class="icon icon-truck"></span>
                    </div>
                </div>
                <div class="feature-content">
                    <h3 class="feature-title">Free Shipping</h3>
                    <p class="feature-text">On all orders over $50</p>
                </div>
            </div>
            <div class="feature-item">
                <div class="feature-icon">
                    <div class="icon-circle">
                        <span class="icon icon-undo"></span>
                    </div>
                </div>
                <div class="feature-content">
                    <h3 class="feature-title">Easy Returns</h3>
                    <p class="feature-text">30 days return policy</p>
                </div>
            </div>
            <div class="feature-item support-247">
                <div class="feature-icon">
                    <div class="icon-circle">
                        <span class="icon icon-headset"></span>
                    </div>
                </div>
                <div class="feature-content">
                    <h3 class="feature-title">24/7 Support</h3>
                    <p class="feature-text">Dedicated support team</p>
                </div>
            </div>
            <div class="feature-item">
                <div class="feature-icon">
                    <div class="icon-circle">
                        <span class="icon icon-lock"></span>
                    </div>
                </div>
                <div class="feature-content">
                    <h3 class="feature-title">Secure Payment</h3>
                    <p class="feature-text">100% secure checkout</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Categories Section -->
<section class="categories">
<<<<<<< HEAD
    <div class="layout-container">
=======
    <div class="page-container">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        <div class="section-title">
            <h2>Shop By Category</h2>
        </div>

        <div class="categories-grid">
            <%
            // Get categories from database
            CategoryDAO categoryDAO = new CategoryDAO();
            List<Category> categories = categoryDAO.getAllCategories();

            // Display up to 6 categories
            int maxCategories = Math.min(categories.size(), 6);
            for (int i = 0; i < maxCategories; i++) {
                Category category = categories.get(i);
                String imageUrl = category.getImageUrl();
                // Use default image if no image is set
                if (imageUrl == null || imageUrl.isEmpty()) {
                    // Default images based on category index (using local images)
                    String[] defaultImages = {
                        "images/categories/category1.jpg",
                        "images/categories/category2.jpg",
                        "images/categories/category3.jpg",
                        "images/categories/category4.jpg",
                        "images/categories/category5.jpg",
                        "images/categories/category6.jpg"
                    };
                    imageUrl = defaultImages[i % defaultImages.length];
                } else {
                    // Use the image from the database
                    imageUrl = request.getContextPath() + "/" + imageUrl;
                }
            %>
            <div class="category-card">
                <img src="<%= imageUrl %>" alt="<%= category.getName() %>">
                <div class="category-content">
                    <h3 class="category-title"><%= category.getName() %></h3>
                    <a href="ProductServlet?category=<%= category.getId() %>" class="category-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>
            <% } %>

            <% if (categories.isEmpty()) { %>
            <!-- Default categories if no categories in database -->
            <div class="category-card">
                <img src="<%=request.getContextPath()%>/images/categories/category_1.jpg" alt="Women's Fashion">
                <div class="category-content">
                    <h3 class="category-title">Women's Fashion</h3>
                    <a href="ProductServlet?category=women" class="category-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <div class="category-card">
                <img src="<%=request.getContextPath()%>/images/categories/category_2.jpg" alt="Men's Fashion">
                <div class="category-content">
                    <h3 class="category-title">Men's Fashion</h3>
                    <a href="ProductServlet?category=men" class="category-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <div class="category-card">
                <img src="<%=request.getContextPath()%>/images/categories/category_3.jpg" alt="Accessories">
                <div class="category-content">
                    <h3 class="category-title">Accessories</h3>
                    <a href="ProductServlet?category=accessories" class="category-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</section>

<!-- Featured Products -->
<section class="featured-products">
<<<<<<< HEAD
    <div class="layout-container">
=======
    <div class="page-container">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        <div class="section-title">
            <h2>Featured Products</h2>
        </div>

        <div class="products-grid">
            <!-- Product 2 -->
            <div class="product-card">
                <div class="product-img">
                    <img src="<%=request.getContextPath()%>/images/products/product1.jpg" alt="Denim Jacket">
                    <span class="product-tag tag-sale">-25%</span>
                    <div class="product-actions">
                        <a href="CartServlet?action=add&productId=2&quantity=1" class="product-action-btn">
                            <i class="fas fa-shopping-cart"></i>
                        </a>
                        <a href="ProductServlet?action=view&id=2" class="product-action-btn">
                            <i class="fas fa-eye"></i>
                        </a>
                    </div>
                </div>
                <div class="product-info">
                    <span class="product-category">Jackets</span>
                    <h3 class="product-title">Classic Denim Jacket</h3>
                    <div class="product-rating">
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="product-price">
                        <span class="current-price">$74.99</span>
                        <span class="old-price">$99.99</span>
                    </div>
                </div>
            </div>

            <!-- Product 3 -->
            <div class="product-card">
                <div class="product-img">
                    <img src="<%=request.getContextPath()%>/images/products/product2.jpg" alt="Summer Dress">
                    <div class="product-actions">
                        <a href="CartServlet?action=add&productId=3&quantity=1" class="product-action-btn">
                            <i class="fas fa-shopping-cart"></i>
                        </a>
                        <a href="ProductServlet?action=view&id=3" class="product-action-btn">
                            <i class="fas fa-eye"></i>
                        </a>
                    </div>
                </div>
                <div class="product-info">
                    <span class="product-category">Dresses</span>
                    <h3 class="product-title">Floral Summer Dress</h3>
                    <div class="product-rating">
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star"></i>
                        <i class="fas fa-star-half-alt"></i>
                    </div>
                    <div class="product-price">
                        <span class="current-price">$59.99</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Special Offer with Image Background -->
<<<<<<< HEAD
<section class="special-offer" style="background-image: url('https://images.unsplash.com/photo-1607083206968-13611e3d76db?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2215&q=80'); background-size: cover; background-position: center;">
    <div class="layout-container">
=======
<section class="special-offer">
    <div class="page-container">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        <div class="offer-content">
            <span class="offer-subtitle">Limited Time Offer</span>
            <h2 class="offer-title">Summer Sale</h2>
            <p class="offer-description">Get up to 50% off on our summer collection. Hurry up before the offer ends!</p>


<<<<<<< HEAD
            <a href="ProductServlet?category=sale" class="button button-animated">Shop Now <i class="fas fa-arrow-right"></i></a>
=======
            <a href="ProductServlet?category=sale" class="action-button primary-button animated-button">Shop Now <i class="fas fa-arrow-right"></i></a>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        </div>
    </div>
</section>

<!-- Collection Showcase -->	`
<section class="collection-showcase">
<<<<<<< HEAD
    <div class="layout-container">
=======
    <div class="page-container">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        <div class="section-title">
            <h2>Our Collections</h2>
        </div>

        <div class="collections-grid">
            <div class="collection-item large">
                <img src="<%=request.getContextPath()%>/images/collections/collection1.jpg" alt="Premium Collection">
                <div class="collection-content">
                    <h3>Premium Collection</h3>
                    <p>Luxury fabrics and exclusive designs</p>
<<<<<<< HEAD
                    <a href="ProductServlet?category=premium" class="button button-small">Explore</a>
=======
                    <a href="ProductServlet?category=premium" class="action-button primary-button action-button-small">Explore</a>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
                </div>
            </div>

            <div class="collection-item">
                <img src="<%=request.getContextPath()%>/images/collections/collection2.jpg" alt="Casual Collection">
                <div class="collection-content">
                    <h3>Casual Wear</h3>
<<<<<<< HEAD
                    <a href="ProductServlet?category=casual" class="button button-small">Explore</a>
=======
                    <a href="ProductServlet?category=casual" class="action-button primary-button action-button-small">Explore</a>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
                </div>
            </div>

            <div class="collection-item">
                <img src="<%=request.getContextPath()%>/images/collections/collection3.jpg" alt="Formal Collection">
                <div class="collection-content">
                    <h3>Formal Wear</h3>
<<<<<<< HEAD
                    <a href="ProductServlet?category=formal" class="button button-small">Explore</a>
=======
                    <a href="ProductServlet?category=formal" class="action-button primary-button action-button-small">Explore</a>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Testimonials -->
<section class="testimonials">
<<<<<<< HEAD
    <div class="layout-container">
=======
    <div class="page-container">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        <div class="section-title">
            <h2>What Our Customers Say</h2>
        </div>

        <div class="testimonials-slider">
            <div class="testimonial-item">
                <p class="testimonial-text">I absolutely love the quality of clothes from Clothee. The fabrics are premium and the designs are trendy. Will definitely shop again!</p>
                <div class="testimonial-author">
                    <div class="author-img">
                        <img src="<%=request.getContextPath()%>/images/testimonials/customer1.jpg" alt="Sandhya">
                    </div>
                    <h4 class="author-name">Sandhya </h4>
                    <span class="author-role">Regular Customer</span>
                </div>
            </div>
        </div>
    </div>
</section>

<%@ include file="/includes/footer.jsp" %>
