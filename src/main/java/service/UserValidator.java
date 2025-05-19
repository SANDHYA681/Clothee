package service;

import dao.UserDAO;

/**
 * User Validator
 * Validates user information following MVC pattern
 */
public class UserValidator {

    private UserDAO userDAO;

    public UserValidator() {
        this.userDAO = new UserDAO();
    }

    /**
     * Validate registration information
     * Note: Users can register with the same first name and last name, but email and username must be unique
     *
     * @param firstName First name
     * @param lastName Last name
     * @param email Email (must be unique)
     * @param username Username (must be unique)
     * @param password Password
     * @param confirmPassword Confirm password
     * @return Error message if validation fails, null if validation passes
     */
    public String validateRegistration(String firstName, String lastName, String email,
                                      String username, String password, String confirmPassword) {
        // Check required fields
        if (firstName == null || firstName.trim().isEmpty()) {
            return "First name is required";
        }

        if (lastName == null || lastName.trim().isEmpty()) {
            return "Last name is required";
        }

        if (email == null || email.trim().isEmpty()) {
            return "Email is required";
        }

        if (username == null || username.trim().isEmpty()) {
            return "Username is required";
        }

        if (password == null || password.trim().isEmpty()) {
            return "Password is required";
        }

        if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
            return "Confirm password is required";
        }

        // Validate email format
        if (!isValidEmail(email)) {
            return "Invalid email format";
        }

        // Check if email already exists
        if (emailExists(email)) {
            return "Email already exists. Please use a different email or login with your existing account. Note that you can register with the same name as other users, but emails must be unique.";
        }

        // Check if username already exists
        if (usernameExists(username)) {
            return "Username already exists. Please choose a different username.";
        }

        // Check if first name already exists
        if (firstNameExists(firstName)) {
            return "First name already exists. Please use a different first name.";
        }

        // Check if passwords match
        if (!password.equals(confirmPassword)) {
            return "Passwords do not match";
        }

        // Check password strength
        if (password.length() < 6) {
            return "Password must be at least 6 characters long";
        }

        // All validations passed
        return null;
    }

    /**
     * Validate login information
     * @param emailOrUsername Email or username
     * @param password Password
     * @return Error message if validation fails, null if validation passes
     */
    public String validateLogin(String emailOrUsername, String password) {
        // Check required fields
        if (emailOrUsername == null || emailOrUsername.trim().isEmpty()) {
            return "Email or username is required";
        }

        if (password == null || password.trim().isEmpty()) {
            return "Password is required";
        }

        // All validations passed
        return null;
    }

    /**
     * Check if email already exists
     * @param email Email to check
     * @return true if email exists, false otherwise
     */
    public boolean emailExists(String email) {
        return userDAO.emailExists(email);
    }

    /**
     * Check if username already exists
     * @param username Username to check
     * @return true if username exists, false otherwise
     */
    public boolean usernameExists(String username) {
        return userDAO.usernameExists(username);
    }

    /**
     * Check if first name already exists
     * @param firstName First name to check
     * @return true if first name exists, false otherwise
     */
    public boolean firstNameExists(String firstName) {
        return userDAO.firstNameExists(firstName);
    }

    /**
     * Validate email format
     * @param email Email to validate
     * @return true if email format is valid, false otherwise
     */
    private boolean isValidEmail(String email) {
        // Simple email validation using regex
        String emailRegex = "^[A-Za-z0-9+_.-]+@(.+)$";
        return email.matches(emailRegex);
    }
}
