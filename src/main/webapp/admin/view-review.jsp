<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
<<<<<<< HEAD
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

// Get success and error messages
String successMessage = request.getParameter("success");
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

    // Get success or error message
    String message = request.getParameter("success");
    String error = request.getParameter("error");
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Review - Admin Dashboard</title>
<<<<<<< HEAD
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
=======
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
<<<<<<< HEAD
        
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
        
=======

        .container {
            width: 80%;
            margin: 20px auto;
        }

        h1 {
            color: #333;
            margin-bottom: 20px;
        }

        .alert {
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 4px;
        }

>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
<<<<<<< HEAD
        
=======

>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
<<<<<<< HEAD
        
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
        
        .review-details {
            margin-bottom: 20px;
        }
        
        .review-detail {
            margin-bottom: 15px;
        }
        
        .review-label {
            font-weight: bold;
            margin-bottom: 5px;
            color: #555;
        }
        
        .review-value {
            color: #333;
        }
        
        .rating {
            color: gold;
            font-size: 18px;
        }
        
        .action-buttons {
            margin-top: 20px;
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
        
        .btn-danger {
            background-color: #dc3545;
            color: #fff;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: #fff;
=======

        .review-card {
            background-color: #fff;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .card-title {
            font-size: 18px;
            margin: 0;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #eee;
            padding-bottom: 15px;
            margin-bottom: 15px;
        }

        .product-info {
            display: flex;
        }

        .product-image {
            width: 80px;
            height: 80px;
            margin-right: 15px;
            border: 1px solid #ddd;
        }

        .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-details h3 {
            margin-top: 0;
            margin-bottom: 5px;
        }

        .product-details p {
            margin: 5px 0;
            color: #666;
        }

        .review-meta {
            text-align: right;
        }

        .review-date {
            color: #666;
            margin-bottom: 5px;
        }

        .review-id {
            color: #999;
            font-size: 12px;
        }

        .user-info {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin-right: 15px;
            border: 1px solid #ddd;
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }

        .user-details h4 {
            margin-top: 0;
            margin-bottom: 5px;
        }

        .user-details p {
            margin: 5px 0;
            color: #666;
        }

        .review-rating {
            margin-bottom: 15px;
        }

        .review-content {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .review-content p {
            margin: 0;
            line-height: 1.6;
        }

        .review-actions {
            display: flex;
            justify-content: flex-end;
        }

        .btn-back, .btn-edit, .btn-delete {
            display: inline-block;
            padding: 8px 15px;
            margin-left: 10px;
            text-decoration: none;
            color: #fff;
            border-radius: 3px;
        }

        .btn-back {
            background-color: #6c757d;
        }

        .btn-edit {
            background-color: #ffc107;
        }

        .btn-delete {
            background-color: #dc3545;
        }

        a {
            color: #007bff;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        }
    </style>
</head>
<body>
<<<<<<< HEAD
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
=======
    <div class="container">
        <h1>View Review Details</h1>

        <% if (message != null && !message.isEmpty()) { %>
            <div class="alert alert-success">
                <%= message %>
            </div>
        <% } %>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
        <% } %>

        <div class="review-card">
            <div class="card-header">
                <h2 class="card-title">Review Details</h2>
                <span>ID: <%= review.getId() %></span>
            </div>

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

            <div class="review-rating">
                <strong>Rating:</strong> <%= review.getRating() %>/5
            </div>

            <div class="review-content">
                <p><%= review.getComment() %></p>
            </div>

            <div class="review-actions">
                <a href="<%=request.getContextPath()%>/AdminReviewServlet" class="btn-back">
                    Back to Reviews
                </a>
                <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=edit&id=<%= review.getId() %>" class="btn-edit">
                    Edit Review
                </a>
                <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=delete&id=<%= review.getId() %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this review?')">
                    Delete Review
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
                </a>
            </div>
        </div>

<<<<<<< HEAD
        <div class="content">
            <div class="content-header">
                <h1>View Review</h1>
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
                    <h2 class="card-title">Review Details</h2>
                </div>
                <div class="card-body">
                    <div class="review-details">
                        <div class="review-detail">
                            <div class="review-label">Review ID</div>
                            <div class="review-value"><%= review.getId() %></div>
                        </div>
                        <div class="review-detail">
                            <div class="review-label">Product</div>
                            <div class="review-value">
                                <a href="<%= request.getContextPath() %>/ProductDetailsServlet?id=<%= review.getProductId() %>">
                                    <%= review.getProductName() %>
                                </a>
                            </div>
                        </div>
                        <div class="review-detail">
                            <div class="review-label">Customer</div>
                            <div class="review-value">
                                <a href="<%= request.getContextPath() %>/admin/AdminUserServlet?action=view&id=<%= review.getUserId() %>">
                                    <%= review.getUserName() %>
                                </a>
                            </div>
                        </div>
                        <div class="review-detail">
                            <div class="review-label">Rating</div>
                            <div class="review-value">
                                <div class="rating">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <% if (i <= review.getRating()) { %>
                                            <i class="fas fa-star"></i>
                                        <% } else { %>
                                            <i class="far fa-star"></i>
                                        <% } %>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <div class="review-detail">
                            <div class="review-label">Comment</div>
                            <div class="review-value"><%= review.getComment() %></div>
                        </div>
                        <div class="review-detail">
                            <div class="review-label">Date</div>
                            <div class="review-value"><%= review.getReviewDate() != null ? dateFormat.format(review.getReviewDate()) : "Unknown date" %></div>
                        </div>
                    </div>

                    <div class="action-buttons">
                        <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet?action=edit&id=<%= review.getId() %>" class="btn btn-primary">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet?action=delete&id=<%= review.getId() %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this review?')">
                            <i class="fas fa-trash"></i> Delete
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/AdminReviewServlet" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Reviews
                        </a>
                    </div>
                </div>
            </div>
        </div>
=======
        <p><a href="<%=request.getContextPath()%>/admin/dashboard.jsp">Back to Dashboard</a></p>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
    </div>
</body>
</html>
