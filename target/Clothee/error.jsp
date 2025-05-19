<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Clothee</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body>
    <!-- Header -->
    <jsp:include page="header.jsp" />

    <!-- Main Content -->
    <main class="container">
        <section class="error-section">
            <div class="error-container">
                <i class="fas fa-exclamation-circle error-icon"></i>
                <h1>Oops! Something went wrong</h1>
                
                <c:choose>
                    <c:when test="${not empty errorMessage}">
                        <p>${errorMessage}</p>
                    </c:when>
                    <c:otherwise>
                        <p>Sorry, something went wrong on our server. We're working to fix the issue.</p>
                    </c:otherwise>
                </c:choose>
                
                <div class="error-actions">
                    <a href="index.jsp" class="btn btn-primary">
                        <i class="fas fa-home"></i> Go to Homepage
                    </a>
                    <a href="javascript:history.back()" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Go Back
                    </a>
                </div>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <jsp:include page="footer.jsp" />

    <!-- JavaScript -->
    <script src="js/script.js"></script>
</body>
</html>
