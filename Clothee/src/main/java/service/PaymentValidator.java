package service;

/**
 * Payment Validator
 * Validates payment information
 */
public class PaymentValidator {

    /**
     * Validate payment information
     * @param cardType Card type
     * @param cardNumber Card number
     * @param expiryDate Expiry date
     * @param cvv CVV
     * @return Error message if validation fails, null if validation passes
     */
    public String validatePayment(String cardType, String cardNumber, String expiryDate, String cvv) {
        // Validate card type
        if (cardType == null || cardType.isEmpty()) {
            return "Please select a card type.";
        }

        // Validate card number
        String cleanCardNumber = cardNumber.replaceAll("\\s+", "");
        if (cleanCardNumber.length() != 16) {
            return "Card number must be 16 digits. Please check your card number.";
        }

        if (!cleanCardNumber.matches("\\d+")) {
            return "Card number must contain only digits. Please check your card number.";
        }

        // Validate CVV
        if (cvv.length() != 3) {
            return "CVV must be 3 digits. Please check your CVV.";
        }

        if (!cvv.matches("\\d+")) {
            return "CVV must contain only digits. Please check your CVV.";
        }

        // Validate expiry date format
        if (!expiryDate.matches("\\d{2}/\\d{2}")) {
            return "Expiry date must be in MM/YY format (e.g., 05/25). Please check your expiry date.";
        }

        // Additional validation for expiry date - check if it's not expired
        try {
            int month = Integer.parseInt(expiryDate.substring(0, 2));
            int year = Integer.parseInt(expiryDate.substring(3, 5)) + 2000; // Convert to 4-digit year

            java.util.Calendar calendar = java.util.Calendar.getInstance();
            int currentMonth = calendar.get(java.util.Calendar.MONTH) + 1; // Calendar months are 0-based
            int currentYear = calendar.get(java.util.Calendar.YEAR);

            if (year < currentYear || (year == currentYear && month < currentMonth)) {
                return "Card has expired. Please use a valid card.";
            }

            if (month < 1 || month > 12) {
                return "Invalid month in expiry date. Month must be between 01 and 12.";
            }
        } catch (NumberFormatException e) {
            return "Invalid expiry date format. Please use MM/YY format.";
        }

        // All validations passed
        return null;
    }

    /**
     * Process payment
     * @param paymentMethod Payment method
     * @param cardNumber Card number
     * @param expiryDate Expiry date
     * @param cvv CVV
     * @param amount Amount to charge
     * @return Error message if payment fails, null if payment succeeds
     */
    public String processPayment(String paymentMethod, String cardNumber, String expiryDate, String cvv, double amount) {
        // First validate the payment information
        String validationError = validatePayment(paymentMethod, cardNumber, expiryDate, cvv);
        if (validationError != null) {
            return validationError;
        }

        // In a real application, this would call a payment gateway API
        // For now, we'll just simulate a successful payment

        // All validations passed and payment processed successfully
        return null;
    }
}
