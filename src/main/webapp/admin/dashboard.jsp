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
<%@ page import="dao.CategoryDAO" %>
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
CategoryDAO categoryDAO = new CategoryDAO();

// Get counts for dashboard cards
int totalOrders = orderDAO.getTotalOrderCount();
int totalProducts = productDAO.getTotalProductCount();
int totalCustomers = userDAO.getTotalCustomerCount();
double totalRevenue = orderDAO.getTotalRevenue();
int totalCategories = categoryDAO.getTotalCategoryCount();

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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-new.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-dashboard-fix.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the new sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

        <div class="content">
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="notification notification-success">
                <%= successMessage %>
            </div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="notification notification-danger">
                <%= errorMessage %>
            </div>
            <% } %>

            <div class="content-header">
                <h1>Admin Dashboard</h1>
                <div class="header-actions">
                    <a href="messages.jsp" class="header-action" title="Messages <% if (unreadMessages > 0) { %>(<%=unreadMessages%> unread)<% } %>">
                        <i class="fas fa-envelope"></i>
                        <% if (unreadMessages > 0) { %><span class="header-badge"><%= unreadMessages %></span><% } %>
                    </a>
                </div>
            </div>

            <div class="dashboard-cards">
                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="dashboard-card-link" style="cursor: pointer !important; pointer-events: auto !important;">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h2 class="card-title">Total Orders</h2>
                            <div class="card-icon orders">
                                <i class="fas fa-shopping-bag"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalOrders %></div>
                        <p class="card-description">All time orders</p>
                    </div>
                </a>

                <a href="<%= request.getContextPath() %>/admin/products.jsp" class="dashboard-card-link" style="cursor: pointer !important; pointer-events: auto !important;">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h2 class="card-title">Total Products</h2>
                            <div class="card-icon products">
                                <i class="fas fa-box"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalProducts %></div>
                        <p class="card-description">Products in inventory</p>
                    </div>
                </a>

                <a href="<%= request.getContextPath() %>/AdminUserServlet" class="dashboard-card-link" style="cursor: pointer !important; pointer-events: auto !important;">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h2 class="card-title">Total Customers</h2>
                            <div class="card-icon users">
                                <i class="fas fa-users"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalCustomers %></div>
                        <p class="card-description">Registered users</p>
                    </div>
                </a>

                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="dashboard-card-link" style="cursor: pointer !important; pointer-events: auto !important;">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h2 class="card-title">Total Revenue</h2>
                            <div class="card-icon revenue">
                                <i class="fas fa-dollar-sign"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= currencyFormat.format(totalRevenue) %></div>
                        <p class="card-description">All time revenue</p>
                    </div>
                </a>

                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="dashboard-card-link" style="cursor: pointer !important; pointer-events: auto !important;">
                    <div class="dashboard-card">
                        <div class="card-header">
                            <h2 class="card-title">Categories</h2>
                            <div class="card-icon categories" style="background-color: rgba(108, 92, 231, 0.1); color: #6c5ce7;">
                                <i class="fas fa-tags"></i>
                            </div>
                        </div>
                        <div class="card-value"><%= totalCategories %></div>
                        <p class="card-description">Product categories</p>
                    </div>
                </a>
            </div>

            <div class="chart-container">
                <div class="chart-card">
                    <div class="section-header">
                        <h2 class="section-title">Admin Quick Actions</h2>
                    </div>
                    <div class="quick-actions">
                        <a href="<%= request.getContextPath() %>/admin/AdminProductServlet?action=showAddForm" class="quick-action-btn" style="cursor: pointer !important; pointer-events: auto !important;">
                            <i class="fas fa-plus-circle"></i>
                            <span>Add New Product</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/AdminCategoryServlet?action=showAddForm" class="quick-action-btn" style="cursor: pointer !important; pointer-events: auto !important;">
                            <i class="fas fa-folder-plus"></i>
                            <span>Add New Category</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="quick-action-btn" style="cursor: pointer !important; pointer-events: auto !important;">
                            <i class="fas fa-envelope"></i>
                            <span>Check Messages <% if (unreadMessages > 0) { %><span class="badge"><%= unreadMessages %></span><% } %></span>
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/add-customer.jsp" class="quick-action-btn" style="cursor: pointer !important; pointer-events: auto !important;">
                            <i class="fas fa-user-plus"></i>
                            <span>Add New Customer</span>
                        </a>
                    </div>
                </div>

                <!-- User role indicator -->
                <div class="user-role-indicator" style="margin-top: 20px; text-align: right;">
                    <span class="user-role-badge">Logged in as: Admin</span>
                </div>
            </div>

            <div class="recent-orders">
                <div class="section-header">
                    <h2 class="section-title">Recent Orders</h2>
                    <a href="orders.jsp" class="view-all">View All</a>
                </div>

                <div class="table-responsive">
                    <table class="orders-table">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer</th>
                                <th>Date</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (recentOrders != null && !recentOrders.isEmpty()) {
                                for (Order order : recentOrders) {
                                    User customer = userDAO.getUserById(order.getUserId());
                            %>
                            <tr>
                                <td>#ORD-<%= order.getId() %></td>
                                <td><%= customer != null ? customer.getFirstName() + " " + customer.getLastName() : "Unknown" %></td>
                                <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                <td><%= currencyFormat.format(order.getTotalPrice()) %></td>
                                <td>
                                    <% if ("delivered".equalsIgnoreCase(order.getStatus())) { %>
                                        <span class="status delivered">Delivered</span>
                                    <% } else if ("processing".equalsIgnoreCase(order.getStatus())) { %>
                                        <span class="status processing">Processing</span>
                                    <% } else if ("cancelled".equalsIgnoreCase(order.getStatus())) { %>
                                        <span class="status cancelled">Cancelled</span>
                                    <% } else { %>
                                        <span class="status"><%= order.getStatus() %></span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="action-btn" title="View">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=showUpdateForm&id=<%= order.getId() %>" class="action-btn" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                </td>
                            </tr>
                            <% }
                            } else { %>
                            <tr>
                                <td colspan="6" style="text-align: center;">No orders found</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="recent-users">
                <div class="section-header">
                    <h2 class="section-title">Recent Customers</h2>
                    <a href="customers.jsp" class="view-all">View All</a>
                </div>

                <div class="table-responsive">
                    <table class="users-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Joined Date</th>
                                <th>Orders</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (recentCustomers != null && !recentCustomers.isEmpty()) {
                                for (User customer : recentCustomers) {
                                    int orderCount = orderDAO.getOrderCountByUserId(customer.getId());
                            %>
                            <tr>
                                <td>#USR-<%= customer.getId() %></td>
                                <td><%= customer.getFirstName() + " " + customer.getLastName() %></td>
                                <td><%= customer.getEmail() %></td>
                                <td><%= dateFormat.format(customer.getCreatedAt()) %></td>
                                <td><%= orderCount %></td>
                                <td>
                                    <a href="../AdminUserServlet?action=view&id=<%= customer.getId() %>" class="action-btn" title="View">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <a href="../AdminUserServlet?action=showEditForm&id=<%= customer.getId() %>" class="action-btn" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <a href="../AdminUserServlet?action=delete&id=<%= customer.getId() %>" class="action-btn" title="Delete" onclick="return confirm('Are you sure you want to delete this user?');">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                            <% }
                            } else { %>
                            <tr>
                                <td colspan="6" style="text-align: center;">No customers found</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

<<<<<<< HEAD
    <!-- No JavaScript -->
=======
    <!-- Minimal UI enhancements are loaded in the header.jsp file -->
    <!-- No additional JavaScript needed here -->
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8

    <!-- Include common footer scripts -->
    <jsp:include page="includes/footer-scripts.jsp" />
</body>
</html>
