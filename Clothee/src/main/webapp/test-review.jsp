<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Review Servlet</title>
</head>
<body>
    <h1>Test Review Servlet</h1>

    <h2>Add Review</h2>
    <form action="ReviewServlet" method="post">
        <input type="hidden" name="action" value="add">
        <input type="hidden" name="productId" value="1">

        <div>
            <label for="rating">Rating:</label>
            <select name="rating" id="rating" required>
                <option value="1">1 Star</option>
                <option value="2">2 Stars</option>
                <option value="3">3 Stars</option>
                <option value="4">4 Stars</option>
                <option value="5">5 Stars</option>
            </select>
        </div>

        <div>
            <label for="comment">Comment:</label>
            <textarea name="comment" id="comment" required></textarea>
        </div>

        <button type="submit">Submit Review</button>
    </form>

    <h2>View Product</h2>
    <a href="ProductDetailsServlet?id=1">View Product 1</a>
</body>
</html>
