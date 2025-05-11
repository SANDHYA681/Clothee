package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Message;
import util.DBConnection;

/**
 * Message Data Access Object
 */
public class MessageDAO {

    /**
     * Add a new message to the database
     * @param message Message object to add
     * @return true if successful, false otherwise
     */
    public boolean addMessage(Message message) {
        // Ensure required columns exist
        ensureReplyColumns();

        System.out.println("MessageDAO: addMessage called for message with subject = " + message.getSubject());

        // Check if this is a reply message
        if (message.isReply() && message.getParentId() > 0) {
            // Use a query that includes reply-specific fields and user_id
            String query = "INSERT INTO messages (user_id, name, email, subject, message, is_read, created_at, parent_id, is_reply) VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?)";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

                if (conn == null) {
                    System.out.println("MessageDAO: Database connection is null");
                    return false;
                }

                System.out.println("MessageDAO: Database connection established for adding reply");

                // Set the parameters
                stmt.setInt(1, message.getUserId()); // Set the user ID
                stmt.setString(2, message.getName());
                stmt.setString(3, message.getEmail());
                stmt.setString(4, message.getSubject());
                stmt.setString(5, message.getMessage());
                stmt.setBoolean(6, message.isRead());
                stmt.setInt(7, message.getParentId());
                stmt.setBoolean(8, true); // This is a reply

                // Execute the query
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    try (ResultSet rs = stmt.getGeneratedKeys()) {
                        if (rs.next()) {
                            int generatedId = rs.getInt(1);
                            message.setId(generatedId);
                            System.out.println("MessageDAO: Reply added successfully with ID = " + generatedId);

                            // Mark the original message as replied
                            markMessageAsReplied(message.getParentId());
                            return true;
                        }
                    }
                }

                System.out.println("MessageDAO: Failed to add reply");
                return false;

            } catch (SQLException e) {
                System.out.println("Error adding reply: " + e.getMessage());
                e.printStackTrace();
                return false;
            }
        }

        // For regular messages, include user_id in the query
        String query = "INSERT INTO messages (user_id, name, email, subject, message, is_read, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            if (conn == null) {
                System.out.println("MessageDAO: Database connection is null");
                return false;
            }

            System.out.println("MessageDAO: Database connection established for addMessage");

            // Set the basic parameters
            int userId = message.getUserId();
            System.out.println("MessageDAO: Message object: " + message);
            System.out.println("MessageDAO: User ID from message: " + userId);

            stmt.setInt(1, userId); // Set the user ID
            stmt.setString(2, message.getName());
            stmt.setString(3, message.getEmail());
            stmt.setString(4, message.getSubject());
            stmt.setString(5, message.getMessage());
            stmt.setBoolean(6, false); // New messages are unread

            // Execute the query
            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedId = rs.getInt(1);
                        message.setId(generatedId);
                        System.out.println("MessageDAO: Message added successfully with ID = " + generatedId);
                        return true;
                    }
                }
            }

            System.out.println("MessageDAO: Failed to add message");
            return false;

        } catch (SQLException e) {
            System.out.println("Error adding message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Add a reply to a message
     * @param reply Reply message
     * @return true if successful, false otherwise
     */
    public boolean addReply(Message reply) {
        System.out.println("MessageDAO: addReply called for parentId = " + reply.getParentId());

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.out.println("MessageDAO: Database connection is null");
                return false;
            }

            // Start transaction
            conn.setAutoCommit(false);

            try {
                // 1. First add the reply as a new message
                System.out.println("MessageDAO: Adding reply as a new message");
                boolean added = addMessage(reply);

                if (!added) {
                    System.out.println("MessageDAO: Failed to add reply as a new message");
                    conn.rollback();
                    return false;
                }

                System.out.println("MessageDAO: Reply added as a new message with ID = " + reply.getId());

                // 2. Mark the original message as both read and replied
                System.out.println("MessageDAO: Marking original message as read and replied");
                String updateQuery = "UPDATE messages SET is_read = TRUE, read_at = NOW(), is_replied = TRUE WHERE id = ?";

                try (PreparedStatement stmt = conn.prepareStatement(updateQuery)) {
                    stmt.setInt(1, reply.getParentId());
                    int rowsAffected = stmt.executeUpdate();

                    if (rowsAffected <= 0) {
                        System.out.println("MessageDAO: Failed to mark original message as read and replied");
                        conn.rollback();
                        return false;
                    }
                }

                // Commit the transaction
                conn.commit();
                System.out.println("MessageDAO: Original message marked as read and replied successfully");
                return true;

            } catch (SQLException e) {
                conn.rollback();
                System.out.println("MessageDAO: SQL error in addReply: " + e.getMessage());
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            System.out.println("MessageDAO: Error in addReply: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Direct method to reply to a message - simpler implementation
     * @param messageId Original message ID
     * @param adminName Admin name
     * @param adminEmail Admin email
     * @param replyContent Reply content
     * @return true if successful, false otherwise
     */
    public boolean directReply(int messageId, String adminName, String adminEmail, String replyContent) {
        System.out.println("MessageDAO: directReply called for messageId = " + messageId);
        System.out.println("MessageDAO: adminName = " + adminName);
        System.out.println("MessageDAO: adminEmail = " + adminEmail);
        System.out.println("MessageDAO: replyContent = " + replyContent);

        // Ensure the messages table has the necessary columns
        ensureReplyColumns();

        try {
            // Get the original message
            Message originalMessage = getMessageById(messageId);
            if (originalMessage == null) {
                System.out.println("MessageDAO: Original message not found with ID = " + messageId);
                return false;
            }

            System.out.println("MessageDAO: Original message found: ID = " + originalMessage.getId() + ", Subject = " + originalMessage.getSubject());

            // Create a connection for transaction
            Connection conn = DBConnection.getConnection();
            if (conn == null) {
                System.out.println("MessageDAO: Failed to get database connection");
                return false;
            }

            System.out.println("MessageDAO: Database connection established for transaction");

            // Disable auto-commit for transaction
            conn.setAutoCommit(false);
            System.out.println("MessageDAO: Auto-commit disabled for transaction");

            try {
                // 1. Always mark the original message as read AND replied
                String readAndReplyQuery = "UPDATE messages SET is_read = TRUE, read_at = NOW(), is_replied = TRUE WHERE id = ?";
                try (PreparedStatement readReplyStmt = conn.prepareStatement(readAndReplyQuery)) {
                    readReplyStmt.setInt(1, messageId);
                    int updateResult = readReplyStmt.executeUpdate();

                    if (updateResult <= 0) {
                        System.out.println("MessageDAO: Failed to mark message as read and replied");
                        conn.rollback();
                        return false;
                    }
                    System.out.println("MessageDAO: Original message marked as read and replied");
                }

                // 2. Create a reply message object
                Message replyMessage = new Message();
                replyMessage.setName(adminName);
                replyMessage.setEmail(adminEmail);
                replyMessage.setSubject("RE: " + originalMessage.getSubject());
                replyMessage.setMessage(replyContent);
                replyMessage.setRead(true); // Admin's reply is already read
                replyMessage.setParentId(messageId); // Set parent ID
                replyMessage.setReply(true); // Mark as a reply
                replyMessage.setReplied(false); // This reply hasn't been replied to

                System.out.println("MessageDAO: Creating reply with parent_id = " + messageId + ", is_reply = true");

                // 3. Add the reply using the addMessage method
                boolean replyAdded = addMessage(replyMessage);
                if (!replyAdded) {
                    System.out.println("MessageDAO: Failed to add reply message");
                    conn.rollback();
                    return false;
                }

                int replyId = replyMessage.getId();
                System.out.println("MessageDAO: Reply added with ID = " + replyId + ", parent_id = " + messageId + ", is_reply = true");

                // Commit the transaction
                conn.commit();
                System.out.println("MessageDAO: Reply added successfully via direct method");
                return true;

            } catch (SQLException e) {
                System.out.println("MessageDAO: SQL error in directReply: " + e.getMessage());
                e.printStackTrace();
                conn.rollback();
                return false;
            } finally {
                // Restore auto-commit
                conn.setAutoCommit(true);
                conn.close();
            }

        } catch (SQLException e) {
            System.out.println("MessageDAO: Error in directReply: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Mark message as read
     * @param messageId Message ID
     * @return true if successful, false otherwise
     */
    public boolean markMessageAsRead(int messageId) {
        String query = "UPDATE messages SET is_read = TRUE, read_at = NOW() WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, messageId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error marking message as read: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if a column exists in the messages table
     * @param columnName Column name to check
     * @return true if column exists, false otherwise
     */
    private boolean columnExists(String columnName) {
        String query = "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                      "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'messages' AND COLUMN_NAME = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, columnName);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            System.out.println("Error checking if column exists: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Ensure the messages table has the necessary columns for replies and user_id
     */
    public void ensureReplyColumns() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.out.println("Failed to get database connection");
                return;
            }

            // Check if columns exist
            boolean hasParentId = columnExists("parent_id");
            boolean hasIsReply = columnExists("is_reply");
            boolean hasIsReplied = columnExists("is_replied");
            boolean hasReadAt = columnExists("read_at");
            boolean hasUserId = columnExists("user_id");

            // Add missing columns
            try (Statement stmt = conn.createStatement()) {
                if (!hasParentId) {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN parent_id INT DEFAULT NULL");
                }

                if (!hasIsReply) {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN is_reply BOOLEAN DEFAULT FALSE");
                }

                if (!hasIsReplied) {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN is_replied BOOLEAN DEFAULT FALSE");
                }

                if (!hasReadAt) {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN read_at TIMESTAMP NULL");
                }

                if (!hasUserId) {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN user_id INT DEFAULT NULL");
                    stmt.executeUpdate("ALTER TABLE messages ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL");
                }
            }

        } catch (SQLException e) {
            System.out.println("Error ensuring reply columns: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Delete a message
     * @param messageId Message ID to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteMessage(int messageId) {
        String query = "DELETE FROM messages WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, messageId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error deleting message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get message by ID
     * @param messageId Message ID
     * @return Message object if found, null otherwise
     */
    public Message getMessageById(int messageId) {
        System.out.println("MessageDAO: getMessageById called with messageId = " + messageId);
        String query = "SELECT * FROM messages WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            if (conn == null) {
                System.out.println("MessageDAO: Database connection is null");
                return null;
            }

            System.out.println("MessageDAO: Database connection established");

            stmt.setInt(1, messageId);
            System.out.println("MessageDAO: Executing query: " + query + " with messageId = " + messageId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("MessageDAO: Message found in database");
                    Message message = extractMessageFromResultSet(rs);
                    System.out.println("MessageDAO: Message extracted: ID=" + message.getId() + ", Subject=" + message.getSubject());
                    return message;
                } else {
                    System.out.println("MessageDAO: No message found with ID = " + messageId);
                }
            }

        } catch (SQLException e) {
            System.out.println("MessageDAO: Error getting message by ID: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.out.println("MessageDAO: Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("MessageDAO: Returning null for messageId = " + messageId);
        return null;
    }

    /**
     * Get all messages
     * @return List of all messages
     */
    public List<Message> getAllMessages() {
        List<Message> messages = new ArrayList<>();
        String query = "SELECT * FROM messages ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                messages.add(extractMessageFromResultSet(rs));
            }

        } catch (SQLException e) {
            System.out.println("Error getting all messages: " + e.getMessage());
            e.printStackTrace();
        }

        return messages;
    }

    /**
     * Get unread messages
     * @return List of unread messages
     */
    public List<Message> getUnreadMessages() {
        List<Message> messages = new ArrayList<>();
        String query = "SELECT * FROM messages WHERE is_read = FALSE AND is_reply = FALSE ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                messages.add(extractMessageFromResultSet(rs));
            }

        } catch (SQLException e) {
            System.out.println("Error getting unread messages: " + e.getMessage());
            e.printStackTrace();
        }

        return messages;
    }

    /**
     * Get replied messages
     * @return List of replied messages
     */
    public List<Message> getRepliedMessages() {
        List<Message> messages = new ArrayList<>();
        String query = "SELECT * FROM messages WHERE is_replied = TRUE ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                messages.add(extractMessageFromResultSet(rs));
            }

        } catch (SQLException e) {
            System.out.println("Error getting replied messages: " + e.getMessage());
            e.printStackTrace();
        }

        return messages;
    }

    /**
     * Get recent messages
     * @param limit Number of messages to return
     * @return List of recent messages
     */
    public List<Message> getRecentMessages(int limit) {
        List<Message> messages = new ArrayList<>();
        String query = "SELECT * FROM messages ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    messages.add(extractMessageFromResultSet(rs));
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting recent messages: " + e.getMessage());
            e.printStackTrace();
        }

        return messages;
    }

    /**
     * Get unread message count
     * @return Number of unread messages
     */
    public int getUnreadMessageCount() {
        String query = "SELECT COUNT(*) FROM messages WHERE is_read = FALSE";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("Error getting unread message count: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get messages by user ID
     * @param userId User ID
     * @return List of messages from user
     */
    public List<Message> getMessagesByUserId(int userId) {
        List<Message> messages = new ArrayList<>();

        // Check if user_id column exists
        if (!columnExists("user_id")) {
            System.out.println("MessageDAO: user_id column doesn't exist, returning all messages");
            return getAllMessages();
        }

        String query = "SELECT * FROM messages WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    messages.add(extractMessageFromResultSet(rs));
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting messages by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return messages;
    }

    /**
     * Mark message as replied and read
     * @param messageId Message ID
     * @return true if successful, false otherwise
     */
    public boolean markMessageAsReplied(int messageId) {
        System.out.println("MessageDAO: markMessageAsReplied called for messageId = " + messageId);
        String query = "UPDATE messages SET is_replied = TRUE, is_read = TRUE, read_at = NOW() WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            if (conn == null) {
                System.out.println("MessageDAO: Database connection is null");
                return false;
            }

            System.out.println("MessageDAO: Database connection established");

            stmt.setInt(1, messageId);
            System.out.println("MessageDAO: Executing query: " + query + " with messageId = " + messageId);

            int rowsAffected = stmt.executeUpdate();
            System.out.println("MessageDAO: Query executed, rowsAffected = " + rowsAffected);

            if (rowsAffected > 0) {
                System.out.println("MessageDAO: Message marked as replied and read successfully");
                return true;
            } else {
                System.out.println("MessageDAO: No rows affected, message not found or already replied");
                return false;
            }

        } catch (SQLException e) {
            System.out.println("MessageDAO: Error marking message as replied: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.out.println("MessageDAO: Unexpected error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Mark message as unread
     * @param messageId Message ID
     * @return true if successful, false otherwise
     */
    public boolean markMessageAsUnread(int messageId) {
        String query = "UPDATE messages SET is_read = FALSE, read_at = NULL WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, messageId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error marking message as unread: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get replies for a message
     * @param parentId Parent message ID
     * @return List of reply messages
     */
    public List<Message> getRepliesByParentId(int parentId) {
        List<Message> replies = new ArrayList<>();

        // First, check if the parent_id column exists
        if (!columnExists("parent_id")) {
            System.out.println("MessageDAO: parent_id column doesn't exist in messages table");
            return replies;
        }

        // Ensure the necessary columns exist
        ensureReplyColumns();

        // Use a query that filters by parent_id and is_reply to ensure we get only actual replies
        String query = "SELECT * FROM messages WHERE parent_id = ? AND is_reply = TRUE ORDER BY created_at ASC";

        System.out.println("MessageDAO: Getting replies for parent ID = " + parentId);
        System.out.println("MessageDAO: Using query: " + query);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            if (conn == null) {
                System.out.println("MessageDAO: Database connection is null");
                return replies;
            }

            stmt.setInt(1, parentId);

            try (ResultSet rs = stmt.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    count++;
                    Message reply = extractMessageFromResultSet(rs);

                    // Double-check that this is actually a reply to the parent message
                    if (reply.getParentId() == parentId) {
                        replies.add(reply);
                        System.out.println("MessageDAO: Found reply ID = " + reply.getId() + ", From: " + reply.getName() + ", is_reply = " + reply.isReply());
                    } else {
                        System.out.println("MessageDAO: Warning - Found message with parent_id = " + reply.getParentId() + " but expected " + parentId);
                    }
                }
                System.out.println("MessageDAO: Found " + count + " replies for parent ID = " + parentId);
            }

        } catch (SQLException e) {
            System.out.println("Error getting replies: " + e.getMessage());
            e.printStackTrace();
        }

        return replies;
    }

    /**
     * Extract message from result set
     * @param rs Result set
     * @return Message object
     * @throws SQLException if error occurs
     */
    private Message extractMessageFromResultSet(ResultSet rs) throws SQLException {
        System.out.println("MessageDAO: extractMessageFromResultSet called");
        Message message = new Message();

        try {
            message.setId(rs.getInt("id"));
            System.out.println("MessageDAO: Set message ID = " + message.getId());

            // Try to get userId if the column exists
            try {
                message.setUserId(rs.getInt("user_id"));
                System.out.println("MessageDAO: Set userId = " + message.getUserId());
            } catch (SQLException e) {
                // Column doesn't exist, set default value
                message.setUserId(0);
                System.out.println("MessageDAO: user_id column doesn't exist, setting default userId = 0");
            }

            message.setName(rs.getString("name"));
            System.out.println("MessageDAO: Set name = " + message.getName());

            message.setEmail(rs.getString("email"));
            System.out.println("MessageDAO: Set email = " + message.getEmail());

            message.setSubject(rs.getString("subject"));
            System.out.println("MessageDAO: Set subject = " + message.getSubject());

            message.setMessage(rs.getString("message"));
            System.out.println("MessageDAO: Set message content");

            message.setRead(rs.getBoolean("is_read"));
            System.out.println("MessageDAO: Set isRead = " + message.isRead());

            message.setCreatedAt(rs.getTimestamp("created_at"));
            System.out.println("MessageDAO: Set createdAt = " + message.getCreatedAt());
        } catch (SQLException e) {
            System.out.println("MessageDAO: Error extracting basic message fields: " + e.getMessage());
            throw e;
        }

        // Check if read_at column exists
        try {
            message.setReadAt(rs.getTimestamp("read_at"));
            System.out.println("MessageDAO: Set readAt = " + message.getReadAt());
        } catch (SQLException e) {
            System.out.println("MessageDAO: read_at column doesn't exist, ignoring");
            // Column doesn't exist, ignore
        }

        // Check if reply-related columns exist
        try {
            message.setParentId(rs.getInt("parent_id"));
            System.out.println("MessageDAO: Set parentId = " + message.getParentId());

            message.setReply(rs.getBoolean("is_reply"));
            System.out.println("MessageDAO: Set isReply = " + message.isReply());

            message.setReplied(rs.getBoolean("is_replied"));
            System.out.println("MessageDAO: Set isReplied = " + message.isReplied());
        } catch (SQLException e) {
            System.out.println("MessageDAO: Reply-related columns don't exist, setting defaults: " + e.getMessage());
            // Columns don't exist, set defaults
            message.setParentId(0);
            message.setReply(false);
            message.setReplied(false);
        }

        System.out.println("MessageDAO: Successfully extracted message: ID=" + message.getId() + ", Subject=" + message.getSubject());
        return message;
    }
}
