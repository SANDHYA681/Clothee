<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderItem" %>
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

// Get order from request attribute (set by AdminOrderServlet)
Order order = (Order) request.getAttribute("order");
List<OrderItem> orderItems = (List<OrderItem>) request.getAttribute("orderItems");
User customer = (User) request.getAttribute("customer");

// If attributes are not set, redirect to AdminOrderServlet
if (order == null) {
    // Get order ID from request parameter
    String orderIdStr = request.getParameter("id");
    if (orderIdStr == null || orderIdStr.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=No+order+ID+provided");
        return;
    }

    try {
        // Instead of redirecting, forward to the servlet
        request.getRequestDispatcher("/AdminOrderServlet?action=showUpdateForm&id=" + orderIdStr).forward(request, response);
    } catch (Exception e) {
        // Log the error
        System.out.println("Error in edit-order.jsp: " + e.getMessage());
        e.printStackTrace();
        // Set error in session instead of URL parameter to avoid encoding issues
        session.setAttribute("errorMessage", "Error loading order: " + e.getMessage());
        response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
    }
    return;
}

// Format date and currency
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss");
DecimalFormat currencyFormat = new DecimalFormat("$#,##0.00");

// Assume all orders are paid
boolean isPaid = true;

// Get status options for dropdown - exclude Cancelled for paid orders
String[] statusOptions;
if (isPaid) {
    statusOptions = new String[]{"Processing", "Shipped", "Delivered"};
    System.out.println("Order is paid, removing Cancelled and Pending options");
} else {
    statusOptions = new String[]{"Pending", "Processing", "Shipped", "Delivered", "Cancelled"};
    System.out.println("Order is not paid, showing all status options");
}

// Check for messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");

// Clear messages after reading them
session.removeAttribute("successMessage");
session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Order - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-order-edit-new.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the new sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

        <div class="content">
            <div class="content-header">
                <h1>Edit Order #<%= order.getId() %></h1>
                <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Back to Order Details
                </a>
            </div>

            <%
            // Check for URL parameters (different from session attributes)
            String successParam = request.getParameter("success");
            String errorParam = request.getParameter("error");

            // Display success message from either session or URL parameter
            if ((successMessage != null && !successMessage.isEmpty()) || (successParam != null && !successParam.isEmpty())) {
            %>
            <div class="alert alert-success">
                <%= successMessage != null && !successMessage.isEmpty() ? successMessage : successParam %>
            </div>
            <% } %>

            <% if ((errorMessage != null && !errorMessage.isEmpty()) || (errorParam != null && !errorParam.isEmpty())) { %>
            <div class="alert alert-danger">
                <%= errorMessage != null && !errorMessage.isEmpty() ? errorMessage : errorParam %>
            </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/AdminOrderServlet" method="post">
                <input type="hidden" name="action" value="updateOrder">
                <input type="hidden" name="orderId" value="<%= order.getId() %>">
                <!-- Add debug info to help troubleshoot -->
                <input type="hidden" name="debug" value="true">

                <div class="form-container">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i> As an administrator, you can only update the order status. Other order details cannot be modified.
                    </div>
                    <div class="form-section">
                        <h2 class="section-title">Order Information</h2>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="status" class="form-label">Status</label>
                                <select name="status" id="status" class="form-control">
                                    <% if (isPaid) { %>
                                    <!-- Placeholder for paid orders -->
                                    <% } %>
                                    <% for (String statusOption : statusOptions) { %>
                                        <option value="<%= statusOption %>" <%= order.getStatus().equals(statusOption) ? "selected" : "" %>><%= statusOption %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="orderDate" class="form-label">Order Date</label>
                                <input type="text" id="orderDate" class="form-control" value="<%= dateFormat.format(order.getOrderDate()) %>" readonly>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h2 class="section-title">Customer Information</h2>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="customerName" class="form-label">Customer Name</label>
                                <input type="text" id="customerName" class="form-control" value="<%= customer != null ? customer.getFirstName() + " " + customer.getLastName() : "Unknown" %>" readonly>
                            </div>
                            <div class="form-group">
                                <label for="customerEmail" class="form-label">Customer Email</label>
                                <input type="email" id="customerEmail" class="form-control" value="<%= customer != null ? customer.getEmail() : "Unknown" %>" readonly>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h2 class="section-title">Payment Information</h2>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="totalPrice" class="form-label">Total Price</label>
                                <input type="number" name="totalPrice" id="totalPrice" class="form-control" value="<%= order.getTotalPrice() %>" step="0.01" min="0" readonly>
                            </div>

                            <!-- Hidden fields to ensure all required data is submitted -->
                            <input type="hidden" name="userId" value="<%= order.getUserId() %>">
                            <% if (order.getOrderDate() != null) { %>
                            <input type="hidden" name="orderDate" value="<%= new java.sql.Timestamp(order.getOrderDate().getTime()) %>">
                            <% } %>
                        </div>
                    </div>

                    <div class="form-section">
                        <h2 class="section-title">Order Items</h2>
                        <table class="items-table">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Price</th>
                                    <th>Quantity</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                if (orderItems != null && !orderItems.isEmpty()) {
                                    for (OrderItem item : orderItems) {
                                        double itemTotal = item.getPrice() * item.getQuantity();
                                %>
                                <tr>
                                    <td>
                                        <div class="product-info">
                                            <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                                                <img src="../<%= item.getImageUrl() %>" alt="<%= item.getProductName() %>" class="product-image">
                                            <% } else { %>
                                                <div class="product-image" style="background-color: #f5f5f5; display: flex; align-items: center; justify-content: center;">
                                                    <i class="fas fa-image" style="color: #ccc;"></i>
                                                </div>
                                            <% } %>
                                            <div><%= item.getProductName() %></div>
                                        </div>
                                    </td>
                                    <td><%= currencyFormat.format(item.getPrice()) %></td>
                                    <td><%= item.getQuantity() %></td>
                                    <td><%= currencyFormat.format(itemTotal) %></td>
                                </tr>
                                <%
                                    }
                                } else {
                                %>
                                <tr>
                                    <td colspan="4" style="text-align: center;">No items found for this order</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>

                    </div>

                    <div class="action-buttons">
                        <a href="<%= request.getContextPath() %>/AdminOrderServlet?action=view&id=<%= order.getId() %>" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
