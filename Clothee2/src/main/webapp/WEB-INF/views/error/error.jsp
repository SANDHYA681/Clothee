<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ include file="/includes/header.jsp" %>

<div class="error-container">
    <div class="error-content">
        <h1 class="error-title">Oops! Something went wrong</h1>
        <p class="error-message">We're sorry, but an error occurred while processing your request.</p>
        <p class="error-details">Error: <%= exception != null ? exception.getMessage() : "Unknown error" %></p>
        <div class="error-actions">
            <a href="HomeServlet" class="btn btn-primary">Go to Homepage</a>
            <a href="javascript:history.back()" class="btn btn-outline">Go Back</a>
        </div>
    </div>
</div>

<style>
    .error-container {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 70vh;
        padding: 40px 20px;
    }
    
    .error-content {
        max-width: 600px;
        text-align: center;
        padding: 40px;
        background-color: #fff;
        border-radius: 10px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    }
    
    .error-title {
        font-size: 32px;
        color: #333;
        margin-bottom: 20px;
    }
    
    .error-message {
        font-size: 18px;
        color: #666;
        margin-bottom: 30px;
    }
    
    .error-details {
        font-size: 14px;
        color: #888;
        margin-bottom: 30px;
        padding: 10px;
        background-color: #f8f9fa;
        border-radius: 5px;
    }
    
    .error-actions {
        display: flex;
        justify-content: center;
        gap: 15px;
    }
    
    .btn {
        padding: 12px 24px;
        border-radius: 5px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s;
    }
    
    .btn-primary {
        background-color: #4a6bdf;
        color: #fff;
        border: none;
    }
    
    .btn-primary:hover {
        background-color: #3a5bcf;
    }
    
    .btn-outline {
        background-color: transparent;
        color: #4a6bdf;
        border: 1px solid #4a6bdf;
    }
    
    .btn-outline:hover {
        background-color: #f0f4ff;
    }
</style>

<%@ include file="/includes/footer.jsp" %>
