<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Review View</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
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
    </style>
</head>
<body>
    <h1>Test Review View</h1>
    
    <p>Click the button below to test the ReviewServlet with the view action:</p>
    
    <a href="<%=request.getContextPath()%>/ReviewServlet?action=view&reviewId=1" class="test-button">
        Test View Review (ID=1)
    </a>
    
    <p>Click the button below to test the ReviewServlet with the delete action:</p>
    
    <a href="<%=request.getContextPath()%>/ReviewServlet?action=delete&reviewId=1&productId=1" class="test-button">
        Test Delete Review (ID=1)
    </a>
    
    <p>Click the button below to test the ReviewServlet with the edit action:</p>
    
    <a href="<%=request.getContextPath()%>/ReviewServlet?action=edit&reviewId=1" class="test-button">
        Test Edit Review (ID=1)
    </a>
    
    <p>Click the button below to go back to the reviews page:</p>
    
    <a href="<%=request.getContextPath()%>/CustomerReviewServlet" class="test-button">
        Go to Reviews Page
    </a>
</body>
</html>
