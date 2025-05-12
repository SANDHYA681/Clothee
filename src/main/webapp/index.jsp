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
<div class="alert alert-success" style="margin: 10px auto; max-width: 800px; text-align: center; padding: 10px; background-color: #d4edda; color: #155724; border-radius: 5px;">
    <%= message %>
</div>
<% } %>

<%
    // Create slides directly in the JSP
    List<Slide> slides = new ArrayList<>();

    // Add slides
    slides.add(new Slide(
        "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
        "Elevate Your Style",
        "Discover the latest trends in fashion and express yourself with our premium collection of clothing and accessories.",
        "ProductServlet?category=new",
        "Shop Now",
        "ProductServlet?category=sale",
        "View Sale"
    ));

    slides.add(new Slide(
        "https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1771&q=80",
        "Summer Collection 2023",
        "Beat the heat with our cool and comfortable summer collection.",
        "ProductServlet?category=summer",
        "Explore Collection",
        null,
        null
    ));

    slides.add(new Slide(
        "https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
        "Exclusive Discounts",
        "Up to 50% off on selected items. Limited time offer!",
        "ProductServlet?category=sale",
        "Shop Sale",
        null,
        null
    ));

    // Get current slide (default to 0)
    int currentSlide = 0;
    String slideParam = request.getParameter("slide");
    if (slideParam != null) {
        if ("next".equals(slideParam)) {
            Integer sessionSlide = (Integer) session.getAttribute("currentSlide");
            if (sessionSlide != null) {
                currentSlide = (sessionSlide + 1) % slides.size();
            }
        } else if ("prev".equals(slideParam)) {
            Integer sessionSlide = (Integer) session.getAttribute("currentSlide");
            if (sessionSlide != null) {
                currentSlide = (sessionSlide - 1 + slides.size()) % slides.size();
            }
        } else {
            try {
                currentSlide = Integer.parseInt(slideParam);
                if (currentSlide < 0 || currentSlide >= slides.size()) {
                    currentSlide = 0;
                }
            } catch (NumberFormatException e) {
                currentSlide = 0;
            }
        }
    }

    // Store current slide in session
    session.setAttribute("currentSlide", currentSlide);

    // Countdown timer calculation removed as requested
%>

<!-- Admin Login Banner -->
<% if (session.getAttribute("userRole") == null) { %>
<div style="background-color: #4a6bdf; color: white; padding: 10px 0; text-align: center;">
    <div style="display: flex; justify-content: center; align-items: center; gap: 20px;">
        <div style="display: flex; align-items: center; gap: 10px;">
            <i class="fas fa-user-shield" style="font-size: 18px;"></i>
            <span>Admin? <a href="admin-login.jsp" style="color: white; text-decoration: underline; font-weight: bold;">Login here</a></span>
        </div>
        <div style="display: flex; align-items: center; gap: 10px;">
            <i class="fas fa-user-plus" style="font-size: 18px;"></i>
            <span>New user? <a href="register.jsp" style="color: white; text-decoration: underline; font-weight: bold;">Register here</a></span>
        </div>
    </div>
</div>
<% } %>

