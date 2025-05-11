<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Get review ID from request
    String reviewIdStr = request.getParameter("reviewId");
    if (reviewIdStr == null || reviewIdStr.isEmpty()) {
        reviewIdStr = "1"; // Default to review ID 1 for testing
    }
    
    int reviewId = Integer.parseInt(reviewIdStr);
    
    // Get all reviews for testing
    ReviewDAO reviewDAO = new ReviewDAO();
    java.util.List<Review> allReviews = reviewDAO.getAllReviews();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test View Review - CLOTHEE</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 20px;
        }
        .test-button {
            display: inline-block;
            padding: 10px 15px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin: 10px;
        }
        .test-button:hover {
            background-color: #2980b9;
        }
        .review-list {
            margin-top: 20px;
        }
        .review-item {
            border: 1px solid #ddd;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <h1>Test View Review</h1>
    
    <p>Click the button below to test the ReviewServlet with the view action:</p>
    
    <a href="<%=request.getContextPath()%>/ReviewServlet?action=view&reviewId=<%= reviewId %>" class="test-button">
        Test View Review (ID=<%= reviewId %>)
    </a>
    
    <p>Or try using a form:</p>
    
    <form action="<%=request.getContextPath()%>/ReviewServlet" method="get">
        <input type="hidden" name="action" value="view">
        <input type="hidden" name="reviewId" value="<%= reviewId %>">
        <button type="submit" class="test-button">
            Test View Review Using Form (ID=<%= reviewId %>)
        </button>
    </form>
    
    <p>Click the button below to go back to the reviews page:</p>
    
    <a href="<%=request.getContextPath()%>/CustomerReviewServlet" class="test-button">
        Go to Reviews Page
    </a>
    
    <h2>Available Reviews:</h2>
    
    <div class="review-list">
        <% if (allReviews != null && !allReviews.isEmpty()) { %>
            <% for (Review review : allReviews) { %>
                <div class="review-item">
                    <p><strong>Review ID:</strong> <%= review.getId() %></p>
                    <p><strong>Product ID:</strong> <%= review.getProductId() %></p>
                    <p><strong>User ID:</strong> <%= review.getUserId() %></p>
                    <p><strong>Rating:</strong> <%= review.getRating() %></p>
                    <p><strong>Comment:</strong> <%= review.getComment() %></p>
                    
                    <a href="<%=request.getContextPath()%>/ReviewServlet?action=view&reviewId=<%= review.getId() %>" class="test-button">
                        View This Review
                    </a>
                </div>
            <% } %>
        <% } else { %>
            <p>No reviews found in the database.</p>
        <% } %>
    </div>
</body>
</html>
