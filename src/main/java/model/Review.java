package model;

import java.sql.Timestamp;
import java.util.Date;

/**
 * Review model class
 */
public class Review {
    private int id;
    private int productId;
    private int userId;
    private int rating;
    private String comment;
    private Timestamp createdAt; // Maps to reviewed_date in the database
    private User user;
    private Product product;

    // These fields are for JSP compatibility
    private Date reviewDate; // Maps to reviewed_date in the database
    private String userName; // Not in DB, for display purposes
    private String productName; // Not in DB, for display purposes

    // Default constructor
    public Review() {
    }

    // Constructor with fields
    public Review(int id, int productId, int userId, int rating, String comment, Timestamp createdAt) {
        this.id = id;
        this.productId = productId;
        this.userId = userId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public java.util.Date getReviewDate() {
        if (reviewDate != null) {
            return reviewDate;
        }
        return createdAt;
    }

    public void setReviewDate(java.util.Date reviewDate) {
        this.reviewDate = reviewDate;

        // Also update createdAt for database compatibility
        if (reviewDate instanceof java.sql.Timestamp) {
            this.createdAt = (java.sql.Timestamp) reviewDate;
        } else if (reviewDate != null) {
            this.createdAt = new java.sql.Timestamp(reviewDate.getTime());
        }
    }

    public String getUserName() {
        if (userName != null) {
            return userName;
        } else if (user != null) {
            return user.getFirstName() + " " + user.getLastName();
        }
        return "User #" + userId;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getProductName() {
        if (productName != null) {
            return productName;
        } else if (product != null) {
            return product.getName();
        }
        return "Product #" + productId;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    // Helper methods
    public String getFormattedRating() {
        StringBuilder stars = new StringBuilder();
        for (int i = 0; i < rating; i++) {
            stars.append("★");
        }
        for (int i = rating; i < 5; i++) {
            stars.append("☆");
        }
        return stars.toString();
    }

    public String getFormattedDate() {
        if (createdAt == null) {
            return "";
        }
        return new java.text.SimpleDateFormat("MMM dd, yyyy").format(createdAt);
    }

    @Override
    public String toString() {
        return "Review{" +
                "id=" + id +
                ", productId=" + productId +
                ", userId=" + userId +
                ", rating=" + rating +
                ", comment='" + comment + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
