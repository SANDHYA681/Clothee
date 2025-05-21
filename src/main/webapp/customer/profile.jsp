<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        // For testing purposes, create a test user
        user = new User();
        user.setId(1); // Assuming user with ID 1 exists in the database
        user.setFirstName("Purnima");
        user.setLastName("as");
        user.setEmail("p@gmail.com");
        user.setPhone("1235678902");
        user.setProfileImage("default.png");

        // In production, uncomment this
        // response.sendRedirect(request.getContextPath() + "/login.jsp");
        // return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        return;
    }

    // Get success or error message if any
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");

    // Clear messages after displaying
    if (successMessage != null) {
        session.removeAttribute("successMessage");
    }

    if (errorMessage != null) {
        session.removeAttribute("errorMessage");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/main.css">
    <style>
        /* Ensure active menu item is orange */
        .sidebar-menu a.active {
            background-color: var(--primary-color) !important;
            color: white !important;
        }

        .sidebar-menu a.active i {
            color: white !important;
        }

        /* Welcome Banner */
        .welcome-banner {
            background: linear-gradient(135deg, var(--primary-light) 0%, var(--primary-color) 100%);
            border-radius: var(--border-radius);
            padding: 25px 30px;
            margin-bottom: 30px;
            color: white;
            display: flex;
            align-items: center;
            box-shadow: var(--shadow-md);
            position: relative;
            overflow: hidden;
        }

        .welcome-banner::before {
            content: '';
            position: absolute;
            top: -50px;
            right: -50px;
            width: 150px;
            height: 150px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
        }

        .welcome-banner::after {
            content: '';
            position: absolute;
            bottom: -60px;
            left: -60px;
            width: 180px;
            height: 180px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
        }

        .welcome-icon {
            width: 60px;
            height: 60px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 20px;
            font-size: 24px;
            flex-shrink: 0;
            position: relative;
            z-index: 1;
        }

        .welcome-content {
            position: relative;
            z-index: 1;
        }

        .welcome-title {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .welcome-subtitle {
            opacity: 0.9;
            font-size: 14px;
        }

        /* Additional profile-specific styles */
        .profile-image-preview {
            width: 180px;
            height: 180px;
            border-radius: 50%;
            overflow: hidden;
            margin: 0 auto;
            position: relative;
            border: 4px solid var(--primary-color);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }

        .profile-image-preview:hover {
            transform: scale(1.05);
        }

        .profile-image-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .image-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: #fff;
            opacity: 0;
            transition: var(--transition);
        }

        .profile-image-preview:hover .image-overlay {
            opacity: 1;
        }

        .image-overlay i {
            font-size: 24px;
            margin-bottom: 8px;
        }

        .tab-nav {
            display: flex;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
            margin-bottom: 25px;
        }

        .tab-item {
            padding: 15px 20px;
            cursor: pointer;
            font-weight: 500;
            border-bottom: 2px solid transparent;
            transition: var(--transition);
            display: flex;
            align-items: center;
            margin-right: 10px;
        }

        .tab-item i {
            margin-right: 8px;
            font-size: 16px;
        }

        .tab-item:hover {
            color: var(--primary-color);
        }

        .tab-item.active {
            color: var(--primary-color);
            border-bottom-color: var(--primary-color);
            font-weight: 600;
        }

        .tab-content {
            padding: 20px 0;
        }

        .tab-pane {
            display: none;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .tab-pane.active {
            display: block;
        }

        .current-picture {
            text-align: center;
            margin-bottom: 30px;
        }

        .current-picture h4 {
            margin-bottom: 15px;
            color: var(--text-dark);
            font-weight: 500;
            font-size: 18px;
        }

        .custom-file-upload {
            display: flex;
            align-items: center;
            margin-top: 15px;
        }

        #file-name {
            margin-left: 10px;
            font-size: 14px;
            color: var(--text-medium);
            padding: 5px 10px;
            background-color: var(--bg-light);
            border-radius: 4px;
        }

        .account-actions {
            margin-top: 50px;
            padding: 25px;
            border-top: 1px solid rgba(0, 0, 0, 0.1);
            background-color: var(--bg-light);
            border-radius: var(--border-radius);
        }

        .account-actions h3 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--text-dark);
            display: flex;
            align-items: center;
        }

        .account-actions h3 i {
            margin-right: 10px;
            color: var(--danger-color);
        }

        .account-actions p {
            margin-bottom: 20px;
            color: var(--text-medium);
            font-size: 14px;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(3px);
        }

        .modal-content {
            background-color: var(--bg-white);
            border-radius: var(--border-radius);
            padding: 30px;
            width: 500px;
            max-width: 90%;
            box-shadow: var(--shadow-md);
            position: relative;
            animation: modalOpen 0.3s ease;
        }

        @keyframes modalOpen {
            from { opacity: 0; transform: scale(0.9); }
            to { opacity: 1; transform: scale(1); }
        }

        .close-modal {
            position: absolute;
            top: 15px;
            right: 15px;
            font-size: 24px;
            cursor: pointer;
            color: var(--text-medium);
            transition: var(--transition);
        }

        .close-modal:hover {
            color: var(--danger-color);
            transform: rotate(90deg);
        }

        .section-card {
            margin-bottom: 0;
        }

        /* Form Styles */
        .input-group {
            margin-bottom: 25px;
        }

        .input-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--text-dark);
            font-size: 15px;
        }

        .input-field {
            width: 100%;
            padding: 14px 15px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: var(--border-radius);
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
            transition: var(--transition);
            background-color: var(--bg-light);
        }

        .input-field:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.2);
            background-color: white;
        }

        .input-help {
            font-size: 12px;
            color: var(--text-medium);
            margin-top: 5px;
            display: block;
        }

        .action-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 30px;
        }

        .button {
            padding: 12px 25px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: none;
            box-shadow: 0 3px 6px rgba(0, 0, 0, 0.1);
        }

        .button i {
            margin-right: 8px;
        }

        .button:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
        }

        .button-secondary {
            background-color: var(--bg-light);
            color: var(--text-dark);
        }

        .button-secondary:hover {
            background-color: #e0e0e0;
        }

        .button-danger {
            background-color: var(--danger-color);
            color: white;
        }

        .button-danger:hover {
            background-color: #c0392b;
        }

        /* Message Styles */
        .message {
            padding: 15px 20px;
            border-radius: var(--border-radius);
            margin-bottom: 25px;
            position: relative;
            padding-left: 45px;
        }

        .message::before {
            font-family: "Font Awesome 5 Free";
            font-weight: 900;
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 18px;
        }

        .message-success {
            background-color: rgba(46, 204, 113, 0.1);
            border-left: 4px solid var(--success-color);
            color: var(--success-color);
        }

        .message-success::before {
            content: "\f058"; /* check-circle */
        }

        .message-danger {
            background-color: rgba(231, 76, 60, 0.1);
            border-left: 4px solid var(--danger-color);
            color: var(--danger-color);
        }

        .message-danger::before {
            content: "\f057"; /* times-circle */
        }

        /* Two-column layout for forms */
        .input-row {
            display: flex;
            gap: 20px;
            margin-bottom: 0;
        }

        .input-row .input-group {
            flex: 1;
        }

        @media (max-width: 768px) {
            .input-row {
                flex-direction: column;
                gap: 0;
            }

            .welcome-banner {
                flex-direction: column;
                text-align: center;
                padding: 20px;
            }

            .welcome-icon {
                margin-right: 0;
                margin-bottom: 15px;
            }
        }
    </style>

