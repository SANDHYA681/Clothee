<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<<<<<<< HEAD
<%@ page import="java.util.ArrayList" %>
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

// Get reviewUser and reviews from request attributes
User reviewUser = (User) request.getAttribute("reviewUser");
List<Review> reviews = (List<Review>) request.getAttribute("reviews");

if (reviewUser == null) {
    response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=User not found");
    return;
}

if (reviews == null) {
    reviews = new ArrayList<>();
}

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");

// Get success and error messages
String successMessage = request.getParameter("success");
String errorMessage = request.getParameter("error");
=======
<%@ page import="java.text.SimpleDateFormat" %>

<%
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

    // Get user and reviews from request attribute (set by AdminReviewServlet)
    User reviewUser = (User) request.getAttribute("reviewUser");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    
    if (reviewUser == null) {
        response.sendRedirect(request.getContextPath() + "/AdminReviewServlet?error=User not found");
        return;
    }
    
    if (reviews == null) {
        response.sendRedirect(request.getContextPath() + "/AdminReviewServlet?error=Reviews not found");
        return;
    }

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");

    // Get success or error message
    String message = request.getParameter("success");
    String error = request.getParameter("error");
    
    // Calculate average rating
    double avgRating = 0;
    if (reviews.size() > 0) {
        int totalRating = 0;
        for (Review review : reviews) {
            totalRating += review.getRating();
        }
        avgRating = (double) totalRating / reviews.size();
    }
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Reviews - Admin Dashboard</title>
<<<<<<< HEAD
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
=======
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-dashboard.css">
    <style>
        .user-header {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            padding: 20px;
        }
        
        .user-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            overflow: hidden;
            margin-right: 20px;
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        }
        
        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
