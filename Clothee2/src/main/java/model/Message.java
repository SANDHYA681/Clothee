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
    private boolean isRead;
    private Timestamp createdAt;
    private Timestamp readAt;
    private int parentId; // For reply threads
    private boolean isReply; // Whether this message is a reply
    private boolean isReplied; // Whether this message has been replied to

    // Default constructor
    public Message() {
        this.parentId = 0;
        this.isReply = false;
        this.isReplied = false;
    }

    // Constructor with fields
    public Message(int id, int userId, String name, String email, String subject, String message, boolean isRead, Timestamp createdAt, Timestamp readAt) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.subject = subject;
        this.message = message;
        this.isRead = isRead;
        this.createdAt = createdAt;
        this.readAt = readAt;
        this.parentId = 0;
        this.isReply = false;
        this.isReplied = false;
    }

    // Constructor with reply fields
    public Message(int id, int userId, String name, String email, String subject, String message, boolean isRead, Timestamp createdAt, Timestamp readAt, int parentId, boolean isReply, boolean isReplied) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.subject = subject;
        this.message = message;
        this.isRead = isRead;
        this.createdAt = createdAt;
        this.readAt = readAt;
        this.parentId = parentId;
        this.isReply = isReply;
        this.isReplied = isReplied;
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

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean isRead) {
        this.isRead = isRead;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getReadAt() {
        return readAt;
    }

    public void setReadAt(Timestamp readAt) {
        this.readAt = readAt;
    }

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }

    public boolean isReply() {
        return isReply;
    }

    public void setReply(boolean isReply) {
        this.isReply = isReply;
    }

    public boolean isReplied() {
        return isReplied;
    }

    public void setReplied(boolean isReplied) {
        this.isReplied = isReplied;
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
                ", isRead=" + isRead +
                ", createdAt=" + createdAt +
                ", readAt=" + readAt +
                '}';
    }
}
