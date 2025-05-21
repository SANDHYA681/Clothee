<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
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

// Get orders from request attribute (set by AdminOrderServlet)
List<Order> orders = (List<Order>) request.getAttribute("orders");
if (orders == null) {
    // If orders is null, redirect to AdminOrderServlet to get the orders
    response.sendRedirect(request.getContextPath() + "/AdminOrderServlet?action=list");
    return;
}

// Get order statistics from request attributes
Integer totalOrders = (Integer) request.getAttribute("totalOrders");
Integer pendingOrders = (Integer) request.getAttribute("pendingOrders");
Integer processingOrders = (Integer) request.getAttribute("processingOrders");
Integer shippedOrders = (Integer) request.getAttribute("shippedOrders");
Integer deliveredOrders = (Integer) request.getAttribute("deliveredOrders");
Integer cancelledOrders = (Integer) request.getAttribute("cancelledOrders");

// Set default values if attributes are not set
if (totalOrders == null) totalOrders = orders.size();
if (pendingOrders == null) pendingOrders = 0;
if (processingOrders == null) processingOrders = 0;
if (shippedOrders == null) shippedOrders = 0;
if (deliveredOrders == null) deliveredOrders = 0;
if (cancelledOrders == null) cancelledOrders = 0;

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");

// Check for messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");
String message = request.getParameter("message");
String error = request.getParameter("error");

