package model;

import java.util.Date;
import java.util.List;


/**
 * Order model class
 */
public class Order {
    private int id;
    private int userId;
    private double totalPrice;
    private Date orderDate; // Maps to order_placed_date in the database
    private String status;
    private List<OrderItem> orderItems;


    // Default constructor
    public Order() {
    }

    // Constructor with fields
    public Order(int id, int userId, double totalPrice, Date orderDate, String status) {
        this.id = id;
        this.userId = userId;
        this.totalPrice = totalPrice;
        this.orderDate = orderDate;
        this.status = status;

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



    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }



    // Alias for setTotalPrice to maintain compatibility
    public void setTotalAmount(double totalAmount) {
        this.totalPrice = totalAmount;
    }

    // Alias for getTotalPrice to maintain compatibility
    public double getTotalAmount() {
        return this.totalPrice;
    }

    public List<OrderItem> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<OrderItem> orderItems) {
        this.orderItems = orderItems;
    }


    @Override
    public String toString() {
        return "Order{" +
                "id=" + id +
                ", userId=" + userId +
                ", totalPrice=" + totalPrice +
                ", orderDate=" + orderDate +
                ", status='" + status + '\'' +
                '}';
    }
}
