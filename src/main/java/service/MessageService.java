package service;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import dao.MessageDAO;
import model.Message;

/**
 * Service class for message-related operations
 */
public class MessageService {
    private MessageDAO messageDAO;

    /**
     * Constructor
     */
    public MessageService() {
        this.messageDAO = new MessageDAO();
    }

    /**
     * Add a new message
     * @param name Sender name
     * @param email Sender email
     * @param subject Message subject
     * @param messageContent Message content
     * @return true if addition successful, false otherwise
     */
    public boolean addMessage(String name, String email, String subject, String messageContent) {
        // Create a simple message with only the essential fields
        Message message = new Message();
        message.setName(name);
        message.setEmail(email);
        message.setSubject(subject);
        message.setMessage(messageContent);
        message.setRead(false);
        message.setCreatedAt(new Timestamp(new Date().getTime()));

        // Add the message to the database
        return messageDAO.addMessage(message);
    }

    /**
     * Save message
     * @param message Message to save
     * @return true if successful, false otherwise
     */
    public boolean saveMessage(Message message) {
        System.out.println("MessageService: saveMessage called");

        try {
            // Set created at if not set
            if (message.getCreatedAt() == null) {
                message.setCreatedAt(new Timestamp(new Date().getTime()));
                System.out.println("MessageService: Set createdAt to current time");
            }

            // Set read status if not set
            if (!message.isRead()) {
                message.setRead(false);
                System.out.println("MessageService: Set isRead to false");
            }

            // Initialize other fields if not set
            if (message.getParentId() <= 0) {
                message.setParentId(0);
                System.out.println("MessageService: Set parentId to 0");
            }

            if (!message.isReply()) {
                message.setReply(false);
                System.out.println("MessageService: Set isReply to false");
            }

            if (!message.isReplied()) {
                message.setReplied(false);
                System.out.println("MessageService: Set isReplied to false");
            }

            System.out.println("MessageService: Calling messageDAO.addMessage");
            boolean result = messageDAO.addMessage(message);
            System.out.println("MessageService: messageDAO.addMessage returned " + result);
            return result;
        } catch (Exception e) {
            System.out.println("MessageService: Exception in saveMessage: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Mark message as read
     * @param messageId Message ID
     * @return true if update successful, false otherwise
     */
    public boolean markMessageAsRead(int messageId) {
        return messageDAO.markMessageAsRead(messageId);
    }

    /**
     * Delete a message
     * @param messageId Message ID
     * @return true if deletion successful, false otherwise
     */
    public boolean deleteMessage(int messageId) {
        return messageDAO.deleteMessage(messageId);
    }

    /**
     * Get message by ID
     * @param messageId Message ID
     * @return Message object if found, null otherwise
     */
    public Message getMessageById(int messageId) {
        return messageDAO.getMessageById(messageId);
    }

    /**
     * Get all messages
     * @return List of all messages
     */
    public List<Message> getAllMessages() {
        return messageDAO.getAllMessages();
    }

    /**
     * Get unread messages
     * @return List of unread messages
     */
    public List<Message> getUnreadMessages() {
        return messageDAO.getUnreadMessages();
    }

    /**
     * Get recent messages
     * @param limit Number of messages to return
     * @return List of recent messages
     */
    public List<Message> getRecentMessages(int limit) {
        return messageDAO.getRecentMessages(limit);
    }

    /**
     * Get unread message count
     * @return Number of unread messages
     */
    public int getUnreadMessageCount() {
        return messageDAO.getUnreadMessageCount();
    }

    /**
     * Get messages by user ID
     * @param userId User ID
     * @return List of messages from user
     */
    public List<Message> getMessagesByUserId(int userId) {
        return messageDAO.getMessagesByUserId(userId);
    }

    /**
     * Reply to a message
     * @param messageId Message ID to reply to
     * @param replyContent Reply content
     * @param adminName Admin name
     * @param adminEmail Admin email
     * @param adminId Admin user ID (optional)
     * @return true if successful, false otherwise
     */
    public boolean replyToMessage(int messageId, String replyContent, String adminName, String adminEmail, int adminId) {
        System.out.println("MessageService: replyToMessage called for messageId = " + messageId);

        // Get the original message
        Message message = messageDAO.getMessageById(messageId);
        if (message == null) {
            System.out.println("MessageService: Original message not found");
            return false;
        }

        System.out.println("MessageService: Original message found: " + message.getSubject());

        // Create a reply message
        Message reply = new Message();
        reply.setName(adminName);
        reply.setEmail(adminEmail);
        reply.setSubject("RE: " + message.getSubject());
        reply.setMessage(replyContent);
        reply.setRead(true); // Admin's reply is already read
        reply.setCreatedAt(new Timestamp(new Date().getTime()));
        reply.setParentId(messageId);
        reply.setReply(true);

        // Set the user ID to the admin's user ID - this is crucial for the SQL query to work
        reply.setUserId(adminId);
        System.out.println("MessageService: Setting admin user ID to " + adminId);

        System.out.println("MessageService: Adding reply to database");

        // Add the reply to the database
        boolean success = messageDAO.addMessage(reply);

        if (success) {
            System.out.println("MessageService: Reply added successfully");
            // Mark the original message as replied
            messageDAO.markMessageAsReplied(messageId);
            return true;
        }

        System.out.println("MessageService: Failed to add reply");
        return false;
    }

    /**
     * Reply to a message (legacy method for backward compatibility)
     * @param messageId Message ID to reply to
     * @param replyContent Reply content
     * @return true if successful, false otherwise
     */
    public boolean replyToMessage(int messageId, String replyContent) {
        // Use default admin name and email
        return replyToMessage(messageId, replyContent, "Admin", "admin@clothee.com", 1);
    }

    /**
     * Reply to a message (legacy method for backward compatibility)
     * @param messageId Message ID to reply to
     * @param replyContent Reply content
     * @param adminName Admin name
     * @param adminEmail Admin email
     * @return true if successful, false otherwise
     */
    public boolean replyToMessage(int messageId, String replyContent, String adminName, String adminEmail) {
        // Use default admin ID
        return replyToMessage(messageId, replyContent, adminName, adminEmail, 1);
    }

    /**
     * Get replies for a message
     * @param messageId Parent message ID
     * @return List of reply messages
     */
    public List<Message> getRepliesByParentId(int messageId) {
        return messageDAO.getRepliesByParentId(messageId);
    }

    /**
     * Check if a user has access to a message
     * Business logic method to centralize access control
     * @param messageId Message ID to check
     * @param userId User ID to check access for
     * @param isAdmin Whether the user is an admin
     * @return true if user has access, false otherwise
     */
    public boolean userHasAccessToMessage(int messageId, int userId, boolean isAdmin) {
        // Admins always have access
        if (isAdmin) {
            return true;
        }

        // Get the message
        Message message = getMessageById(messageId);
        if (message == null) {
            return false;
        }

        // Check if the message belongs to the user
        return message.getUserId() == userId;
    }

    /**
     * Get message with replies
     * Business logic method to get a message and its replies in one call
     * @param messageId Message ID
     * @return Message object with replies set, or null if not found
     */
    public Message getMessageWithReplies(int messageId) {
        Message message = getMessageById(messageId);
        if (message == null) {
            return null;
        }

        // Mark as read if not already
        if (!message.isRead()) {
            markMessageAsRead(messageId);
            message.setRead(true);
        }

        // Get replies
        List<Message> replies = getRepliesByParentId(messageId);

        // We could extend the Message class to include a replies field,
        // but for now we'll just return the message and let the controller handle the replies separately
        return message;
    }
}
