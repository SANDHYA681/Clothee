<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Check if user is logged in
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

User user = (User) userObj;

// Get review from request attribute (set by ReviewServlet)
Review review = (Review) request.getAttribute("review");
if (review == null) {
    // If review is not in request, redirect to ReviewServlet with edit action
    String reviewId = request.getParameter("reviewId");
    if (reviewId != null && !reviewId.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/ReviewServlet?action=edit&reviewId=" + reviewId);
    } else {
        response.sendRedirect(request.getContextPath() + "/CustomerReviewServlet");
    }
    return;
}

// Get product from review
Product product = review.getProduct();
if (product == null) {
    response.sendRedirect(request.getContextPath() + "/CustomerReviewServlet?error=Product+not+found");
    return;
}

// Date formatter
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");

// Get error message if any
String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Review - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .edit-review-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }

        .edit-review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .edit-review-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
        }

        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 15px;
            background-color: #f5f5f5;
            color: #333;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-back:hover {
            background-color: #e0e0e0;
        }

        .product-info {
            display: flex;
            align-items: center;
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
        }

        .product-image {
            width: 80px;
            height: 80px;
            border-radius: 4px;
            overflow: hidden;
            margin-right: 15px;
        }

        .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-details h3 {
            font-size: 18px;
            margin-bottom: 5px;
        }

        .product-details p {
            color: #666;
            font-size: 14px;
        }

        .review-form {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #333;
        }

        .rating-input {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
        }

        .rating-input input[type="radio"] {
            display: none;
        }

        .rating-input label {
            font-size: 24px;
            color: #ddd;
            cursor: pointer;
        }

        .rating-input label:hover,
        .rating-input label:hover ~ label,
        .rating-input input[type="radio"]:checked ~ label {
            color: #ff8800;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }

        .btn-cancel {
            padding: 10px 20px;
            background-color: #f5f5f5;
            color: #333;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
        }

        .btn-submit {
            padding: 10px 20px;
            background-color: #ff8800;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
        }

        .btn-cancel:hover {
            background-color: #e0e0e0;
        }

        .btn-submit:hover {
            background-color: #e67a00;
        }

        .alert {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
    </style>
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="../includes/header.jsp" />

    <div class="edit-review-container">
        <div class="edit-review-header">
            <h1 class="edit-review-title">Edit Your Review</h1>
            <a href="<%=request.getContextPath()%>/customer/reviews.jsp" class="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Reviews
            </a>
        </div>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <% } %>

        <div class="product-info">
            <div class="product-image">
                <img src="<%=request.getContextPath()%>/<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
            </div>
            <div class="product-details">
                <h3><%= product.getName() %></h3>
                <p><%= product.getCategory() %></p>
            </div>
        </div>

        <div class="review-form">
            <form action="<%=request.getContextPath()%>/ReviewServlet" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="reviewId" value="<%= review.getId() %>">
                <input type="hidden" name="productId" value="<%= review.getProductId() %>">

                <div class="form-group">
                    <label class="form-label">Your Rating</label>
                    <div class="rating-input">
                        <% for (int i = 5; i >= 1; i--) { %>
                            <input type="radio" name="rating" id="star<%= i %>" value="<%= i %>" <%= review.getRating() == i ? "checked" : "" %>>
                            <label for="star<%= i %>"><i class="fas fa-star"></i></label>
                        <% } %>
                    </div>
                </div>

                <div class="form-group">
                    <label for="comment" class="form-label">Your Review</label>
                    <textarea id="comment" name="comment" class="form-control" required><%= review.getComment() %></textarea>
                </div>

                <div class="form-actions">
                    <a href="<%=request.getContextPath()%>/customer/reviews.jsp" class="btn-cancel">Cancel</a>
                    <button type="submit" class="btn-submit">Update Review</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="../includes/footer.jsp" />
</body>
</html>
