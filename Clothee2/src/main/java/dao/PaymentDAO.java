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
import java.util.UUID;

import model.Payment;
import util.DBConnection;

/**
 * Payment Data Access Object
 */
public class PaymentDAO {
    
    /**
     * Create a new payment
     * @param payment Payment object
     * @return true if successful, false otherwise
     */
    public boolean createPayment(Payment payment) {
        String query = "INSERT INTO payments (order_id, user_id, payment_method, amount, status, payment_date, transaction_id, card_number) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            // Generate transaction ID if not provided
            if (payment.getTransactionId() == null || payment.getTransactionId().isEmpty()) {
                payment.setTransactionId(generateTransactionId());
            }
            
            // Set payment date if not provided
            if (payment.getPaymentDate() == null) {
                payment.setPaymentDate(new Timestamp(new Date().getTime()));
            }
            
            stmt.setInt(1, payment.getOrderId());
            stmt.setInt(2, payment.getUserId());
            stmt.setString(3, payment.getPaymentMethod());
            stmt.setDouble(4, payment.getAmount());
            stmt.setString(5, payment.getStatus());
            stmt.setTimestamp(6, payment.getPaymentDate());
            stmt.setString(7, payment.getTransactionId());
            stmt.setString(8, payment.getCardNumber());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        payment.setId(rs.getInt(1));
                        return true;
                    }
                }
            }
            
            return false;
            
        } catch (SQLException e) {
            System.out.println("Error creating payment: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get payment by ID
     * @param paymentId Payment ID
     * @return Payment object if found, null otherwise
     */
    public Payment getPaymentById(int paymentId) {
        String query = "SELECT * FROM payments WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, paymentId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractPaymentFromResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("Error getting payment by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get payments by order ID
     * @param orderId Order ID
     * @return List of payments for the order
     */
    public List<Payment> getPaymentsByOrderId(int orderId) {
        List<Payment> payments = new ArrayList<>();
        String query = "SELECT * FROM payments WHERE order_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, orderId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(extractPaymentFromResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            System.out.println("Error getting payments by order ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return payments;
    }
    
    /**
     * Get payments by user ID
     * @param userId User ID
     * @return List of payments for the user
     */
    public List<Payment> getPaymentsByUserId(int userId) {
        List<Payment> payments = new ArrayList<>();
        String query = "SELECT * FROM payments WHERE user_id = ? ORDER BY payment_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(extractPaymentFromResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            System.out.println("Error getting payments by user ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return payments;
    }
    
    /**
     * Update payment status
     * @param paymentId Payment ID
     * @param status New status
     * @return true if successful, false otherwise
     */
    public boolean updatePaymentStatus(int paymentId, String status) {
        String query = "UPDATE payments SET status = ? WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, paymentId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.out.println("Error updating payment status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get all payments
     * @return List of all payments
     */
    public List<Payment> getAllPayments() {
        List<Payment> payments = new ArrayList<>();
        String query = "SELECT * FROM payments ORDER BY payment_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                payments.add(extractPaymentFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            System.out.println("Error getting all payments: " + e.getMessage());
            e.printStackTrace();
        }
        
        return payments;
    }
    
    /**
     * Get recent payments
     * @param limit Number of payments to return
     * @return List of recent payments
     */
    public List<Payment> getRecentPayments(int limit) {
        List<Payment> payments = new ArrayList<>();
        String query = "SELECT * FROM payments ORDER BY payment_date DESC LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(extractPaymentFromResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            System.out.println("Error getting recent payments: " + e.getMessage());
            e.printStackTrace();
        }
        
        return payments;
    }
    
    /**
     * Generate a unique transaction ID
     * @return Transaction ID
     */
    private String generateTransactionId() {
        return "TXN" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    
    /**
     * Extract payment from result set
     * @param rs Result set
     * @return Payment object
     * @throws SQLException If an error occurs
     */
    private Payment extractPaymentFromResultSet(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setId(rs.getInt("id"));
        payment.setOrderId(rs.getInt("order_id"));
        payment.setUserId(rs.getInt("user_id"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setAmount(rs.getDouble("amount"));
        payment.setStatus(rs.getString("status"));
        payment.setPaymentDate(rs.getTimestamp("payment_date"));
        payment.setTransactionId(rs.getString("transaction_id"));
        payment.setCardNumber(rs.getString("card_number"));
        return payment;
    }
}
