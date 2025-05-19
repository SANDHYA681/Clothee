<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ include file="/includes/header.jsp" %>

<div class="error-container">
    <div class="error-content">
        <div class="error-code">404</div>
        <h1 class="error-title">Page Not Found</h1>
        <p class="error-message">The page you are looking for does not exist or has been moved.</p>
        <div class="error-actions">
            <a href="index.jsp" class="btn btn-primary">Go to Homepage</a>
            <a href="ProductServlet" class="btn btn-secondary">Browse Products</a>
        </div>
    </div>
</div>

<style>
.error-container {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 70vh;
    padding: 50px 20px;
    background-color: #f9f9f9;
}

.error-content {
    max-width: 600px;
    text-align: center;
    padding: 40px;
    background-color: #fff;
    border-radius: 10px;
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
}

.error-code {
    font-size: 120px;
    font-weight: 700;
    color: #4a6bdf;
    line-height: 1;
    margin-bottom: 20px;
}

.error-title {
    font-size: 32px;
    color: #333;
    margin-bottom: 15px;
}

.error-message {
    font-size: 16px;
    color: #666;
    margin-bottom: 30px;
}

.error-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
}

.btn {
    display: inline-block;
    padding: 12px 25px;
    border-radius: 5px;
    font-weight: 600;
    text-decoration: none;
    transition: all 0.3s ease;
}

.btn-primary {
    background-color: #4a6bdf;
    color: #fff;
}

.btn-primary:hover {
    background-color: #3a5bce;
}

.btn-secondary {
    background-color: #f5f5f5;
    color: #333;
}

.btn-secondary:hover {
    background-color: #e5e5e5;
}
</style>

<%@ include file="/includes/footer.jsp" %>
