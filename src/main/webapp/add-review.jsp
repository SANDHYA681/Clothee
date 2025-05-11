<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Check if user is logged in
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=ReviewServlet?action=add&productId=" + request.getParameter("productId"));
    return;
}

// Get product from request attribute
Product product = (Product) request.getAttribute("product");
if (product == null) {
    response.sendRedirect(request.getContextPath() + "/ProductServlet");
    return;
}

// Get error message if any
String errorMessage = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Review - <%= product.getName() %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .review-form-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .review-form-header {
            margin-bottom: 25px;
            text-align: center;
        }
        
        .review-form-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
        }
        
        .product-info {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 8px;
        }
        
        .product-image {
            width: 100px;
            height: 100px;
            border-radius: 8px;
            overflow: hidden;
            margin-right: 20px;
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
            margin-bottom: 5px;
        }
        
        .rating-input {
            margin-bottom: 20px;
        }
        
        .rating-label {
            display: block;
            font-weight: 500;
            margin-bottom: 10px;
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
            font-size: 30px;
            color: #ddd;
            padding: 0 5px;
        }
        
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label {
            color: #ffb700;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            font-weight: 500;
            margin-bottom: 8px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
        }
        
        textarea.form-control {
            min-height: 150px;
            resize: vertical;
        }
        
        .form-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 4px;
            font-family: 'Poppins', sans-serif;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn-primary {
            background-color: #ff6b6b;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #ff5252;
        }
        
        .btn-secondary {
            background-color: #f1f1f1;
            color: #333;
        }
        
        .btn-secondary:hover {
            background-color: #e1e1e1;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-danger {
            background-color: #ffe5e5;
            color: #d63031;
            border-left: 4px solid #d63031;
        }
    </style>
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="header.jsp" />
    
    <div class="container">
        <div class="review-form-container">
            <div class="review-form-header">
                <h1 class="review-form-title">Write a Review</h1>
                <p>Share your thoughts about this product with other customers</p>
            </div>
            
            <% if (errorMessage != null) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
            <% } %>
            
            <div class="product-info">
                <div class="product-image">
                    <img src="<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
                </div>
                <div class="product-details">
                    <h3><%= product.getName() %></h3>
                    <p><strong>Category:</strong> <%= product.getCategory() %></p>
                    <p><strong>Price:</strong> $<%= String.format("%.2f", product.getPrice()) %></p>
                </div>
            </div>
            
            <form action="ReviewServlet" method="post">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="productId" value="<%= product.getId() %>">
                
                <div class="rating-input">
                    <label class="rating-label">Your Rating</label>
                    <div class="star-rating">
                        <input type="radio" id="star5" name="rating" value="5" required>
                        <label for="star5" title="5 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star4" name="rating" value="4">
                        <label for="star4" title="4 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star3" name="rating" value="3">
                        <label for="star3" title="3 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star2" name="rating" value="2">
                        <label for="star2" title="2 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star1" name="rating" value="1">
                        <label for="star1" title="1 star"><i class="fas fa-star"></i></label>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="comment" class="form-label">Your Review</label>
                    <textarea id="comment" name="comment" class="form-control" required placeholder="What did you like or dislike about this product? How was the quality? Would you recommend it to others?"></textarea>
                </div>
                
                <div class="form-actions">
                    <a href="ProductServlet?action=detail&id=<%= product.getId() %>" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">Submit Review</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Include Footer -->
    <jsp:include page="footer.jsp" />
</body>
</html>
