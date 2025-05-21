<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="dao.ReviewDAO" %>

<%
// Get reviews from request attribute (set by AdminReviewServlet)
List<Review> reviews = (List<Review>) request.getAttribute("reviews");

// If reviews is null, get them directly (fallback)
if (reviews == null) {
    ReviewDAO reviewDAO = new ReviewDAO();
    reviews = reviewDAO.getAllReviews();
}

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");

// Get success and error messages
String successMessage = request.getParameter("success");
String errorMessage = request.getParameter("error");

// Get user from session
User user = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Reviews - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-reviews.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the new sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

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
                                <%= String.format("%.1f", avgRating) %> <i class="fas fa-star filled"></i>
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
                                                            <i class="fas fa-star filled"></i>
                                                        <% } else { %>
                                                            <i class="far fa-star empty"></i>
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
</body>
</html>