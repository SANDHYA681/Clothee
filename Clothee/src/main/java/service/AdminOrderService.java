package service;

import dao.OrderDAO;
import dao.UserDAO;
import dao.PaymentDAO;
import model.Order;
import model.OrderItem;
import model.User;
import model.Payment;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service class for admin order operations
 * This follows the MVC pattern by separating business logic from controllers and views
 */
public class AdminOrderService {
    private OrderDAO orderDAO;
    private UserDAO userDAO;
    private PaymentDAO paymentDAO;

    public AdminOrderService() {
        this.orderDAO = new OrderDAO();
        this.userDAO = new UserDAO();
        this.paymentDAO = new PaymentDAO();
    }

    /**
     * Get all orders with complete information
     * @return List of all orders
     */
    public List<Order> getAllOrders() {
        return orderDAO.getAllOrders();
    }

    /**
     * Get orders filtered by status
     * @param status Order status to filter by
     * @return List of orders with the specified status
     */
    public List<Order> getOrdersByStatus(String status) {
        // If status is null, empty, or "all", return all orders
        if (status == null || status.isEmpty() || status.equalsIgnoreCase("all")) {
            return getAllOrders();
        }

        List<Order> allOrders = orderDAO.getAllOrders();
        List<Order> filteredOrders = new ArrayList<>();

        for (Order order : allOrders) {
            if (order.getStatus() != null && order.getStatus().equalsIgnoreCase(status)) {
                filteredOrders.add(order);
            }
        }

        return filteredOrders;
    }

    /**
     * Get order by ID
     * @param orderId Order ID
     * @return Order object or null if not found
     */
    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    /**
     * Get total order count
     * @return Total number of orders
     */
    public int getTotalOrderCount() {
        return orderDAO.getTotalOrderCount();
    }

    /**
     * Get order statistics
     * @return Map containing order statistics
     */
    public Map<String, Integer> getOrderStatistics() {
        List<Order> orders = orderDAO.getAllOrders();
        Map<String, Integer> statistics = new HashMap<>();

        int totalOrders = orders.size();
        int pendingOrders = 0;
        int processingOrders = 0;
        int shippedOrders = 0;
        int deliveredOrders = 0;
        int cancelledOrders = 0;

        for (Order order : orders) {
            String status = order.getStatus().toLowerCase();
            if (status.equals("pending")) {
                pendingOrders++;
            } else if (status.equals("processing")) {
                processingOrders++;
            } else if (status.equals("shipped")) {
                shippedOrders++;
            } else if (status.equals("delivered")) {
                deliveredOrders++;
            } else if (status.equals("cancelled")) {
                cancelledOrders++;
            }
        }

        statistics.put("totalOrders", totalOrders);
        statistics.put("pendingOrders", pendingOrders);
        statistics.put("processingOrders", processingOrders);
        statistics.put("shippedOrders", shippedOrders);
        statistics.put("deliveredOrders", deliveredOrders);
        statistics.put("cancelledOrders", cancelledOrders);

        return statistics;
    }

    /**
     * Get customer name by user ID
     * @param userId User ID
     * @return Customer name or "Unknown" if not found
     */
    public String getCustomerName(int userId) {
        User user = userDAO.getUserById(userId);
        if (user != null) {
            return user.getFirstName() + " " + user.getLastName();
        }
        return "Unknown";
    }

    /**
     * Get customer by user ID
     * @param userId User ID
     * @return User object or null if not found
     */
    public User getCustomerById(int userId) {
        return userDAO.getUserById(userId);
    }

    /**
     * Get order items by order ID
     * @param orderId Order ID
     * @return List of order items
     */
    public List<OrderItem> getOrderItemsByOrderId(int orderId) {
        return orderDAO.getOrderItemsByOrderId(orderId);
    }

    /**
     * Update order status
     * @param orderId Order ID
     * @param status New status
     * @return true if successful, false otherwise
     */
    public boolean updateOrderStatus(int orderId, String status) {
        System.out.println("AdminOrderService: Updating order status for order ID: " + orderId + " to: " + status);

        // Use the dedicated updateOrderStatus method in OrderDAO
        boolean result = orderDAO.updateOrderStatus(orderId, status);
        System.out.println("AdminOrderService: Update result: " + (result ? "Success" : "Failed"));
        return result;
    }

    /**
     * Delete order
     * @param orderId Order ID
     * @return true if successful, false otherwise
     */
    public boolean deleteOrder(int orderId) {
        return orderDAO.deleteOrder(orderId);
    }

    /**
     * Update order
     * @param order Order to update
     * @return true if successful, false otherwise
     */
    public boolean updateOrder(Order order) {
        System.out.println("AdminOrderService: Updating order: " + order);
        try {
            return orderDAO.updateOrder(order);
        } catch (Exception e) {
            System.out.println("AdminOrderService: Error updating order: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update all pending orders with paid payments to Processing status
     * This is useful for fixing existing data in the database
     * @return Number of orders updated
     */
    public int updatePaidPendingOrders() {
        System.out.println("AdminOrderService: Updating paid pending orders to Processing status");
        try {
            return orderDAO.updatePaidPendingOrders();
        } catch (Exception e) {
            System.out.println("AdminOrderService: Error updating paid pending orders: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Check if an order has a completed payment
     * @param orderId Order ID to check
     * @return true if the order has a completed payment, false otherwise
     */
    public boolean hasCompletedPayment(int orderId) {
        List<Payment> payments = paymentDAO.getPaymentsByOrderId(orderId);

        if (payments == null || payments.isEmpty()) {
            return false;
        }

        for (Payment payment : payments) {
            String status = payment.getStatus();
            if (status != null && (status.equalsIgnoreCase("Completed") || status.equalsIgnoreCase("Paid"))) {
                return true;
            }
        }

        return false;
    }
}
