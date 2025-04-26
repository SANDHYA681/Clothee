package service;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import dao.PaymentMethodDAO;
import model.PaymentMethod;

/**
 * Service class for payment method operations
 */
public class PaymentMethodService {
    private PaymentMethodDAO paymentMethodDAO;
    private PaymentValidator paymentValidator;

    /**
     * Constructor
     */
    public PaymentMethodService() {
        this.paymentMethodDAO = new PaymentMethodDAO();
        this.paymentValidator = new PaymentValidator();
    }

    /**
     * Add a new payment method
     * @param userId User ID
     * @param cardType Card type
     * @param cardName Name on card
     * @param cardNumber Card number
     * @param expiryDate Expiry date
     * @param cvv CVV
     * @param billingAddress Billing address
     * @param billingCity Billing city
     * @param billingState Billing state
     * @param billingZip Billing zip code
     * @param billingCountry Billing country
     * @param isDefault Whether this is the default payment method
     * @return Error message if validation fails, null if successful
     */
    public String addPaymentMethod(int userId, String cardType, String cardName, String cardNumber, 
                                 String expiryDate, String cvv, String billingAddress, String billingCity, 
                                 String billingState, String billingZip, String billingCountry, boolean isDefault) {
        
        // Validate payment information
        String validationError = paymentValidator.validatePayment(cardType, cardNumber, expiryDate, cvv);
        if (validationError != null) {
            return validationError;
        }
        
        // Create payment method object
        PaymentMethod paymentMethod = new PaymentMethod();
        paymentMethod.setUserId(userId);
        paymentMethod.setCardType(cardType);
        paymentMethod.setCardName(cardName);
        paymentMethod.setCardNumber(cardNumber);
        paymentMethod.setExpiryDate(expiryDate);
        paymentMethod.setBillingAddress(billingAddress);
        paymentMethod.setBillingCity(billingCity);
        paymentMethod.setBillingState(billingState);
        paymentMethod.setBillingZip(billingZip);
        paymentMethod.setBillingCountry(billingCountry);
        paymentMethod.setDefault(isDefault);
        paymentMethod.setCreatedAt(new Timestamp(new Date().getTime()));
        paymentMethod.setUpdatedAt(new Timestamp(new Date().getTime()));
        
        // Save payment method
        boolean success = paymentMethodDAO.createPaymentMethod(paymentMethod);
        
        if (success) {
            return null; // No error
        } else {
            return "Failed to save payment method. Please try again.";
        }
    }
    
    /**
     * Get payment methods by user ID
     * @param userId User ID
     * @return List of payment methods
     */
    public List<PaymentMethod> getPaymentMethodsByUserId(int userId) {
        return paymentMethodDAO.getPaymentMethodsByUserId(userId);
    }
    
    /**
     * Get payment method by ID
     * @param id Payment method ID
     * @return PaymentMethod object or null if not found
     */
    public PaymentMethod getPaymentMethodById(int id) {
        return paymentMethodDAO.getPaymentMethodById(id);
    }
    
    /**
     * Update payment method
     * @param id Payment method ID
     * @param userId User ID
     * @param cardType Card type
     * @param cardName Name on card
     * @param expiryDate Expiry date
     * @param billingAddress Billing address
     * @param billingCity Billing city
     * @param billingState Billing state
     * @param billingZip Billing zip code
     * @param billingCountry Billing country
     * @param isDefault Whether this is the default payment method
     * @return Error message if validation fails, null if successful
     */
    public String updatePaymentMethod(int id, int userId, String cardType, String cardName, 
                                    String expiryDate, String billingAddress, String billingCity, 
                                    String billingState, String billingZip, String billingCountry, boolean isDefault) {
        
        // Get existing payment method
        PaymentMethod paymentMethod = paymentMethodDAO.getPaymentMethodById(id);
        
        if (paymentMethod == null) {
            return "Payment method not found.";
        }
        
        // Check if the payment method belongs to the user
        if (paymentMethod.getUserId() != userId) {
            return "You do not have permission to update this payment method.";
        }
        
        // Update payment method
        paymentMethod.setCardType(cardType);
        paymentMethod.setCardName(cardName);
        paymentMethod.setExpiryDate(expiryDate);
        paymentMethod.setBillingAddress(billingAddress);
        paymentMethod.setBillingCity(billingCity);
        paymentMethod.setBillingState(billingState);
        paymentMethod.setBillingZip(billingZip);
        paymentMethod.setBillingCountry(billingCountry);
        paymentMethod.setDefault(isDefault);
        paymentMethod.setUpdatedAt(new Timestamp(new Date().getTime()));
        
        // Save updated payment method
        boolean success = paymentMethodDAO.updatePaymentMethod(paymentMethod);
        
        if (success) {
            return null; // No error
        } else {
            return "Failed to update payment method. Please try again.";
        }
    }
    
    /**
     * Delete payment method
     * @param id Payment method ID
     * @param userId User ID
     * @return Error message if validation fails, null if successful
     */
    public String deletePaymentMethod(int id, int userId) {
        // Get existing payment method
        PaymentMethod paymentMethod = paymentMethodDAO.getPaymentMethodById(id);
        
        if (paymentMethod == null) {
            return "Payment method not found.";
        }
        
        // Check if the payment method belongs to the user
        if (paymentMethod.getUserId() != userId) {
            return "You do not have permission to delete this payment method.";
        }
        
        // Delete payment method
        boolean success = paymentMethodDAO.deletePaymentMethod(id);
        
        if (success) {
            return null; // No error
        } else {
            return "Failed to delete payment method. Please try again.";
        }
    }
    
    /**
     * Set payment method as default
     * @param id Payment method ID
     * @param userId User ID
     * @return Error message if validation fails, null if successful
     */
    public String setDefaultPaymentMethod(int id, int userId) {
        // Get existing payment method
        PaymentMethod paymentMethod = paymentMethodDAO.getPaymentMethodById(id);
        
        if (paymentMethod == null) {
            return "Payment method not found.";
        }
        
        // Check if the payment method belongs to the user
        if (paymentMethod.getUserId() != userId) {
            return "You do not have permission to update this payment method.";
        }
        
        // Set as default
        boolean success = paymentMethodDAO.setDefaultPaymentMethod(id, userId);
        
        if (success) {
            return null; // No error
        } else {
            return "Failed to set payment method as default. Please try again.";
        }
    }
}
