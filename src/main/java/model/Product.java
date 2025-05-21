package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Product model class
 */
public class Product {
    private int id;
    private String name;
    private String description;
    private double price;
    private int stock;
    private String category;
    private String type;
    private String imageUrl;
    private List<String> additionalImages;

    private boolean featured;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default constructor
    public Product() {
        this.additionalImages = new ArrayList<>();
    }

    // Constructor with fields
    public Product(int id, String name, String description, double price, int stock, String category, String type,
            String imageUrl, boolean featured, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
        this.stock = stock;
        this.category = category;
        this.type = type;
        this.imageUrl = imageUrl;
        this.featured = featured;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.additionalImages = new ArrayList<>();
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }



    public boolean isFeatured() {
        return featured;
    }

    public void setFeatured(boolean featured) {
        this.featured = featured;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Helper methods

    public String getFormattedPrice() {
        return String.format("$%.2f", price);
    }

    public String getDefaultImage() {
        if (imageUrl != null && !imageUrl.isEmpty()) {
            return imageUrl;
        } else {
            return getPlaceholderImage();
        }
    }

    public String getPlaceholderImage() {
        return "images/products/placeholder.jpg";
    }

    /**
     * Get the average rating for this product
     * This is a placeholder method that should be replaced with actual data from the database
     * @return Average rating (0-5)
     */
    public double getAverageRating() {
        // In a real implementation, this would query the database for all reviews of this product
        // and calculate the average rating
        // For now, we'll return a placeholder value
        return 4.5;
    }

    /**
     * Add an additional image URL to the product
     * @param imageUrl Image URL to add
     */
    public void addAdditionalImage(String imageUrl) {
        try {
            if (this.additionalImages == null) {
                this.additionalImages = new ArrayList<>();
            }
            if (imageUrl != null && !imageUrl.isEmpty()) {
                this.additionalImages.add(imageUrl);
            }
        } catch (Exception e) {
            System.out.println("Error in addAdditionalImage: " + e.getMessage());
            e.printStackTrace();
            // Initialize the list if there was an error
            this.additionalImages = new ArrayList<>();
        }
    }

    /**
     * Get all additional images for this product
     * @return List of additional image URLs
     */
    public List<String> getAdditionalImages() {
        try {
            if (this.additionalImages == null) {
                this.additionalImages = new ArrayList<>();
            }
            return this.additionalImages;
        } catch (Exception e) {
            System.out.println("Error in getAdditionalImages: " + e.getMessage());
            e.printStackTrace();
            // Return an empty list if there was an error
            return new ArrayList<>();
        }
    }

    /**
     * Set additional images for this product
     * @param additionalImages List of image URLs
     */
    public void setAdditionalImages(List<String> additionalImages) {
        try {
            if (additionalImages == null) {
                this.additionalImages = new ArrayList<>();
            } else {
                this.additionalImages = additionalImages;
            }
        } catch (Exception e) {
            System.out.println("Error in setAdditionalImages: " + e.getMessage());
            e.printStackTrace();
            // Initialize the list if there was an error
            this.additionalImages = new ArrayList<>();
        }
    }


    @Override
    public String toString() {
        return "Product{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                ", category='" + category + '\'' +
                ", type='" + type + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                ", additionalImages=" + additionalImages +
                ", featured=" + featured +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
