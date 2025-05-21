<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Cart" %>
<%@ page import="service.CartService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect("../admin/dashboard.jsp");
        return;
    }

    // Get success or error message if any
    String successMessage = (String) session.getAttribute("addressSuccessMessage");
    String errorMessage = (String) session.getAttribute("addressErrorMessage");

    // Clear messages after displaying
    if (successMessage != null) {
        session.removeAttribute("addressSuccessMessage");
    }

    if (errorMessage != null) {
        session.removeAttribute("addressErrorMessage");
    }

    // Get user shipping address
    CartService cartService = new CartService();
    String shippingAddress = cartService.getCartAddress(user.getId());
    // Check if user has a shipping address
    boolean hasAddress = shippingAddress != null && !shippingAddress.isEmpty();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Addresses - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/dashboard-pro.css">

    /* Ensure active menu item is orange */
    .sidebar-menu a.active {
        background-color: #ff8800 !important;
        color: white !important;
    }

    .sidebar-menu a.active i {
        color: white !important;
    }

    body {
        background-color: #f5f5f5;
        padding: 0;
        margin: 0;
        font-family: 'Poppins', sans-serif;
    }

    .dashboard-container {
        display: flex;
        min-height: 100vh;
    }

    .sidebar {
        width: var(--sidebar-width);
        background-color: var(--dark-color);
        color: white;
        position: fixed;
        height: 100vh;
        overflow-y: auto;
        transition: all 0.3s ease;
    }

    .sidebar-header {
        padding: 20px;
        text-align: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }

    .logo {
        display: flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        color: white;
        margin-bottom: 10px;
    }

    .logo-icon {
        font-size: 24px;
        color: var(--primary-color);
        margin-right: 10px;
    }

    .logo-text {
        font-size: 24px;
        font-weight: 700;
        letter-spacing: 1px;
    }

    .user-info {
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    .user-avatar {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background-color: var(--primary-color);
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 10px;
        font-size: 32px;
        overflow: hidden;
    }

    .user-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .user-name {
        font-weight: 600;
        margin-bottom: 5px;
    }

    .user-role {
        font-size: 14px;
        color: rgba(255, 255, 255, 0.7);
    }

    .main-content {
        flex: 1;
        margin-left: var(--sidebar-width);
        padding: 20px;
        transition: all 0.3s ease;
    }

    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        background-color: white;
        padding: 15px 20px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    .page-title {
        font-size: 24px;
        font-weight: 600;
    }

    .header-actions {
        display: flex;
        align-items: center;
    }

    .header-action {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: var(--light-color);
        color: var(--dark-color);
        margin-left: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
    }

    .header-action:hover {
        background-color: var(--primary-color);
        color: white;
    }

    .dashboard-section-card {
        background-color: white;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        margin-bottom: 30px;
    }

    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 4px;
    }

    .alert-success {
        background-color: #ffebcc;
        color: #ff8800;
        border: 1px solid #ffcc80;
        border-left: 5px solid #ff8800;
    }

    .alert-danger {
        background-color: #ffebcc;
        color: #ff8800;
        border: 1px solid #ffcc80;
        border-left: 5px solid #ff8800;
    }

    .btn {
        display: inline-block;
        background-color: var(--primary-color) !important;
        color: white !important;
        padding: 10px 20px;
        border-radius: 5px;
        text-decoration: none;
        font-weight: 500;
        transition: all 0.3s ease;
        border: none;
        cursor: pointer;
    }

    .btn:hover {
        background-color: var(--secondary-color) !important;
        transform: translateY(-3px);
        box-shadow: 0 5px 15px rgba(255, 136, 0, 0.2);
    }

    .btn-secondary {
        background-color: #ff8800 !important;
    }

    .btn-secondary:hover {
        background-color: #ffa640 !important;
    }

    .toggle-sidebar {
        display: none;
        position: fixed;
        top: 20px;
        left: 20px;
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: var(--primary-color);
        color: white;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        z-index: 100;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    }

    /* Address-specific styles */
    .empty-state {
        text-align: center;
        padding: 30px 0;
        margin-bottom: 20px;
    }

    .empty-state i {
        font-size: 48px;
        color: #ddd;
        margin-bottom: 15px;
    }

    .empty-state p {
        color: var(--text-medium);
        margin-bottom: 0;
    }

    .addresses-list {
        margin-bottom: 20px;
    }

    .address-card {
        border: 1px solid #eee;
        border-radius: 8px;
        padding: 15px;
        margin-bottom: 15px;
        position: relative;
        transition: all 0.3s ease;
    }

    .address-card:hover {
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        transform: translateY(-2px);
    }

    .address-card.default {
        border-color: #ff8800;
        background-color: rgba(255, 136, 0, 0.05);
    }

    .default-badge {
        position: absolute;
        top: 10px;
        right: 10px;
        background-color: #ff8800;
        color: white;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 500;
    }

    .address-content {
        margin-bottom: 15px;
    }

    .address-line {
        margin-bottom: 5px;
    }

    .address-actions {
        display: flex;
        gap: 10px;
    }

    .address-action {
        padding: 5px 10px;
        border-radius: 4px;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }

    .address-action.edit {
        color: #ff8800;
        border: 1px solid #ff8800;
        background-color: transparent;
    }

    .address-action.edit:hover {
        background-color: #ff8800;
        color: white;
    }

    .address-action.delete {
        color: #dc3545;
        border: 1px solid #dc3545;
        background-color: transparent;
    }

    .address-action.delete:hover {
        background-color: #dc3545;
        color: white;
    }

    .address-action.default {
        color: #28a745;
        border: 1px solid #28a745;
        background-color: transparent;
    }

    .address-action.default:hover {
        background-color: #28a745;
        color: white;
    }

    .address-form-container {
        border-top: 1px solid #eee;
        padding-top: 20px;
        margin-top: 20px;
    }

    .form-group {
        margin-bottom: 15px;
    }

    .form-group label {
        display: block;
        margin-bottom: 5px;
        font-weight: 500;
        color: #333;
    }

    .form-group input,
    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 10px 15px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
        transition: all 0.3s ease;
    }

    .form-group input:focus,
    .form-group select:focus,
    .form-group textarea:focus {
        border-color: #ff8800;
        box-shadow: 0 0 0 3px rgba(255, 136, 0, 0.1);
        outline: none;
    }

    .form-row {
        display: flex;
        gap: 15px;
    }

    .form-row .form-group {
        flex: 1;
    }

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 20px;
    }

    .checkbox-container {
        display: block;
        position: relative;
        padding-left: 30px;
        margin-bottom: 12px;
        cursor: pointer;
        font-size: 14px;
        color: #333;
    }

    .checkbox-container input {
        position: absolute;
        opacity: 0;
        cursor: pointer;
        height: 0;
        width: 0;
    }

    .checkmark {
        position: absolute;
        top: 0;
        left: 0;
        height: 20px;
        width: 20px;
        background-color: #eee;
        border-radius: 4px;
    }

    .checkbox-container:hover input ~ .checkmark {
        background-color: #ccc;
    }

    .checkbox-container input:checked ~ .checkmark {
        background-color: #ff8800;
    }

    .checkmark:after {
        content: "";
        position: absolute;
        display: none;
    }

    .checkbox-container input:checked ~ .checkmark:after {
        display: block;
    }

    .checkbox-container .checkmark:after {
        left: 7px;
        top: 3px;
        width: 5px;
        height: 10px;
        border: solid white;
        border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }

    @media (max-width: 992px) {
        .sidebar {
            transform: translateX(-100%);
        }

        .sidebar.active {
            transform: translateX(0);
        }

        .main-content {
            margin-left: 0;
        }

        .toggle-sidebar {
            display: flex;
        }

        .form-row {
            flex-direction: column;
            gap: 0;
        }
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
                <h1 class="page-title">My Addresses</h1>
                <div class="header-actions">
                    <!-- User account navigation -->
                    <a href="<%=request.getContextPath()%>/cart.jsp" class="header-action" title="Cart">
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

            <div class="dashboard-section-card">
                <div class="addresses-list">
                    <h3>Your Saved Addresses</h3>

                    <% if (!hasAddress) { %>
                        <div class="empty-state">
                            <i class="fas fa-map-marker-alt"></i>
                            <p>You don't have any saved address yet.</p>
                        </div>
                    <% } else { %>
                            <div class="address-card default">
                                <span class="default-badge">Default</span>
                                <div class="address-content">
                                    <div class="address-line"><strong>Shipping Address:</strong> <%= shippingAddress %></div>
                                    <div class="address-line"><strong>Full Name:</strong> <%= user.getFirstName() + " " + user.getLastName() %></div>
                                    <div class="address-line"><strong>Phone:</strong> <%= user.getPhone() != null ? user.getPhone() : "Not provided" %></div>
                                </div>
                                <div class="address-actions">
                                    <a href="<%=request.getContextPath()%>/customer/edit-addresses.jsp" class="address-action edit">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                </div>
                            </div>
                    <% } %>

                    <div style="display: flex; gap: 15px; margin-top: 20px;">
                        <a href="<%=request.getContextPath()%>/customer/edit-addresses.jsp?checkout=true" class="action-button" style="background-color: #ff8800 !important; font-size: 16px; padding: 12px 20px; box-shadow: 0 4px 8px rgba(255, 136, 0, 0.3); position: relative; overflow: hidden; display: inline-block; text-decoration: none;">
                            <i class="fas fa-plus-circle" style="margin-right: 8px;"></i>Add New Address
                            <span style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to right, transparent, rgba(255, 255, 255, 0.2), transparent); transform: translateX(-100%); animation: shine 2s infinite;"></span>
                        </a>

                        <% if (hasAddress) { %>
                        <a href="<%=request.getContextPath()%>/PaymentServlet?action=checkout" class="action-button" style="background-color: #28a745 !important; color: white; font-size: 16px; padding: 12px 20px; box-shadow: 0 4px 8px rgba(40, 167, 69, 0.3); position: relative; overflow: hidden; display: inline-block; text-decoration: none;">
                            <i class="fas fa-credit-card" style="margin-right: 8px;"></i>Proceed to Payment
                            <span style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(to right, transparent, rgba(255, 255, 255, 0.2), transparent); transform: translateX(-100%); animation: shine 2s infinite;"></span>
                        </a>
                        <% } %>
                    </div>
                    <style>
                        @keyframes shine {
                            100% {
                                transform: translateX(100%);
                            }
                        }
                    </style>
                </div>


            </div>
        </div>
    </div>

    <script>
        // Toggle sidebar on mobile
        const toggleSidebar = document.getElementById('toggleSidebar');
        const sidebar = document.getElementById('sidebar');

        toggleSidebar.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });

        // No JavaScript functions for editing addresses - using server-side approach instead
    </script>
</body>
</html>
