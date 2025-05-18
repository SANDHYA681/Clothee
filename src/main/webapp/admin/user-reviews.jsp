<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Reviews - Admin Dashboard</title>
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
        }
        
        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
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
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
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
</body>
</html>
