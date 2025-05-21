<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/includes/header.jsp" %>
<link rel="stylesheet" type="text/css" href="css/register.css">

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');">
    <div class="page-header-content">
        <h1 class="page-title">REGISTER</h1>
        <p class="page-subtitle">Create an account to enjoy a personalized shopping experience</p>
    </div>
</div>

<section class="register-section">
    <div class="container">
        <div class="form-container">
            <form action="RegisterServlet" method="post" id="registerForm">
                <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger">
                    <%= request.getAttribute("errorMessage") %>
                </div>
                <% } %>
                <% if (session.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success">
                    <%= session.getAttribute("successMessage") %>
                    <% session.removeAttribute("successMessage"); %>
                </div>
                <% } %>
                <%
                String message = request.getParameter("message");
                if (message != null) {
                %>
                <div class="alert alert-info">
                    <%= message %>
                </div>
                <% } %>
                <%
                String redirectUrl = request.getParameter("redirectUrl");
                if (redirectUrl != null) {
                %>
                <input type="hidden" name="redirectUrl" value="<%= redirectUrl %>">
                <% } %>
                <h2 class="form-title">Create Your Account</h2>
                <p class="form-subtitle">Join CLOTHEE to discover your perfect style</p>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="firstName">First Name</label>
                        <div class="input-with-icon">
                            <i class="fas fa-user input-icon"></i>
                            <input type="text" id="firstName" name="firstName" class="form-control" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="lastName">Last Name</label>
                        <div class="input-with-icon">
                            <i class="fas fa-user input-icon"></i>
                            <input type="text" id="lastName" name="lastName" class="form-control" required>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <div class="input-with-icon">
                        <i class="fas fa-envelope input-icon"></i>
                        <input type="email" id="email" name="email" class="form-control" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="phone">Phone Number</label>
                    <div class="input-with-icon">
                        <i class="fas fa-phone input-icon"></i>
                        <input type="tel" id="phone" name="phone" class="form-control">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="password">Password</label>
                    <div class="input-with-icon password-input" style="position: relative;">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="password" name="password" class="form-control" required>
                        <button type="button" class="password-toggle" data-input="password" style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer;">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Confirm Password</label>
                    <div class="input-with-icon password-input" style="position: relative;">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required>
                        <button type="button" class="password-toggle" data-input="confirmPassword" style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer;">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group checkbox-group">
                    <div style="display: flex; align-items: flex-start; margin-bottom: 15px;">
                        <input type="checkbox" id="termsAgree" name="termsAgree" required style="margin-top: 4px; margin-right: 8px;">
                        <label for="termsAgree">I agree to the <a href="#" class="form-link">Terms of Service</a> and <a href="#" class="form-link">Privacy Policy</a></label>
                    </div>
                </div>

                <div class="form-actions">
                    <input type="submit" value="Create Account" style="width: 100%; padding: 12px 20px; background-color: #ff6b6b; color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
                </div>

                <div class="form-footer">
                    <p>Already have an account? <a href="login.jsp<%= redirectUrl != null ? "?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8") : "" %>" class="form-link">Login</a></p>
                </div>
            </form>
        </div>
    </div>
</section>

<!-- Password toggle functionality is now handled by ui-enhancements.js -->

<%@ include file="/includes/footer.jsp" %>
