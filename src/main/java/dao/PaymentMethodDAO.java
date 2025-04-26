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

import model.PaymentMethod;
import util.DBConnection;

/**
 * Payment Method Data Access Object
 */
public class PaymentMethodDAO {
    
    /**
     * Create a new payment method
     * @param paymentMethod PaymentMethod object
     * @return true if successful, false otherwise
     */
    public boolean createPaymentMethod(PaymentMethod paymentMethod) {
        String query = "INSERT INTO payment_methods (user_id, card_type, card_name, card_number, expiry_date, " +
                      "billing_address, billing_city, billing_state, billing_zip, billing_country, is_default, created_at, updated_at) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            // Set timestamps if not already set
            if (paymentMethod.getCreatedAt() == null) {
                paymentMethod.setCreatedAt(new Timestamp(new Date().getTime()));
            }
            if (paymentMethod.getUpdatedAt() == null) {
                paymentMethod.setUpdatedAt(new Timestamp(new Date().getTime()));
            }
            
            // If this is the default payment method, unset any existing default
            if (paymentMethod.isDefault()) {
                unsetDefaultPaymentMethods(paymentMethod.getUserId(), conn);
            }
            
            // Only store the last 4 digits of the card number for security
            String cardNumber = paymentMethod.getCardNumber();
            if (cardNumber != null && !cardNumber.isEmpty()) {
                // Clean the card number (remove spaces)
                cardNumber = cardNumber.replaceAll("\\s+", "");
                
                // If the card number is at least 4 digits, only store the last 4
                if (cardNumber.length() >= 4) {
                    cardNumber = cardNumber.substring(cardNumber.length() - 4);
                }
            }
            
            stmt.setInt(1, paymentMethod.getUserId());
            stmt.setString(2, paymentMethod.getCardType());
            stmt.setString(3, paymentMethod.getCardName());
            stmt.setString(4, cardNumber);
            stmt.setString(5, paymentMethod.getExpiryDate());
            stmt.setString(6, paymentMethod.getBillingAddress());
            stmt.setString(7, paymentMethod.getBillingCity());
            stmt.setString(8, paymentMethod.getBillingState());
            stmt.setString(9, paymentMethod.getBillingZip());
            stmt.setString(10, paymentMethod.getBillingCountry());
            stmt.setBoolean(11, paymentMethod.isDefault());
            stmt.setTimestamp(12, paymentMethod.getCreatedAt());
            stmt.setTimestamp(13, paymentMethod.getUpdatedAt());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        paymentMethod.setId(rs.getInt(1));
                        return true;
                    }
                }
            }
            
            return false;
            
        } catch (SQLException e) {
            System.out.println("Error creating payment method: " + e.getMessage());
            System.out.println("SQL State: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.out.println("Unexpected error creating payment method: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Unset default payment methods for a user
     * @param userId User ID
     * @param conn Database connection
     * @throws SQLException If an error occurs
     */
    private void unsetDefaultPaymentMethods(int userId, Connection conn) throws SQLException {
        String query = "UPDATE payment_methods SET is_default = false WHERE user_id = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }
    
    /**
     * Get payment methods by user ID
     * @param userId User ID
     * @return List of payment methods
     */
    public List<PaymentMethod> getPaymentMethodsByUserId(int userId) {
        String query = "SELECT * FROM payment_methods WHERE user_id = ? ORDER BY is_default DESC, created_at DESC";
        List<PaymentMethod> paymentMethods = new ArrayList<>();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    paymentMethods.add(extractPaymentMethodFromResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            System.out.println("Error getting payment methods: " + e.getMessage());
            e.printStackTrace();
        }
        
        return paymentMethods;
    }
    
    /**
     * Get payment method by ID
     * @param id Payment method ID
     * @return PaymentMethod object or null if not found
     */
    public PaymentMethod getPaymentMethodById(int id) {
        String query = "SELECT * FROM payment_methods WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractPaymentMethodFromResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("Error getting payment method: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Update payment method
     * @param paymentMethod PaymentMethod object
     * @return true if successful, false otherwise
     */
    public boolean updatePaymentMethod(PaymentMethod paymentMethod) {
        String query = "UPDATE payment_methods SET card_type = ?, card_name = ?, expiry_date = ?, " +
                      "billing_address = ?, billing_city = ?, billing_state = ?, billing_zip = ?, " +
                      "billing_country = ?, is_default = ?, updated_at = ? WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            // Begin transaction
            conn.setAutoCommit(false);
            
            // If this is the default payment method, unset any existing default
            if (paymentMethod.isDefault()) {
                unsetDefaultPaymentMethods(paymentMethod.getUserId(), conn);
            }
            
            // Update payment method
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                // Set updated timestamp
                paymentMethod.setUpdatedAt(new Timestamp(new Date().getTime()));
                
                stmt.setString(1, paymentMethod.getCardType());
                stmt.setString(2, paymentMethod.getCardName());
                stmt.setString(3, paymentMethod.getExpiryDate());
                stmt.setString(4, paymentMethod.getBillingAddress());
                stmt.setString(5, paymentMethod.getBillingCity());
                stmt.setString(6, paymentMethod.getBillingState());
                stmt.setString(7, paymentMethod.getBillingZip());
                stmt.setString(8, paymentMethod.getBillingCountry());
                stmt.setBoolean(9, paymentMethod.isDefault());
                stmt.setTimestamp(10, paymentMethod.getUpdatedAt());
                stmt.setInt(11, paymentMethod.getId());
                
                int rowsAffected = stmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
            
        } catch (SQLException e) {
            System.out.println("Error updating payment method: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete payment method
     * @param id Payment method ID
     * @return true if successful, false otherwise
     */
    public boolean deletePaymentMethod(int id) {
        String query = "DELETE FROM payment_methods WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.out.println("Error deleting payment method: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Set payment method as default
     * @param id Payment method ID
     * @param userId User ID
     * @return true if successful, false otherwise
     */
    public boolean setDefaultPaymentMethod(int id, int userId) {
        try (Connection conn = DBConnection.getConnection()) {
            // Begin transaction
            conn.setAutoCommit(false);
            
            try {
                // Unset any existing default payment methods
                unsetDefaultPaymentMethods(userId, conn);
                
                // Set the specified payment method as default
                String query = "UPDATE payment_methods SET is_default = true, updated_at = ? WHERE id = ? AND user_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(query)) {
                    stmt.setTimestamp(1, new Timestamp(new Date().getTime()));
                    stmt.setInt(2, id);
                    stmt.setInt(3, userId);
                    
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
                conn.rollback();
                throw e;
            }
            
        } catch (SQLException e) {
            System.out.println("Error setting default payment method: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Extract payment method from result set
     * @param rs Result set
     * @return PaymentMethod object
     * @throws SQLException If an error occurs
     */
    private PaymentMethod extractPaymentMethodFromResultSet(ResultSet rs) throws SQLException {
        PaymentMethod paymentMethod = new PaymentMethod();
        paymentMethod.setId(rs.getInt("id"));
        paymentMethod.setUserId(rs.getInt("user_id"));
        paymentMethod.setCardType(rs.getString("card_type"));
        paymentMethod.setCardName(rs.getString("card_name"));
        paymentMethod.setCardNumber(rs.getString("card_number"));
        paymentMethod.setExpiryDate(rs.getString("expiry_date"));
        paymentMethod.setBillingAddress(rs.getString("billing_address"));
        paymentMethod.setBillingCity(rs.getString("billing_city"));
        paymentMethod.setBillingState(rs.getString("billing_state"));
        paymentMethod.setBillingZip(rs.getString("billing_zip"));
        paymentMethod.setBillingCountry(rs.getString("billing_country"));
        paymentMethod.setDefault(rs.getBoolean("is_default"));
        paymentMethod.setCreatedAt(rs.getTimestamp("created_at"));
        paymentMethod.setUpdatedAt(rs.getTimestamp("updated_at"));
        return paymentMethod;
    }
}
