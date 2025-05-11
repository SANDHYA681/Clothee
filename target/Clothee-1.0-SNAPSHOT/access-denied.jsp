<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .access-denied-container {
            max-width: 800px;
            margin: 100px auto;
            text-align: center;
            padding: 40px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        .access-denied-icon {
            font-size: 80px;
            color: #ff6b6b;
            margin-bottom: 20px;
        }
        
        .access-denied-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
            color: #333;
        }
        
        .access-denied-message {
            font-size: 18px;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .btn-home {
            display: inline-block;
            background-color: #ff6b6b;
            color: #fff;
            padding: 12px 30px;
            border-radius: 30px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-right: 15px;
        }
        
        .btn-home:hover {
            background-color: #ff5252;
            transform: translateY(-3px);
        }
        
        .btn-login {
            display: inline-block;
            background-color: #f5f5f5;
            color: #333;
            padding: 12px 30px;
            border-radius: 30px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-login:hover {
            background-color: #e0e0e0;
            transform: translateY(-3px);
        }
    </style>
</head>
<body>
    <jsp:include page="includes/header.jsp" />
    
    <div class="access-denied-container">
        <div class="access-denied-icon">
            <i class="fas fa-exclamation-circle"></i>
        </div>
        <h1 class="access-denied-title">Access Denied</h1>
        <p class="access-denied-message">
            Sorry, you don't have permission to access this page. This area is restricted to administrators only.
            <br>
            Please log in with an administrator account or return to the home page.
        </p>
        <div class="access-denied-actions">
            <a href="index.jsp" class="btn-home">Go to Home</a>
            <a href="login.jsp" class="btn-login">Log In</a>
        </div>
    </div>
    
    <jsp:include page="includes/footer.jsp" />
</body>
</html>
