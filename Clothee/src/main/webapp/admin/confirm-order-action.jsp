<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>

<%
// Check if user is logged in and is an admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User user = (User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get order from request attribute
Order order = (Order) request.getAttribute("order");
if (order == null) {
    response.sendRedirect(request.getContextPath() + "/AdminOrderServlet?error=Order+not+found");
    return;
}

// Get action to confirm
String confirmAction = (String) request.getAttribute("confirmAction");
if (confirmAction == null) {
    confirmAction = "delete"; // Default action
}

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");

// Set page title and action text based on the action
String pageTitle = "Confirm Order Deletion";
String actionText = "delete";
String actionButtonText = "Delete Order";
String actionButtonClass = "btn-danger";
String actionIcon = "fa-trash";

if (confirmAction.equals("cancel")) {
    pageTitle = "Confirm Order Cancellation";
    actionText = "cancel";
    actionButtonText = "Cancel Order";
    actionButtonClass = "btn-warning";
    actionIcon = "fa-ban";
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - <%= pageTitle %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin-unified.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <style>
        .confirmation-card {
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
            max-width: 600px;
            margin: 0 auto;
        }

        .confirmation-icon {
            font-size: 48px;
            color: #f44336;
            margin-bottom: 20px;
            text-align: center;
        }

        .confirmation-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: center;
        }

        .confirmation-message {
            font-size: 16px;
            margin-bottom: 30px;
            text-align: center;
            color: #555;
        }

        .order-details {
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .detail-label {
            font-weight: 500;
            color: #555;
        }

        .confirmation-actions {
            display: flex;
            justify-content: center;
            gap: 20px;
        }

        .btn-danger {
            background-color: #f44336;
            color: white;
        }

        .btn-danger:hover {
            background-color: #d32f2f;
        }

        .btn-warning {
            background-color: #ff9800;
            color: white;
        }

        .btn-warning:hover {
            background-color: #f57c00;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="user-details">
                        <h4><%= user.getFirstName() %></h4>
                        <p>Administrator</p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="dashboard.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a href="products.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-box"></i></span>
                    Products
                </a>
                <a href="categories.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tags"></i></span>
                    Categories
                </a>
                <a href="orders.jsp" class="menu-item active">
                    <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
                    Orders
                </a>
                <a href="customers.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-users"></i></span>
                    Customers
                </a>
                <a href="reviews.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-star"></i></span>
                    Reviews
                </a>
                <a href="messages.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-envelope"></i></span>
                    Messages
                </a>
                <a href="settings.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-cog"></i></span>
                    Settings
                </a>
                <a href="../LogoutServlet" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <button id="sidebarToggle" class="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>

                <div class="header-actions">
                    <div class="search-box">
                        <input type="text" placeholder="Search...">
                        <button><i class="fas fa-search"></i></button>
                    </div>

                    <div class="notifications">
                        <button class="notification-btn">
                            <i class="fas fa-bell"></i>
                            <span class="badge">3</span>
                        </button>
                    </div>
                </div>
            </div>

            <div class="content">
                <div class="content-header">
                    <h1><i class="fas fa-exclamation-triangle"></i> <%= pageTitle %></h1>
                    <a href="orders.jsp" class="btn-back">
                        <i class="fas fa-arrow-left"></i> Back to Orders
                    </a>
                </div>

                <div class="confirmation-card">
                    <div class="confirmation-icon">
                        <i class="fas <%= actionIcon %>"></i>
                    </div>
                    <h2 class="confirmation-title">Are you sure you want to <%= actionText %> this order?</h2>
                    <p class="confirmation-message">This action cannot be undone. Please confirm that you want to <%= actionText %> the following order:</p>

                    <div class="order-details">
                        <div class="detail-row">
                            <span class="detail-label">Order ID:</span>
                            <span>#<%= order.getId() %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Date:</span>
                            <span><%= dateFormat.format(order.getOrderDate()) %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Customer ID:</span>
                            <span>#<%= order.getUserId() %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Total Amount:</span>
                            <span><%= currencyFormat.format(order.getTotalPrice()) %></span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Status:</span>
                            <span><%= order.getStatus() %></span>
                        </div>
                    </div>

                    <div class="confirmation-actions">
                        <a href="orders.jsp" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=delete&id=<%= order.getId() %>" class="btn <%= actionButtonClass %>">
                            <i class="fas <%= actionIcon %>"></i> <%= actionButtonText %>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });
    </script>
</body>
</html>
