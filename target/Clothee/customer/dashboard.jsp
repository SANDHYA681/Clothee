<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.OrderDAO" %>
<%-- Wishlist import removed --%>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dao.CartDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Order" %>
<%@ page import="model.Product" %>
<%@ page import="model.Cart" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        return;
    }

    // Get counts for dashboard cards
    OrderDAO orderDAO = new OrderDAO();
    // WishlistDAO removed
    CartDAO cartDAO = new CartDAO();
    ReviewDAO reviewDAO = new ReviewDAO();
    ProductDAO productDAO = new ProductDAO();

    int totalOrders = 0;
    // wishlistItems removed
    // savedAddresses removed
    int reviewsGiven = 0;

    // Get featured products
    List<Product> featuredProducts = productDAO.getFeaturedProducts(4);

    try {
        totalOrders = orderDAO.getOrderCountByUserId(user.getId());
    } catch (Exception e) {
        System.out.println("Error getting order count: " + e.getMessage());
        e.printStackTrace();
    }

    // Wishlist count code removed

    // Address check code removed

    try {
        reviewsGiven = reviewDAO.getReviewCountByUserId(user.getId());
    } catch (Exception e) {
        System.out.println("Error getting review count: " + e.getMessage());
        e.printStackTrace();
    }

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/main.css">

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
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <% if (user.getProfileImage().startsWith("images/")) { %>
                                <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } %>
                        <% } else { %>
                            <div class="no-profile-image">
                                <i class="fas fa-user"></i>
                            </div>
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>


                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Customer Dashboard</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/customer/edit-dashboard.jsp" class="header-action" title="Edit Dashboard">
                        <i class="fas fa-cog"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>



            <div class="dashboard-cards">
                <a href="orders.jsp" class="dashboard-card-link">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h2 class="card-title">Total Orders</h2>
                            <div class="card-icon orders">
                                <i class="fas fa-shopping-bag"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalOrders %></div>
                        <p class="card-description">All your orders</p>
                    </div>
                </a>

                <!-- Wishlist card removed -->

                <!-- Saved Addresses card removed -->

                <a href="reviews.jsp" class="dashboard-card-link">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h2 class="card-title">Reviews Given</h2>
                            <div class="card-icon reviews">
                                <i class="fas fa-star"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= reviewsGiven %></div>
                        <p class="card-description">Your product reviews</p>
                    </div>
                </a>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Quick Actions</h2>
                    <span class="user-role-badge">Logged in as: Customer</span>
                </div>
                <div class="quick-actions">
                    <a href="profile.jsp" class="quick-action-btn">
                        <i class="fas fa-user-edit"></i>
                        <span>Edit Profile</span>
                    </a>
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="quick-action-btn">
                        <i class="fas fa-shopping-cart"></i>
                        <span>View Cart</span>
                    </a>
                    <a href="<%=request.getContextPath()%>/CartServlet?action=checkout" class="quick-action-btn" style="background-color: #ff8800; color: white; position: relative; overflow: hidden;">
                        <i class="fas fa-credit-card" style="color: white;"></i>
                        <span>Proceed to Checkout</span>
                        <span style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to right, transparent, rgba(255, 255, 255, 0.2), transparent); transform: translateX(-100%); animation: shine 2s infinite;"></span>
                    </a>
                    <style>
                        @keyframes shine {
                            100% {
                                transform: translateX(100%);
                            }
                        }
                    </style>
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="quick-action-btn">
                        <i class="fas fa-tshirt"></i>
                        <span>Browse Products</span>
                    </a>
                    <a href="<%=request.getContextPath()%>/customer/reviews.jsp" class="quick-action-btn">
                        <i class="fas fa-star"></i>
                        <span>My Reviews</span>
                    </a>
                    <a href="<%=request.getContextPath()%>/CustomerMessageServlet" class="quick-action-btn">
                        <i class="fas fa-envelope"></i>
                        <span>My Messages</span>
                    </a>
                    <!-- Manage Addresses button removed -->
                    <!-- Customize Dashboard button removed -->
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Recent Orders</h2>
                    <a href="orders.jsp" class="view-all" style="color: #ff8800;">View All</a>
                </div>
                <div class="recent-orders">
                    <% if (totalOrders > 0) {
                        // Get recent orders (limit to 5)
                        List<Order> recentOrders = orderDAO.getRecentOrders(5);
                        if (!recentOrders.isEmpty()) {
                            // Display recent orders
                            for (Order order : recentOrders) {
                    %>
                        <div class="order-item">
                            <div class="order-details">
                                <div class="order-id">Order #<%= order.getId() %></div>
                                <div class="order-date"><%= dateFormat.format(order.getOrderDate()) %></div>
                                <div class="order-status"><span class="status-badge <%= order.getStatus().toLowerCase() %>"><%= order.getStatus() %></span></div>
                                <div class="order-total">$<%= String.format("%.2f", order.getTotalPrice()) %></div>
                            </div>
                        </div>
                    <%
                            }
                        } else {
                    %>
                        <p>Your recent orders will appear here.</p>
                    <%
                        }
                    } else {
                    %>
                    <p>You haven't placed any orders yet.</p>
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="view-all" style="display: inline-block; margin-top: 10px; color: #ff8800;">Start Shopping</a>
                    <% } %>
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Recently Viewed Items</h2>
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="view-all" style="color: #ff8800;">Browse Products</a>
                </div>
                <div class="recently-viewed">
                    <%
                        // Get recently viewed products from session if available
                        List<Product> recentlyViewedProducts = (List<Product>) session.getAttribute("recentlyViewedProducts");
                        if (recentlyViewedProducts != null && !recentlyViewedProducts.isEmpty()) {
                    %>
                    <div class="product-grid">
                        <% for (Product product : recentlyViewedProducts) { %>
                        <div class="product-card">
                            <div class="product-image">
                                <img src="<%=request.getContextPath()%>/<%= product.getImageUrl() != null ? product.getImageUrl() : "images/products/placeholder.jpg" %>" alt="<%= product.getName() %>">
                            </div>
                            <div class="product-info">
                                <h3 class="product-name"><%= product.getName() %></h3>
                                <div class="product-price">$<%= String.format("%.2f", product.getPrice()) %></div>
                                <a href="<%=request.getContextPath()%>/ProductServlet?action=view&id=<%= product.getId() %>" class="view-product">View Product</a>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } else { %>
                    <p>No items viewed recently.</p>
                    <% } %>
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Featured Products</h2>
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="view-all" style="color: #ff8800;">View All Products</a>
                </div>
                <div class="featured-products">
                    <% if (featuredProducts != null && !featuredProducts.isEmpty()) { %>
                    <div class="product-grid">
                        <% for (Product product : featuredProducts) { %>
                        <div class="product-card">
                            <div class="product-image">
                                <img src="<%=request.getContextPath()%>/<%= product.getImageUrl() != null ? product.getImageUrl() : "images/products/placeholder.jpg" %>" alt="<%= product.getName() %>">
                                <span class="product-badge">Featured</span>
                            </div>
                            <div class="product-info">
                                <h3 class="product-name"><%= product.getName() %></h3>
                                <div class="product-price">$<%= String.format("%.2f", product.getPrice()) %></div>
                                <div class="product-actions">
                                    <a href="<%=request.getContextPath()%>/ProductServlet?action=view&id=<%= product.getId() %>" class="view-product">View Details</a>
                                    <a href="<%=request.getContextPath()%>/CartServlet?action=add&productId=<%= product.getId() %>&quantity=1" class="add-to-cart-btn" style="margin-top: 10px; display: inline-block; text-align: center;"><i class="fas fa-shopping-cart"></i> Add to Cart</a>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } else { %>
                    <p>No featured products available.</p>
                    <% } %>
                </div>
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