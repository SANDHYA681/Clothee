<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
<<<<<<< HEAD:target/Clothee/admin/edit-review.jsp
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

// Get review from request attribute
Review review = (Review) request.getAttribute("review");
if (review == null) {
    response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Review not found");
    return;
}

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");

// Get error message
String errorMessage = request.getParameter("error");
=======
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check if user is an admin
    if (!user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
        return;
    }

    // Get review from request attribute (set by AdminReviewServlet)
    Review review = (Review) request.getAttribute("review");
    if (review == null) {
        response.sendRedirect(request.getContextPath() + "/AdminReviewServlet?error=Review not found");
        return;
    }

    // Get product and user from review
    Product product = review.getProduct();
    User reviewUser = review.getUser();

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");

    // Get error message
    String error = request.getParameter("error");
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8:target/Clothee-1.0-SNAPSHOT/admin/edit-review.jsp
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Review - Admin Dashboard</title>
<<<<<<< HEAD:target/Clothee/admin/edit-review.jsp
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        
        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 250px;
            background-color: #333;
            color: #fff;
            padding: 20px 0;
        }
        
        .content {
            flex: 1;
            padding: 20px;
        }
        
        .sidebar-header {
            padding: 0 20px 20px;
            border-bottom: 1px solid #444;
        }
        
        .logo {
            display: flex;
            align-items: center;
            color: #fff;
            text-decoration: none;
            margin-bottom: 20px;
        }
        
        .logo-icon {
            font-size: 24px;
            margin-right: 10px;
        }
        
        .logo-text {
            font-size: 20px;
            font-weight: bold;
        }
        
        .user-info {
            display: flex;
            align-items: center;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #555;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            overflow: hidden;
        }
        
        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .no-profile-image {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #555;
            color: #fff;
        }
        
        .user-details h4 {
            margin: 0;
            font-size: 16px;
        }
        
        .user-details p {
            margin: 5px 0 0;
            font-size: 12px;
            color: #ccc;
        }
        
        .sidebar-menu {
            padding: 20px;
        }
        
        .menu-item {
            display: flex;
            align-items: center;
            padding: 10px 0;
            color: #ddd;
            text-decoration: none;
            transition: color 0.3s;
        }
        
        .menu-item:hover, .menu-item.active {
            color: #fff;
        }
        
        .menu-icon {
            width: 20px;
            margin-right: 10px;
            text-align: center;
        }
        
        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .content-header h1 {
            margin: 0;
            color: #333;
        }
        
        .alert {
            padding: 10px 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .card {
            background-color: #fff;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .card-header {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .card-title {
            margin: 0;
            font-size: 18px;
            color: #333;
        }
        
        .card-body {
            padding: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        
        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }
        
        .rating-input {
            margin-bottom: 20px;
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
            padding: 0 5px;
        }
        
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label {
            color: gold;
        }
        
        .form-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            display: inline-block;
            padding: 8px 15px;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 500;
            cursor: pointer;
            border: none;
        }
        
        .btn-primary {
            background-color: #007bff;
            color: #fff;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: #fff;
        }
        
        .review-info {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 4px;
            border-left: 4px solid #007bff;
        }
        
        .review-info-item {
            margin-bottom: 10px;
        }
        
        .review-info-label {
            font-weight: bold;
            color: #555;
        }
        
        .review-info-value {
            color: #333;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
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

        <div class="content">
            <div class="content-header">
                <h1>Edit Review</h1>
            </div>

            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
            <% } %>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Edit Review</h2>
                </div>
                <div class="card-body">
                    <div class="review-info">
                        <div class="review-info-item">
                            <span class="review-info-label">Product:</span>
                            <span class="review-info-value"><%= review.getProductName() %></span>
                        </div>
                        <div class="review-info-item">
                            <span class="review-info-label">Customer:</span>
                            <span class="review-info-value"><%= review.getUserName() %></span>
                        </div>
                        <div class="review-info-item">
                            <span class="review-info-label">Date:</span>
                            <span class="review-info-value"><%= review.getReviewDate() != null ? dateFormat.format(review.getReviewDate()) : "Unknown date" %></span>
                        </div>
                    </div>

                    <form action="<%= request.getContextPath() %>/admin/AdminReviewServlet" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" value="<%= review.getId() %>">

                        <div class="rating-input">
                            <label class="form-label">Rating</label>
                            <div class="star-rating">
                                <input type="radio" id="star5" name="rating" value="5" <%= review.getRating() == 5 ? "checked" : "" %> required>
                                <label for="star5" title="5 stars"><i class="fas fa-star"></i></label>

                                <input type="radio" id="star4" name="rating" value="4" <%= review.getRating() == 4 ? "checked" : "" %>>
                                <label for="star4" title="4 stars"><i class="fas fa-star"></i></label>

                                <input type="radio" id="star3" name="rating" value="3" <%= review.getRating() == 3 ? "checked" : "" %>>
                                <label for="star3" title="3 stars"><i class="fas fa-star"></i></label>

                                <input type="radio" id="star2" name="rating" value="2" <%= review.getRating() == 2 ? "checked" : "" %>>
                                <label for="star2" title="2 stars"><i class="fas fa-star"></i></label>

                                <input type="radio" id="star1" name="rating" value="1" <%= review.getRating() == 1 ? "checked" : "" %>>
                                <label for="star1" title="1 star"><i class="fas fa-star"></i></label>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="comment" class="form-label">Comment</label>
                            <textarea id="comment" name="comment" class="form-control" required><%= review.getComment() %></textarea>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Update Review</button>
                            <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet?action=view&id=<%= review.getId() %>" class="btn btn-secondary">Cancel</a>
                        </div>
                    </form>
                </div>
