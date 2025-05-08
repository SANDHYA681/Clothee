<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 - Forbidden</title>
    <link rel="stylesheet" href="../css/variables.css">
    <link rel="stylesheet" href="../css/common.css">
    <style>
        .error-container {
            text-align: center;
            padding: 100px 20px;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .error-code {
            font-size: 120px;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 20px;
        }
        
        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
        }
        
        .error-description {
            font-size: 16px;
            color: var(--text-medium);
            margin-bottom: 40px;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">403</div>
        <h1 class="error-message">Access Denied</h1>
        <p class="error-description">
            <% if(request.getAttribute("errorMessage") != null) { %>
                <%= request.getAttribute("errorMessage") %>
            <% } else { %>
                You don't have permission to access this resource.
            <% } %>
        </p>
        <a href="../index.jsp" class="btn btn-primary">Go to Homepage</a>
    </div>
</body>
</html>
