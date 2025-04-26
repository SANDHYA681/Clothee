package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Cart model class
 */
public class Cart {
    private int id;
    private int userId;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<CartItem> items;

    // Address fields
    private String fullName;
    private String street;
    private String city;
    private String state;
    private String zipCode;
    private String country;
    private String phone;

    // Default constructor
    public Cart() {
        this.items = new ArrayList<>();
    }

    // Constructor with fields
    public Cart(int id, int userId, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.userId = userId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.items = new ArrayList<>();
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

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getZipCode() {
        return zipCode;
    }

    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    // Helper methods
    public void addItem(CartItem item) {
        // Check if product already exists in cart
        for (CartItem existingItem : items) {
            if (existingItem.getProductId() == item.getProductId()) {
                // Update quantity instead of adding new item
                existingItem.setQuantity(existingItem.getQuantity() + item.getQuantity());
                return;
            }
        }

        // Add new item
        items.add(item);
    }

    public void updateItemQuantity(int productId, int quantity) {
        for (CartItem item : items) {
            if (item.getProductId() == productId) {
                item.setQuantity(quantity);
                return;
            }
        }
    }

    public void removeItem(int productId) {
        items.removeIf(item -> item.getProductId() == productId);
    }

    public void clear() {
        items.clear();
    }

    public int getItemCount() {
        int count = 0;
        for (CartItem item : items) {
            count += item.getQuantity();
        }
        return count;
    }

    public double getSubtotal() {
        double subtotal = 0;
        for (CartItem item : items) {
            subtotal += item.getSubtotal();
        }
        return subtotal;
    }

    public double getShipping() {
        // Free shipping for now
        return 0.0;
    }

    public double getTax() {
        // 10% tax rate
        return getSubtotal() * 0.1;
    }

    public double getTotal() {
        return getSubtotal() + getShipping() + getTax();
    }

    @Override
    public String toString() {
        return "Cart{" +
                "id=" + id +
                ", userId=" + userId +
                ", itemCount=" + getItemCount() +
                ", subtotal=" + getSubtotal() +
                ", tax=" + getTax() +
                ", shipping=" + getShipping() +
                ", total=" + getTotal() +
                ", fullName='" + fullName + '\'' +
                ", street='" + street + '\'' +
                ", city='" + city + '\'' +
                ", state='" + state + '\'' +
                ", zipCode='" + zipCode + '\'' +
                ", country='" + country + '\'' +
                ", phone='" + phone + '\'' +
                '}';
    }
}
