package model;

import java.sql.Timestamp;

/**
 * Message model class for contact form submissions
 */
public class Message {
    private int id;
    private int userId;
    private String name;
    private String email;
    private String subject;
    private String message;
    private Timestamp createdAt;
    private int parentId = 0; // ID of the message this is replying to (0 if not a reply)

    // Default constructor
    public Message() {
    }

    // Constructor with fields
    public Message(int id, int userId, String name, String email, String subject, String message, Timestamp createdAt, int parentId) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.subject = subject;
        this.message = message;
        this.createdAt = createdAt;
        this.parentId = parentId;
    }

    // Constructor without parentId for backward compatibility
    public Message(int id, int userId, String name, String email, String subject, String message, Timestamp createdAt) {
        this(id, userId, name, email, subject, message, createdAt, 0);
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }

    // Helper method to check if this message is a reply
    public boolean isReply() {
        // Since we're removing parent_id, we'll determine if it's a reply based on the subject
        return subject != null && subject.startsWith("RE: ");
    }

    // Transient field to store if this message has been replied to
    // This is a transient field used only in memory, not stored in the database
    private transient boolean replied = false;

    // Helper method to check if this message has been replied to
    public boolean isReplied() {
        return replied;
    }

    // Setter for replied status
    public void setReplied(boolean replied) {
        this.replied = replied;
    }

    // Helper method to check if this message has been read
    // Since we're not tracking read status in the database, we'll assume all messages are read
    public boolean isRead() {
        return true;
    }

    // Helper methods
    public String getFormattedDate() {
        if (createdAt == null) {
            return "";
        }
        return new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(createdAt);
    }

    public String getShortMessage() {
        if (message == null || message.isEmpty()) {
            return "";
        }
        return message.length() > 100 ? message.substring(0, 100) + "..." : message;
    }

    @Override
    public String toString() {
        return "Message{" +
                "id=" + id +
                ", userId=" + userId +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", subject='" + subject + '\'' +
                ", message='" + message + '\'' +
                ", createdAt=" + createdAt +
                ", parentId=" + parentId +
                '}';
    }
}
