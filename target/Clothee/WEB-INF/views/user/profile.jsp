<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ include file="/includes/header.jsp" %>
<link rel="stylesheet" type="text/css" href="css/profile.css">

<%
    // Get user from request attribute
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get active tab
    String activeTab = (String) request.getAttribute("tab");
    if (activeTab == null) {
        activeTab = "profile";
    }

    // Get success and error messages
    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");
%>

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');">
    <div class="page-header-content">
        <h1 class="page-title">MY PROFILE</h1>
        <p class="page-subtitle">Manage your personal information and preferences</p>
    </div>
</div>

<section class="profile-section">
    <div class="container">
        <div class="dashboard-wrapper">
            <div class="dashboard-sidebar">
                <div class="user-profile">
                    <div class="profile-image">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <img src="images/user-placeholder.jpg" alt="<%= user.getFullName() %>">
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFullName() %></h3>
                    <p class="user-email"><%= user.getEmail() %></p>
                </div>

                <ul class="dashboard-menu">
                    <li><a href="HomeServlet"><i class="fas fa-home"></i> Home</a></li>
                    <li class="active"><a href="UserServlet?action=profile"><i class="fas fa-user"></i> My Profile</a></li>
                    <li><a href="OrderServlet?action=history"><i class="fas fa-shopping-bag"></i> My Orders</a></li>
                    <li><a href="WishlistServlet"><i class="fas fa-heart"></i> Wishlist</a></li>
                    <li><a href="CartServlet"><i class="fas fa-shopping-cart"></i> My Cart</a></li>
                    <li><a href="ProductServlet"><i class="fas fa-tshirt"></i> Shop Products</a></li>
                    <li><a href="AddressServlet"><i class="fas fa-map-marker-alt"></i> My Addresses</a></li>
                    <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </div>

            <div class="dashboard-content">
                <div class="dashboard-header">
                    <h2>My Profile</h2>
                    <p>Update your personal information and manage your account</p>
                </div>

                <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
                <% } %>

                <div class="profile-tabs">
                    <ul class="nav-tabs">
                        <li class="tab-item <%= "profile".equals(activeTab) ? "active" : "" %>" data-tab="personal-info">Personal Information</li>
                        <li class="tab-item <%= "password".equals(activeTab) ? "active" : "" %>" data-tab="change-password">Change Password</li>
                        <li class="tab-item <%= "picture".equals(activeTab) ? "active" : "" %>" data-tab="profile-picture">Profile Picture</li>
                    </ul>

                    <div class="tab-content">
                        <!-- Personal Information Tab -->
                        <div class="tab-pane <%= "profile".equals(activeTab) ? "active" : "" %>" id="personal-info">
                            <form action="UserServlet" method="post" class="profile-form">
                                <input type="hidden" name="action" value="updateProfile">
                                <input type="hidden" name="tab" value="profile">

                                <div class="form-group">
                                    <label for="firstName">First Name</label>
                                    <input type="text" id="firstName" name="firstName" value="<%= user.getFirstName() %>" required>
                                </div>

                                <div class="form-group">
                                    <label for="lastName">Last Name</label>
                                    <input type="text" id="lastName" name="lastName" value="<%= user.getLastName() %>" required>
                                </div>

                                <div class="form-group">
                                    <label for="email">Email Address</label>
                                    <input type="email" id="email" name="email" value="<%= user.getEmail() %>" readonly>
                                    <small class="form-text">Email address cannot be changed</small>
                                </div>

                                <div class="form-group">
                                    <label for="phone">Phone Number</label>
                                    <input type="tel" id="phone" name="phone" value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn btn-primary">Save Changes</button>
                                </div>
                            </form>
                        </div>

                        <!-- Change Password Tab -->
                        <div class="tab-pane <%= "password".equals(activeTab) ? "active" : "" %>" id="change-password">
                            <form action="UserServlet" method="post" class="profile-form">
                                <input type="hidden" name="action" value="updatePassword">
                                <input type="hidden" name="tab" value="password">

                                <div class="form-group">
                                    <label for="currentPassword">Current Password</label>
                                    <input type="password" id="currentPassword" name="currentPassword" required>
                                </div>

                                <div class="form-group">
                                    <label for="newPassword">New Password</label>
                                    <input type="password" id="newPassword" name="newPassword" required>
                                </div>

                                <div class="form-group">
                                    <label for="confirmPassword">Confirm New Password</label>
                                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn btn-primary">Change Password</button>
                                </div>
                            </form>
                        </div>

                        <!-- Profile Picture Tab -->
                        <div class="tab-pane <%= "picture".equals(activeTab) ? "active" : "" %>" id="profile-picture">
                            <form action="UserServlet" method="post" enctype="multipart/form-data" class="profile-form">
                                <input type="hidden" name="action" value="updateProfileImage">
                                <input type="hidden" name="tab" value="picture">

                                <div class="current-picture">
                                    <h4>Current Profile Picture</h4>
                                    <div class="profile-image-preview">
                                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                                            <img src="<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                                        <% } else { %>
                                            <img src="images/user-placeholder.jpg" alt="<%= user.getFullName() %>">
                                        <% } %>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="profileImage">Upload New Picture</label>
                                    <input type="file" id="profileImage" name="profileImage" accept="image/*" required>
                                    <small class="form-text">Recommended size: 300x300 pixels. Max file size: 2MB.</small>
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn btn-primary">Upload Picture</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
    .profile-section {
        padding: 40px 0;
    }

    .dashboard-wrapper {
        display: flex;
        gap: 30px;
    }

    .dashboard-sidebar {
        width: 280px;
        flex-shrink: 0;
    }

    .dashboard-content {
        flex-grow: 1;
    }

    .user-profile {
        background-color: #fff;
        border-radius: 8px;
        padding: 20px;
        text-align: center;
        margin-bottom: 20px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    .profile-image {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        overflow: hidden;
        margin: 0 auto 15px;
        border: 3px solid #4a6bdf;
    }

    .profile-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .user-name {
        font-size: 18px;
        margin-bottom: 5px;
        color: #333;
    }

    .user-email {
        font-size: 14px;
        color: #666;
        margin-bottom: 0;
    }

    .dashboard-menu {
        background-color: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .dashboard-menu li {
        border-bottom: 1px solid #eee;
    }

    .dashboard-menu li:last-child {
        border-bottom: none;
    }

    .dashboard-menu a {
        display: block;
        padding: 15px 20px;
        color: #333;
        text-decoration: none;
        transition: all 0.3s;
    }

    .dashboard-menu a i {
        margin-right: 10px;
        color: #4a6bdf;
    }

    .dashboard-menu li.active a,
    .dashboard-menu a:hover {
        background-color: #f8f9fa;
        color: #4a6bdf;
    }

    .dashboard-header {
        margin-bottom: 30px;
    }

    .dashboard-header h2 {
        font-size: 24px;
        margin-bottom: 10px;
        color: #333;
    }

    .dashboard-header p {
        color: #666;
        margin-bottom: 0;
    }

    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 4px;
    }

    .alert-success {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }

    .alert-danger {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    .profile-tabs {
        background-color: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        margin-bottom: 30px;
    }

    .nav-tabs {
        display: flex;
        list-style: none;
        padding: 0;
        margin: 0;
        background-color: #f8f9fa;
        border-bottom: 1px solid #eee;
    }

    .tab-item {
        padding: 15px 20px;
        cursor: pointer;
        transition: all 0.3s;
    }

    .tab-item.active {
        background-color: #fff;
        color: #4a6bdf;
        border-bottom: 2px solid #4a6bdf;
    }

    .tab-content {
        padding: 20px;
    }

    .tab-pane {
        display: none;
    }

    .tab-pane.active {
        display: block;
    }

    .profile-form {
        max-width: 600px;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-group label {
        display: block;
        margin-bottom: 5px;
        color: #333;
        font-weight: 500;
    }

    .form-group input {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
    }

    .form-text {
        display: block;
        margin-top: 5px;
        font-size: 12px;
        color: #666;
    }

    .form-actions {
        margin-top: 30px;
    }

    .btn {
        padding: 10px 20px;
        border-radius: 4px;
        border: none;
        cursor: pointer;
        font-weight: 500;
        transition: all 0.3s;
    }

    .btn-primary {
        background-color: #4a6bdf;
        color: #fff;
    }

    .btn-primary:hover {
        background-color: #3a5bce;
    }

    .current-picture {
        margin-bottom: 20px;
    }

    .profile-image-preview {
        width: 150px;
        height: 150px;
        border-radius: 50%;
        overflow: hidden;
        margin: 15px 0;
        border: 3px solid #4a6bdf;
    }

    .profile-image-preview img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
</style>

<script>
    // Tab switching - UI enhancement only
    document.querySelectorAll('.tab-item').forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons and content
            document.querySelectorAll('.tab-item').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach(content => content.classList.remove('active'));

            // Add active class to clicked button and corresponding content
            this.classList.add('active');
            document.getElementById(this.dataset.tab).classList.add('active');
        });
    });
</script>

<%@ include file="/includes/footer.jsp" %>
