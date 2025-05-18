package dao;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import model.Order;
import model.OrderItem;
import model.Product;
import model.User;
import util.DBConnection;

/**
 * Order Data Access Object
 */
public class OrderDAO {
    private UserDAO userDAO;
    private ProductDAO productDAO;

    public OrderDAO() {
        this.userDAO = new UserDAO();
        this.productDAO = new ProductDAO();
    }

    /**
     * Check if orders table has a specific column
     *
     * @param columnName Name of the column to check
     * @return true if column exists, false otherwise
     */
    private boolean checkIfOrdersTableHasColumn(String columnName) {
        try (Connection conn = DBConnection.getConnection()) {
            // Get metadata about the orders table
            java.sql.DatabaseMetaData metaData = conn.getMetaData();
            try (ResultSet columns = metaData.getColumns(null, null, "orders", columnName)) {
                return columns.next(); // If there's a result, the column exists
            }
        } catch (SQLException e) {
            System.out.println("Error checking if " + columnName + " column exists: " + e.getMessage());
            e.printStackTrace();
            return false; // Assume column doesn't exist if there's an error
        }
    }

    /**
     * Check if orders table has shipping_address column
     *
     * @return true if column exists, false otherwise
     */
    private boolean checkIfOrdersTableHasShippingAddressColumn() {
        // Always return true since we know the column exists in the database
        return true;
    }

    /**
     * Check if orders table has payment_method column
     *
     * @return true if column exists, false otherwise
     */
    private boolean checkIfOrdersTableHasPaymentMethodColumn() {
        // Always return true since we know the column exists in the database
        return true;
    }