<<<<<<< HEAD
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
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
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
        
        .customer-info {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 4px;
            border-left: 4px solid #007bff;
            display: flex;
            align-items: center;
        }
        
        .customer-avatar {
            width: 80px;
            height: 80px;
            margin-right: 15px;
            border-radius: 50%;
            overflow: hidden;
            background-color: #eee;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .customer-avatar img {
=======
        .user-details h3 {
            font-size: 20px;
            margin-bottom: 5px;
        }
        
        .user-details p {
            margin: 5px 0;
            color: #666;
        }
        
        .user-rating {
            display: flex;
            align-items: center;
            margin-top: 10px;
        }
        
        .rating-stars {
            color: #ffc107;
            margin-right: 10px;
        }
        
        .rating-number {
            font-weight: bold;
            margin-right: 5px;
        }
        
        .reviews-container {
            margin-top: 20px;
        }

        .review-item {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            padding: 20px;
            margin-bottom: 20px;
            transition: transform 0.3s ease;
        }

        .review-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #f0f0f0;
        }

        .product-info {
            display: flex;
            align-items: center;
        }

        .product-image {
            width: 60px;
            height: 60px;
            border-radius: 8px;
            overflow: hidden;
            margin-right: 15px;
        }

        .product-image img {
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
<<<<<<< HEAD
        
        .customer-avatar i {
            font-size: 40px;
            color: #aaa;
        }
        
        .customer-details {
            flex: 1;
        }
        
        .customer-name {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .customer-meta {
            color: #666;
            font-size: 14px;
        }
        
        .review-stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .stat-item {
            display: flex;
            align-items: center;
        }
        
        .stat-label {
            font-weight: bold;
            margin-right: 5px;
            color: #555;
        }
        
        .stat-value {
            color: #333;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        th {
            background-color: #f9f9f9;
            font-weight: bold;
            color: #555;
        }
        
        .rating {
            color: gold;
        }
        
        .review-comment {
            max-width: 300px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn-view, .btn-edit, .btn-delete {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 30px;
            height: 30px;
            border-radius: 4px;
            color: #fff;
            text-decoration: none;
        }
        
        .btn-view {
            background-color: #17a2b8;
        }
        
        .btn-edit {
            background-color: #ffc107;
            color: #212529;
        }
        
        .btn-delete {
            background-color: #dc3545;
        }
        
        .no-reviews {
            padding: 30px;
            text-align: center;
            color: #666;
        }
        
        .back-link {
            display: inline-flex;
            align-items: center;
            color: #007bff;
            text-decoration: none;
            margin-bottom: 20px;
        }
        
        .back-link i {
            margin-right: 5px;
=======

        .product-details h3 {
            font-size: 16px;
            margin-bottom: 5px;
        }

        .product-details p {
            font-size: 14px;
            color: #777;
            margin: 0;
        }

        .review-date {
            font-size: 14px;
            color: #777;
        }

        .review-rating {
            margin-bottom: 15px;
        }

        .review-rating i {
            color: #ddd;
            margin-right: 2px;
        }

        .review-rating i.filled {
            color: #ffc107;
        }

        .review-content {
            margin-bottom: 20px;
            line-height: 1.6;
            color: #444;
        }

        .review-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .btn-view, .btn-edit, .btn-delete {
            padding: 8px 15px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn-view {
            background-color: #3498db;
            color: white;
        }

        .btn-view:hover {
            background-color: #2980b9;
        }

        .btn-edit {
            background-color: #f39c12;
            color: white;
        }

        .btn-edit:hover {
            background-color: #e67e22;
        }

        .btn-delete {
            background-color: #e74c3c;
            color: white;
        }

        .btn-delete:hover {
            background-color: #c0392b;
        }

        .no-reviews {
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 30px;
            text-align: center;
            margin-top: 20px;
        }

        .no-reviews i {
            font-size: 48px;
            color: #ddd;
            margin-bottom: 20px;
        }

        .no-reviews h3 {
            font-size: 20px;
            margin-bottom: 10px;
            color: #444;
        }

        .no-reviews p {
            color: #777;
            margin-bottom: 20px;
        }

        .alert {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
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
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
<<<<<<< HEAD
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
                <h1>Customer Reviews</h1>
            </div>

            <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to All Reviews
            </a>

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

            <div class="customer-info">
                <div class="customer-avatar">
                    <% if (reviewUser.getProfileImage() != null && !reviewUser.getProfileImage().isEmpty()) { %>
                        <img src="<%= request.getContextPath() %>/<%= reviewUser.getProfileImage() %>" alt="<%= reviewUser.getFullName() %>">
                    <% } else { %>
                        <i class="fas fa-user"></i>
                    <% } %>
                </div>
                <div class="customer-details">
                    <div class="customer-name"><%= reviewUser.getFullName() %></div>
                    <div class="customer-meta">
                        <span><%= reviewUser.getEmail() %></span>
                        <% if (reviewUser.getPhone() != null && !reviewUser.getPhone().isEmpty()) { %>
                            <span> • <%= reviewUser.getPhone() %></span>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Reviews by <%= reviewUser.getFirstName() %></h2>
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
                    <% if (reviews != null && !reviews.isEmpty()) { %>
                        <div class="table-responsive">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Product</th>
                                        <th>Rating</th>
                                        <th>Comment</th>
                                        <th>Date</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Review review : reviews) { %>
                                        <tr>
                                            <td><%= review.getId() %></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/ProductDetailsServlet?id=<%= review.getProductId() %>">
                                                    <%= review.getProductName() %>
                                                </a>
                                            </td>
                                            <td>
                                                <div class="rating">
                                                    <% for (int i = 1; i <= 5; i++) { %>
                                                        <% if (i <= review.getRating()) { %>
                                                            <i class="fas fa-star"></i>
                                                        <% } else { %>
                                                            <i class="far fa-star"></i>
                                                        <% } %>
                                                    <% } %>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="review-comment" title="<%= review.getComment() %>">
                                                    <%= review.getComment() %>
                                                </div>
                                            </td>
                                            <td><%= review.getReviewDate() != null ? dateFormat.format(review.getReviewDate()) : "Unknown date" %></td>
                                            <td>
                                                <div class="action-buttons">
                                                    <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet?action=view&id=<%= review.getId() %>" class="btn-view" title="View">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet?action=edit&id=<%= review.getId() %>" class="btn-edit" title="Edit">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet?action=delete&id=<%= review.getId() %>" class="btn-delete" title="Delete" onclick="return confirm('Are you sure you want to delete this review?')">
                                                        <i class="fas fa-trash"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <div class="no-reviews">
                            <i class="fas fa-star" style="font-size: 48px; color: #ddd; margin-bottom: 15px;"></i>
                            <h3>No reviews found for this customer</h3>
                            <p>This customer has not submitted any reviews yet.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
=======
        <%@ include file="../includes/admin-sidebar.jsp" %>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">User Reviews</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/AdminReviewServlet" class="header-action" title="Back to All Reviews">
                        <i class="fas fa-arrow-left"></i>
                    </a>
                </div>
            </div>

            <% if (message != null && !message.isEmpty()) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <%= message %>
                </div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> <%= error %>
                </div>
            <% } %>

            <div class="user-header">
                <div class="user-avatar">
                    <% if (reviewUser.getProfileImage() != null && !reviewUser.getProfileImage().isEmpty()) { %>
                        <img src="<%=request.getContextPath()%>/images/avatars/<%= reviewUser.getProfileImage() %>" alt="<%= reviewUser.getFullName() %>">
                    <% } else { %>
                        <img src="<%=request.getContextPath()%>/images/user-placeholder.jpg" alt="<%= reviewUser.getFullName() %>">
                    <% } %>
                </div>
                <div class="user-details">
                    <h3><%= reviewUser.getFullName() %></h3>
                    <p><strong>Email:</strong> <%= reviewUser.getEmail() %></p>
                    <p><strong>Role:</strong> <%= reviewUser.isAdmin() ? "Admin" : "Customer" %></p>
                    <div class="user-rating">
                        <div class="rating-stars">
                            <% for (int i = 1; i <= 5; i++) { %>
                                <% if (i <= Math.floor(avgRating)) { %>
                                    <i class="fas fa-star"></i>
                                <% } else if (i == Math.floor(avgRating) + 1 && avgRating - Math.floor(avgRating) >= 0.5) { %>
                                    <i class="fas fa-star-half-alt"></i>
                                <% } else { %>
                                    <i class="far fa-star"></i>
                                <% } %>
                            <% } %>
                        </div>
                        <span class="rating-number"><%= String.format("%.1f", avgRating) %></span>
                        <span>(<%= reviews.size() %> <%= reviews.size() == 1 ? "review" : "reviews" %>)</span>
                    </div>
                    <p><a href="<%=request.getContextPath()%>/AdminUserServlet?action=view&id=<%= reviewUser.getId() %>" target="_blank">View User Profile</a></p>
                </div>
            </div>

            <div class="content-card">
                <div class="card-header">
                    <h2 class="card-title">Reviews by <%= reviewUser.getFullName() %></h2>
                    <span><%= reviews.size() %> <%= reviews.size() == 1 ? "review" : "reviews" %></span>
                </div>

                <% if (reviews != null && !reviews.isEmpty()) { %>
                    <div class="reviews-container">
                        <% for (Review review : reviews) {
                            Product product = review.getProduct();
                            if (product == null) {
                                // Skip this review if product is not set
                                continue;
                            }
                        %>
                            <div class="review-item">
                                <div class="review-header">
                                    <div class="product-info">
                                        <div class="product-image">
                                            <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                                <img src="<%=request.getContextPath()%>/<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
                                            <% } else { %>
                                                <img src="<%=request.getContextPath()%>/images/product-placeholder.jpg" alt="<%= product.getName() %>">
                                            <% } %>
                                        </div>
                                        <div class="product-details">
                                            <h3><a href="<%=request.getContextPath()%>/ProductServlet?action=detail&id=<%= product.getId() %>"><%= product.getName() %></a></h3>
                                            <p><%= product.getCategory() %></p>
                                        </div>
                                    </div>
                                    <div class="review-date">
                                        <%= dateFormat.format(review.getReviewDate()) %>
                                    </div>
                                </div>

                                <div class="review-rating">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <i class="fas fa-star <%= i <= review.getRating() ? "filled" : "" %>"></i>
                                    <% } %>
                                </div>

                                <div class="review-content">
                                    <p><%= review.getComment() %></p>
                                </div>

                                <div class="review-actions">
                                    <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=view&id=<%= review.getId() %>" class="btn-view">
                                        <i class="fas fa-eye"></i> View
                                    </a>
                                    <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=edit&id=<%= review.getId() %>" class="btn-edit">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=delete&id=<%= review.getId() %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this review?')">
                                        <i class="fas fa-trash"></i> Delete
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="no-reviews">
                        <i class="fas fa-star"></i>
                        <h3>No reviews found for this user</h3>
                        <p>This user has not submitted any reviews yet.</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Toggle sidebar visibility when the toggle button is clicked
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });

        // Automatically hide notification messages after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.display = 'none';
            });
        }, 5000);
    </script>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
</body>
</html>
