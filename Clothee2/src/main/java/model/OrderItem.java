package model;

/**
 * Order Item model class
 */
public class OrderItem {
    private int id;
    private int orderId;
    private int productId;
    private String productName;
    private double price;
    private int quantity;
    private String imageUrl;


    // Default constructor
    public OrderItem() {
    }

    // Constructor with fields
    public OrderItem(int id, int orderId, int productId, String productName, double price, int quantity, String imageUrl) {
        this.id = id;
        this.orderId = orderId;
        this.productId = productId;
        this.productName = productName;
        this.price = price;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
    }



    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }



    // Helper methods
    public double getSubtotal() {
        return price * quantity;
    }

    public String getFormattedPrice() {
        return String.format("$%.2f", price);
    }

    public String getFormattedSubtotal() {
        return String.format("$%.2f", getSubtotal());
    }

    @Override
    public String toString() {
        return "OrderItem{" +
                "id=" + id +
                ", orderId=" + orderId +
                ", productId=" + productId +
                ", productName='" + productName + '\'' +
                ", price=" + price +
                ", quantity=" + quantity +
                '}';
    }
}
