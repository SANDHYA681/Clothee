<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    // Check if user is logged in as admin
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null || !userRole.equals("admin")) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Get user ID from session
    int userId = (int) session.getAttribute("userId");
    String firstName = (String) session.getAttribute("userFirstName");
    String lastName = (String) session.getAttribute("userLastName");
    String email = (String) session.getAttribute("userEmail");

    // Create a User object if needed
    User user = null;

    // Try to get user from request attribute (set by ProfileServlet)
    user = (User) request.getAttribute("user");

    // If not in request, try to get from session as fallback
    if (user == null) {
        user = (User) session.getAttribute("user");
    }

    // If still null, create a temporary user object with session data
    if (user == null) {
        user = new User();
        user.setId(userId);
        user.setFirstName(firstName != null ? firstName : "Admin");
        user.setLastName(lastName != null ? lastName : "User");
        user.setEmail(email != null ? email : "");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-dashboard.css">
    <style>
        /* Additional styles specific to profile page */
        .user-avatar-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .user-avatar:hover .user-avatar-overlay {
            opacity: 1;
        }

        .btn-change-avatar {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            font-size: 14px;
        }

        .password-field {
            position: relative;
        }

        .password-toggle {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #777;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <% if (user.getProfileImage().startsWith("images/")) { %>
                                <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>" id="profileImagePreview">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>" id="profileImagePreview">
                            <% } %>
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="Default Profile Image" id="profileImagePreview">
                        <% } %>
                        <div class="user-avatar-overlay">
                            <a href="<%=request.getContextPath()%>/ProfileImageServlet" class="btn-change-avatar">
                                <i class="fas fa-camera"></i> <%= user.getProfileImage() != null && !user.getProfileImage().isEmpty() ? "Change" : "Upload" %>
                            </a>
                        </div>
                    </div>
                    <h3 class="user-name"><%= user.getFullName() %></h3>
                    <p class="user-role">Administrator</p>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="dashboard.jsp" class="menu-item">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    Dashboard
                </a>
                <a href="products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    Products
                </a>
                <a href="categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="customers.jsp" class="menu-item">
                    <i class="fas fa-users menu-icon"></i>
                    Customers
                </a>
                <a href="reviews.jsp" class="menu-item">
                    <i class="fas fa-star menu-icon"></i>
                    Reviews
                </a>
                <a href="profile.jsp" class="menu-item active">
                    <i class="fas fa-user menu-icon"></i>
                    My Profile
                </a>
                <a href="settings.jsp" class="menu-item">
                    <i class="fas fa-cog menu-icon"></i>
                    Settings
                </a>
                <a href="../LogoutServlet" class="menu-item">
                    <i class="fas fa-sign-out-alt menu-icon"></i>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Welcome, <%= user.getFirstName() %>!</h1>
                <div class="header-actions">
                    <a href="notifications.jsp" class="header-action" title="Notifications">
                        <i class="fas fa-bell"></i>
                    </a>
                    <a href="messages.jsp" class="header-action" title="Messages">
                        <i class="fas fa-envelope"></i>
                    </a>
                    <a href="../index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <div class="profile-card" style="background-color: #fff8f0; border-left: 4px solid var(--primary-color);">
                <div style="display: flex; align-items: center; gap: 20px;">
                    <div style="width: 60px; height: 60px; background-color: var(--primary-color); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px;">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div>
                        <h2 style="font-size: 24px; margin-bottom: 5px; color: var(--dark-color);">Welcome to your Admin Profile, <%= user.getFirstName() %>!</h2>
                        <p style="color: var(--text-medium); margin: 0;">Here you can manage your personal information and account security.</p>
                    </div>
                </div>
            </div>

            <div class="profile-card">
                <div class="profile-card-header">
                    <h2 class="profile-card-title">Personal Information</h2>
                </div>

                <%
                String successMessage = request.getParameter("success");
                String errorMessage = request.getParameter("error");
                %>
                <div class="alert alert-success" id="profileSuccessMessage" style="<%= successMessage != null && !successMessage.isEmpty() ? "" : "display: none;" %>"><%= successMessage != null ? successMessage : "" %></div>
                <div class="alert alert-danger" id="profileErrorMessage" style="<%= errorMessage != null && !errorMessage.isEmpty() ? "" : "display: none;" %>"><%= errorMessage != null ? errorMessage : "" %></div>

                <form id="profileForm" action="../ProfileUpdateServlet" method="post">
                    <!-- No hidden action field needed with dedicated servlet -->

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="firstName">First Name</label>
                            <input type="text" id="firstName" name="firstName" class="form-control" value="<%= user.getFirstName() %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="lastName">Last Name</label>
                            <input type="text" id="lastName" name="lastName" class="form-control" value="<%= user.getLastName() %>" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="email">Email Address</label>
                        <input type="email" id="email" name="email" class="form-control" value="<%= user.getEmail() %>" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" class="form-control" value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                    </div>

                    <div class="form-group">
                        <button type="submit" class="btn btn-primary" id="updateProfileBtn">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>

            <div class="profile-card">
                <div class="profile-card-header">
                    <h2 class="profile-card-title">Security</h2>
                </div>

                <%
                String passwordSuccessMessage = request.getParameter("passwordSuccess");
                String passwordErrorMessage = request.getParameter("passwordError");
                %>
                <div class="alert alert-success" id="passwordSuccessMessage" style="<%= passwordSuccessMessage != null && !passwordSuccessMessage.isEmpty() ? "" : "display: none;" %>"><%= passwordSuccessMessage != null ? passwordSuccessMessage : "" %></div>
                <div class="alert alert-danger" id="passwordErrorMessage" style="<%= passwordErrorMessage != null && !passwordErrorMessage.isEmpty() ? "" : "display: none;" %>"><%= passwordErrorMessage != null ? passwordErrorMessage : "" %></div>

                <form id="passwordForm" action="../PasswordServlet" method="post">
                    <!-- No hidden action field needed with dedicated servlet -->

                    <div class="form-group">
                        <label class="form-label" for="currentPassword">Current Password</label>
                        <input type="password" id="currentPassword" name="currentPassword" class="form-control" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="newPassword">New Password</label>
                            <input type="password" id="newPassword" name="newPassword" class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="confirmPassword">Confirm New Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required>
                        </div>
                    </div>

                    <div class="password-requirements">
                        <p><strong>Password Requirements:</strong></p>
                        <ul>
                            <li>At least 8 characters long</li>
                            <li>Contains at least one uppercase letter</li>
                            <li>Contains at least one lowercase letter</li>
                            <li>Contains at least one number</li>
                            <li>Contains at least one special character</li>
                        </ul>
                    </div>

                    <div class="form-group">
                        <button type="submit" class="btn btn-primary" id="updatePasswordBtn">
                            <i class="fas fa-lock"></i> Update Password
                        </button>
                    </div>
                </form>
            </div>

            <div class="profile-card">
                <div class="profile-card-header">
                    <h2 class="profile-card-title">Profile Picture</h2>
                </div>

                <div class="profile-picture-container" style="text-align: center; margin: 20px 0;">
                    <h4 style="margin-bottom: 15px;">Current Profile Picture</h4>
                    <div style="width: 150px; height: 150px; margin: 0 auto; border-radius: 50%; overflow: hidden; border: 3px solid var(--primary-color);">
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <% if (user.getProfileImage().startsWith("images/")) { %>
                                <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>" style="width: 100%; height: 100%; object-fit: cover;">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>" style="width: 100%; height: 100%; object-fit: cover;">
                            <% } %>
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="Default Profile Image" style="width: 100%; height: 100%; object-fit: cover;">
                        <% } %>
                    </div>

                    <div style="margin-top: 20px;">
                        <a href="<%=request.getContextPath()%>/ProfileImageServlet" class="btn btn-primary" style="display: inline-block; padding: 10px 20px;">
                            <i class="fas fa-upload"></i> <%= user.getProfileImage() != null && !user.getProfileImage().isEmpty() ? "Change" : "Upload" %> Profile Picture
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- No JavaScript - Following MVC pattern -->
</body>
</html>