</head>
<body>
    <div class="dashboard-container">
<<<<<<< HEAD
        <!-- Sidebar toggle button removed as JavaScript is not being used -->
=======
        <!-- Dashboard layout structure -->
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
        <!-- Mobile users can use browser back button instead -->

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <% if (user.getProfileImage().startsWith("images/")) { %>
                                <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } %>
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="Default Profile Image">
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>

                    <!-- Profile Image Upload Link -->
                    <div class="file-upload-container">
                        <a href="<%=request.getContextPath()%>/ProfileImageServlet" class="file-upload-button">
                            <i class="fas fa-camera"></i> Change Photo
                        </a>
                    </div>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">My Profile</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <!-- Welcome Banner -->
            <div class="welcome-banner">
                <div class="welcome-icon">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="welcome-content">
                    <h2 class="welcome-title">Welcome, <%= user.getFirstName() %>!</h2>
                    <p class="welcome-subtitle">Manage your personal information, update your password, and customize your profile.</p>
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">My Profile</h2>
                    <span>Update your personal information and manage your account</span>
                </div>

                <% if (successMessage != null) { %>
                <div class="message message-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <% if (errorMessage != null) { %>
                <div class="message message-danger">
                    <%= errorMessage %>
                </div>
                <% } %>

                <div class="profile-tabs">
                    <div class="tab-nav">
                        <a href="<%= request.getContextPath() %>/customer/profile.jsp?tab=personal-info" class="tab-item <%= request.getParameter("tab") == null || "personal-info".equals(request.getParameter("tab")) ? "active" : "" %>">
                            <i class="fas fa-user-edit"></i> Personal Information
                        </a>
                        <a href="<%= request.getContextPath() %>/customer/profile.jsp?tab=change-password" class="tab-item <%= "change-password".equals(request.getParameter("tab")) ? "active" : "" %>">
                            <i class="fas fa-key"></i> Change Password
                        </a>
                        <a href="<%= request.getContextPath() %>/customer/profile.jsp?tab=profile-picture" class="tab-item <%= "profile-picture".equals(request.getParameter("tab")) ? "active" : "" %>">
                            <i class="fas fa-camera"></i> Profile Picture
                        </a>
                    </div>

                    <div class="tab-content">
                        <!-- Personal Information Tab -->
                        <div class="tab-pane <%= request.getParameter("tab") == null || "personal-info".equals(request.getParameter("tab")) ? "active" : "" %>" id="personal-info">
                            <form action="<%= request.getContextPath() %>/ProfileServlet" method="post">
                                <input type="hidden" name="action" value="updateProfile">

                                <div class="input-row">
                                    <div class="input-group">
                                        <label for="firstName">First Name</label>
                                        <input type="text" id="firstName" name="firstName" class="input-field" value="<%= user.getFirstName() %>" required>
                                    </div>

                                    <div class="input-group">
                                        <label for="lastName">Last Name</label>
                                        <input type="text" id="lastName" name="lastName" class="input-field" value="<%= user.getLastName() %>" required>
                                    </div>
                                </div>

                                <div class="input-group">
                                    <label for="email">Email Address</label>
                                    <input type="email" id="email" name="email" class="input-field" value="<%= user.getEmail() %>" required>
                                </div>

                                <div class="input-group">
                                    <label for="phone">Phone Number</label>
                                    <input type="tel" id="phone" name="phone" class="input-field" value="<%= user.getPhone() != null ? user.getPhone() : "" %>" placeholder="Enter your phone number">
                                </div>

                                <div class="action-buttons">
                                    <button type="submit" class="button" style="background-color: var(--primary-color); color: white;">
                                        <i class="fas fa-save"></i> Save Changes
                                    </button>
                                </div>
                            </form>
                        </div>

                        <!-- Change Password Tab -->
                        <div class="tab-pane <%= "change-password".equals(request.getParameter("tab")) ? "active" : "" %>" id="change-password">
                            <form action="<%= request.getContextPath() %>/PasswordServlet" method="post">

                                <div class="input-group">
                                    <label for="currentPassword">Current Password</label>
                                    <input type="password" id="currentPassword" name="currentPassword" class="input-field" required>
                                </div>

                                <div class="input-row">
                                    <div class="input-group">
                                        <label for="newPassword">New Password</label>
                                        <input type="password" id="newPassword" name="newPassword" class="input-field" required>
                                        <small class="input-help">Password must be at least 8 characters long.</small>
                                    </div>

                                    <div class="input-group">
                                        <label for="confirmPassword">Confirm New Password</label>
                                        <input type="password" id="confirmPassword" name="confirmPassword" class="input-field" required>
                                    </div>
                                </div>

                                <div class="action-buttons">
                                    <button type="submit" class="button" style="background-color: var(--primary-color); color: white;">
                                        <i class="fas fa-key"></i> Change Password
                                    </button>
                                </div>
                            </form>
                        </div>

                        <!-- Profile Picture Tab -->
                        <div class="tab-pane <%= "profile-picture".equals(request.getParameter("tab")) ? "active" : "" %>" id="profile-picture">
                            <div class="current-picture">
                                <h4>Current Profile Picture</h4>
                                <div class="profile-image-preview">
                                    <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                                        <% if (user.getProfileImage().startsWith("images/")) { %>
                                            <img src="<%= request.getContextPath() %>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                                        <% } else { %>
                                            <img src="<%= request.getContextPath() %>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                                        <% } %>
                                    <% } else { %>
                                        <img src="<%= request.getContextPath() %>/images/avatars/default-avatar.jpg" alt="Default Profile Image">
                                    <% } %>
                                </div>
                            </div>

                            <div class="action-buttons" style="text-align: center; margin-top: 20px;">
                                <a href="<%=request.getContextPath()%>/ProfileImageServlet" class="button" style="background-color: var(--primary-color); color: white;">
                                    <i class="fas fa-upload"></i> Upload New Picture
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

<<<<<<< HEAD
                <!-- Deactivate Account feature removed as requested -->
=======
                <!-- End of profile management section -->
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
            </div>
        </div>
    </div>

<<<<<<< HEAD
    <!-- JavaScript removed as requested to rely solely on MVC backend -->
=======
    <!-- All functionality is handled through server-side processing -->
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8
</body>
</html>