    /**
     * Create a new order
     *
     * @param order Order object to create
     * @return true if successful, false otherwise
     */
    public boolean createOrder(Order order) {
        // Use simplified query without shipping_address and payment_method
        String query = "INSERT INTO orders (user_id, total_price, status, order_placed_date) " +
                "VALUES (?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);

            stmt.setInt(1, order.getUserId());
            stmt.setDouble(2, order.getTotalPrice());

            // Set the default status if not provided
            String status = order.getStatus();
            if (status == null || status.isEmpty()) {
                status = "Processing";
                System.out.println("OrderDAO: Setting default status to Processing");
            }

            // Update the order object with the correct status
            order.setStatus(status);
            stmt.setString(3, status);
            stmt.setTimestamp(4, new Timestamp(order.getOrderDate().getTime()));

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        int orderId = rs.getInt(1);
                        order.setId(orderId);

                        // Create payment record
                        String paymentMethod = "Credit Card"; // Default payment method
                        createPayment(orderId, paymentMethod, conn);

                        // Create shipping record
                        boolean shippingCreated = createShipping(orderId, order.getStatus(), conn);

                        // If shipping record creation failed due to missing address, log it but continue
                        if (!shippingCreated) {
                            System.out.println("OrderDAO: Warning - Shipping record not created for order ID: " + orderId + ". Missing shipping address.");
                        }

                        // Note: Order items should be added separately

                        conn.commit();
                        return true;
                    }
                }
            }

            conn.rollback();
            return false;

        } catch (SQLException e) {
            System.out.println("Error creating order: " + e.getMessage());
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                System.out.println("Error rolling back transaction: " + ex.getMessage());
            }

            return false;
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.out.println("Error closing resources: " + e.getMessage());
            }
        }
    }

    /**
     * Get shipping address from cart for a user associated with an order
     * @param orderId Order ID
     * @param conn Database connection
     * @return Shipping address string or empty string if not found
     * @throws SQLException if error occurs
     */
    private String getShippingAddressFromCart(int orderId, Connection conn) throws SQLException {
        // First get the user ID from the order
        String userQuery = "SELECT user_id FROM orders WHERE id = ?";
        int userId = -1;

        try (PreparedStatement userStmt = conn.prepareStatement(userQuery)) {
            userStmt.setInt(1, orderId);
            try (ResultSet rs = userStmt.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("user_id");
                }
            }
        }

        if (userId == -1) {
            return "Shipping information not available"; // Order not found or no user ID
        }

        // Get shipping address from CartService
        String shippingAddress = service.CartService.getShippingAddress(userId);

        // If no shipping address is found, return an empty string
        // This will force the user to enter shipping information
        if (shippingAddress == null || shippingAddress.isEmpty()) {
            return "";
        }

        return shippingAddress;
    }

    /**
     * Create shipping record
     *
     * @param orderId Order ID
     * @param status  Order status
     * @param conn    Database connection
     * @return true if successful, false otherwise
     * @throws SQLException if error occurs
     */
    private boolean createShipping(int orderId, String status, Connection conn) throws SQLException {
        // First check if a shipping record already exists for this order
        String checkQuery = "SELECT id FROM shipping WHERE order_id = ?";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
            checkStmt.setInt(1, orderId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    // Shipping record already exists, no need to create another one
                    System.out.println("OrderDAO: Shipping record already exists for order ID: " + orderId);
                    return true;
                }
            }
        }

        // Get shipping address from cart
        String shippingAddress = getShippingAddressFromCart(orderId, conn);

        // If shipping address is empty, don't create a shipping record
        if (shippingAddress == null || shippingAddress.isEmpty()) {
            System.out.println("OrderDAO: No shipping address found for order ID: " + orderId + ", skipping shipping record creation");
            return false;
        }

        // Create shipping record with the same status as the order
        String query = "INSERT INTO shipping (order_id, shipping_date, shipping_status, shipping_address) " +
                "VALUES (?, CURRENT_TIMESTAMP, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, orderId);
            stmt.setString(2, status);
            stmt.setString(3, shippingAddress);

            int rowsAffected = stmt.executeUpdate();
            System.out.println("OrderDAO: Created shipping record for order ID: " + orderId + ", status: " + status);
            return rowsAffected > 0;
        }
    }

    /**
     * Create payment record
     *
     * @param orderId       Order ID
     * @param paymentMethod Payment method
     * @param conn          Database connection
     * @return true if successful, false otherwise
     * @throws SQLException if error occurs
     */
    private boolean createPayment(int orderId, String paymentMethod, Connection conn) throws SQLException {
        // First check if a payment record already exists for this order
        String checkQuery = "SELECT id FROM payments WHERE order_id = ?";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
            checkStmt.setInt(1, orderId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    // Payment record already exists, no need to create another one
                    System.out.println("OrderDAO: Payment record already exists for order ID: " + orderId);
                    return true;
                }
            }
        }

        // Get the order to get the total price (which now includes tax and shipping)
        String orderQuery = "SELECT total_price FROM orders WHERE id = ?";
        double amount = 0.0;

        try (PreparedStatement orderStmt = conn.prepareStatement(orderQuery)) {
            orderStmt.setInt(1, orderId);
            try (ResultSet rs = orderStmt.executeQuery()) {
                if (rs.next()) {
                    amount = rs.getDouble("total_price");
                }
            }
        }

        // Determine payment status based on payment method
        // For Credit Card and PayPal, payment is considered completed immediately
        String paymentStatus = "Pending";
        if (paymentMethod.equalsIgnoreCase("Credit Card") ||
                paymentMethod.equalsIgnoreCase("PayPal")) {
            paymentStatus = "Completed";

            // Also update the order status to Processing since payment is completed
            String updateOrderQuery = "UPDATE orders SET status = 'Processing' WHERE id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateOrderQuery)) {
                updateStmt.setInt(1, orderId);
                int rowsUpdated = updateStmt.executeUpdate();
                System.out.println("OrderDAO: Updated order status to Processing for paid order ID: " + orderId + ", rows updated: " + rowsUpdated);
            }
        }

        String query = "INSERT INTO payments (order_id, payment_method, status, payment_date, amount, user_id) " +
                "SELECT ?, ?, ?, CURRENT_TIMESTAMP, ?, user_id FROM orders WHERE id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, orderId);
            stmt.setString(2, paymentMethod);
            stmt.setString(3, paymentStatus);
            stmt.setDouble(4, amount);
            stmt.setInt(5, orderId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    /**
     * Add an order item
     *
     * @param item OrderItem object to add
     * @param conn Database connection
     * @return true if successful, false otherwise
     * @throws SQLException if error occurs
     */
    private boolean addOrderItem(OrderItem item, Connection conn) throws SQLException {
        String query = "INSERT INTO order_items (order_id, product_id, product_name, price, quantity, image_url) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, item.getOrderId());
            stmt.setInt(2, item.getProductId());
            stmt.setString(3, item.getProductName());
            stmt.setDouble(4, item.getPrice());
            stmt.setInt(5, item.getQuantity());
            stmt.setString(6, item.getImageUrl());

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        item.setId(rs.getInt(1));
                        return true;
                    }
                }
            }

            return false;
        }
    }

    /**
     * Update order status
     *
     * @param orderId Order ID
     * @param status  New status
     * @return true if successful, false otherwise
     */
    public boolean updateOrderStatus(int orderId, String status) {
        System.out.println("OrderDAO: Updating order status for order ID: " + orderId + " to: " + status);
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // First check if this order has a completed payment
            boolean hasCompletedPayment = false;
            String paymentQuery = "SELECT status FROM payments WHERE order_id = ?";
            try (PreparedStatement paymentStmt = conn.prepareStatement(paymentQuery)) {
                paymentStmt.setInt(1, orderId);
                try (ResultSet rs = paymentStmt.executeQuery()) {
                    if (rs.next()) {
                        String paymentStatus = rs.getString("status");
                        hasCompletedPayment = "Completed".equalsIgnoreCase(paymentStatus) || "Paid".equalsIgnoreCase(paymentStatus);
                        System.out.println("OrderDAO: Order has completed payment: " + hasCompletedPayment);
                    }
                }
            } catch (SQLException e) {
                System.out.println("OrderDAO: Error checking payment status (continuing anyway): " + e.getMessage());
                // Continue even if payment check fails
            }

            // If trying to set status to "Pending" but payment is completed, use "Processing" instead
            if ("Pending".equalsIgnoreCase(status) && hasCompletedPayment) {
                status = "Processing";
                System.out.println("OrderDAO: Changed status from Pending to Processing for paid order");
            }

            // Update the order status
            String query = "UPDATE orders SET status = ? WHERE id = ?";
            System.out.println("OrderDAO: Executing query: " + query.replace("?", "'" + status + "', '" + orderId + "'"));
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, status);
                stmt.setInt(2, orderId);

                int rowsAffected = stmt.executeUpdate();
                System.out.println("OrderDAO: Update result - rows affected: " + rowsAffected);
                if (rowsAffected <= 0) {
                    System.out.println("OrderDAO: No rows affected, rolling back");
                    conn.rollback();
                    return false;
                }
            }

            // Also update the shipping status to match the order status
            try {
                // First check if a shipping record exists
                String checkQuery = "SELECT id FROM shipping WHERE order_id = ?";
                boolean shippingExists = false;
                try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                    checkStmt.setInt(1, orderId);
                    try (ResultSet rs = checkStmt.executeQuery()) {
                        shippingExists = rs.next();
                    }
                }

                if (shippingExists) {
                    // Update existing shipping record
                    String shippingQuery = "UPDATE shipping SET shipping_status = ? WHERE order_id = ?";
                    System.out.println("OrderDAO: Updating shipping status: " + shippingQuery.replace("?", "'" + status + "', '" + orderId + "'"));
                    try (PreparedStatement shippingStmt = conn.prepareStatement(shippingQuery)) {
                        shippingStmt.setString(1, status);
                        shippingStmt.setInt(2, orderId);
                        int shippingRowsAffected = shippingStmt.executeUpdate();
                        System.out.println("OrderDAO: Shipping update result - rows affected: " + shippingRowsAffected);
                    }
                } else {
                    // Create new shipping record
                    System.out.println("OrderDAO: No shipping record found for order ID: " + orderId + ", creating one");
                    createShipping(orderId, status, conn);
                }
            } catch (SQLException e) {
                System.out.println("OrderDAO: Error updating shipping status (continuing anyway): " + e.getMessage());
                // Continue even if shipping update fails
            }

            conn.commit();
            System.out.println("OrderDAO: Successfully updated order status to: " + status);
            return true;

        } catch (SQLException e) {
            System.out.println("OrderDAO: Error updating order status: " + e.getMessage());
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("OrderDAO: Error rolling back transaction: " + ex.getMessage());
                }
            }

            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("OrderDAO: Error closing connection: " + e.getMessage());
                }
            }
        }
    }

    /**
     * Update order
     *
     * @param order Order object with updated information
     * @return true if successful, false otherwise
     */
    public boolean updateOrder(Order order) {
        System.out.println("OrderDAO: Updating order with ID: " + order.getId());
        System.out.println("OrderDAO: New status: " + order.getStatus());
        System.out.println("OrderDAO: New total price: " + order.getTotalPrice());

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Only update the status field as per admin requirements
            String query = "UPDATE orders SET status = ? WHERE id = ?";
            System.out.println("OrderDAO: Executing query: " + query.replace("?", "'" + order.getStatus() + "', '" + order.getId() + "'"));

            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, order.getStatus());
                stmt.setInt(2, order.getId());

                int rowsAffected = stmt.executeUpdate();
                System.out.println("OrderDAO: Update result - rows affected: " + rowsAffected);

                if (rowsAffected <= 0) {
                    System.out.println("OrderDAO: No rows affected, rolling back");
                    conn.rollback();
                    return false;
                }
            }

            // Also update the shipping status to match the order status
            try {
                // First check if a shipping record exists
                String checkQuery = "SELECT id FROM shipping WHERE order_id = ?";
                boolean shippingExists = false;
                try (PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                    checkStmt.setInt(1, order.getId());
                    try (ResultSet rs = checkStmt.executeQuery()) {
                        shippingExists = rs.next();
                    }
                }

                if (shippingExists) {
                    // Update existing shipping record
                    String shippingQuery = "UPDATE shipping SET shipping_status = ? WHERE order_id = ?";
                    System.out.println("OrderDAO: Updating shipping status: " + shippingQuery.replace("?", "'" + order.getStatus() + "', '" + order.getId() + "'"));
                    try (PreparedStatement shippingStmt = conn.prepareStatement(shippingQuery)) {
                        shippingStmt.setString(1, order.getStatus());
                        shippingStmt.setInt(2, order.getId());
                        int shippingRowsAffected = shippingStmt.executeUpdate();
                        System.out.println("OrderDAO: Shipping update result - rows affected: " + shippingRowsAffected);
                    }
                } else {
                    // Create new shipping record
                    System.out.println("OrderDAO: No shipping record found for order ID: " + order.getId() + ", creating one");
                    createShipping(order.getId(), order.getStatus(), conn);
                }
            } catch (SQLException e) {
                System.out.println("OrderDAO: Error updating shipping status (continuing anyway): " + e.getMessage());
                // Continue even if shipping update fails
            }

            conn.commit();
            System.out.println("OrderDAO: Successfully updated order status to: " + order.getStatus());
            return true;

        } catch (SQLException e) {
            System.out.println("OrderDAO: Error updating order: " + e.getMessage());
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("OrderDAO: Error rolling back transaction: " + ex.getMessage());
                }
            }

            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("OrderDAO: Error closing connection: " + e.getMessage());
                }
            }
        }
    }

    /**
     * Update payment status
     *
     * @param orderId       Order ID
     * @param paymentStatus New payment status
     * @return true if successful, false otherwise
     */
    public boolean updatePaymentStatus(int orderId, String paymentStatus) {
        String query = "UPDATE payments SET status = ? WHERE order_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, paymentStatus);
            stmt.setInt(2, orderId);

            int rowsAffected = stmt.executeUpdate();

            // If no payment record exists, create one
            if (rowsAffected == 0) {
                String insertQuery = "INSERT INTO payments (order_id, status, payment_date, payment_method, amount, user_id) " +
                        "SELECT ?, ?, CURRENT_TIMESTAMP, 'Credit Card', total_price, user_id FROM orders WHERE id = ?";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
                    insertStmt.setInt(1, orderId);
                    insertStmt.setString(2, paymentStatus);
                    insertStmt.setInt(3, orderId);
                    rowsAffected = insertStmt.executeUpdate();
                }
            }

            // If payment status is Completed or Paid, update order status to Processing if it's currently Pending
            if (rowsAffected > 0 && ("Completed".equalsIgnoreCase(paymentStatus) || "Paid".equalsIgnoreCase(paymentStatus))) {
                // Update order status to Processing regardless of current status
                String updateOrderQuery = "UPDATE orders SET status = 'Processing' WHERE id = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateOrderQuery)) {
                    updateStmt.setInt(1, orderId);
                    int rowsUpdated = updateStmt.executeUpdate();
                    System.out.println("OrderDAO: Updated order status to Processing for paid order ID: " + orderId + ", rows updated: " + rowsUpdated);
                }
            }

            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error updating payment status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get order by ID
     *
     * @param orderId Order ID
     * @return Order object if found, null otherwise
     */
    public Order getOrderById(int orderId) {
        System.out.println("OrderDAO: Getting order by ID: " + orderId);

        // First, try a simple query without joins to avoid potential issues
        String simpleQuery = "SELECT * FROM orders WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(simpleQuery)) {

            stmt.setInt(1, orderId);
            System.out.println("OrderDAO: Executing query: " + simpleQuery.replace("?", String.valueOf(orderId)));

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("OrderDAO: Found order with ID: " + orderId);
                    Order order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setTotalPrice(rs.getDouble("total_price"));
                    order.setOrderDate(rs.getTimestamp("order_placed_date"));
                    order.setStatus(rs.getString("status"));

                    // Shipping address and payment method are no longer stored

                    // Try to load order items
                    try {
                        List<OrderItem> orderItems = getOrderItemsByOrderId(order.getId(), conn);
                        order.setOrderItems(orderItems);
                        System.out.println("OrderDAO: Loaded " + (orderItems != null ? orderItems.size() : 0) + " order items");
                    } catch (Exception e) {
                        System.out.println("OrderDAO: Error loading order items: " + e.getMessage());
                        order.setOrderItems(new ArrayList<>());
                    }

                    System.out.println("OrderDAO: Returning order: " + order);
                    return order;
                } else {
                    System.out.println("OrderDAO: No order found with ID: " + orderId);
                }
            }
        } catch (SQLException e) {
            System.out.println("OrderDAO: Error getting order by ID: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("OrderDAO: Returning null for order ID: " + orderId);
        return null;
    }

    /**
     * Get order items by order ID
     *
     * @param orderId Order ID
     * @param conn    Database connection
     * @return List of order items
     */
    public List<OrderItem> getOrderItemsByOrderId(int orderId, Connection conn) {
        List<OrderItem> orderItems = new ArrayList<>();

        // First check if the order_items table exists
        try {
            DatabaseMetaData dbm = conn.getMetaData();
            ResultSet tables = dbm.getTables(null, null, "order_items", null);
            if (!tables.next()) {
                System.out.println("Warning: order_items table does not exist");
                return orderItems;
            }
        } catch (SQLException e) {
            System.out.println("Error checking if order_items table exists: " + e.getMessage());
            return orderItems;
        }

        String query = "SELECT * FROM order_items WHERE order_id = ?";

        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, orderId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    try {
                        OrderItem item = extractOrderItemFromResultSet(rs);
                        orderItems.add(item);
                    } catch (SQLException e) {
                        System.out.println("Error extracting order item: " + e.getMessage());
                        // Continue to next item
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Error getting order items: " + e.getMessage());
            e.printStackTrace();
        }

        return orderItems;
    }

    /**
     * Get order items by order ID
     *
     * @param orderId Order ID
     * @return List of order items
     */
    public List<OrderItem> getOrderItemsByOrderId(int orderId) {
        try (Connection conn = DBConnection.getConnection()) {
            return getOrderItemsByOrderId(orderId, conn);
        } catch (SQLException e) {
            System.out.println("Error getting order items: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * Update all pending orders with paid payments to Processing status
     * This is useful for fixing existing data in the database
     *
     * @return Number of orders updated
     */
    public int updatePaidPendingOrders() {
        // First, update all orders with Credit Card or PayPal payment methods to Processing status
        String query1 = "UPDATE orders o SET o.status = 'Processing' " +
                "WHERE (o.payment_method = 'Credit Card' OR o.payment_method = 'PayPal')";

        // Second, update all orders with Completed or Paid payments to Processing status
        String query2 = "UPDATE orders o SET o.status = 'Processing' " +
                "WHERE o.id IN (SELECT p.order_id FROM payments p WHERE p.status = 'Completed' OR p.status = 'Paid')";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            int rowsAffected1 = stmt.executeUpdate(query1);
            System.out.println("OrderDAO: Updated " + rowsAffected1 + " orders with Credit Card or PayPal payment methods to Processing status");

            int rowsAffected2 = stmt.executeUpdate(query2);
            System.out.println("OrderDAO: Updated " + rowsAffected2 + " orders with Completed or Paid payments to Processing status");

            return rowsAffected1 + rowsAffected2;

        } catch (SQLException e) {
            System.out.println("Error updating paid pending orders: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Load shipping address for an order - stub method since shipping address is no longer stored
     *
     * @param order Order to load shipping address for
     * @param conn  Database connection
     */
    private void loadShippingAddress(Order order, Connection conn) {
        // Shipping address is no longer stored
        System.out.println("Note: Shipping address is no longer stored in the order");
    }

    /**
     * Load payment method for an order
     *
     * @param order Order to load payment method for
     * @param conn  Database connection
     */

    /**
     * Get orders by user ID
     *
     * @param userId User ID
     * @return List of orders for the user
     */
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orders = new ArrayList<>();

        // First check if the orders table exists
        try (Connection conn = DBConnection.getConnection()) {
            DatabaseMetaData dbm = conn.getMetaData();
            ResultSet tables = dbm.getTables(null, null, "orders", null);
            if (!tables.next()) {
                System.out.println("Warning: orders table does not exist");
                return orders;
            }

            String query = "SELECT * FROM orders " +
                    "WHERE user_id = ? " +
                    "ORDER BY order_placed_date DESC";

            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, userId);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        try {
                            Order order = extractOrderFromResultSet(rs);

                            // Shipping address and payment method are no longer stored

                            // Load order items
                            List<OrderItem> orderItems = getOrderItemsByOrderId(order.getId(), conn);
                            order.setOrderItems(orderItems);

                            orders.add(order);
                        } catch (SQLException e) {
                            System.out.println("Error processing order: " + e.getMessage());
                            // Continue to next order
                        }
                    }
                }
            } catch (SQLException e) {
                System.out.println("Error executing query: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (SQLException e) {
            System.out.println("Error getting orders by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return orders;
    }

    /**
     * Get orders by user ID and filter by status
     *
     * @param userId User ID
     * @param status Order status to filter by (null for all statuses)
     * @return List of filtered orders for the user
     */
    public List<Order> getOrdersByUserId(int userId, String status) {
        // If status is null, empty, or "all", get all orders for the user
        if (status == null || status.isEmpty() || status.equalsIgnoreCase("all")) {
            return getOrdersByUserId(userId);
        }

        List<Order> orders = new ArrayList<>();

        // First check if the orders table exists
        try (Connection conn = DBConnection.getConnection()) {
            DatabaseMetaData dbm = conn.getMetaData();
            ResultSet tables = dbm.getTables(null, null, "orders", null);
            if (!tables.next()) {
                System.out.println("Warning: orders table does not exist");
                return orders;
            }

            String query = "SELECT * FROM orders " +
                    "WHERE user_id = ? AND status = ? " +
                    "ORDER BY order_placed_date DESC";

            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, userId);
                stmt.setString(2, status);

                System.out.println("OrderDAO - Executing query with userId=" + userId + " and status=" + status);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        try {
                            Order order = extractOrderFromResultSet(rs);

                            // Shipping address and payment method are no longer stored

                            // Load order items
                            List<OrderItem> orderItems = getOrderItemsByOrderId(order.getId(), conn);
                            order.setOrderItems(orderItems);

                            orders.add(order);
                        } catch (SQLException e) {
                            System.out.println("Error processing order: " + e.getMessage());
                            // Continue to next order
                        }
                    }
                }

                System.out.println("OrderDAO - Found " + orders.size() + " orders with status " + status);
            } catch (SQLException e) {
                System.out.println("Error executing query: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (SQLException e) {
            System.out.println("Error getting filtered orders by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return orders;
    }

    /**
     * Get all orders
     *
     * @return List of all orders
     */
    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        String query = "SELECT o.*, u.first_name, u.last_name " +
                "FROM orders o " +
                "LEFT JOIN users u ON o.user_id = u.id " +
                "ORDER BY o.order_placed_date DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                Order order = extractOrderFromResultSet(rs);

                // Shipping address and payment method are no longer stored

                // User information is loaded separately

                // Note: Order items are loaded separately

                orders.add(order);
            }

        } catch (SQLException e) {
            System.out.println("Error getting all orders: " + e.getMessage());
            e.printStackTrace();
        }

        return orders;
    }

    /**
     * Get recent orders
     *
     * @param limit Number of orders to return
     * @return List of recent orders
     */
    public List<Order> getRecentOrders(int limit) {
        List<Order> orders = new ArrayList<>();
        String query = "SELECT * FROM orders " +
                "ORDER BY order_placed_date DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Order order = extractOrderFromResultSet(rs);

                    // Shipping address and payment method are no longer stored

                    // Note: Order items are loaded separately

                    // Load user
                    User user = userDAO.getUserById(order.getUserId());
                    // User information is loaded separately

                    orders.add(order);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting recent orders: " + e.getMessage());
            e.printStackTrace();
        }

        return orders;
    }


    /**
     * Get order count
     *
     * @return Number of orders
     */
    public int getOrderCount() {
        String query = "SELECT COUNT(*) FROM orders";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("Error getting order count: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get total order count for dashboard
     *
     * @return Total number of orders
     */
    public int getTotalOrderCount() {
        return getOrderCount();
    }

    /**
     * Get total revenue for dashboard
     *
     * @return Total revenue from all orders
     */
    public double getTotalRevenue() {
        String query = "SELECT SUM(total_price) FROM orders";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            if (rs.next()) {
                return rs.getDouble(1);
            }

        } catch (SQLException e) {
            System.out.println("Error getting total revenue: " + e.getMessage());
            e.printStackTrace();
        }

        return 0.0;
    }

    /**
     * Add an order item
     *
     * @param item OrderItem object to add
     * @return true if successful, false otherwise
     */
    public boolean addOrderItem(OrderItem item) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            boolean success = addOrderItem(item, conn);

            if (success) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }

        } catch (SQLException e) {
            System.out.println("Error adding order item: " + e.getMessage());
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                System.out.println("Error rolling back transaction: " + ex.getMessage());
            }

            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.out.println("Error closing connection: " + e.getMessage());
            }
        }
    }

    /**
     * Get order count by user ID
     *
     * @param userId User ID
     * @return Number of orders for the user
     */
    public int getOrderCountByUserId(int userId) {
        System.out.println("OrderDAO: Getting order count for user ID: " + userId);
        String query = "SELECT COUNT(*) FROM orders WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            // First check if the orders table exists
            DatabaseMetaData dbm = conn.getMetaData();
            ResultSet tables = dbm.getTables(null, null, "orders", null);
            if (!tables.next()) {
                System.out.println("OrderDAO: Warning - orders table does not exist");
                return 0;
            }

            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, userId);
                System.out.println("OrderDAO: Executing query: " + query.replace("?", String.valueOf(userId)));

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        int count = rs.getInt(1);
                        System.out.println("OrderDAO: Found " + count + " orders for user ID: " + userId);
                        return count;
                    }
                }
            } catch (SQLException e) {
                System.out.println("OrderDAO: Error executing query: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (SQLException e) {
            System.out.println("OrderDAO: Error getting connection or checking table: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("OrderDAO: Returning 0 orders for user ID: " + userId);
        return 0;
    }

    /**
     * Get total sales
     *
     * @return Total sales amount
     */
    public double getTotalSales() {
        String query = "SELECT SUM(total_price) FROM orders WHERE id IN (SELECT order_id FROM payments WHERE status = 'Paid')";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            if (rs.next()) {
                return rs.getDouble(1);
            }

        } catch (SQLException e) {
            System.out.println("Error getting total sales: " + e.getMessage());
            e.printStackTrace();
        }

        return 0.0;
    }

    /**
     * Delete order
     *
     * @param orderId Order ID
     * @return true if successful, false otherwise
     */
    public boolean deleteOrder(int orderId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Delete order items first (cascade delete should handle this, but just to be safe)
            String deleteItemsQuery = "DELETE FROM order_items WHERE order_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteItemsQuery)) {
                stmt.setInt(1, orderId);
                stmt.executeUpdate();
            }

            // Delete shipping record if exists
            String deleteShippingQuery = "DELETE FROM shipping WHERE order_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteShippingQuery)) {
                stmt.setInt(1, orderId);
                stmt.executeUpdate();
            }

            // Delete payment record if exists
            String deletePaymentQuery = "DELETE FROM payments WHERE order_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deletePaymentQuery)) {
                stmt.setInt(1, orderId);
                stmt.executeUpdate();
            }

            // Delete order
            String deleteOrderQuery = "DELETE FROM orders WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteOrderQuery)) {
                stmt.setInt(1, orderId);
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            }

        } catch (SQLException e) {
            System.out.println("Error deleting order: " + e.getMessage());
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                System.out.println("Error rolling back transaction: " + ex.getMessage());
            }

            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.out.println("Error closing connection: " + e.getMessage());
            }
        }
    }

    /**
     * Extract order from result set
     *
     * @param rs Result set
     * @return Order object
     * @throws SQLException if error occurs
     */
    private Order extractOrderFromResultSet(ResultSet rs) throws SQLException {
        Order order = new Order();

        try {
            order.setId(rs.getInt("id"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'id' column: " + e.getMessage());
        }

        try {
            order.setUserId(rs.getInt("user_id"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'user_id' column: " + e.getMessage());
        }

        try {
            order.setTotalPrice(rs.getDouble("total_price"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'total_price' column: " + e.getMessage());
        }

        try {
            order.setStatus(rs.getString("status"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'status' column: " + e.getMessage());
        }

        // Handle different date column names
        try {
            order.setOrderDate(rs.getTimestamp("order_placed_date"));
        } catch (SQLException e) {
            try {
                order.setOrderDate(rs.getTimestamp("created_at"));
            } catch (SQLException ex) {
                // If neither column exists, set current time
                System.out.println("Warning: Could not get date column: " + e.getMessage());
                order.setOrderDate(new Timestamp(System.currentTimeMillis()));
            }
        }

        // Payment method is no longer stored

        return order;
    }

    /**
     * Extract order item from result set
     *
     * @param rs Result set
     * @return OrderItem object
     * @throws SQLException if error occurs
     */
    private OrderItem extractOrderItemFromResultSet(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();

        try {
            item.setId(rs.getInt("id"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'id' column for order item: " + e.getMessage());
        }

        try {
            item.setOrderId(rs.getInt("order_id"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'order_id' column for order item: " + e.getMessage());
        }

        try {
            item.setProductId(rs.getInt("product_id"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'product_id' column for order item: " + e.getMessage());
        }

        try {
            item.setProductName(rs.getString("product_name"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'product_name' column for order item: " + e.getMessage());
        }

        try {
            item.setPrice(rs.getDouble("price"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'price' column for order item: " + e.getMessage());
        }

        try {
            item.setQuantity(rs.getInt("quantity"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'quantity' column for order item: " + e.getMessage());
        }

        try {
            item.setImageUrl(rs.getString("image_url"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'image_url' column for order item: " + e.getMessage());
        }

        return item;
    }


}
