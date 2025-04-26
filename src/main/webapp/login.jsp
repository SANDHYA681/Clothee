<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/includes/header.jsp" %>
<link rel="stylesheet" type="text/css" href="css/login.css">

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');">
    <div class="page-header-content">
        <h1 class="page-title">LOGIN</h1>
        <p class="page-subtitle">Welcome back to CLOTHEE</p>
    </div>
</div>

<section class="login-section">
    <div class="container">
        <div class="form-container">
            <div class="tabs">
                <%
                String tab = request.getParameter("tab");
                if (tab == null) {
                    tab = (request.getAttribute("activeTab") != null) ? (String)request.getAttribute("activeTab") : "customer";
                }
                %>
                <button class="tab-btn <%= (tab == null || "customer".equals(tab)) ? "active" : "" %>" data-tab="customer">Customer Login</button>
                <a href= "admin-login.jsp" > Admin Login</a>
            </div>

            <%
            String error = request.getParameter("error");
            if (error == null && request.getAttribute("error") != null) {
                error = (String) request.getAttribute("error");
            }

            if (error != null) {
            %>
            <div class="alert alert-danger">
                <%= error %>
            </div>
            <% } %>

            <%
            String message = request.getParameter("message");
            if (message == null && request.getAttribute("message") != null) {
                message = (String) request.getAttribute("message");
            }

            if (message != null) {
            %>
            <div class="alert alert-success">
                <%= message %>
            </div>
            <% } %>

            <div class="tab-content <%= (tab == null || "customer".equals(tab)) ? "active" : "" %>" id="customer-tab">
                <form action="<%= request.getContextPath() %>/LoginServlet" method="post" id="customerLoginForm">
                    <input type="hidden" name="userType" value="customer">

                    <%
                    String redirectUrl = request.getParameter("redirectUrl");
                    if (redirectUrl == null && request.getAttribute("redirectUrl") != null) {
                        redirectUrl = (String) request.getAttribute("redirectUrl");
                    }
                    if (redirectUrl == null && session.getAttribute("redirectUrl") != null) {
                        redirectUrl = (String) session.getAttribute("redirectUrl");
                        session.removeAttribute("redirectUrl"); // Clear it after use
                    }

                    if (redirectUrl != null) {
                    %>
                    <input type="hidden" name="redirectUrl" value="<%= redirectUrl %>">
                    <% } %>

                    <h2 class="form-title">Customer Login</h2>
                    <p class="form-subtitle">Welcome back! Please login to your account</p>

                    <div class="form-group">
                        <label class="form-label" for="customerEmail">Email Address</label>
                        <div class="input-with-icon">
                            <i class="fas fa-envelope input-icon"></i>
                            <input type="email" id="customerEmail" name="email" class="form-control" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="customerPassword">Password</label>
                        <div class="input-with-icon password-input">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password" id="customerPassword" name="password" class="form-control" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('customerPassword')">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-options">
                        <div class="checkbox-container">
                            <input type="checkbox" id="customerRememberMe" name="rememberMe" value="true">
                            <label for="customerRememberMe">Remember me</label>
                        </div>
                        <a href="ForgotPasswordServlet" class="forgot-password">Forgot Password?</a>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-animated">Login <i class="fas fa-sign-in-alt"></i></button>
                    </div>

                    <div class="form-footer">
                        <p>Don't have an account? <a href="register.jsp<%= redirectUrl != null ? "?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8") : "" %>" class="form-link">Register</a></p>
                    </div>
                </form>
            </div>

            <div class="tab-content <%= "admin".equals(tab) ? "active" : "" %>" id="admin-tab">
                <form action="<%= request.getContextPath() %>/LoginServlet" method="post" id="adminLoginForm">
                    <input type="hidden" name="userType" value="admin">
                    <% if (redirectUrl != null) { %>
                    <input type="hidden" name="redirectUrl" value="<%= redirectUrl %>">
                    <% } %>

                    <h2 class="form-title">Admin Login</h2>
                    <p class="form-subtitle">Admin access only</p>

                    <div class="form-group">
                        <label class="form-label" for="adminEmail">Email Address</label>
                        <div class="input-with-icon">
                            <i class="fas fa-envelope input-icon"></i>
                            <input type="email" id="adminEmail" name="email" class="form-control" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="adminPassword">Password</label>
                        <div class="input-with-icon password-input">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password" id="adminPassword" name="password" class="form-control" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('adminPassword')">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-animated">Login <i class="fas fa-sign-in-alt"></i></button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<script>
    // Tab switching - UI enhancement only
    document.querySelectorAll('.tab-btn').forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons and content
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

            // Add active class to clicked button and corresponding content
            this.classList.add('active');
            document.getElementById(this.dataset.tab + '-tab').classList.add('active');
        });
    });

    // Password toggle - UI enhancement only
    function togglePassword(inputId) {
        const passwordInput = document.getElementById(inputId);
        const icon = passwordInput.nextElementSibling.querySelector('i');

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            passwordInput.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }
</script>

<%@ include file="/includes/footer.jsp" %>
