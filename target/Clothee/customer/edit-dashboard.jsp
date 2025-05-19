<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.WishlistDAO" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dao.CartDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Order" %>
<%@ page import="model.Product" %>
<%@ page import="model.Cart" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
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

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Dashboard - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/dashboard-pro.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() != null ? user.getProfileImage() : "default.png" %>" alt="Profile Image">
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Edit Dashboard</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
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

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Dashboard Settings</h2>
                </div>
                <div class="dashboard-settings">
                    <form action="<%=request.getContextPath()%>/DashboardSettingsServlet" method="post">
                        <input type="hidden" name="action" value="updateSettings">

                        <div class="form-group">
                            <label for="displayName">Display Name</label>
                            <input type="text" id="displayName" name="displayName" class="form-control" value="<%= user.getFirstName() + " " + user.getLastName() %>" required>
                        </div>

                        <div class="form-group">
                            <label>Dashboard Layout</label>
                            <div class="radio-group">
                                <label class="radio-label">
                                    <input type="radio" name="dashboardLayout" value="default" checked>
                                    <span>Default Layout</span>
                                </label>
                                <label class="radio-label">
                                    <input type="radio" name="dashboardLayout" value="compact">
                                    <span>Compact Layout</span>
                                </label>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Color Theme</label>
                            <div class="color-options">
                                <label class="color-option">
                                    <input type="radio" name="colorTheme" value="orange" checked>
                                    <span class="color-preview" style="background-color: #ff8800;"></span>
                                    <span>Orange (Default)</span>
                                </label>
                                <label class="color-option">
                                    <input type="radio" name="colorTheme" value="blue">
                                    <span class="color-preview" style="background-color: #4a6bdf;"></span>
                                    <span>Blue</span>
                                </label>
                                <label class="color-option">
                                    <input type="radio" name="colorTheme" value="green">
                                    <span class="color-preview" style="background-color: #28a745;"></span>
                                    <span>Green</span>
                                </label>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Dashboard Widgets</label>
                            <div class="checkbox-group">
                                <label class="checkbox-label">
                                    <input type="checkbox" name="widgets" value="orders" checked>
                                    <span>Orders</span>
                                </label>
                                <label class="checkbox-label">
                                    <input type="checkbox" name="widgets" value="wishlist" checked>
                                    <span>Wishlist</span>
                                </label>
                                <label class="checkbox-label">
                                    <input type="checkbox" name="widgets" value="addresses" checked>
                                    <span>Addresses</span>
                                </label>
                                <label class="checkbox-label">
                                    <input type="checkbox" name="widgets" value="reviews" checked>
                                    <span>Reviews</span>
                                </label>
                                <label class="checkbox-label">
                                    <input type="checkbox" name="widgets" value="recentlyViewed" checked>
                                    <span>Recently Viewed Products</span>
                                </label>
                                <label class="checkbox-label">
                                    <input type="checkbox" name="widgets" value="featuredProducts" checked>
                                    <span>Featured Products</span>
                                </label>
                            </div>
                        </div>

                        <div class="form-actions">
                            <a href="dashboard.jsp" class="btn btn-secondary">
                                <i class="fas fa-times"></i> Cancel
                            </a>
                            <button type="submit" class="btn">
                                <i class="fas fa-save"></i> Save Changes
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <style>
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }

        .alert-success {
            background-color: rgba(40, 167, 69, 0.1);
            border: 1px solid rgba(40, 167, 69, 0.2);
            color: #28a745;
        }

        .alert-danger {
            background-color: rgba(220, 53, 69, 0.1);
            border: 1px solid rgba(220, 53, 69, 0.2);
            color: #dc3545;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-family: 'Poppins', sans-serif;
            font-size: 14px;
        }

        .radio-group, .checkbox-group {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }

        .radio-label, .checkbox-label {
            display: flex;
            align-items: center;
            cursor: pointer;
        }

        .radio-label input, .checkbox-label input {
            margin-right: 8px;
        }

        .color-options {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }

        .color-option {
            display: flex;
            align-items: center;
            cursor: pointer;
        }

        .color-preview {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            margin-right: 8px;
            border: 1px solid #ddd;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 30px;
        }

        .btn {
            display: inline-block;
            padding: 12px 25px;
            border-radius: 5px;
            cursor: pointer;
            font-family: 'Poppins', sans-serif;
            font-weight: 500;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn i {
            margin-right: 8px;
        }

        .btn {
            background-color: #ff8800;
            color: white;
            border: none;
        }

        .btn:hover {
            background-color: #e67a00;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
        }
    </style>

    <script>
        // Toggle sidebar on mobile
        const toggleSidebar = document.getElementById('toggleSidebar');
        const sidebar = document.getElementById('sidebar');

        toggleSidebar.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    </script>
</body>
</html>
