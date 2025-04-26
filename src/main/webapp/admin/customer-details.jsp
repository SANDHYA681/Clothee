<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>

<%@ page import="model.Message" %>
<%@ page import="model.Review" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
// Check if user is logged in and is an admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User currentUser = (User) userObj;
if (!currentUser.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get user to view
User viewUser = (User) request.getAttribute("user");
if (viewUser == null) {
    response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
    return;
}

// Get orders
List<Order> orders = (List<Order>) request.getAttribute("orders");
if (orders == null) {
    orders = new ArrayList<>();
    System.out.println("customer-details.jsp: Orders attribute is null, using empty list");
}
int orderCount = orders.size();

// Get wishlist items (empty list since we removed wishlist functionality)
List<Object> wishlistItems = (List<Object>) request.getAttribute("wishlistItems");
int wishlistCount = wishlistItems != null ? wishlistItems.size() : 0;

// Get messages
List<Message> messages = (List<Message>) request.getAttribute("messages");
if (messages == null) {
    messages = new ArrayList<>();
    System.out.println("customer-details.jsp: Messages attribute is null, using empty list");
}
int messageCount = messages.size();

// Get reviews
List<Review> reviews = (List<Review>) request.getAttribute("reviews");
if (reviews == null) {
    reviews = new ArrayList<>();
    System.out.println("customer-details.jsp: Reviews attribute is null, using empty list");
}
int reviewCount = reviews.size();

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Details - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-customers-enhanced.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%= request.getContextPath() %>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <h3 class="user-name"><%= currentUser.getFirstName() %></h3>
                    <p class="user-role">Administrator</p>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}dashboard.jsp" class="menu-item">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    Dashboard
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    Products
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}customers.jsp" class="menu-item active">
                    <i class="fas fa-users menu-icon"></i>
                    Customers
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}reviews.jsp" class="menu-item">
                    <i class="fas fa-star menu-icon"></i>
                    Reviews
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}messages.jsp" class="menu-item">
                    <i class="fas fa-envelope menu-icon"></i>
                    Messages
                </a>
                <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}settings.jsp" class="menu-item">
                    <i class="fas fa-cog menu-icon"></i>
                    Settings
                </a>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="menu-item">
                    <i class="fas fa-sign-out-alt menu-icon"></i>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Customer Details</h1>
                <div class="header-actions">
                    <a href="<%= request.getContextPath() %>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <a href="${baseUrl != null ? baseUrl : request.getContextPath().concat('/admin/')}customers.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to Customers
            </a>

            <div class="customer-details">
                <div class="customer-profile">
                    <div class="profile-header">
                        <div class="profile-image">
                            <% if (viewUser.getProfileImage() != null && !viewUser.getProfileImage().isEmpty()) { %>
                                <img src="<%= request.getContextPath() %>/<%= viewUser.getProfileImage() %>" alt="<%= viewUser.getFirstName() + " " + viewUser.getLastName() %>">
                            <% } else { %>
                                <img src="<%= request.getContextPath() %>/images/avatars/default.png" alt="<%= viewUser.getFirstName() + " " + viewUser.getLastName() %>">
                            <% } %>
                        </div>
                        <h2 class="profile-name"><%= viewUser.getFirstName() + " " + viewUser.getLastName() %></h2>
                        <span class="profile-role <%= viewUser.isAdmin() ? "admin" : "customer" %>">
                            <%= viewUser.isAdmin() ? "Administrator" : "Customer" %>
                        </span>
                    </div>

                    <div class="profile-stats">
                        <div class="stat-item">
                            <div class="stat-value"><%= orderCount %></div>
                            <div class="stat-label">Orders</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value"><%= wishlistCount %></div>
                            <div class="stat-label">Wishlist</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value"><%= reviewCount %></div>
                            <div class="stat-label">Reviews</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value"><%= messageCount %></div>
                            <div class="stat-label">Messages</div>
                        </div>
                    </div>
                    <div class="profile-stats">
                        <div class="stat-item">
                            <div class="stat-value"><%= viewUser.getCreatedAt() != null ? dateFormat.format(viewUser.getCreatedAt()).substring(0, 3) : "N/A" %></div>
                            <div class="stat-label">Member Since</div>
                        </div>
                    </div>

                    <div class="profile-actions">
                        <% if (!viewUser.isAdmin()) { %>
                            <a href="<%= request.getContextPath() %>/AdminUserServlet?action=showEditForm&id=<%= viewUser.getId() %>" class="profile-btn primary">
                                <i class="fas fa-edit"></i> Edit Profile
                            </a>
                        <% } %>
                        <% if (viewUser.getId() != currentUser.getId()) { %>
                            <a href="<%= request.getContextPath() %>/AdminUserServlet?action=delete&id=<%= viewUser.getId() %>" class="profile-btn danger" onclick="return confirm('Are you sure you want to delete this user? This action cannot be undone.');">
                                <i class="fas fa-trash"></i> Delete Account
                            </a>
                        <% } %>
                    </div>
                </div>

                <div class="customer-info">
                    <div class="info-section">
                        <div class="info-header">
                            <h3 class="info-title">Personal Information</h3>
                        </div>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">Full Name</div>
                                <div class="info-value"><%= viewUser.getFirstName() + " " + viewUser.getLastName() %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Email</div>
                                <div class="info-value"><%= viewUser.getEmail() %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Phone</div>
                                <div class="info-value"><%= viewUser.getPhone() != null ? viewUser.getPhone() : "Not provided" %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Address</div>
                                <div class="info-value">
                                    <%
                                    String address = null;
                                    try {
                                        address = viewUser.getAddress();
                                    } catch (Exception e) {
                                        // Ignore any errors
                                    }
                                    %>
                                    <%= address != null ? address : "Not provided" %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="info-section">
                        <div class="info-header">
                            <h3 class="info-title">Account Information</h3>
                        </div>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">User ID</div>
                                <div class="info-value">#<%= viewUser.getId() %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Role</div>
                                <div class="info-value"><%= viewUser.isAdmin() ? "Administrator" : "Customer" %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Created At</div>
                                <div class="info-value"><%= viewUser.getCreatedAt() != null ? dateFormat.format(viewUser.getCreatedAt()) : "N/A" %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Last Updated</div>
                                <div class="info-value"><%= viewUser.getUpdatedAt() != null ? dateFormat.format(viewUser.getUpdatedAt()) : "N/A" %></div>
                            </div>
                        </div>
                    </div>

                    <div class="info-section">
                        <div class="info-header">
                            <h3 class="info-title">Order History</h3>
                            <a href="orders.jsp?userId=<%= viewUser.getId() %>" class="view-all">View All</a>
                        </div>
                        <% if (orderCount > 0) { %>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Date</th>
                                        <th>Total</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    int displayLimit = Math.min(orders.size(), 3);
                                    for (int i = 0; i < displayLimit; i++) {
                                        Order order = orders.get(i);
                                    %>
                                    <tr>
                                        <td>#ORD-<%= order.getId() %></td>
                                        <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                        <td><%= currencyFormat.format(order.getTotalPrice()) %></td>
                                        <td>
                                            <span class="status <%= order.getStatus().toLowerCase() %>"><%= order.getStatus() %></span>
                                        </td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="action-btn" title="View Order Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <p>This customer has not placed any orders yet.</p>
                        <% } %>
                    </div>



                    <div class="info-section">
                        <div class="info-header">
                            <h3 class="info-title">Customer Messages</h3>
                        </div>
                        <% if (messageCount > 0) { %>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Subject</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    int messageLimit = Math.min(messages.size(), 3);
                                    for (int i = 0; i < messageLimit; i++) {
                                        Message message = messages.get(i);
                                    %>
                                    <tr>
                                        <td><%= dateFormat.format(message.getCreatedAt()) %></td>
                                        <td><%= message.getSubject() %></td>
                                        <td>
                                            <span class="status <%= message.isRead() ? "read" : "unread" %>"><%= message.isRead() ? "Read" : "Unread" %></span>
                                        </td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/MessageServlet?action=view&id=<%= message.getId() %>" class="action-btn" title="View">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <p>This customer has not sent any messages.</p>
                        <% } %>
                    </div>

                    <div class="info-section">
                        <div class="info-header">
                            <h3 class="info-title">Product Reviews</h3>
                        </div>
                        <% if (reviewCount > 0) { %>
                            <div class="reviews-list">
                                <%
                                int reviewLimit = Math.min(reviews.size(), 3);
                                for (int i = 0; i < reviewLimit; i++) {
                                    Review review = reviews.get(i);
                                %>
                                <div class="review-item">
                                    <div class="review-header">
                                        <div class="review-product">
                                            <strong>Product:</strong> <%= review.getProductName() %>
                                        </div>
                                        <div class="review-rating">
                                            <% for (int star = 1; star <= 5; star++) { %>
                                                <i class="fas fa-star <%= star <= review.getRating() ? "filled" : "" %>"></i>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="review-content">
                                        <p><%= review.getComment() %></p>
                                    </div>
                                    <div class="review-date">
                                        <small>Posted on <%= dateFormat.format(review.getCreatedAt()) %></small>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <p>This customer has not written any reviews.</p>
                        <% } %>
                    </div>
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
