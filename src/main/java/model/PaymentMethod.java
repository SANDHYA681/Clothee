package model;

import java.sql.Timestamp;

/**
 * Payment Method model class
 */
public class PaymentMethod {
    private int id;
    private int userId;
    private String cardType;
    private String cardName;
    private String cardNumber; // Last 4 digits only for security
    private String expiryDate;
    private String billingAddress;
    private String billingCity;
    private String billingState;
    private String billingZip;
    private String billingCountry;
    private boolean isDefault;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default constructor
    public PaymentMethod() {
    }

    // Constructor with fields
    public PaymentMethod(int id, int userId, String cardType, String cardName, String cardNumber, 
                        String expiryDate, String billingAddress, String billingCity, 
                        String billingState, String billingZip, String billingCountry, 
                        boolean isDefault, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.userId = userId;
        this.cardType = cardType;
        this.cardName = cardName;
        this.cardNumber = cardNumber;
        this.expiryDate = expiryDate;
        this.billingAddress = billingAddress;
        this.billingCity = billingCity;
        this.billingState = billingState;
        this.billingZip = billingZip;
        this.billingCountry = billingCountry;
        this.isDefault = isDefault;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and setters
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

    public String getCardType() {
        return cardType;
    }

    public void setCardType(String cardType) {
        this.cardType = cardType;
    }

    public String getCardName() {
        return cardName;
    }

    public void setCardName(String cardName) {
        this.cardName = cardName;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(String expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getBillingAddress() {
        return billingAddress;
    }

    public void setBillingAddress(String billingAddress) {
        this.billingAddress = billingAddress;
    }

    public String getBillingCity() {
        return billingCity;
    }

    public void setBillingCity(String billingCity) {
        this.billingCity = billingCity;
    }

    public String getBillingState() {
        return billingState;
    }

    public void setBillingState(String billingState) {
        this.billingState = billingState;
    }

    public String getBillingZip() {
        return billingZip;
    }

    public void setBillingZip(String billingZip) {
        this.billingZip = billingZip;
    }

    public String getBillingCountry() {
        return billingCountry;
    }

    public void setBillingCountry(String billingCountry) {
        this.billingCountry = billingCountry;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean isDefault) {
        this.isDefault = isDefault;
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

    // Get masked card number (e.g., **** **** **** 1234)
    public String getMaskedCardNumber() {
        if (cardNumber == null || cardNumber.isEmpty()) {
            return "";
        }
        
        // Clean the card number (remove spaces)
        String cleanCardNumber = cardNumber.replaceAll("\\s+", "");
        
        // If the card number is less than 4 digits, return it as is
        if (cleanCardNumber.length() < 4) {
            return cleanCardNumber;
        }
        
        // Get the last 4 digits
        String lastFourDigits = cleanCardNumber.substring(cleanCardNumber.length() - 4);
        
        // Return masked card number
        return "**** **** **** " + lastFourDigits;
    }

    // Get card icon class based on card type
    public String getCardIconClass() {
        if (cardType == null) {
            return "fa-credit-card";
        }
        
        switch (cardType.toLowerCase()) {
            case "visa":
                return "fa-cc-visa";
            case "mastercard":
                return "fa-cc-mastercard";
            case "amex":
                return "fa-cc-amex";
            case "discover":
                return "fa-cc-discover";
            default:
                return "fa-credit-card";
        }
    }

    @Override
    public String toString() {
        return "PaymentMethod{" +
                "id=" + id +
                ", userId=" + userId +
                ", cardType='" + cardType + '\'' +
                ", cardName='" + cardName + '\'' +
                ", cardNumber='" + getMaskedCardNumber() + '\'' +
                ", expiryDate='" + expiryDate + '\'' +
                ", billingAddress='" + billingAddress + '\'' +
                ", billingCity='" + billingCity + '\'' +
                ", billingState='" + billingState + '\'' +
                ", billingZip='" + billingZip + '\'' +
                ", billingCountry='" + billingCountry + '\'' +
                ", isDefault=" + isDefault +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
