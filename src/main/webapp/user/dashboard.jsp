<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Get user information
    String userName = user.getFirstName() + " " + user.getLastName();
    String userEmail = user.getEmail();
    String userRole = user.getRole();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/styles.css">
    <style>
        :root {
            --primary-color: #ff6b6b;
            --secondary-color: #4ecdc4;
            --dark-color: #2d3436;
            --light-color: #f9f9f9;
            --sidebar-width: 250px;
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
        }

        .user-name {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .user-role {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.7);
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            text-decoration: none;
            color: rgba(255, 255, 255, 0.7);
            transition: all 0.3s ease;
        }

        .menu-item:hover {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .menu-item.active {
            background-color: var(--primary-color);
            color: white;
        }

        .menu-icon {
            margin-right: 15px;
            width: 20px;
            text-align: center;
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

        .dashboard-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .dashboard-card {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
        }

        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .card-title {
            font-size: 16px;
            font-weight: 500;
            color: #666;
        }

        .card-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .card-icon.orders {
            background-color: rgba(255, 107, 107, 0.1);
            color: var(--primary-color);
        }

        .card-icon.wishlist {
            background-color: rgba(78, 205, 196, 0.1);
            color: var(--secondary-color);
        }

        .card-icon.cart {
            background-color: rgba(255, 230, 109, 0.1);
            color: #ffe66d;
        }

        .card-icon.reviews {
            background-color: rgba(74, 107, 223, 0.1);
            color: #4a6bdf;
        }

        .card-value {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .card-description {
            font-size: 14px;
            color: #888;
        }

        .recent-orders {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 18px;
            font-weight: 600;
        }

        .view-all {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .view-all:hover {
            text-decoration: underline;
        }

        .orders-table {
            width: 100%;
            border-collapse: collapse;
        }

        .orders-table th, .orders-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        .orders-table th {
            font-weight: 500;
            color: #666;
            background-color: #f9f9f9;
        }

        .orders-table tr:last-child td {
            border-bottom: none;
        }

        .orders-table tr:hover td {
            background-color: #f5f5f5;
        }

        .status {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .status.delivered {
            background-color: rgba(78, 205, 196, 0.1);
            color: var(--secondary-color);
        }

        .status.processing {
            background-color: rgba(255, 230, 109, 0.1);
            color: #ffa502;
        }

        .status.cancelled {
            background-color: rgba(255, 107, 107, 0.1);
            color: var(--primary-color);
        }

        .action-btn {
            width: 30px;
            height: 30px;
            border-radius: 5px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background-color: #f5f5f5;
            color: #666;
            margin-right: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .action-btn:hover {
            background-color: var(--primary-color);
            color: white;
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
                        <i class="fas fa-user"></i>
                    </div>
                    <h3 class="user-name"><%= userName %></h3>
                    <p class="user-role"><%= userRole %></p>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="dashboard.jsp" class="menu-item active">
                    <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a href="profile.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-user"></i></span>
                    My Profile
                </a>
                <a href="orders.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
                    My Orders
                </a>
                <a href="wishlist.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-heart"></i></span>
                    Wishlist
                </a>
                <a href="addresses.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-map-marker-alt"></i></span>
                    My Addresses
                </a>
                <a href="reviews.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-star"></i></span>
                    My Reviews
                </a>
                <a href="../LoginServlet?action=logout" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Dashboard</h1>
                <div class="header-actions">
                    <a href="../cart.jsp" class="header-action" title="Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="../wishlist.jsp" class="header-action" title="Wishlist">
                        <i class="fas fa-heart"></i>
                    </a>
                    <a href="../notifications.jsp" class="header-action" title="Notifications">
                        <i class="fas fa-bell"></i>
                    </a>
                    <a href="../index.jsp" class="header-action" title="Back to Shop">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-cards">
                <div class="dashboard-card">
                    <div class="card-header">
                        <h2 class="card-title">Total Orders</h2>
                        <div class="card-icon orders">
                            <i class="fas fa-shopping-bag"></i>
                        </div>
                    </div>
                    <div class="card-value">12</div>
                    <p class="card-description">You have placed 12 orders so far</p>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <h2 class="card-title">Wishlist Items</h2>
                        <div class="card-icon wishlist">
                            <i class="fas fa-heart"></i>
                        </div>
                    </div>
                    <div class="card-value">8</div>
                    <p class="card-description">You have 8 items in your wishlist</p>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <h2 class="card-title">Cart Items</h2>
                        <div class="card-icon cart">
                            <i class="fas fa-shopping-cart"></i>
                        </div>
                    </div>
                    <div class="card-value">3</div>
                    <p class="card-description">You have 3 items in your cart</p>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <h2 class="card-title">My Reviews</h2>
                        <div class="card-icon reviews">
                            <i class="fas fa-star"></i>
                        </div>
                    </div>
                    <div class="card-value">5</div>
                    <p class="card-description">You have submitted 5 reviews</p>
                </div>
            </div>

            <div class="recent-orders">
                <div class="section-header">
                    <h2 class="section-title">Recent Orders</h2>
                    <a href="orders.jsp" class="view-all">View All</a>
                </div>

                <table class="orders-table">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Date</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>#ORD-2023-1001</td>
                            <td>June 15, 2023</td>
                            <td>$129.99</td>
                            <td><span class="status delivered">Delivered</span></td>
                            <td>
                                <a href="order-details.jsp?id=1001" class="action-btn" title="View">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="track-order.jsp?id=1001" class="action-btn" title="Track">
                                    <i class="fas fa-truck"></i>
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td>#ORD-2023-1002</td>
                            <td>June 10, 2023</td>
                            <td>$89.50</td>
                            <td><span class="status delivered">Delivered</span></td>
                            <td>
                                <a href="order-details.jsp?id=1002" class="action-btn" title="View">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="track-order.jsp?id=1002" class="action-btn" title="Track">
                                    <i class="fas fa-truck"></i>
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td>#ORD-2023-1003</td>
                            <td>June 5, 2023</td>
                            <td>$210.75</td>
                            <td><span class="status processing">Processing</span></td>
                            <td>
                                <a href="order-details.jsp?id=1003" class="action-btn" title="View">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="track-order.jsp?id=1003" class="action-btn" title="Track">
                                    <i class="fas fa-truck"></i>
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td>#ORD-2023-1004</td>
                            <td>May 28, 2023</td>
                            <td>$45.99</td>
                            <td><span class="status cancelled">Cancelled</span></td>
                            <td>
                                <a href="order-details.jsp?id=1004" class="action-btn" title="View">
                                    <i class="fas fa-eye"></i>
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td>#ORD-2023-1005</td>
                            <td>May 20, 2023</td>
                            <td>$175.25</td>
                            <td><span class="status delivered">Delivered</span></td>
                            <td>
                                <a href="order-details.jsp?id=1005" class="action-btn" title="View">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="track-order.jsp?id=1005" class="action-btn" title="Track">
                                    <i class="fas fa-truck"></i>
                                </a>
                            </td>
                        </tr>
                    </tbody>
                </table>
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
    </script>
</body>
</html>
