<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Check if user is logged in and is an admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User user = (User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get reviews from request attribute (set by AdminReviewServlet)
List<Review> reviews = (List<Review>) request.getAttribute("reviews");

// If reviews is null, get them directly (fallback)
if (reviews == null) {
    ReviewDAO reviewDAO = new ReviewDAO();
    reviews = reviewDAO.getAllReviews();
}

// Delete review if requested
String deleteId = request.getParameter("delete");
if (deleteId != null && !deleteId.isEmpty()) {
    int id = Integer.parseInt(deleteId);
    ReviewDAO reviewDAO = new ReviewDAO();
    boolean success = reviewDAO.deleteReview(id);
    if (success) {
        response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?message=Review+deleted+successfully");
    } else {
        response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Failed+to+delete+review");
    }
    return;
}

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");

// Get success and error messages
String successMessage = request.getParameter("success");
String errorMessage = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Reviews</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-dashboard.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="sidebar-toggle" id="sidebarToggle">
                    <i class="fas fa-chevron-left"></i>
                </div>
                <div class="user-info">
                    <div class="user-avatar">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <div class="no-profile-image">
                                <i class="fas fa-user"></i>
                            </div>
                        <% } %>
                    </div>
                    <div class="user-details">
                        <h4><%= user.getFullName() %></h4>
                        <p><%= user.getRole() %></p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="dashboard.jsp" class="menu-item">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    Dashboard
                </a>
                <a href="products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    Products
                </a>
                <a href="categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/AdminUserServlet" class="menu-item">
                    <i class="fas fa-users menu-icon"></i>
                    Customers
                </a>
                <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet" class="menu-item active">
                    <i class="fas fa-star menu-icon"></i>
                    Reviews
                </a>
                <a href="messages.jsp" class="menu-item">
                    <i class="fas fa-envelope menu-icon"></i>
                    Messages
                </a>
                <a href="settings.jsp" class="menu-item">
                    <i class="fas fa-cog menu-icon"></i>
                    Settings
                </a>
                <a href="../LogoutServlet" class="menu-item">
                    <i class="fas fa-sign-out-alt menu-icon"></i>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <button id="sidebarToggle" class="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>

                <!-- Search box and notifications removed as requested -->
            </div>

            <div class="content">
                <div class="content-header">
                    <h1>Review Management</h1>
                </div>

                <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
                <% } %>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">All Reviews</h2>
                        <div class="review-stats">
                            <div class="stat-item">
                                <span class="stat-label">Total:</span>
                                <span class="stat-value"><%= reviews.size() %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Average Rating:</span>
                                <span class="stat-value">
                                    <%
                                    double avgRating = 0;
                                    if (!reviews.isEmpty()) {
                                        double sum = 0;
                                        for (Review review : reviews) {
                                            sum += review.getRating();
                                        }
                                        avgRating = sum / reviews.size();
                                    }
                                    %>
                                    <%= String.format("%.1f", avgRating) %> <i class="fas fa-star" style="color: gold;"></i>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Product</th>
                                        <th>Customer</th>
                                        <th>Rating</th>
                                        <th>Comment</th>
                                        <th>Date</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (reviews != null && !reviews.isEmpty()) { %>
                                        <% for (Review review : reviews) { %>
                                            <tr>
                                                <td><%= review.getId() %></td>
                                                <td>
                                                    <a href="view-product.jsp?id=<%= review.getProductId() %>">
                                                        <%= review.getProductName() %>
                                                    </a>
                                                </td>
                                                <td>
                                                    <a href="view-customer.jsp?id=<%= review.getUserId() %>">
                                                        <%= review.getUserName() %>
                                                    </a>
                                                </td>
                                                <td>
                                                    <div class="rating">
                                                        <% for (int i = 1; i <= 5; i++) { %>
                                                            <% if (i <= review.getRating()) { %>
                                                                <i class="fas fa-star" style="color: gold;"></i>
                                                            <% } else { %>
                                                                <i class="far fa-star" style="color: #ccc;"></i>
                                                            <% } %>
                                                        <% } %>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="review-comment">
                                                        <%= review.getComment() %>
                                                    </div>
                                                </td>
                                                <td><%= review.getReviewDate() != null ? dateFormat.format(review.getReviewDate()) : "-" %></td>
                                                <td>
                                                    <div class="action-buttons">
                                                        <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet?action=delete&id=<%= review.getId() %>" class="btn-delete" title="Delete" onclick="return confirm('Are you sure you want to delete this review?')">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    <% } else { %>
                                        <tr>
                                            <td colspan="7" class="text-center">No reviews found</td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- View Review Modal removed -->


</body>
</html>
