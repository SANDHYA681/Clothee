<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>

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

    // Get orders for this user
    List<Order> orders = new ArrayList<>();
    // Get orders from the session (set by OrderServlet)
    Object ordersObj = session.getAttribute("userOrders");
    if (ordersObj != null) {
        orders = (List<Order>) ordersObj;
    }

    // Get success and error messages if any
    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");

    // Get pagination info from session
    Integer currentPage = (Integer) session.getAttribute("currentPage");
    Integer totalPages = (Integer) session.getAttribute("totalPages");

    // Default values if not set
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;

    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/dashboard-pro.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/order-page.css">
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
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default.png" alt="<%= user.getFullName() %>">
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title"><i class="fas fa-shopping-bag"></i> My Orders</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="Back to Shop">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <!-- Filter Orders -->
            <div class="filter-section">
                <form action="<%=request.getContextPath()%>/OrderServlet" method="get" class="filter-form">
                    <input type="hidden" name="action" value="viewOrders">
                    <div class="form-group">
                        <label for="status">Filter by Status:</label>
                        <select name="status" id="status" class="form-control">
                            <option value="all">All Orders</option>
                            <option value="Pending">Pending</option>
                            <option value="Processing">Processing</option>
                            <option value="Shipped">Shipped</option>
                            <option value="Delivered">Delivered</option>
                            <option value="Cancelled">Cancelled</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-filter">Filter</button>
                </form>
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

            <% if (orders.isEmpty()) { %>
                <div class="orders-container">
                    <div class="empty-state">
                        <i class="fas fa-shopping-bag"></i>
                        <p>You haven't placed any orders yet.</p>
                        <a href="<%=request.getContextPath()%>/ProductServlet" class="btn-primary">Shop Now</a>
                    </div>
                </div>
            <% } else { %>
                <div class="orders-container">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Total</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Order order : orders) { %>
                                <tr>
                                    <td>#ORD-<%= order.getId() %></td>
                                    <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                    <td>
                                        <span class="badge <%= order.getStatus().toLowerCase() %>">
                                            <%= order.getStatus() %>
                                        </span>
                                    </td>
                                    <td>$<%= String.format("%.2f", order.getTotalPrice()) %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrder&id=<%= order.getId() %>" class="btn-view" title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <% if (totalPages > 1) { %>
                    <div class="pagination">
                        <% if (currentPage > 1) { %>
                            <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders&page=<%= currentPage - 1 %>" class="page-link"><i class="fas fa-chevron-left"></i> Previous</a>
                        <% } else { %>
                            <span class="page-link disabled"><i class="fas fa-chevron-left"></i> Previous</span>
                        <% } %>

                        <div class="page-numbers">
                            <%
                            // Show at most 5 page numbers
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, startPage + 4);

                            // Adjust start page if needed
                            if (endPage - startPage < 4) {
                                startPage = Math.max(1, endPage - 4);
                            }

                            for (int i = startPage; i <= endPage; i++) {
                            %>
                                <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders&page=<%= i %>" class="page-number <%= i == currentPage ? "active" : "" %>"><%= i %></a>
                            <% } %>
                        </div>

                        <% if (currentPage < totalPages) { %>
                            <a href="<%=request.getContextPath()%>/OrderServlet?action=viewOrders&page=<%= currentPage + 1 %>" class="page-link">Next <i class="fas fa-chevron-right"></i></a>
                        <% } else { %>
                            <span class="page-link disabled">Next <i class="fas fa-chevron-right"></i></span>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </div><!-- End of main-content -->
    </div><!-- End of dashboard-container -->

    <!-- Include external JavaScript file -->
    <script src="<%=request.getContextPath()%>/js/sidebar.js"></script>

    <!-- CSS moved to external file: orders.css -->
</body>
</html>
