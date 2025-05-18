<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Review - Admin Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }

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
        }
    </style>
</head>
<body>
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
                </a>
            </div>
        </div>

        <p><a href="<%=request.getContextPath()%>/admin/dashboard.jsp">Back to Dashboard</a></p>
    </div>
</body>
</html>
