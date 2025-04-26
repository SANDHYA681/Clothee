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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${contextPath == null ? request.getContextPath() : contextPath}/css/admin-orders-mvc.css">
    <style>
        /* Additional header styles */
        .dashboard-header {
            background-color: #ffffff;
            padding: 15px 20px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            border-radius: var(--border-radius);
        }

        .page-title {
            font-size: 24px;
            font-weight: 600;
            color: var(--primary-color);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .page-title i {
            font-size: 22px;
        }

        .header-actions {
            display: flex;
            gap: 10px;
        }

        .header-action {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--light-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-color);
            text-decoration: none;
            transition: var(--transition);
        }

        .header-action:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .sidebar-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 20px;
            color: var(--text-color);
            cursor: pointer;
        }

        /* Enhanced sidebar styles */
        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 260px;
            background-color: #2c3e50;
            color: #ecf0f1;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            overflow-y: auto;
            transition: all 0.3s ease;
            z-index: 1000;
        }

        .sidebar.collapsed {
            width: 70px;
        }

        .sidebar-header {
            padding: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            color: #ecf0f1;
            margin-bottom: 15px;
        }

        .logo-icon {
            font-size: 24px;
            color: var(--primary-color);
        }

        .logo-text {
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 1px;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 0;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background-color: var(--primary-color);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }

        .user-details {
            overflow: hidden;
        }

        .user-details h4 {
            margin: 0;
            font-size: 16px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-details p {
            margin: 0;
            font-size: 12px;
            opacity: 0.7;
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-item {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            text-decoration: none;
            color: #ecf0f1;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
            margin-bottom: 5px;
            font-weight: 400;
        }

        .menu-item:hover {
            background-color: rgba(255, 255, 255, 0.1);
            border-left-color: var(--primary-color);
            color: #ffffff;
        }

        .menu-item.active {
            background-color: rgba(52, 152, 219, 0.2);
            border-left-color: var(--primary-color);
            font-weight: 500;
            color: #ffffff;
        }

        .menu-icon {
            margin-right: 12px;
            width: 20px;
            text-align: center;
            font-size: 16px;
            color: rgba(255, 255, 255, 0.7);
        }

        .menu-item:hover .menu-icon,
        .menu-item.active .menu-icon {
            color: var(--primary-color);
        }

        .main-content {
            flex: 1;
            margin-left: 260px;
            padding: 20px;
            transition: all 0.3s ease;
        }

        .main-content.expanded {
            margin-left: 70px;
        }

        /* Enhanced alert styles */
        .alert {
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: var(--border-radius);
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            transition: opacity 0.3s ease;
        }

        .alert i {
            font-size: 18px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

        /* Payment status badge with tooltip */
        .badge[title] {
            cursor: help;
            position: relative;
        }

        .badge[title]:hover::after {
            content: attr(title);
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            background-color: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
            z-index: 10;
            margin-bottom: 5px;
        }

        .badge[title]:hover::before {
            content: "";
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            border-width: 5px;
            border-style: solid;
            border-color: rgba(0, 0, 0, 0.8) transparent transparent transparent;
            z-index: 10;
        }

        /* Fix Paid Orders button */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .section-header .header-actions {
            display: flex;
            gap: 10px;
        }

        .section-header .btn-primary {
            display: flex;
            align-items: center;
            gap: 5px;
            padding: 8px 12px;
            background-color: #3498db;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        .section-header .btn-primary:hover {
            background-color: #2980b9;
        }

        @media (max-width: 768px) {
            .sidebar-toggle {
                display: block;
            }

            .sidebar {
                transform: translateX(-100%);
                width: 240px;
            }

            .sidebar.collapsed {
                transform: translateX(0);
                width: 240px;
            }

            .main-content {
                margin-left: 0;
            }

            .main-content.expanded {
                margin-left: 0;
            }

            .dashboard-header {
                padding: 10px 15px;
            }

            .page-title {
                font-size: 20px;
            }

            .order-stats {
                flex-direction: column;
            }

            .stat-item {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/index.jsp" class="logo">
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
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/dashboard.jsp" class="menu-item">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    Dashboard
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    Products
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/orders.jsp" class="menu-item active">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/customers.jsp" class="menu-item">
                    <i class="fas fa-users menu-icon"></i>
                    Customers
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/reviews.jsp" class="menu-item">
                    <i class="fas fa-star menu-icon"></i>
                    Reviews
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/messages.jsp" class="menu-item">
                    <i class="fas fa-envelope menu-icon"></i>
                    Messages
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/settings.jsp" class="menu-item">
                    <i class="fas fa-cog menu-icon"></i>
                    Settings
                </a>
                <a href="${contextPath == null ? request.getContextPath() : contextPath}/LogoutServlet" class="menu-item">
                    <i class="fas fa-sign-out-alt menu-icon"></i>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <button id="sidebarToggle" class="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>
                <h1 class="page-title"><i class="fas fa-shopping-bag"></i> Order Management</h1>
                <div class="header-actions">
                    <a href="${contextPath == null ? request.getContextPath() : contextPath}/admin/dashboard.jsp" class="header-action" title="Dashboard">
                        <i class="fas fa-tachometer-alt"></i>
                    </a>
                    <a href="${contextPath == null ? request.getContextPath() : contextPath}/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                    <a href="${contextPath == null ? request.getContextPath() : contextPath}/LogoutServlet" class="header-action" title="Logout">
                        <i class="fas fa-sign-out-alt"></i>
                    </a>
                </div>
            </div>

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

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Filter Orders</h2>
                    <div class="header-actions">
                        <a href="${contextPath == null ? request.getContextPath() : contextPath}/AdminDatabaseFixServlet?action=fixPaidOrders" class="btn-primary" title="Fix Paid Orders">
                            <i class="fas fa-sync"></i> Fix Paid Orders
                        </a>
                    </div>
                </div>
                <div class="filter-options" style="display: flex; gap: 10px; margin-bottom: 20px;">
                    <form action="<%=request.getContextPath()%>/AdminOrderServlet" method="get" class="filter-form" style="display: flex; gap: 10px; width: 100%;">
                        <input type="hidden" name="action" value="list">
                        <select name="status" id="statusFilter" class="form-control" style="flex: 1;">
                            <option value="all">All Statuses</option>
                            <option value="Pending" <%= request.getParameter("status") != null && request.getParameter("status").equals("Pending") ? "selected" : "" %>>Pending</option>
                            <option value="Processing" <%= request.getParameter("status") != null && request.getParameter("status").equals("Processing") ? "selected" : "" %>>Processing</option>
                            <option value="Shipped" <%= request.getParameter("status") != null && request.getParameter("status").equals("Shipped") ? "selected" : "" %>>Shipped</option>
                            <option value="Delivered" <%= request.getParameter("status") != null && request.getParameter("status").equals("Delivered") ? "selected" : "" %>>Delivered</option>
                            <option value="Cancelled" <%= request.getParameter("status") != null && request.getParameter("status").equals("Cancelled") ? "selected" : "" %>>Cancelled</option>
                        </select>
                        <button type="submit" class="btn-primary" style="padding: 10px 15px;">
                            <i class="fas fa-filter"></i> Apply Filter
                        </button>
                    </form>
                </div>
            </div>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fas fa-list"></i> All Orders</h2>
                        <div class="order-stats">
                            <div class="stat-item">
                                <span class="stat-label">Total:</span>
                                <span class="stat-value"><%= totalOrders %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Pending:</span>
                                <span class="stat-value"><%= pendingOrders %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Processing:</span>
                                <span class="stat-value"><%= processingOrders %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Shipped:</span>
                                <span class="stat-value"><%= shippedOrders %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Delivered:</span>
                                <span class="stat-value"><%= deliveredOrders %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Cancelled:</span>
                                <span class="stat-value"><%= cancelledOrders %></span>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Customer</th>
                                        <th>Date</th>
                                        <th>Total</th>
                                        <th>Order Status</th>
                                        <th>Payment Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (orders != null && !orders.isEmpty()) { %>
                                        <% for (Order order : orders) { %>
                                            <tr>
                                                <td>#<%= order.getId() %></td>
                                                <td>
                                                    <a href="../AdminUserServlet?action=view&id=<%= order.getUserId() %>">
                                                        Customer #<%= order.getUserId() %>
                                                    </a>
                                                </td>
                                                <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                                <td><%= currencyFormat.format(order.getTotalPrice()) %></td>
                                                <td>
                                                    <%
                                                    String paymentMethod = order.getPaymentMethod();
                                                    boolean isPaid = paymentMethod != null && (paymentMethod.equalsIgnoreCase("Credit Card") || paymentMethod.equalsIgnoreCase("PayPal"));

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
                                                    // Determine payment status based on payment method
                                                    String paymentStatus = "Pending";
                                                    if (isPaid) {
                                                        paymentStatus = "Paid";
                                                    } else if (order.getStatus().equalsIgnoreCase("Cancelled")) {
                                                        paymentStatus = "Cancelled";
                                                    }

                                                    // Show payment method as tooltip
                                                    String paymentTooltip = paymentMethod != null && !paymentMethod.isEmpty() ?
                                                        paymentMethod : "Not specified";
                                                    %>
                                                    <span class="badge badge-<%= paymentStatus.toLowerCase() %>" title="<%= paymentTooltip %>"><%= paymentStatus %></span>
                                                </td>
                                                <td>
                                                    <div class="action-buttons">
                                                        <a href="${contextPath == null ? request.getContextPath() : contextPath}/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="btn-view" title="View">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <a href="${contextPath == null ? request.getContextPath() : contextPath}/AdminOrderServlet?action=showUpdateForm&id=<%= order.getId() %>" class="btn-edit" title="Update Status">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <%
                                                        // Only show delete button if order is not paid
                                                        if (!paymentStatus.equalsIgnoreCase("Paid")) {
                                                        %>
                                                            <a href="${contextPath == null ? request.getContextPath() : contextPath}/AdminOrderServlet?action=confirmDelete&id=<%= order.getId() %>" class="btn-delete" title="Delete">
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
    </div>

    <!-- Update Order Status Modal -->
    <div class="modal" id="updateStatusModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-edit"></i> Update Order Status</h2>
                <span class="close-modal">&times;</span>
            </div>
            <div class="modal-body">
                <form id="updateStatusForm" action="${contextPath == null ? request.getContextPath() : contextPath}/OrderServlet" method="post">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" id="orderId" name="orderId">

                    <div class="form-group">
                        <label for="orderStatus">Status</label>
                        <select id="orderStatus" name="status" class="form-control" required>
                            <option value="Pending">Pending</option>
                            <option value="Processing">Processing</option>
                            <option value="Shipped">Shipped</option>
                            <option value="Delivered">Delivered</option>
                            <option value="Cancelled">Cancelled</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="statusNote">Note (Optional)</label>
                        <textarea id="statusNote" name="note" class="form-control"></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn-secondary" id="cancelUpdate">Cancel</button>
                        <button type="submit" class="btn-primary">Update Status</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle functionality
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.querySelector('.main-content');

            sidebar.classList.toggle('collapsed');
            mainContent.classList.toggle('expanded');

            // Store sidebar state in localStorage
            const isSidebarCollapsed = sidebar.classList.contains('collapsed');
            localStorage.setItem('sidebarCollapsed', isSidebarCollapsed);
        });

        // Check if sidebar was collapsed in previous session
        document.addEventListener('DOMContentLoaded', function() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.querySelector('.main-content');
            const isMobile = window.innerWidth <= 768;

            // On mobile, sidebar is hidden by default
            if (isMobile) {
                sidebar.classList.remove('collapsed');
                mainContent.classList.remove('expanded');
            } else {
                // On desktop, restore previous state
                const wasSidebarCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
                if (wasSidebarCollapsed) {
                    sidebar.classList.add('collapsed');
                    mainContent.classList.add('expanded');
                }
            }
        });

        // Modal functionality
        const modal = document.getElementById('updateStatusModal');
        const closeBtn = document.querySelector('.close-modal');
        const cancelBtn = document.getElementById('cancelUpdate');

        function updateOrderStatus(orderId) {
            document.getElementById('orderId').value = orderId;
            modal.style.display = 'block';
        }

        closeBtn.addEventListener('click', function() {
            modal.style.display = 'none';
        });

        cancelBtn.addEventListener('click', function() {
            modal.style.display = 'none';
        });

        window.addEventListener('click', function(event) {
            if (event.target === modal) {
                modal.style.display = 'none';
            }
        });

        // Filter functionality
        document.querySelector('.btn-filter')?.addEventListener('click', function() {
            const status = document.getElementById('statusFilter').value;
            const rows = document.querySelectorAll('.data-table tbody tr');

            rows.forEach(row => {
                const statusCell = row.querySelector('td:nth-child(5)');
                if (!statusCell) return;

                const statusText = statusCell.textContent.trim();

                if (status === '' || statusText.includes(status)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.opacity = '0';
                setTimeout(function() {
                    alert.style.display = 'none';
                }, 300);
            });
        }, 5000);

        // Function to confirm order deletion
        function confirmDelete(orderId) {
            if (confirm("Are you sure you want to delete this order? This action cannot be undone.")) {
                window.location.href = "${contextPath == null ? request.getContextPath() : contextPath}/AdminOrderServlet?action=delete&id=" + orderId;
            }
        }

        // Add active class to current menu item
        document.addEventListener('DOMContentLoaded', function() {
            const currentPath = window.location.pathname;
            const menuItems = document.querySelectorAll('.menu-item');

            menuItems.forEach(function(item) {
                const href = item.getAttribute('href');
                if (href && currentPath.includes(href.split('?')[0])) {
                    item.classList.add('active');
                }
            });
        });
    </script>
</body>
</html>
