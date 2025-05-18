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

    // Get error message
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Review - Admin Dashboard</title>
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
            </div>
        </div>
    </div>
</body>
</html>
