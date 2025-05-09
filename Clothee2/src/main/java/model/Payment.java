package model;

import java.sql.Timestamp;

/**
 * Payment model class
 */
public class Payment {
    private int id;
    private int orderId;
    private int userId;
    private String paymentMethod;
    private double amount;
    private String status;
    private Timestamp paymentDate;
    private String transactionId;
    private String cardNumber; // Last 4 digits only for security
    private String gatewayReference;
    private String errorCode;
    private String errorMessage;
    private String billingAddress;
    private String billingCity;
    private String billingState;
    private String billingZip;
    private String billingCountry;

    // Default constructor
    public Payment() {
    }

    // Constructor with fields
    public Payment(int id, int orderId, int userId, String paymentMethod, double amount,
                  String status, Timestamp paymentDate, String transactionId, String cardNumber) {
        this.id = id;
        this.orderId = orderId;
        this.userId = userId;
        this.paymentMethod = paymentMethod;
        this.amount = amount;
        this.status = status;
        this.paymentDate = paymentDate;
        this.transactionId = transactionId;
        this.cardNumber = cardNumber;
    }

    // Constructor with all fields
    public Payment(int id, int orderId, int userId, String paymentMethod, double amount,
                  String status, Timestamp paymentDate, String transactionId, String cardNumber,
                  String gatewayReference, String errorCode, String errorMessage,
                  String billingAddress, String billingCity, String billingState,
                  String billingZip, String billingCountry) {
        this.id = id;
        this.orderId = orderId;
        this.userId = userId;
        this.paymentMethod = paymentMethod;
        this.amount = amount;
        this.status = status;
        this.paymentDate = paymentDate;
        this.transactionId = transactionId;
        this.cardNumber = cardNumber;
        this.gatewayReference = gatewayReference;
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
        this.billingAddress = billingAddress;
        this.billingCity = billingCity;
        this.billingState = billingState;
        this.billingZip = billingZip;
        this.billingCountry = billingCountry;
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

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Timestamp paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getGatewayReference() {
        return gatewayReference;
    }

    public void setGatewayReference(String gatewayReference) {
        this.gatewayReference = gatewayReference;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
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

    @Override
    public String toString() {
        return "Payment{" +
                "id=" + id +
                ", orderId=" + orderId +
                ", userId=" + userId +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", amount=" + amount +
                ", status='" + status + '\'' +
                ", paymentDate=" + paymentDate +
                ", transactionId='" + transactionId + '\'' +
                ", cardNumber='" + cardNumber + '\'' +
                ", gatewayReference='" + gatewayReference + '\'' +
                ", errorCode='" + errorCode + '\'' +
                ", errorMessage='" + errorMessage + '\'' +
                ", billingAddress='" + billingAddress + '\'' +
                ", billingCity='" + billingCity + '\'' +
                ", billingState='" + billingState + '\'' +
                ", billingZip='" + billingZip + '\'' +
                ", billingCountry='" + billingCountry + '\'' +
                '}';
    }
}
