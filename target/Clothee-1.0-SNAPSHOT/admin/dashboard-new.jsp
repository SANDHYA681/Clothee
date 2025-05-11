<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="model.Product" %>
<%@ page import="model.Message" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dao.MessageDAO" %>
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

// Get data for dashboard
UserDAO userDAO = new UserDAO();
OrderDAO orderDAO = new OrderDAO();
ProductDAO productDAO = new ProductDAO();
MessageDAO messageDAO = new MessageDAO();

// Get counts for dashboard cards
int totalOrders = orderDAO.getTotalOrderCount();
int totalProducts = productDAO.getTotalProductCount();
int totalCustomers = userDAO.getTotalCustomerCount();
double totalRevenue = orderDAO.getTotalRevenue();

// Get recent orders and customers for tables
List<Order> recentOrders = orderDAO.getRecentOrders(5);
List<User> recentCustomers = userDAO.getRecentCustomers(5);

// Get unread message count
int unreadMessages = messageDAO.getUnreadMessageCount();

// Check for messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");

// Clear messages after reading them
session.removeAttribute("successMessage");
session.removeAttribute("errorMessage");

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin-unified.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <a href="dashboard.jsp" class="logo">
                    <i class="fas fa-tshirt logo-icon"></i>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="user-name"><%= user.getFirstName() %> <%= user.getLastName() %></div>
                    <div class="user-role">Admin</div>
                </div>
            </div>
            <div class="sidebar-menu">
                <a href="dashboard.jsp" class="menu-item active">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    <span>Dashboard</span>
                </a>
                <a href="products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    <span>Products</span>
                </a>
                <a href="categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    <span>Categories</span>
                </a>
                <a href="orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-cart menu-icon"></i>
                    <span>Orders</span>
                </a>
                <a href="customers.jsp" class="menu-item">
                    <i class="fas fa-users menu-icon"></i>
                    <span>Customers</span>
                </a>
                <a href="reviews.jsp" class="menu-item">
                    <i class="fas fa-star menu-icon"></i>
                    <span>Reviews</span>
                </a>
                <a href="messages.jsp" class="menu-item">
                    <i class="fas fa-envelope menu-icon"></i>
                    <span>Messages</span>
                    <% if (unreadMessages > 0) { %>
                        <span class="badge"><%= unreadMessages %></span>
                    <% } %>
                </a>
                <a href="settings.jsp" class="menu-item">
                    <i class="fas fa-cog menu-icon"></i>
                    <span>Settings</span>
                </a>
                <a href="../LogoutServlet" class="menu-item">
                    <i class="fas fa-sign-out-alt menu-icon"></i>
                    <span>Logout</span>
                </a>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Dashboard Header -->
            <div class="dashboard-header">
                <h1 class="page-title">Dashboard</h1>
                <div class="header-actions">
                    <a href="messages.jsp" class="header-action">
                        <i class="fas fa-envelope"></i>
                        <% if (unreadMessages > 0) { %>
                            <span class="header-badge"><%= unreadMessages %></span>
                        <% } %>
                    </a>
                    <a href="settings.jsp" class="header-action">
                        <i class="fas fa-cog"></i>
                    </a>
                    <a href="../LogoutServlet" class="header-action">
                        <i class="fas fa-sign-out-alt"></i>
                    </a>
                </div>
            </div>

            <!-- Success/Error Messages -->
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <%= successMessage %>
                </div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
                </div>
            <% } %>

            <!-- Dashboard Cards -->
            <div class="dashboard-cards">
                <a href="orders.jsp" class="dashboard-card-link">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h3 class="card-title">Total Orders</h3>
                            <div class="card-icon orders">
                                <i class="fas fa-shopping-cart"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalOrders %></div>
                        <div class="card-description">View all orders</div>
                    </div>
                </a>
                <a href="products.jsp" class="dashboard-card-link">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h3 class="card-title">Total Products</h3>
                            <div class="card-icon products">
                                <i class="fas fa-box"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalProducts %></div>
                        <div class="card-description">View all products</div>
                    </div>
                </a>
                <a href="customers.jsp" class="dashboard-card-link">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h3 class="card-title">Total Customers</h3>
                            <div class="card-icon users">
                                <i class="fas fa-users"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalCustomers %></div>
                        <div class="card-description">View all customers</div>
                    </div>
                </a>
                <a href="orders.jsp" class="dashboard-card-link">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h3 class="card-title">Total Revenue</h3>
                            <div class="card-icon revenue">
                                <i class="fas fa-dollar-sign"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= currencyFormat.format(totalRevenue) %></div>
                        <div class="card-description">View revenue details</div>
                    </div>
                </a>
            </div>

            <!-- Recent Orders -->
            <div class="recent-orders">
                <div class="section-header">
                    <h2 class="section-title">Recent Orders</h2>
                    <a href="orders.jsp" class="view-all">View All</a>
                </div>
                <table class="orders-table">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Customer</th>
                            <th>Date</th>
                            <th>Total</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentOrders.isEmpty()) { %>
                            <tr>
                                <td colspan="5" style="text-align: center;">No orders found</td>
                            </tr>
                        <% } else { %>
                            <% for (Order order : recentOrders) { %>
                                <tr>
                                    <td>#<%= order.getId() %></td>
                                    <td><%= order.getUserName() %></td>
                                    <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                    <td><%= currencyFormat.format(order.getTotalPrice()) %></td>
                                    <td>
                                        <span class="status <%= order.getStatus().toLowerCase() %>">
                                            <%= order.getStatus() %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Recent Customers -->
            <div class="recent-users">
                <div class="section-header">
                    <h2 class="section-title">Recent Customers</h2>
                    <a href="customers.jsp" class="view-all">View All</a>
                </div>
                <table class="users-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Joined</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentCustomers.isEmpty()) { %>
                            <tr>
                                <td colspan="4" style="text-align: center;">No customers found</td>
                            </tr>
                        <% } else { %>
                            <% for (User customer : recentCustomers) { %>
                                <tr>
                                    <td>#<%= customer.getId() %></td>
                                    <td><%= customer.getFirstName() %> <%= customer.getLastName() %></td>
                                    <td><%= customer.getEmail() %></td>
                                    <td><%= dateFormat.format(customer.getCreatedAt()) %></td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Toggle sidebar on mobile
        document.addEventListener('DOMContentLoaded', function() {
            const menuToggle = document.querySelector('.menu-toggle');
            const sidebar = document.querySelector('.sidebar');

            if (menuToggle) {
                menuToggle.addEventListener('click', function() {
                    sidebar.classList.toggle('active');
                });
            }
        });
    </script>
</body>
</html>