// Clear messages after reading them
session.removeAttribute("successMessage");
session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Orders</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-orders-blue.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-orders-fix.css">
    <style>
        /* Additional compact styles */
        .admin-content {
            padding: 10px;
        }
        .content-header {
            margin-bottom: 10px;
            padding: 8px 0;
        }
        .page-title {
            font-size: 18px;
            margin: 0;
        }
        .dashboard-container {
            min-height: auto;
        }
        .content {
            padding: 10px;
        }
        .alert {
            padding: 8px;
            margin-bottom: 10px;
        }
        /* Make table more compact */
        .data-table td, .data-table th {
            padding: 4px 6px;
            font-size: 12px;
        }
        /* Compact card */
        .card {
            margin-bottom: 10px !important;
        }
        .card-header {
            padding: 8px 10px;
        }
        .card-title {
            font-size: 14px;
        }
        .card-body {
            padding: 10px !important;
        }
        /* Compact stats */
        .order-stats {
            gap: 8px !important;
        }
        .stat-card {
            padding: 8px !important;
        }
        .stat-icon {
            width: 30px !important;
            height: 30px !important;
            margin-bottom: 5px !important;
        }
        .stat-icon i {
            font-size: 12px !important;
        }
        .stat-value {
            font-size: 16px !important;
            margin-bottom: 2px !important;
        }
        .stat-label {
            font-size: 10px !important;
        }
        /* Compact action buttons */
        .action-buttons {
            gap: 5px !important;
        }
        .action-btn {
            width: 24px !important;
            height: 24px !important;
        }
        .action-btn i {
            font-size: 12px !important;
        }
        /* Status badge */
        .badge {
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 10px;
        }
        /* Header actions */
        .header-actions {
            display: none; /* Hide header actions to save space */
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the new sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

        <div class="content">
            <div class="content-header">
                <h1>Order Management</h1>
            </div>

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

            <% if (message != null && !message.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= message %>
            </div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
            <% } %>

<<<<<<< HEAD:target/Clothee/admin/orders.jsp
            <!-- Fix Paid Orders button removed as requested -->

            <!-- Order Statistics -->
            <div class="card">
=======
            <!-- Order Statistics Section -->
            <div class="card" style="margin-bottom: 10px;">
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8:target/Clothee-1.0-SNAPSHOT/admin/orders.jsp
                <div class="card-header">
                    <h2 class="card-title"><i class="fas fa-chart-pie"></i> Order Statistics</h2>
                </div>
                <div class="card-body">
                    <div class="order-stats">
                        <div class="stat-card" style="border-left-color: #4361ee;">
                            <div class="stat-icon" style="background-color: rgba(67, 97, 238, 0.1);">
                                <i class="fas fa-shopping-bag" style="color: #4361ee;"></i>
                            </div>
                            <div class="stat-value"><%= totalOrders %></div>
                            <div class="stat-label">Total Orders</div>
                        </div>

                        <div class="stat-card" style="border-left-color: #f39c12;">
                            <div class="stat-icon" style="background-color: rgba(243, 156, 18, 0.1);">
                                <i class="fas fa-clock" style="color: #f39c12;"></i>
                            </div>
                            <div class="stat-value"><%= pendingOrders %></div>
                            <div class="stat-label">Pending</div>
                        </div>

                        <div class="stat-card" style="border-left-color: #3498db;">
                            <div class="stat-icon" style="background-color: rgba(52, 152, 219, 0.1);">
                                <i class="fas fa-cog" style="color: #3498db;"></i>
                            </div>
                            <div class="stat-value"><%= processingOrders %></div>
                            <div class="stat-label">Processing</div>
                        </div>

                        <div class="stat-card" style="border-left-color: #4361ee;">
                            <div class="stat-icon" style="background-color: rgba(67, 97, 238, 0.1);">
                                <i class="fas fa-truck" style="color: #4361ee;"></i>
                            </div>
                            <div class="stat-value"><%= shippedOrders %></div>
                            <div class="stat-label">Shipped</div>
                        </div>

                        <div class="stat-card" style="border-left-color: #2ecc71;">
                            <div class="stat-icon" style="background-color: rgba(46, 204, 113, 0.1);">
                                <i class="fas fa-check-circle" style="color: #2ecc71;"></i>
                            </div>
                            <div class="stat-value"><%= deliveredOrders %></div>
                            <div class="stat-label">Delivered</div>
                        </div>

                        <div class="stat-card" style="border-left-color: #e74c3c;">
                            <div class="stat-icon" style="background-color: rgba(231, 76, 60, 0.1);">
                                <i class="fas fa-times-circle" style="color: #e74c3c;"></i>
                            </div>
                            <div class="stat-value"><%= cancelledOrders %></div>
                            <div class="stat-label">Cancelled</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title"><i class="fas fa-list"></i> All Orders</h2>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="width: 60px;">Order ID</th>
                                    <th style="width: 100px;">Customer</th>
                                    <th style="width: 120px;">Date</th>
                                    <th style="width: 80px;">Total</th>
                                    <th style="width: 100px;">Order Status</th>
                                    <th style="width: 100px;">Payment Status</th>
                                    <th style="width: 80px;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (orders != null && !orders.isEmpty()) { %>
                                    <% for (Order order : orders) { %>
                                        <tr>
                                            <td><a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" style="color: #4361ee; text-decoration: underline;">#<%= order.getId() %></a></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/AdminUserServlet?action=view&id=<%= order.getUserId() %>">
                                                    Customer #<%= order.getUserId() %>
                                                </a>
                                            </td>
                                            <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                            <td><%= currencyFormat.format(order.getTotalPrice()) %></td>
                                            <td>
                                                <%
                                                // Assume all orders are paid
                                                boolean isPaid = true;

                                                // Only show the order status in this column (not payment status)
                                                String displayStatus = order.getStatus();

                                                // If order is paid but status is still pending, show as processing
                                                if (isPaid && displayStatus.equalsIgnoreCase("Pending")) {
                                                    displayStatus = "Processing";
                                                }
                                                %>
                                                <span class="badge badge-<%= displayStatus.toLowerCase() %>"><%= displayStatus %></span>
                                            </td>
                                            <td>
                                                <%
                                                // Determine payment status
                                                String paymentStatus = "Paid";
                                                if (order.getStatus().equalsIgnoreCase("Cancelled")) {
                                                    paymentStatus = "Cancelled";
                                                }

                                                // Set tooltip
                                                String paymentTooltip = "Payment processed";
                                                %>
                                                <span class="badge badge-<%= paymentStatus.toLowerCase() %>" title="<%= paymentTooltip %>"><%= paymentStatus %></span>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <%
                                                    // Only show edit button if order is not delivered
                                                    if (!displayStatus.equalsIgnoreCase("Delivered")) {
                                                    %>
                                                    <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=showUpdateForm&id=<%= order.getId() %>" class="btn-edit" title="Update Order">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <% } else { %>
                                                    <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="btn-view" title="View Order (Delivered orders cannot be edited)">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <% } %>
                                                    <%
                                                    // Only show delete button if order is not paid
                                                    if (!paymentStatus.equalsIgnoreCase("Paid")) {
                                                    %>
                                                        <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=confirmDelete&id=<%= order.getId() %>" class="btn-delete" title="Delete Order">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    <% } else { %>
                                                        <!-- Disabled delete button for paid orders -->
                                                        <span class="btn-delete disabled" title="Cannot delete paid orders" style="opacity: 0.5; cursor: not-allowed;">
                                                            <i class="fas fa-trash"></i>
                                                        </span>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } else { %>
                                    <tr>
                                        <td colspan="7" class="text-center"><i class="fas fa-info-circle"></i> No orders found</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

<<<<<<< HEAD:target/Clothee/admin/orders.jsp
    <!-- Modal has been removed to comply with project requirements (no JavaScript) -->
    <!-- Status updates can be handled through direct links to the update page instead -->
=======
    <!-- Status updates are handled through direct links to the update page -->

    <!-- Add minimal JavaScript for sidebar toggle -->
    <script>
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });
    </script>
>>>>>>> 9b37fa48ea2abd2526c46b02e1af26f3d35528e8:target/Clothee-1.0-SNAPSHOT/admin/orders.jsp
</body>
</html>
