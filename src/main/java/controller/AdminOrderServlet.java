package controller;

import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.OrderDAO;
import model.Order;
import model.OrderItem;
import model.User;
import service.AdminOrderService;

/**
 * Servlet implementation class AdminOrderServlet
 */
// Servlet mapping defined in web.xml
public class AdminOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AdminOrderService orderService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminOrderServlet() {
        super();
        orderService = new AdminOrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "view":
                viewOrder(request, response);
                break;
            case "delete":
                deleteOrder(request, response);
                break;
            case "confirmDelete":
                confirmDeleteOrder(request, response);
                break;
            case "showUpdateForm":
                showUpdateOrderForm(request, response);
                break;
            default:
                listOrders(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "updateStatus":
                updateOrderStatus(request, response);
                break;
            case "updateOrder":
                updateOrder(request, response);
                break;
            default:
                listOrders(request, response);
        }
    }

    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get all orders first
        List<Order> allOrders = orderService.getAllOrders();

        // Get status filter parameter
        String statusFilter = request.getParameter("status");
        System.out.println("AdminOrderServlet - Status filter parameter: " + statusFilter);

        // Filter orders if needed
        List<Order> orders;
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equalsIgnoreCase("all")) {
            // Manual filtering
            orders = new ArrayList<>();
            for (Order order : allOrders) {
                if (order.getStatus() != null && order.getStatus().equalsIgnoreCase(statusFilter)) {
                    orders.add(order);
                }
            }
            System.out.println("AdminOrderServlet - Filtered orders by status: " + statusFilter + ", found " + orders.size() + " orders");
        } else {
            // Use all orders
            orders = allOrders;
            System.out.println("AdminOrderServlet - Using all orders, found " + orders.size() + " orders");
        }

        // Get order statistics for the dashboard
        Map<String, Integer> statistics = orderService.getOrderStatistics();

        // Set attributes for the JSP
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", statistics.get("totalOrders"));
        request.setAttribute("pendingOrders", statistics.get("pendingOrders"));
        request.setAttribute("processingOrders", statistics.get("processingOrders"));
        request.setAttribute("shippedOrders", statistics.get("shippedOrders"));
        request.setAttribute("deliveredOrders", statistics.get("deliveredOrders"));
        request.setAttribute("cancelledOrders", statistics.get("cancelledOrders"));

        // Set context path for CSS and JS files
        request.setAttribute("contextPath", request.getContextPath());
        System.out.println("AdminOrderServlet: Setting contextPath for orders.jsp: " + request.getContextPath());

        // Forward to the original JSP
        request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
    }

    private void viewOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("id");
        System.out.println("AdminOrderServlet: viewOrder called with id=" + orderIdStr);

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            System.out.println("AdminOrderServlet: Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Invalid+order+ID");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            System.out.println("AdminOrderServlet: Parsed order ID: " + orderId);
            Order order = orderService.getOrderById(orderId);
            System.out.println("AdminOrderServlet: Order retrieved: " + (order != null ? "Yes" : "No"));

            if (order == null) {
                System.out.println("AdminOrderServlet: Order not found");
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Order+not+found");
                return;
            }

            // Get customer name for the order
            System.out.println("AdminOrderServlet: Getting customer for user ID: " + order.getUserId());
            String customerName = orderService.getCustomerName(order.getUserId());
            User customer = orderService.getCustomerById(order.getUserId());
            System.out.println("AdminOrderServlet: Customer retrieved: " + (customer != null ? "Yes" : "No"));

            // Get order items
            System.out.println("AdminOrderServlet: Getting order items for order ID: " + order.getId());
            List<OrderItem> orderItems = orderService.getOrderItemsByOrderId(order.getId());
            System.out.println("AdminOrderServlet: Retrieved " + (orderItems != null ? orderItems.size() : 0) + " order items");

            // Set attributes for the JSP
            request.setAttribute("order", order);
            request.setAttribute("orderItems", orderItems);
            request.setAttribute("customer", customer);
            request.setAttribute("customerName", customerName);

            // Set context path for CSS and JS files
            request.setAttribute("contextPath", request.getContextPath());
            System.out.println("AdminOrderServlet: Forwarding to order-details.jsp");
            request.getRequestDispatcher("/admin/order-details.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            System.out.println("AdminOrderServlet: Invalid order ID format: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Invalid+order+ID");
        } catch (Exception e) {
            System.out.println("AdminOrderServlet: Error viewing order: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Error+viewing+order");
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("orderId");
        String status = request.getParameter("status");

        if (orderIdStr == null || orderIdStr.trim().isEmpty() || status == null || status.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Invalid+order+data");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            boolean success = orderService.updateOrderStatus(orderId, status);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/order-details.jsp?id=" + orderId + "&success=Order+status+updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/order-details.jsp?id=" + orderId + "&error=Failed+to+update+order+status");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Invalid+order+ID");
        }
    }

    private void updateOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Print all request parameters for debugging
        System.out.println("AdminOrderServlet: All request parameters:");
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            System.out.println("  " + paramName + ": " + request.getParameter(paramName));
        }

        String orderIdStr = request.getParameter("orderId");
        String status = request.getParameter("status");
        String shippingAddress = request.getParameter("shippingAddress");
        String paymentMethod = request.getParameter("paymentMethod");
        String totalPriceStr = request.getParameter("totalPrice");

        System.out.println("AdminOrderServlet: updateOrder called with parameters:");
        System.out.println("  orderId: " + orderIdStr);
        System.out.println("  status: " + status);
        System.out.println("  shippingAddress: " + shippingAddress);
        System.out.println("  paymentMethod: " + paymentMethod);
        System.out.println("  totalPrice: " + totalPriceStr);

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            System.out.println("AdminOrderServlet: Missing order ID parameter");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Missing+order+ID");
            return;
        }

        if (status == null || status.trim().isEmpty()) {
            System.out.println("AdminOrderServlet: Missing status parameter");
            status = "Pending"; // Default status if not provided
            System.out.println("AdminOrderServlet: Using default status: " + status);
        }

        if (totalPriceStr == null || totalPriceStr.trim().isEmpty()) {
            System.out.println("AdminOrderServlet: Missing total price parameter");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Missing+total+price");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            double totalPrice = Double.parseDouble(totalPriceStr);

            // Get the existing order
            Order order = orderService.getOrderById(orderId);
            if (order == null) {
                System.out.println("AdminOrderServlet: Order not found with ID: " + orderId);
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Order+not+found");
                return;
            }

            System.out.println("AdminOrderServlet: Found order with ID: " + orderId);
            System.out.println("AdminOrderServlet: Current order state: " + order);

            // Check if order is paid
            boolean isPaid = false;
            String currentPaymentMethod = order.getPaymentMethod();
            if (currentPaymentMethod != null && (currentPaymentMethod.equalsIgnoreCase("Credit Card") || currentPaymentMethod.equalsIgnoreCase("PayPal"))) {
                isPaid = true;
            }

            // Don't allow setting a paid order to Cancelled
            if (isPaid && status.equalsIgnoreCase("Cancelled")) {
                System.out.println("AdminOrderServlet: Attempt to cancel a paid order. Rejected.");
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Cannot cancel an order that has been paid");
                response.sendRedirect(request.getContextPath() + "/AdminOrderServlet?action=showUpdateForm&id=" + orderId);
                return;
            }

            // Also don't allow setting a paid order back to Pending
            if (isPaid && status.equalsIgnoreCase("Pending")) {
                System.out.println("AdminOrderServlet: Attempt to set a paid order to Pending. Setting to Processing instead.");
                status = "Processing";
            }

            // Update order properties
            order.setStatus(status);
            order.setShippingAddress(shippingAddress);
            order.setPaymentMethod(paymentMethod);
            order.setTotalPrice(totalPrice);

            System.out.println("AdminOrderServlet: Updating order with new values: " + order);

            // Update the order in the database
            boolean success = orderService.updateOrder(order);
            System.out.println("AdminOrderServlet: Update result: " + (success ? "Success" : "Failed"));

            if (success) {
                // Set success message in session to ensure it persists through redirects
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "Order updated successfully");
                response.sendRedirect(request.getContextPath() + "/AdminOrderServlet?action=view&id=" + orderId);
            } else {
                // Set error message in session to ensure it persists through redirects
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Failed to update order");
                response.sendRedirect(request.getContextPath() + "/AdminOrderServlet?action=showUpdateForm&id=" + orderId);
            }
        } catch (NumberFormatException e) {
            System.out.println("AdminOrderServlet: Error parsing numeric values: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Invalid+numeric+data:+" + e.getMessage());
        } catch (Exception e) {
            System.out.println("AdminOrderServlet: Unexpected error updating order: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Unexpected+error");
        }
    }

    private void deleteOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("id");

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Invalid+order+ID");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);

            // Check if the order has been paid
            Order order = orderService.getOrderById(orderId);
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp?error=Order+not+found");
                return;
            }

            // Check if the order has been paid
            boolean isPaid = false;
            String paymentMethod = order.getPaymentMethod();
            if (paymentMethod != null && (paymentMethod.equalsIgnoreCase("Credit Card") || paymentMethod.equalsIgnoreCase("PayPal"))) {
                isPaid = true;
            }

            // Also check payment status in the payments table
            boolean hasCompletedPayment = orderService.hasCompletedPayment(orderId);

            if (isPaid || hasCompletedPayment) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Cannot delete paid orders");
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
                return;
            }

            boolean success = orderService.deleteOrder(orderId);

            if (success) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "Order deleted successfully");
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Failed to delete order");
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
            }
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
        }
    }

    /**
     * Show confirmation page for deleting an order
     */
    private void confirmDeleteOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderIdStr = request.getParameter("id");

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderService.getOrderById(orderId);

            if (order == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Order not found");
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
                return;
            }

            // Check if the order has been paid
            boolean isPaid = false;
            String paymentMethod = order.getPaymentMethod();
            if (paymentMethod != null && (paymentMethod.equalsIgnoreCase("Credit Card") || paymentMethod.equalsIgnoreCase("PayPal"))) {
                isPaid = true;
            }

            // Also check payment status in the payments table
            boolean hasCompletedPayment = orderService.hasCompletedPayment(orderId);

            if (isPaid || hasCompletedPayment) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Cannot delete paid orders");
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
                return;
            }

            // Set order in request
            request.setAttribute("order", order);
            request.setAttribute("confirmAction", "delete");

            // Set context path for CSS and JS files
            request.setAttribute("contextPath", request.getContextPath());

            // Forward to confirmation page
            request.getRequestDispatcher("/admin/confirm-order-action.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
        }
    }

    /**
     * Show form for updating an order
     */
    private void showUpdateOrderForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("AdminOrderServlet: showUpdateOrderForm method called");
        String orderIdStr = request.getParameter("id");
        System.out.println("AdminOrderServlet: Order ID parameter: " + orderIdStr);

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            System.out.println("AdminOrderServlet: Invalid order ID parameter");
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            System.out.println("AdminOrderServlet: Fetching order with ID: " + orderId);
            Order order = orderService.getOrderById(orderId);

            if (order == null) {
                System.out.println("AdminOrderServlet: Order not found with ID: " + orderId);
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Order not found");
                response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
                return;
            }
            System.out.println("AdminOrderServlet: Found order: " + order);

            // Get customer name for the order
            System.out.println("AdminOrderServlet: Fetching customer with ID: " + order.getUserId());
            String customerName = orderService.getCustomerName(order.getUserId());
            User customer = orderService.getCustomerById(order.getUserId());
            System.out.println("AdminOrderServlet: Found customer: " + (customer != null ? customer.getFirstName() + " " + customer.getLastName() : "null"));

            // Get order items
            System.out.println("AdminOrderServlet: Fetching order items for order ID: " + order.getId());
            List<OrderItem> orderItems = orderService.getOrderItemsByOrderId(order.getId());
            System.out.println("AdminOrderServlet: Found " + (orderItems != null ? orderItems.size() : "null") + " order items");

            // Set attributes for the JSP
            request.setAttribute("order", order);
            request.setAttribute("orderItems", orderItems);
            request.setAttribute("customer", customer);
            request.setAttribute("customerName", customerName);

            // Set context path for CSS and JS files
            request.setAttribute("contextPath", request.getContextPath());
            System.out.println("AdminOrderServlet: Set contextPath: " + request.getContextPath());

            // Forward to edit order page
            System.out.println("AdminOrderServlet: Forwarding to edit-order.jsp");
            request.getRequestDispatcher("/admin/edit-order.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            System.out.println("AdminOrderServlet: Error parsing order ID: " + e.getMessage());
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
        } catch (Exception e) {
            System.out.println("AdminOrderServlet: Unexpected error in showUpdateOrderForm: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error loading order: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/orders.jsp");
        }
    }
}
