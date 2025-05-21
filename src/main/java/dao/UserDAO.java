package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.User;
import util.DBConnection;
import util.PasswordHasher;

public class UserDAO {

    public boolean addUser(User user) {
        try {
            return addUserWithRole(user);
        } catch (SQLException e) {
            // If the first attempt fails (possibly due to missing role column), try the alternative approach
            if (e.getMessage().contains("role") || e.getMessage().contains("column")) {
                System.out.println("Trying alternative user insertion without role column");
                try {
                    return addUserWithoutRole(user);
                } catch (SQLException ex) {
                    System.err.println("SQL Error in alternative addUser for " + user.getEmail() + ": " + ex.getMessage());
                    ex.printStackTrace();
                    throw new RuntimeException("Failed to add user: " + ex.getMessage(), ex);
                }
            } else {
                System.err.println("SQL Error in addUser for " + user.getEmail() + ": " + e.getMessage());
                e.printStackTrace();
                throw new RuntimeException("Failed to add user: " + e.getMessage(), e);
            }
        }
    }

    private boolean addUserWithRole(User user) throws SQLException {
        // Using the schema from clothee.sql
        String query = "INSERT INTO users (first_name, last_name, email, password, phone, role, is_admin, profile_image, created_at, updated_at) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPassword());
            stmt.setString(5, user.getPhone());
            stmt.setString(6, user.getRole());
            stmt.setBoolean(7, user.isAdmin());
            stmt.setString(8, user.getProfileImage());
            stmt.setTimestamp(9, user.getCreatedAt());
            stmt.setTimestamp(10, user.getUpdatedAt());

            int rowsAffected = stmt.executeUpdate();
            System.out.println("addUserWithRole: " + rowsAffected + " rows affected for " + user.getEmail() + ", isAdmin: " + user.isAdmin());
            return rowsAffected > 0;
        }
    }

    // This method is kept for backward compatibility but should not be used with the updated schema
    private boolean addUserWithoutRole(User user) throws SQLException {
        // Redirect to the method that works with the updated schema
        return addUserWithRole(user);
    }

    public boolean updateUser(User user) {
        try {
            return updateUserWithRole(user);
        } catch (SQLException e) {
            // If the first attempt fails (possibly due to missing role column), try the alternative approach
            if (e.getMessage().contains("role") || e.getMessage().contains("column")) {
                System.out.println("Trying alternative user update without role column");
                try {
                    return updateUserWithoutRole(user);
                } catch (SQLException ex) {
                    System.err.println("SQL Error in alternative updateUser for " + user.getEmail() + ": " + ex.getMessage());
                    ex.printStackTrace();
                    throw new RuntimeException("Failed to update user: " + ex.getMessage(), ex);
                }
            } else {
                System.err.println("SQL Error in updateUser for " + user.getEmail() + ": " + e.getMessage());
                e.printStackTrace();
                throw new RuntimeException("Failed to update user: " + e.getMessage(), e);
            }
        }
    }

    private boolean updateUserWithRole(User user) throws SQLException {
        System.out.println("UserDAO.updateUserWithRole - Starting update for user ID: " + user.getId());

        // First, get the existing user to ensure we have all fields
        User existingUser = getUserById(user.getId());
        if (existingUser == null) {
            System.out.println("UserDAO.updateUserWithRole - User not found with ID: " + user.getId());
            return false;
        }

        // Use a more specific query that only updates the fields we want to change
        String query = "UPDATE users SET first_name = ?, last_name = ?, email = ?, phone = ?, profile_image = ?, " +
                       "updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            // Set the fields we want to update
            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPhone() != null ? user.getPhone() : "");
            stmt.setString(5, user.getProfileImage());
            stmt.setInt(6, user.getId());

            System.out.println("UserDAO.updateUserWithRole - Executing update query");
            System.out.println("UserDAO.updateUserWithRole - firstName: " + user.getFirstName());
            System.out.println("UserDAO.updateUserWithRole - lastName: " + user.getLastName());
            System.out.println("UserDAO.updateUserWithRole - email: " + user.getEmail());
            System.out.println("UserDAO.updateUserWithRole - phone: " + (user.getPhone() != null ? user.getPhone() : ""));
            System.out.println("UserDAO.updateUserWithRole - profileImage: " + user.getProfileImage());

            int rowsAffected = stmt.executeUpdate();
            System.out.println("UserDAO.updateUserWithRole - Update result: " + rowsAffected + " rows affected");
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("UserDAO.updateUserWithRole - SQL Exception: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    // This method is kept for backward compatibility but should not be used with the updated schema
    private boolean updateUserWithoutRole(User user) throws SQLException {
        System.out.println("UserDAO.updateUserWithoutRole - Starting update for user ID: " + user.getId());

        // First, get the existing user to ensure we have all fields
        User existingUser = getUserById(user.getId());
        if (existingUser == null) {
            System.out.println("UserDAO.updateUserWithoutRole - User not found with ID: " + user.getId());
            return false;
        }

        // Use a more specific query that only updates the fields we want to change
        // This version doesn't include the role column
        String query = "UPDATE users SET first_name = ?, last_name = ?, email = ?, phone = ?, profile_image = ?, " +
                       "updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            // Set the fields we want to update
            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPhone() != null ? user.getPhone() : "");
            stmt.setString(5, user.getProfileImage());
            stmt.setInt(6, user.getId());

            System.out.println("UserDAO.updateUserWithoutRole - Executing update query");

            int rowsAffected = stmt.executeUpdate();
            System.out.println("UserDAO.updateUserWithoutRole - Update result: " + rowsAffected + " rows affected");
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("UserDAO.updateUserWithoutRole - SQL Exception: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public boolean updatePassword(int userId, String newPassword) {
        String query = "UPDATE users SET password = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            String hashedPassword = PasswordHasher.hashPassword(newPassword);
            stmt.setString(1, hashedPassword);
            stmt.setInt(2, userId);

            int rowsAffected = stmt.executeUpdate();
            System.out.println("updatePassword: " + rowsAffected + " rows affected for userId " + userId);
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("SQL Error in updatePassword for userId " + userId + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to update password: " + e.getMessage(), e);
        }
    }

    public boolean deleteUser(int userId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Check if user has related records that would prevent deletion
            if (hasRelatedRecords(conn, userId)) {
                System.out.println("User " + userId + " has related records that prevent deletion");
                conn.rollback();
                return false;
            }

            // First, delete related records in other tables
            deleteRelatedRecords(conn, userId);

            // Then delete the user
            String query = "DELETE FROM users WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, userId);
                int rowsAffected = stmt.executeUpdate();

                // Commit the transaction
                conn.commit();

                System.out.println("deleteUser: " + rowsAffected + " rows affected for userId " + userId);
                return rowsAffected > 0;
            }
        } catch (SQLException e) {
            // Rollback the transaction in case of error
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error rolling back transaction: " + ex.getMessage());
                }
            }
            System.err.println("SQL Error in deleteUser for userId " + userId + ": " + e.getMessage());
            e.printStackTrace();
            return false; // Return false instead of throwing exception
        } finally {
            // Close the connection
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                }
            }
        }
    }

    /**
     * Check if a user has related records that would prevent deletion
     * @param conn Database connection
     * @param userId User ID
     * @return true if user has related records, false otherwise
     * @throws SQLException If an SQL error occurs
     */
    private boolean hasRelatedRecords(Connection conn, int userId) throws SQLException {
        // Check for orders
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM orders WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return true;
                }
            }
        } catch (SQLException e) {
            // If table doesn't exist, ignore
            if (!e.getMessage().contains("doesn't exist")) {
                throw e;
            }
        }

        return false;
    }

    /**
     * Delete related records for a user before deleting the user
     * @param conn Database connection
     * @param userId User ID
     * @throws SQLException If an SQL error occurs
     */
    private void deleteRelatedRecords(Connection conn, int userId) throws SQLException {
        // Delete from cart
        try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM cart WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            // If table doesn't exist, ignore
            if (!e.getMessage().contains("doesn't exist")) {
                throw e;
            }
        }

        // Delete from wishlist
        try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM wishlist WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            // If table doesn't exist, ignore
            if (!e.getMessage().contains("doesn't exist")) {
                throw e;
            }
        }

        // Delete from reviews
        try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM reviews WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            // If table doesn't exist, ignore
            if (!e.getMessage().contains("doesn't exist")) {
                throw e;
            }
        }

        // Delete from messages
        try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM messages WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            // If table doesn't exist, ignore
            if (!e.getMessage().contains("doesn't exist")) {
                throw e;
            }
        }

        // Delete from orders (this will cascade to order_items)
        try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM orders WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            // If table doesn't exist, ignore
            if (!e.getMessage().contains("doesn't exist")) {
                throw e;
            }
        }
    }

    public User getUserById(int userId) {
        String query = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = extractUserFromResultSet(rs);
                    System.out.println("getUserById: Found user with ID " + userId);
                    return user;
                }
                System.out.println("getUserById: No user found with ID " + userId);
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in getUserById for userId " + userId + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get user by ID: " + e.getMessage(), e);
        }

        return null;
    }

    public User getUserByEmail(String email) {
        String query = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = extractUserFromResultSet(rs);
                    System.out.println("getUserByEmail: Found user with email " + email + ", Role: " + user.getRole());
                    return user;
                }
                System.out.println("getUserByEmail: No user found with email " + email);
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in getUserByEmail for email " + email + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get user by email: " + e.getMessage(), e);
        }

        return null;
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String query = "SELECT * FROM users ORDER BY id";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }
            System.out.println("getAllUsers: Retrieved " + users.size() + " users");

        } catch (SQLException e) {
            System.err.println("SQL Error in getAllUsers: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get all users: " + e.getMessage(), e);
        }

        return users;
    }

    public List<User> getUsersByRole(String role) {
        List<User> users = new ArrayList<>();

        try {
            // Try with role column first
            users = getUsersByRoleColumn(role);
        } catch (SQLException e) {
            // If that fails, try with is_admin column
            if (e.getMessage().contains("role") || e.getMessage().contains("column")) {
                System.out.println("Trying to get users by is_admin instead of role");
                try {
                    boolean isAdmin = "admin".equalsIgnoreCase(role);
                    users = getUsersByIsAdmin(isAdmin);
                } catch (SQLException ex) {
                    System.err.println("SQL Error getting users by is_admin: " + ex.getMessage());
                    ex.printStackTrace();
                    throw new RuntimeException("Failed to get users by role: " + ex.getMessage(), ex);
                }
            } else {
                System.err.println("SQL Error in getUsersByRole for role " + role + ": " + e.getMessage());
                e.printStackTrace();
                throw new RuntimeException("Failed to get users by role: " + e.getMessage(), e);
            }
        }

        return users;
    }

    private List<User> getUsersByRoleColumn(String role) throws SQLException {
        List<User> users = new ArrayList<>();
        String query = "SELECT * FROM users WHERE role = ? ORDER BY id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, role);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(extractUserFromResultSet(rs));
                }
                System.out.println("getUsersByRoleColumn: Retrieved " + users.size() + " users with role " + role);
            }
        }

        return users;
    }

    private List<User> getUsersByIsAdmin(boolean isAdmin) throws SQLException {
        List<User> users = new ArrayList<>();
        String query = "SELECT * FROM users WHERE is_admin = ? ORDER BY id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setBoolean(1, isAdmin);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(extractUserFromResultSet(rs));
                }
                System.out.println("getUsersByIsAdmin: Retrieved " + users.size() + " users with is_admin = " + isAdmin);
            }
        }

        return users;
    }

    public User authenticate(String email, String password) {
        try {
            User user = getUserByEmail(email);
            if (user == null) {
                System.out.println("Authentication failed: No user found for email " + email);
                return null;
            }
            if (PasswordHasher.checkPassword(password, user.getPassword())) {
                System.out.println("Authentication successful for email " + email + ", Role: " + user.getRole());
                return user;
            } else {
                System.out.println("Authentication failed: Incorrect password for email " + email);
                return null;
            }
        } catch (Exception e) {
            System.err.println("Authentication error for email " + email + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Authentication failed: " + e.getMessage(), e);
        }
    }

    public int getUserCount() {
        String query = "SELECT COUNT(*) FROM users";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("getUserCount: " + count + " users found");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in getUserCount: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get user count: " + e.getMessage(), e);
        }

        return 0;
    }

    /**
     * Get total customer count for dashboard
     * @return Total number of customers (non-admin users)
     */
    public int getTotalCustomerCount() {
        String query = "SELECT COUNT(*) FROM users WHERE is_admin = FALSE";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("getTotalCustomerCount: " + count + " customers found");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in getTotalCustomerCount: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get customer count: " + e.getMessage(), e);
        }

        return 0;
    }

    /**
     * Get recent customers for dashboard
     * @param limit Number of customers to return
     * @return List of recent customers (non-admin users)
     */
    public List<User> getRecentCustomers(int limit) {
        List<User> customers = new ArrayList<>();
        String query = "SELECT * FROM users WHERE is_admin = FALSE ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    customers.add(extractUserFromResultSet(rs));
                }
                System.out.println("getRecentCustomers: Retrieved " + customers.size() + " recent customers");
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in getRecentCustomers: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get recent customers: " + e.getMessage(), e);
        }

        return customers;
    }

    public List<User> getRecentUsers(int limit) {
        List<User> users = new ArrayList<>();
        String query = "SELECT * FROM users ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(extractUserFromResultSet(rs));
                }
                System.out.println("getRecentUsers: Retrieved " + users.size() + " recent users");
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in getRecentUsers: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get recent users: " + e.getMessage(), e);
        }

        return users;
    }

    public boolean emailExists(String email) {
        String query = "SELECT COUNT(*) FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    boolean exists = rs.getInt(1) > 0;
                    System.out.println("emailExists: Email " + email + " exists: " + exists);
                    return exists;
                }
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in emailExists for email " + email + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to check email existence: " + e.getMessage(), e);
        }

        return false;
    }

    /**
     * Check if a username exists in the database
     * Note: In the current schema, we're using email as the username
     * The system uses email addresses for user identification
     *
     * @param username Username to check
     * @return true if username exists, false otherwise
     */
    public boolean usernameExists(String username) {
        // Currently using email as username
        return emailExists(username);
    }

    /**
     * Check if a first name already exists in the database
     *
     * @param firstName First name to check
     * @return true if the first name exists, false otherwise
     */
    public boolean firstNameExists(String firstName) {
        String query = "SELECT COUNT(*) FROM users WHERE first_name = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, firstName);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    boolean exists = rs.getInt(1) > 0;
                    System.out.println("firstNameExists: First name '" + firstName + "' exists: " + exists);
                    return exists;
                }
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in firstNameExists for name '" + firstName + "': " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to check first name existence: " + e.getMessage(), e);
        }

        return false;
    }

    /**
     * Check if a phone number already exists in the database
     *
     * @param phone Phone number to check
     * @return true if the phone number exists, false otherwise
     */
    public boolean phoneExists(String phone) {
        // If phone is null or empty, return false
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }

        String query = "SELECT COUNT(*) FROM users WHERE phone = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, phone);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    boolean exists = rs.getInt(1) > 0;
                    System.out.println("phoneExists: Phone number '" + phone + "' exists: " + exists);
                    return exists;
                }
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in phoneExists for phone '" + phone + "': " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to check phone existence: " + e.getMessage(), e);
        }

        return false;
    }

    public boolean validatePassword(int userId, String password) {
        String query = "SELECT password FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password");
                    return PasswordHasher.checkPassword(password, storedPassword);
                }
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in validatePassword for userId " + userId + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to validate password: " + e.getMessage(), e);
        }

        return false;
    }

    public boolean updateProfileImage(int userId, String profileImagePath) {
        String query = "UPDATE users SET profile_image = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, profileImagePath);
            stmt.setInt(2, userId);

            int rowsAffected = stmt.executeUpdate();
            System.out.println("updateProfileImage: " + rowsAffected + " rows affected for userId " + userId);
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("SQL Error in updateProfileImage for userId " + userId + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to update profile image: " + e.getMessage(), e);
        }
    }

    /**
     * Deactivate a user account
     * Since we don't have a 'status' column in the users table, we'll use the delete method
     * In a real application, you would typically set a status flag rather than deleting the user
     *
     * @param userId The ID of the user to deactivate
     * @return true if the user was successfully deactivated, false otherwise
     */
    public boolean deactivateUser(int userId) {
        // For now, we'll just delete the user
        return deleteUser(userId);
    }

    public boolean updateUserAddress(int userId, String address) {
        // Since address is not in the users table, we'll store it in the shipping table
        // First check if there's an order for this user
        String checkOrderQuery = "SELECT id FROM orders WHERE user_id = ? LIMIT 1";
        String updateShippingQuery = "UPDATE shipping SET shipping_address = ? WHERE order_id = ?";
        String insertShippingQuery = "INSERT INTO shipping (shipping_address, order_id) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            // Check if user has an order
            int orderId = -1;
            try (PreparedStatement checkStmt = conn.prepareStatement(checkOrderQuery)) {
                checkStmt.setInt(1, userId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        orderId = rs.getInt("id");
                    }
                }
            }

            if (orderId > 0) {
                // Check if shipping record exists
                String checkShippingQuery = "SELECT id FROM shipping WHERE order_id = ?";
                boolean shippingExists = false;

                try (PreparedStatement checkShippingStmt = conn.prepareStatement(checkShippingQuery)) {
                    checkShippingStmt.setInt(1, orderId);
                    try (ResultSet rs = checkShippingStmt.executeQuery()) {
                        shippingExists = rs.next();
                    }
                }

                if (shippingExists) {
                    // Update existing shipping record
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateShippingQuery)) {
                        updateStmt.setString(1, address);
                        updateStmt.setInt(2, orderId);
                        int rowsAffected = updateStmt.executeUpdate();
                        return rowsAffected > 0;
                    }
                } else {
                    // Insert new shipping record
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertShippingQuery)) {
                        insertStmt.setString(1, address);
                        insertStmt.setInt(2, orderId);
                        int rowsAffected = insertStmt.executeUpdate();
                        return rowsAffected > 0;
                    }
                }
            }

            // If no order exists, we can't store the address in the shipping table
            // This is a limitation of the current database schema
            return false;

        } catch (SQLException e) {
            System.err.println("SQL Error in updateUserAddress for userId " + userId + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to update user address: " + e.getMessage(), e);
        }
    }

    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setPhone(rs.getString("phone"));

        // Get role from the result set
        String role = rs.getString("role");
        user.setRole(role != null ? role : "user");

        // Also check is_admin for consistency
        boolean isAdmin = rs.getBoolean("is_admin");
        user.setAdmin(isAdmin);

        // Ensure role and isAdmin are consistent
        if (isAdmin && (role == null || !role.equalsIgnoreCase("admin"))) {
            user.setRole("admin");
        }

        user.setProfileImage(rs.getString("profile_image"));

        // Try to get address from shipping table if available
        try {
            // Check if the shipping_address column exists in the result set
            rs.findColumn("shipping_address");
            user.setAddress(rs.getString("shipping_address"));
        } catch (SQLException e) {
            // If shipping_address column doesn't exist, set address to null
            user.setAddress(null);
        }

        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }

    // Method getTotalCustomerCount() is already defined above at line 435

    // Method getRecentCustomers(int limit) is already defined above at line 462
}