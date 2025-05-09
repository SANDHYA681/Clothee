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
                    <div class="password-field">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="password" name="password" class="form-control" required>
                        <span class="password-toggle" onclick="togglePassword('password')">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Confirm Password</label>
                    <div class="password-field">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required>
                        <span class="password-toggle" onclick="togglePassword('confirmPassword')">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Account Type</label>
                    <div class="radio-group">
                        <label class="checkbox-container">
                            <input type="radio" name="accountType" value="user" checked>
                            <span class="checkmark"></span>
                            Customer - Shop our products
                        </label>
                        <label class="checkbox-container">
                            <input type="radio" name="accountType" value="admin">
                            <span class="checkmark"></span>
                            Admin - Manage the store
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <label class="checkbox-container">
                        <input type="checkbox" name="termsAgreed" required>
                        <span class="checkmark"></span>
                        I agree to the <a href="#" class="form-link">Terms & Conditions</a> and <a href="#" class="form-link">Privacy Policy</a>
                    </label>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-animated">Create Account <i class="fas fa-user-plus"></i></button>
                </div>

                <div class="form-footer">
                    <p>Already have an account? <a href="LoginServlet" class="form-link">Login</a></p>
                </div>
            </form>
        </div>
    </div>
</section>

<script>
    // Password toggle - minimal JavaScript only for UI enhancement
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
