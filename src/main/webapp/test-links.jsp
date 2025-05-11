<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Links</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            color: #333;
        }
        .link-container {
            margin: 20px 0;
        }
        .link {
            display: inline-block;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-right: 10px;
        }
        .link:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <h1>Test Links</h1>
    
    <div class="link-container">
        <a href="<%=request.getContextPath()%>/admin-test.jsp" class="link">Admin Test Page</a>
        <a href="<%=request.getContextPath()%>/customer-test.jsp" class="link">Customer Test Page</a>
    </div>
    
    <div class="link-container">
        <a href="<%=request.getContextPath()%>/admin/admin-dashboard-sample.jsp" class="link">Admin Dashboard Sample</a>
        <a href="<%=request.getContextPath()%>/customer/customer-dashboard-sample.jsp" class="link">Customer Dashboard Sample</a>
    </div>
</body>
</html>
