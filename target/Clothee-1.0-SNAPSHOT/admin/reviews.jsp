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

    // Check if user is an admin
    if (!user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
        return;
    }

    // Get reviews from request attribute (set by AdminReviewServlet)
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) {
        // If reviews not in request, redirect to AdminReviewServlet
        response.sendRedirect(request.getContextPath() + "/AdminReviewServlet");
        return;
    }

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");

    // Get success or error message
    String message = request.getParameter("success");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Reviews - Admin Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }

        .container {
            width: 90%;
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

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            background-color: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }

        tr:hover {
            background-color: #f9f9f9;
        }

        .action-link {
            display: inline-block;
            padding: 5px 10px;
            margin-right: 5px;
            text-decoration: none;
            color: #fff;
            border-radius: 3px;
        }

        .view-link {
            background-color: #4CAF50;
        }

        .delete-link {
            background-color: #f44336;
        }

        .filter-form {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #fff;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .filter-form label {
            margin-right: 10px;
        }

        .filter-form select {
            padding: 5px;
            margin-right: 15px;
        }

        .filter-form input[type="submit"] {
            padding: 5px 15px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }

        .no-reviews {
            padding: 20px;
            text-align: center;
            background-color: #fff;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Manage Customer Reviews</h1>

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

        <form action="<%=request.getContextPath()%>/AdminReviewServlet" method="get" class="filter-form">
            <input type="hidden" name="action" value="list">
            <label for="ratingFilter">Filter by Rating:</label>
            <select name="rating" id="ratingFilter">
                <option value="all">All Ratings</option>
                <option value="5">5 Stars</option>
                <option value="4">4 Stars</option>
                <option value="3">3 Stars</option>
                <option value="2">2 Stars</option>
                <option value="1">1 Star</option>
            </select>

            <label for="sortFilter">Sort by:</label>
            <select name="sort" id="sortFilter">
                <option value="newest">Newest First</option>
                <option value="oldest">Oldest First</option>
                <option value="highest">Highest Rating</option>
                <option value="lowest">Lowest Rating</option>
            </select>

            <input type="submit" value="Apply Filters">
        </form>

        <% if (reviews != null && !reviews.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Product</th>
                        <th>Customer</th>
                        <th>Rating</th>
                        <th>Comment</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Review review : reviews) {
                        Product product = review.getProduct();
                        User reviewUser = review.getUser();
                        if (product == null || reviewUser == null) {
                            // Skip this review if product or user is not set
                            continue;
                        }
                    %>
                        <tr>
                            <td><%= review.getId() %></td>
                            <td><%= product.getName() %></td>
                            <td><%= reviewUser.getFullName() %></td>
                            <td><%= review.getRating() %>/5</td>
                            <td><%= review.getComment().length() > 50 ? review.getComment().substring(0, 50) + "..." : review.getComment() %></td>
                            <td><%= dateFormat.format(review.getReviewDate()) %></td>
                            <td>
                                <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=view&id=<%= review.getId() %>" class="action-link view-link">View</a>
                                <a href="<%=request.getContextPath()%>/AdminReviewServlet?action=delete&id=<%= review.getId() %>" class="action-link delete-link" onclick="return confirm('Are you sure you want to delete this review?')">Delete</a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="no-reviews">
                <h3>No reviews found</h3>
                <p>There are no product reviews in the database yet.</p>
            </div>
        <% } %>

        <p><a href="<%=request.getContextPath()%>/admin/dashboard.jsp">Back to Dashboard</a></p>
    </div>
</body>
</html>