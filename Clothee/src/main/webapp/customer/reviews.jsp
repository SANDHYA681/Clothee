<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

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

    // Get reviews from request attribute (set by CustomerReviewServlet)
    List<Review> userReviews = (List<Review>) request.getAttribute("userReviews");
    if (userReviews == null) {
        // If reviews not in request, redirect to CustomerReviewServlet
        response.sendRedirect(request.getContextPath() + "/CustomerReviewServlet");
        return;
    }

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");

    // Get success or error message
    String message = request.getParameter("message");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reviews - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/dashboard-pro.css">
    <style>
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
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

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

        .btn-edit, .btn-delete, .btn-view {
            padding: 8px 15px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }

        .btn-view {
            background-color: #3498db;
            color: white;
            cursor: pointer;
            display: inline-block;
            font-weight: bold;
            border: 2px solid #3498db;
        }

        .btn-view:hover {
            background-color: #2980b9;
            border-color: #2980b9;
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
        }

        .btn-shop {
            display: inline-block;
            background-color: #ff8800;
            color: white;
            padding: 10px 20px;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-shop:hover {
            background-color: #e67e22;
            transform: translateY(-2px);
        }


    </style>
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
                            <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/user-placeholder.jpg" alt="<%= user.getFullName() %>">
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>

                    <!-- Profile Image Upload Link -->
                    <div class="file-upload-container">
                        <a href="<%=request.getContextPath()%>/ProfileImageServlet" class="file-upload-button">
                            <i class="fas fa-camera"></i> Change Photo
                        </a>
                    </div>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">My Reviews</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="header-action" title="Dashboard">
                        <i class="fas fa-tachometer-alt"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="header-action" title="Shop Products">
                        <i class="fas fa-tshirt"></i>
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

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Your Product Reviews</h2>
                    <span><%= userReviews.size() %> <%= userReviews.size() == 1 ? "review" : "reviews" %> submitted</span>
                </div>

                <% if (userReviews != null && !userReviews.isEmpty()) { %>
                    <div class="reviews-container">
                        <% for (Review review : userReviews) {
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
                                    <a href="<%=request.getContextPath()%>/ReviewServlet?action=view&reviewId=<%= review.getId() %>" class="btn-view">
                                        <i class="fas fa-eye"></i> View
                                    </a>
                                    <a href="<%=request.getContextPath()%>/ReviewServlet?action=edit&reviewId=<%= review.getId() %>" class="btn-edit">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    <a href="<%=request.getContextPath()%>/ReviewServlet?action=delete&reviewId=<%= review.getId() %>&productId=<%= review.getProductId() %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this review?')">
                                        <i class="fas fa-trash"></i> Delete
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="no-reviews">
                        <i class="fas fa-star"></i>
                        <h3>You haven't written any reviews yet</h3>
                        <p>Share your thoughts on products you've purchased to help other customers make informed decisions.</p>
                        <a href="<%=request.getContextPath()%>/ProductServlet" class="btn-shop">
                            <i class="fas fa-tshirt"></i> Browse Products
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });

        // Auto-submit profile image form when file is selected
        document.getElementById('dashboardProfileImage').addEventListener('change', function() {
            if (this.files.length > 0) {
                document.querySelector('.profile-upload-form button[type="submit"]').style.display = 'inline-block';
            }
        });
    </script>
</body>
</html>
