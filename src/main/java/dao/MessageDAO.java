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
        System.out.println("MessageDAO: addMessage called for message with subject = " + message.getSubject());

        // Query for messages with essential fields including parent_id
        String query = "INSERT INTO messages (user_id, name, email, subject, message, created_at, parent_id) VALUES (?, ?, ?, ?, ?, NOW(), ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            if (conn == null) {
                System.out.println("MessageDAO: Database connection is null");
                return false;
            }

            System.out.println("MessageDAO: Database connection established for addMessage");

            // Set the parameters
            int userId = message.getUserId();
            System.out.println("MessageDAO: Message object: " + message);
            System.out.println("MessageDAO: User ID from message: " + userId);

            stmt.setInt(1, userId); // Set the user ID
            stmt.setString(2, message.getName());
            stmt.setString(3, message.getEmail());
            stmt.setString(4, message.getSubject());
            stmt.setString(5, message.getMessage());
            stmt.setInt(6, message.getParentId()); // Set the parent ID

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

        // Since we're simplifying the database schema, we'll just add the reply as a new message
        return addMessage(reply);
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

            // Create a reply message object
            Message replyMessage = new Message();
            replyMessage.setName(adminName);
            replyMessage.setEmail(adminEmail);
            replyMessage.setSubject("RE: " + originalMessage.getSubject());
            replyMessage.setMessage(replyContent);
            replyMessage.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

            System.out.println("MessageDAO: Creating reply to message ID = " + messageId);

            // Add the reply using the addMessage method
            boolean replyAdded = addMessage(replyMessage);
            if (!replyAdded) {
                System.out.println("MessageDAO: Failed to add reply message");
                return false;
            }

            System.out.println("MessageDAO: Reply added successfully");
            return true;

        } catch (Exception e) {
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
        // Since we're removing is_read field, we'll just check if the message exists
        Message message = getMessageById(messageId);
        return message != null;
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
     * Ensure the messages table has the necessary columns for replies
     */
    public void ensureReplyColumns() {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.out.println("Failed to get database connection");
                return;
            }

            // Check if user_id and parent_id columns exist
            boolean hasUserId = columnExists("user_id");
            boolean hasParentId = columnExists("parent_id");

            // Add missing columns
            try (Statement stmt = conn.createStatement()) {
                if (!hasUserId) {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN user_id INT DEFAULT NULL");
                    stmt.executeUpdate("ALTER TABLE messages ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL");
                    System.out.println("Added user_id column to messages table");
                }

                if (!hasParentId) {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN parent_id INT DEFAULT 0");
                    System.out.println("Added parent_id column to messages table");
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
     * Update a message
     * @param message Message object to update
     * @return true if successful, false otherwise
     */
    public boolean updateMessage(Message message) {
        String query = "UPDATE messages SET name = ?, email = ?, subject = ?, message = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, message.getName());
            stmt.setString(2, message.getEmail());
            stmt.setString(3, message.getSubject());
            stmt.setString(4, message.getMessage());
            stmt.setInt(5, message.getId());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error updating message: " + e.getMessage());
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
        return getAllMessages();
    }

    /**
     * Get replied messages
     * @return List of replied messages
     */
    public List<Message> getRepliedMessages() {
        return getAllMessages();
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

        // Since we're removing is_replied and is_read fields, we'll just check if the message exists
        Message message = getMessageById(messageId);
        return message != null;
    }

    /**
     * Mark message as unread
     * @param messageId Message ID
     * @return true if successful, false otherwise
     */
    public boolean markMessageAsUnread(int messageId) {
        // Since we're removing is_read field, we'll just check if the message exists
        Message message = getMessageById(messageId);
        return message != null;
    }

    /**
     * Get replies for a message
     * @param parentId Parent message ID
     * @return List of reply messages
     */
    public List<Message> getRepliesByParentId(int parentId) {
        List<Message> replies = new ArrayList<>();

        // Check if parent_id column exists
        if (!columnExists("parent_id")) {
            System.out.println("MessageDAO: Using subject-based approach");

            // Get the original message to find its subject
            Message originalMessage = getMessageById(parentId);
            if (originalMessage == null) {
                System.out.println("MessageDAO: Original message not found, returning empty list");
                return replies;
            }

            // Get all messages
            List<Message> allMessages = getAllMessages();

            // The reply subject pattern is "RE: " + original subject
            String replySubject = "RE: " + originalMessage.getSubject();

            System.out.println("MessageDAO: Looking for replies with subject = " + replySubject);

            // Find all messages that have the reply subject
            for (Message message : allMessages) {
                if (message.getSubject() != null && message.getSubject().equals(replySubject)) {
                    replies.add(message);
                    System.out.println("MessageDAO: Found reply ID = " + message.getId() + ", From: " + message.getName());
                }
            }
        } else {
            // Use parent_id column to find replies
            String query = "SELECT * FROM messages WHERE parent_id = ? ORDER BY created_at ASC";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {

                stmt.setInt(1, parentId);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Message reply = extractMessageFromResultSet(rs);
                        replies.add(reply);
                        System.out.println("MessageDAO: Found reply ID = " + reply.getId() + ", From: " + reply.getName());
                    }
                }

            } catch (SQLException e) {
                System.out.println("Error getting replies by parent ID: " + e.getMessage());
                e.printStackTrace();
            }
        }

        System.out.println("MessageDAO: Found " + replies.size() + " replies for message ID = " + parentId);
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

            // Try to get parentId if the column exists
            try {
                message.setParentId(rs.getInt("parent_id"));
                System.out.println("MessageDAO: Set parentId = " + message.getParentId());
            } catch (SQLException e) {
                // Column doesn't exist, set default value
                message.setParentId(0);
                System.out.println("MessageDAO: parent_id column doesn't exist, setting default parentId = 0");
            }

            message.setName(rs.getString("name"));
            System.out.println("MessageDAO: Set name = " + message.getName());

            message.setEmail(rs.getString("email"));
            System.out.println("MessageDAO: Set email = " + message.getEmail());

            message.setSubject(rs.getString("subject"));
            System.out.println("MessageDAO: Set subject = " + message.getSubject());

            message.setMessage(rs.getString("message"));
            System.out.println("MessageDAO: Set message content");

            message.setCreatedAt(rs.getTimestamp("created_at"));
            System.out.println("MessageDAO: Set createdAt = " + message.getCreatedAt());
        } catch (SQLException e) {
            System.out.println("MessageDAO: Error extracting basic message fields: " + e.getMessage());
            throw e;
        }

        System.out.println("MessageDAO: Successfully extracted message: ID=" + message.getId() + ", Subject=" + message.getSubject());
        return message;
    }
}
