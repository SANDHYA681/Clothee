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
     * Get messages by user ID
     * @param userId User ID
     * @return List of messages from user
     */
    public List<Message> getMessagesByUserId(int userId) {
        List<Message> messages = messageDAO.getMessagesByUserId(userId);

        // For each message, check if there are any replies
        for (Message message : messages) {
            // Get all messages to check for replies
            List<Message> allMessages = messageDAO.getAllMessages();

            // Check if any message is a reply to this one (has "RE: " + original subject)
            String replySubject = "RE: " + message.getSubject();
            for (Message potentialReply : allMessages) {
                if (potentialReply.getSubject() != null && potentialReply.getSubject().equals(replySubject)) {
                    // Found a reply, mark the original message as replied
                    message.setReplied(true);
                    break;
                }
            }
        }

        return messages;
    }

    /**
     * Reply to a message
     * @param messageId Message ID to reply to
     * @param replyContent Reply content
     * @param adminName Admin name
     * @param adminEmail Admin email
     * @param adminId Admin user ID
     * @return true if successful, false otherwise
     */
    public boolean replyToMessage(int messageId, String replyContent, String adminName, String adminEmail, int adminId) {
        // Get the original message
        Message originalMessage = getMessageById(messageId);
        if (originalMessage == null) {
            System.out.println("MessageService: Original message not found");
            return false;
        }

        // Create a reply message
        Message reply = new Message();
        reply.setName(adminName);
        reply.setEmail(adminEmail);
        reply.setSubject("RE: " + originalMessage.getSubject());
        reply.setMessage(replyContent);
        reply.setUserId(adminId);
        // Not setting parentId as we're removing that field
        reply.setCreatedAt(new Timestamp(new Date().getTime()));

        System.out.println("MessageService: Created reply to message ID = " + messageId);

        // Save the reply
        return messageDAO.addMessage(reply);
    }

    /**
     * Get replies for a message
     * @param messageId Message ID
     * @return List of replies
     */
    public List<Message> getRepliesByParentId(int messageId) {
        System.out.println("MessageService: getRepliesByParentId called for messageId = " + messageId);

        try {
            // Get the original message to find its subject
            Message originalMessage = getMessageById(messageId);
            if (originalMessage == null) {
                System.out.println("MessageService: Original message not found, returning empty list");
                return new java.util.ArrayList<>();
            }

            // Get all messages
            List<Message> allMessages = messageDAO.getAllMessages();
            List<Message> replies = new java.util.ArrayList<>();

            // The reply subject pattern is "RE: " + original subject
            String replySubject = "RE: " + originalMessage.getSubject();

            // Find all messages that have the reply subject
            for (Message message : allMessages) {
                if (message.getSubject() != null && message.getSubject().equals(replySubject)) {
                    replies.add(message);
                }
            }

            System.out.println("MessageService: Found " + replies.size() + " replies for message ID = " + messageId);
            return replies;
        } catch (Exception e) {
            System.out.println("MessageService: Error in getRepliesByParentId: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        }
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
     * Get message by ID
     * This method replaces getMessageWithReplies to avoid using parent_id
     * @param messageId Message ID
     * @return Message object if found, null otherwise
     */
    public Message getMessageWithReplies(int messageId) {
        System.out.println("MessageService: getMessageWithReplies called for messageId = " + messageId);

        // Simply get the message by ID without relying on parent_id
        Message message = getMessageById(messageId);

        if (message == null) {
            System.out.println("MessageService: Message not found with ID = " + messageId);
            return null;
        }

        // Check if there are any replies to this message
        List<Message> allMessages = messageDAO.getAllMessages();
        String replySubject = "RE: " + message.getSubject();

        for (Message potentialReply : allMessages) {
            if (potentialReply.getSubject() != null && potentialReply.getSubject().equals(replySubject)) {
                // Found a reply, mark the original message as replied
                message.setReplied(true);
                break;
            }
        }

        System.out.println("MessageService: Message found with ID = " + messageId + ", replied = " + message.isReplied());
        return message;
    }
}