=======
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-reviews.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-edit-review.css">
</head>
<body>
    <div class="dashboard-container">
        <%@ include file="../includes/admin-sidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Edit Review</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/AdminReviewServlet" class="header-action" title="Back to Reviews">
                        Back to Reviews
                    </a>
                </div>
            </div>

            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= error %>
                </div>
            <% } %>

            <div class="content-card">
                <div class="card-header">
                    <h2 class="card-title">Edit Review</h2>
                    <span>ID: <%= review.getId() %></span>
                </div>

                <form action="<%=request.getContextPath()%>/AdminReviewServlet" method="post" class="review-form">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= review.getId() %>">

                    <div class="review-header">
                        <div class="product-info">
                            <div class="product-image">
                                <% if (product != null && product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                    <img src="<%=request.getContextPath()%>/<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
                                <% } else { %>
                                    <img src="<%=request.getContextPath()%>/images/product-placeholder.jpg" alt="Product Image">
                                <% } %>
                            </div>
                            <div class="product-details">
                                <h3><%= product != null ? product.getName() : "Unknown Product" %></h3>
                                <p><strong>Category:</strong> <%= product != null ? product.getCategory() : "Unknown" %></p>
                                <p><strong>Price:</strong> $<%= product != null ? String.format("%.2f", product.getPrice()) : "0.00" %></p>
                                <p><a href="<%=request.getContextPath()%>/ProductServlet?action=detail&id=<%= product != null ? product.getId() : 0 %>" target="_blank">View Product</a></p>
                            </div>
                        </div>
                        <div class="review-meta">
                            <div class="review-date">
                                <strong>Submitted:</strong> <%= dateFormat.format(review.getReviewDate()) %>
                            </div>
                            <div class="review-id">
                                Review ID: <%= review.getId() %>
                            </div>
                        </div>
                    </div>

                    <div class="user-info">
                        <div class="user-avatar">
                            <% if (reviewUser != null && reviewUser.getProfileImage() != null && !reviewUser.getProfileImage().isEmpty()) { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= reviewUser.getProfileImage() %>" alt="<%= reviewUser.getFullName() %>">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/user-placeholder.jpg" alt="User Avatar">
                            <% } %>
                        </div>
                        <div class="user-details">
                            <h4><%= reviewUser != null ? reviewUser.getFullName() : "Unknown User" %></h4>
                            <p><strong>Email:</strong> <%= reviewUser != null ? reviewUser.getEmail() : "Unknown" %></p>
                            <p><a href="<%=request.getContextPath()%>/AdminUserServlet?action=view&id=<%= reviewUser != null ? reviewUser.getId() : 0 %>">View User Profile</a></p>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Rating</label>
                        <div class="rating-options">
                            <div class="rating-option">
                                <input type="radio" id="star5" name="rating" value="5" <%= review.getRating() == 5 ? "checked" : "" %> required>
                                <label for="star5">5 - Excellent</label>
                            </div>
                            <div class="rating-option">
                                <input type="radio" id="star4" name="rating" value="4" <%= review.getRating() == 4 ? "checked" : "" %>>
                                <label for="star4">4 - Very Good</label>
                            </div>
                            <div class="rating-option">
                                <input type="radio" id="star3" name="rating" value="3" <%= review.getRating() == 3 ? "checked" : "" %>>
                                <label for="star3">3 - Good</label>
                            </div>
                            <div class="rating-option">
                                <input type="radio" id="star2" name="rating" value="2" <%= review.getRating() == 2 ? "checked" : "" %>>
                                <label for="star2">2 - Fair</label>
                            </div>
                            <div class="rating-option">
                                <input type="radio" id="star1" name="rating" value="1" <%= review.getRating() == 1 ? "checked" : "" %>>
                                <label for="star1">1 - Poor</label>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="comment" class="form-label">Review Comment</label>
                        <textarea id="comment" name="comment" class="form-control" required><%= review.getComment() %></textarea>
                    </div>

                    <div class="form-actions">
                        <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=view&id=<%= review.getId() %>" class="btn-cancel">
                            Cancel
                        </a>
                        <button type="submit" class="btn-submit">
                            Save Changes
                        </button>
                    </div>
                </form>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8:target/Clothee-1.0-SNAPSHOT/admin/edit-review.jsp
            </div>
        </div>
    </div>
</body>
</html>
