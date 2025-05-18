package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import model.Shipping;
import util.DBConnection;

/**
 * Shipping Data Access Object
 */
public class ShippingDAO {

    /**
     * Create a new shipping record
     * @param shipping Shipping object
     * @return true if successful, false otherwise
     */
    public boolean createShipping(Shipping shipping) {
        String query = "INSERT INTO shipping (order_id, shipping_date, shipping_status, shipping_address) " +
                      "VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            // Set shipping date if not provided
            if (shipping.getShippingDate() == null) {
                shipping.setShippingDate(new Timestamp(new Date().getTime()));
            }

            // Debug output
            System.out.println("ShippingDAO: Creating shipping record with:" +
                    "\n  orderId=" + shipping.getOrderId() +
                    "\n  shippingDate=" + shipping.getShippingDate() +
                    "\n  shippingStatus=" + shipping.getShippingStatus() +
                    "\n  shippingAddress=" + shipping.getShippingAddress());

            stmt.setInt(1, shipping.getOrderId());
            stmt.setTimestamp(2, shipping.getShippingDate());

            // Handle null values for strings
            if (shipping.getShippingStatus() != null) {
                stmt.setString(3, shipping.getShippingStatus());
            } else {
                stmt.setString(3, "Pending"); // Default status
            }

            if (shipping.getShippingAddress() != null) {
                stmt.setString(4, shipping.getShippingAddress());
            } else {
                stmt.setString(4, "Address not provided"); // Default address
            }

            int rowsAffected = stmt.executeUpdate();
            System.out.println("ShippingDAO: Rows affected: " + rowsAffected);

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        shipping.setId(rs.getInt(1));
                        System.out.println("ShippingDAO: Created shipping record with ID: " + shipping.getId());
                        return true;
                    }
                }
            }

            System.out.println("ShippingDAO: Failed to create shipping record");
            return false;

        } catch (SQLException e) {
            System.out.println("Error creating shipping record: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get shipping record by order ID
     * @param orderId Order ID
     * @return Shipping object if found, null otherwise
     */
    public Shipping getShippingByOrderId(int orderId) {
        // Validate input parameter
        if (orderId <= 0) {
            System.out.println("ShippingDAO: Invalid order ID: " + orderId);
            return null;
        }

        System.out.println("ShippingDAO: Getting shipping for order ID " + orderId);
        String query = "SELECT * FROM shipping WHERE order_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, orderId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Shipping shipping = extractShippingFromResultSet(rs);
                    System.out.println("ShippingDAO: Found shipping record for order ID " + orderId + ": " + shipping);
                    return shipping;
                } else {
                    System.out.println("ShippingDAO: No shipping record found for order ID " + orderId);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting shipping by order ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Update shipping status
     * @param orderId Order ID
     * @param status New status
     * @return true if successful, false otherwise
     */
    public boolean updateShippingStatus(int orderId, String status) {
        // Validate input parameters
        if (orderId <= 0) {
            System.out.println("ShippingDAO: Invalid order ID: " + orderId);
            return false;
        }

        if (status == null || status.trim().isEmpty()) {
            System.out.println("ShippingDAO: Invalid status: " + status);
            status = "Pending"; // Default status if null or empty
        }

        System.out.println("ShippingDAO: Updating shipping status for order ID " + orderId + " to " + status);

        String query = "UPDATE shipping SET shipping_status = ? WHERE order_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, status);
            stmt.setInt(2, orderId);

            int rowsAffected = stmt.executeUpdate();
            System.out.println("ShippingDAO: Update affected " + rowsAffected + " rows");

            // If no shipping record exists, create one
            if (rowsAffected == 0) {
                System.out.println("ShippingDAO: No shipping record found for order ID " + orderId + ", creating one");

                // Try to get shipping address from cart
                String shippingAddress = getShippingAddressFromCart(orderId, conn);

                Shipping shipping = new Shipping();
                shipping.setOrderId(orderId);
                shipping.setShippingStatus(status);
                shipping.setShippingDate(new Timestamp(new Date().getTime()));
                shipping.setShippingAddress(shippingAddress);
                return createShipping(shipping);
            }

            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error updating shipping status: " + e.getMessage());
            e.printStackTrace();
            return false;
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

        // Get user information from users table
        String userName = getUserFullName(userId, conn);
        if (userName != null && !userName.isEmpty()) {
            return userName + " (Order #" + orderId + ")";
        }

        return "Customer #" + userId + " (Order #" + orderId + ")"; // Default if nothing else is available
    }

    /**
     * Get user's full name from users table
     * @param userId User ID
     * @param conn Database connection
     * @return User's full name or empty string if not found
     */
    private String getUserFullName(int userId, Connection conn) throws SQLException {
        String query = "SELECT first_name, last_name FROM users WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String firstName = rs.getString("first_name");
                    String lastName = rs.getString("last_name");
                    if (firstName != null && lastName != null) {
                        return firstName + " " + lastName;
                    }
                }
            }
        }
        return "";
    }

    /**
     * Extract shipping object from result set
     * @param rs Result set
     * @return Shipping object
     * @throws SQLException if error occurs
     */
    private Shipping extractShippingFromResultSet(ResultSet rs) throws SQLException {
        Shipping shipping = new Shipping();
        shipping.setId(rs.getInt("id"));
        shipping.setOrderId(rs.getInt("order_id"));

        // Handle potential null values
        java.sql.Timestamp timestamp = rs.getTimestamp("shipping_date");
        if (timestamp != null) {
            shipping.setShippingDate(timestamp);
        }

        shipping.setShippingStatus(rs.getString("shipping_status"));
        shipping.setShippingAddress(rs.getString("shipping_address"));
        return shipping;
    }
}