<!-- Hero Section with Modern Slider -->
<section class="hero-slider">
    <div class="slider-container">
        <%
        if (slides != null && !slides.isEmpty()) {
            for (int i = 0; i < slides.size(); i++) {
                Slide slide = slides.get(i);
        %>
        <div class="slide <%= i == currentSlide ? "active" : "" %>">
            <div class="slide-bg" style="background-image: url('<%= slide.getImageUrl() %>');"></div>
            <div class="slide-overlay"></div>
            <div class="slide-content">
                <div class="slide-text-container">
                    <h1 class="slide-title"><%= slide.getTitle() %></h1>
                    <p class="slide-subtitle"><%= slide.getSubtitle() %></p>
                    <div class="slide-buttons">
                        <a href="<%= slide.getPrimaryButtonUrl() %>" class="btn btn-primary"><%= slide.getPrimaryButtonText() %></a>
                        <% if (slide.getSecondaryButtonUrl() != null && slide.getSecondaryButtonText() != null) { %>
                        <a href="<%= slide.getSecondaryButtonUrl() %>" class="btn btn-outline"><%= slide.getSecondaryButtonText() %></a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <%
            }
        }
        %>
        <a href="index.jsp?slide=prev" class="slider-arrow prev"><i class="fas fa-chevron-left"></i></a>
        <a href="index.jsp?slide=next" class="slider-arrow next"><i class="fas fa-chevron-right"></i></a>
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
    </div>
</section>

<!-- Features Section with Modern Design -->
<section class="features">
    <div class="container">
        <div class="features-grid">
            <div class="feature-item">
                <div class="feature-icon">
                    <div class="icon-circle">
                        <i class="fas fa-truck"></i>
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
                        <i class="fas fa-undo"></i>
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
                        <i class="fas fa-headset"></i>
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
                        <i class="fas fa-lock"></i>
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
    <div class="container">
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
                    // Default images based on category index
                    String[] defaultImages = {
                        "https://images.unsplash.com/photo-1581044777550-4cfa60707c03?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=772&q=80",
                        "https://images.unsplash.com/photo-1617137968427-85924c800a22?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80",
                        "https://images.unsplash.com/photo-1584917865442-de89df76afd3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=870&q=80",
                        "https://images.unsplash.com/photo-1576566588028-4147f3842f27?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=764&q=80",
                        "https://images.unsplash.com/photo-1551232864-3f0890e580d9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80",
                        "https://images.unsplash.com/photo-1562157873-818bc0726f68?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=654&q=80"
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
                <img src="https://images.unsplash.com/photo-1581044777550-4cfa60707c03?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=772&q=80" alt="Women's Fashion">
                <div class="category-content">
                    <h3 class="category-title">Women's Fashion</h3>
                    <a href="ProductServlet?category=women" class="category-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <div class="category-card">
                <img src="https://images.unsplash.com/photo-1617137968427-85924c800a22?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80" alt="Men's Fashion">
                <div class="category-content">
                    <h3 class="category-title">Men's Fashion</h3>
                    <a href="ProductServlet?category=men" class="category-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>

            <div class="category-card">
                <img src="https://images.unsplash.com/photo-1584917865442-de89df76afd3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=870&q=80" alt="Accessories">
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
    <div class="container">
        <div class="section-title">
            <h2>Featured Products</h2>
        </div>

        <div class="products-grid">
            <!-- Product 2 -->
            <div class="product-card">
                <div class="product-img">
                    <img src="https://images.unsplash.com/photo-1611312449408-fcece27cdbb7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=869&q=80" alt="Denim Jacket">
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
                    <img src="https://images.unsplash.com/photo-1612336307429-8a898d10e223?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80" alt="Summer Dress">
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
<section class="special-offer" style="background-image: url('https://images.unsplash.com/photo-1607083206968-13611e3d76db?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2215&q=80'); background-size: cover; background-position: center;">
    <div class="container">
        <div class="offer-content">
            <span class="offer-subtitle">Limited Time Offer</span>
            <h2 class="offer-title">Summer Sale</h2>
            <p class="offer-description">Get up to 50% off on our summer collection. Hurry up before the offer ends!</p>


            <a href="ProductServlet?category=sale" class="btn btn-animated">Shop Now</a>
        </div>
    </div>
</section>

<!-- Collection Showcase -->	`
<section class="collection-showcase">
    <div class="container">
        <div class="section-title">
            <h2>Our Collections</h2>
        </div>

        <div class="collections-grid">
            <div class="collection-item large">
                <img src="https://images.unsplash.com/photo-1539109136881-3be0616acf4b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80" alt="Premium Collection">
                <div class="collection-content">
                    <h3>Premium Collection</h3>
                    <p>Luxury fabrics and exclusive designs</p>
                    <a href="ProductServlet?category=premium" class="btn btn-sm">Explore</a>
                </div>
            </div>

            <div class="collection-item">
                <img src="https://images.unsplash.com/photo-1551232864-3f0890e580d9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80" alt="Casual Collection">
                <div class="collection-content">
                    <h3>Casual Wear</h3>
                    <a href="ProductServlet?category=casual" class="btn btn-sm">Explore</a>
                </div>
            </div>

            <div class="collection-item">
                <img src="https://images.unsplash.com/photo-1595777457583-95e059d581b8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=783&q=80" alt="Formal Collection">
                <div class="collection-content">
                    <h3>Formal Wear</h3>
                    <a href="ProductServlet?category=formal" class="btn btn-sm">Explore</a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Testimonials -->
<section class="testimonials">
    <div class="container">
        <div class="section-title">
            <h2>What Our Customers Say</h2>
        </div>

        <div class="testimonials-slider">
            <div class="testimonial-item">
                <p class="testimonial-text">I absolutely love the quality of clothes from Clothee. The fabrics are premium and the designs are trendy. Will definitely shop again!</p>
                <div class="testimonial-author">
                    <div class="author-img">
                        <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80" alt="Sarah Johnson">
                    </div>
                    <h4 class="author-name">Sandhya </h4>
                    <span class="author-role">Regular Customer</span>
                </div>
            </div>
        </div>
    </div>
</section>

<%@ include file="/includes/footer.jsp" %>
