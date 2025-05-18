package model;

import java.sql.Timestamp;

/**
 * Shipping model class
 */
public class Shipping {
    private int id;
    private int orderId;
    private Timestamp shippingDate;
    private String shippingStatus;
    private String shippingAddress;

    // Default constructor
    public Shipping() {
    }

    // Constructor with fields
    public Shipping(int id, int orderId, Timestamp shippingDate, String shippingStatus, String shippingAddress) {
        this.id = id;
        this.orderId = orderId;
        this.shippingDate = shippingDate;
        this.shippingStatus = shippingStatus;
        this.shippingAddress = shippingAddress;
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

    public Timestamp getShippingDate() {
        return shippingDate;
    }

    public void setShippingDate(Timestamp shippingDate) {
        this.shippingDate = shippingDate;
    }

    public String getShippingStatus() {
        return shippingStatus;
    }

    public void setShippingStatus(String shippingStatus) {
        this.shippingStatus = shippingStatus;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    @Override
    public String toString() {
        return "Shipping{" +
                "id=" + id +
                ", orderId=" + orderId +
                ", shippingDate=" + (shippingDate != null ? shippingDate : "null") +
                ", shippingStatus='" + (shippingStatus != null ? shippingStatus : "null") + '\'' +
                ", shippingAddress='" + (shippingAddress != null ? shippingAddress : "null") + '\'' +
                '}';
    }
}
