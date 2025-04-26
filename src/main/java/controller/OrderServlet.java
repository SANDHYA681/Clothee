package controller;

import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Order;
import model.User;
import service.OrderService;

/**
 * Servlet implementation class OrderServlet
 * Handles customer orders
 */
// Servlet mapping defined in web.xml
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderService orderService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public OrderServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            action = "viewOrders";
        }

        switch (action) {
            case "viewOrders":
                viewOrders(request, response);
                break;
            case "viewOrder":
                viewOrderDetails(request, response);
                break;
            case "cancel":
                cancelOrder(request, response);
                break;
            case "nextOrder":
                navigateToNextOrder(request, response);
                break;
            case "prevOrder":
                navigateToPrevOrder(request, response);
                break;
            default:
                viewOrders(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * View all orders for the logged-in user
     */
    private void viewOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get all orders for this user
        List<Order> allOrders = orderService.getOrdersByUserId(user.getId());

        // Get filter parameter
        String statusFilter = request.getParameter("status");
        System.out.println("OrderServlet - Status filter parameter: " + statusFilter);

        // Store the filter in session for the JSP page
        session.setAttribute("statusFilter", statusFilter);

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
            System.out.println("OrderServlet - Filtered orders by status: " + statusFilter + ", found " + orders.size() + " orders");
        } else {
            // Use all orders
            orders = allOrders;
            System.out.println("OrderServlet - Using all orders, found " + orders.size() + " orders");
        }

        // Store orders in session for the JSP page
        session.setAttribute("userOrders", orders);

        // Add pagination info if needed
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                // Use default page 1
            }
        }

        session.setAttribute("currentPage", page);

        // Calculate total pages (10 orders per page)
        int totalOrders = orders.size();
        int ordersPerPage = 10;
        int totalPages = (int) Math.ceil((double) totalOrders / ordersPerPage);
        session.setAttribute("totalPages", totalPages);

        // Forward to orders page
        request.getRequestDispatcher("/customer/orders.jsp").forward(request, response);
    }

    /**
     * View details of a specific order
     */
    private void viewOrderDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get order ID from request
        String orderIdStr = request.getParameter("id");

        if (orderIdStr == null || orderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);

            // Get order
            Order order = orderService.getOrderById(orderId);

            // Check if order exists and belongs to this user
            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
                return;
            }

            // Get all orders for this user (for navigation)
            List<Order> userOrders = orderService.getOrdersByUserId(user.getId());

            // Store orders in session for navigation
            session.setAttribute("userOrders", userOrders);

            // Find current order index for navigation info
            int currentIndex = -1;
            for (int i = 0; i < userOrders.size(); i++) {
                if (userOrders.get(i).getId() == orderId) {
                    currentIndex = i;
                    break;
                }
            }

            // Add navigation info to request
            request.setAttribute("currentOrderIndex", currentIndex);
            request.setAttribute("totalOrders", userOrders.size());
            request.setAttribute("hasPrevious", currentIndex > 0);
            request.setAttribute("hasNext", currentIndex < userOrders.size() - 1);

            // Set order in request
            request.setAttribute("order", order);

            // Forward to order details page
            request.getRequestDispatcher("/customer/order-details-new.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
        }
    }

    /**
     * Cancel an order
     */
    private void cancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get order ID from request
        String orderIdStr = request.getParameter("id");

        if (orderIdStr == null || orderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders&error=Missing+order+ID");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);

            // Get order
            Order order = orderService.getOrderById(orderId);

            // Check if order exists and belongs to this user
            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders&error=Order+not+found");
                return;
            }

            // Check if order can be canceled (only if it's in "Processing" or "Pending" status)
            if (!order.getStatus().equalsIgnoreCase("Processing") && !order.getStatus().equalsIgnoreCase("Pending")) {
                response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders&error=Order+cannot+be+cancelled");
                return;
            }

            // Update order status to "Cancelled"
            order.setStatus("Cancelled");
            boolean success = orderService.updateOrder(order);

            if (success) {
                // Redirect to the orders page with success message
                response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders&success=Order+cancelled+successfully");
            } else {
                // Redirect to the orders page with error message
                response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders&error=Failed+to+cancel+order");
            }
        } catch (NumberFormatException e) {
            // Invalid order ID format
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders&error=Invalid+order+ID");
        } catch (Exception e) {
            // Log the exception
            e.printStackTrace();
            // Redirect to the orders page with a generic error message
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders&error=An+error+occurred+while+cancelling+the+order");
        }
    }

    /**
     * Navigate to the next order in the user's order list
     */
    private void navigateToNextOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get current order ID from request
        String currentOrderIdStr = request.getParameter("id");

        if (currentOrderIdStr == null || currentOrderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
            return;
        }

        try {
            int currentOrderId = Integer.parseInt(currentOrderIdStr);

            // Get all orders for this user
            List<Order> userOrders = orderService.getOrdersByUserId(user.getId());

            // Find the index of the current order
            int currentIndex = -1;
            for (int i = 0; i < userOrders.size(); i++) {
                if (userOrders.get(i).getId() == currentOrderId) {
                    currentIndex = i;
                    break;
                }
            }

            // If current order not found or it's the last order, redirect to orders list
            if (currentIndex == -1 || currentIndex >= userOrders.size() - 1) {
                response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
                return;
            }

            // Get the next order
            Order nextOrder = userOrders.get(currentIndex + 1);

            // Redirect to view the next order
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrder&id=" + nextOrder.getId());

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
        }
    }

    /**
     * Navigate to the previous order in the user's order list
     */
    private void navigateToPrevOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get current order ID from request
        String currentOrderIdStr = request.getParameter("id");

        if (currentOrderIdStr == null || currentOrderIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
            return;
        }

        try {
            int currentOrderId = Integer.parseInt(currentOrderIdStr);

            // Get all orders for this user
            List<Order> userOrders = orderService.getOrdersByUserId(user.getId());

            // Find the index of the current order
            int currentIndex = -1;
            for (int i = 0; i < userOrders.size(); i++) {
                if (userOrders.get(i).getId() == currentOrderId) {
                    currentIndex = i;
                    break;
                }
            }

            // If current order not found or it's the first order, redirect to orders list
            if (currentIndex <= 0) {
                response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
                return;
            }

            // Get the previous order
            Order prevOrder = userOrders.get(currentIndex - 1);

            // Redirect to view the previous order
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrder&id=" + prevOrder.getId());

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/OrderServlet?action=viewOrders");
        }
    }
}
