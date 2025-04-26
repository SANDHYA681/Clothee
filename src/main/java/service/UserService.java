package service;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import dao.UserDAO;
import model.User;
import util.PasswordHasher;

public class UserService {
    private UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    public User registerUser(String firstName, String lastName, String email, String password, String phone) {
        return registerUser(firstName, lastName, email, password, phone, false);
    }

    public User registerUser(String firstName, String lastName, String email, String password, String phone, boolean isAdmin) {
        if (userDAO.emailExists(email)) {
            System.out.println("Registration failed: Email " + email + " already exists");
            return null;
        }

        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPassword(PasswordHasher.hashPassword(password));
        user.setPhone(phone);
        user.setRole(isAdmin ? "admin" : "user");
        user.setAdmin(isAdmin);
        // Explicitly set profileImage to null - users must upload their own
        user.setProfileImage(null);
        user.setCreatedAt(new Timestamp(new Date().getTime()));
        user.setUpdatedAt(new Timestamp(new Date().getTime()));

        boolean success = userDAO.addUser(user);
        if (success) {
            System.out.println("Registration successful for " + email + ", Role: " + user.getRole() + ", isAdmin: " + user.isAdmin());
            return userDAO.getUserByEmail(email);
        }
        System.out.println("Registration failed for " + email);
        return null;
    }

    public User authenticateUser(String email, String password) {
        try {
            User user = userDAO.authenticate(email, password);
            if (user == null) {
                System.out.println("UserService: Authentication failed for " + email);
            } else {
                System.out.println("UserService: Authentication successful for " + email);
            }
            return user;
        } catch (Exception e) {
            System.err.println("UserService authentication error for " + email + ": " + e.getMessage());
            throw new RuntimeException("Authentication failed: " + e.getMessage(), e);
        }
    }

    public User getUserById(int userId) {
        try {
            User user = userDAO.getUserById(userId);
            if (user == null) {
                System.out.println("UserService: No user found with ID " + userId);
            } else {
                System.out.println("UserService: Retrieved user with ID " + userId);
            }
            return user;
        } catch (Exception e) {
            System.err.println("UserService getUserById error for userId " + userId + ": " + e.getMessage());
            throw new RuntimeException("Failed to get user by ID: " + e.getMessage(), e);
        }
    }

    public boolean updateUserProfile(int userId, String firstName, String lastName, String phone) {
        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setPhone(phone);
        user.setUpdatedAt(new Timestamp(new Date().getTime()));
        return userDAO.updateUser(user);
    }

    public boolean updateUserProfile(int userId, String firstName, String lastName, String email, String phone, String role) {
        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        user.setRole(isAdmin ? "admin" : "user");
        user.setAdmin(isAdmin);
        user.setUpdatedAt(new Timestamp(new Date().getTime()));
        return userDAO.updateUser(user);
    }

    public boolean updateUserPassword(int userId, String currentPassword, String newPassword) {
        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        if (!PasswordHasher.checkPassword(currentPassword, user.getPassword())) {
            return false;
        }
        return userDAO.updatePassword(userId, newPassword);
    }

    public boolean updatePassword(int userId, String newPassword) {
        return userDAO.updatePassword(userId, newPassword);
    }

    public boolean updateUserProfileImage(int userId, String profileImage) {
        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        user.setProfileImage(profileImage);
        user.setUpdatedAt(new Timestamp(new Date().getTime()));
        return userDAO.updateUser(user);
    }

    // getUserById method is already defined above

    public User getUserByEmail(String email) {
        return userDAO.getUserByEmail(email);
    }

    public List<User> getAllUsers() {
        return userDAO.getAllUsers();
    }

    public List<User> getUsersByRole(String role) {
        return userDAO.getUsersByRole(role);
    }

    public boolean deleteUser(int userId) {
        return userDAO.deleteUser(userId);
    }

    /**
     * Check if email exists in the database
     * Note: This method is functionally identical to isEmailTaken()
     * @param email Email to check
     * @return true if email exists, false otherwise
     */
    public boolean emailExists(String email) {
        return userDAO.emailExists(email);
    }

    /**
     * Check if email is already taken
     * @param email Email to check
     * @return true if email is taken, false otherwise
     */
    public boolean isEmailTaken(String email) {
        return userDAO.emailExists(email);
    }

    /**
     * Add a new user (for admin use)
     * @param user User to add
     * @return true if successful, false otherwise
     */
    public boolean addUser(User user) {
        // Hash password if not already hashed
        if (!user.getPassword().startsWith("$2a$")) {
            user.setPassword(PasswordHasher.hashPassword(user.getPassword()));
        }

        // Set timestamps if not already set
        if (user.getCreatedAt() == null) {
            user.setCreatedAt(new Timestamp(new Date().getTime()));
        }
        if (user.getUpdatedAt() == null) {
            user.setUpdatedAt(new Timestamp(new Date().getTime()));
        }

        return userDAO.addUser(user);
    }

    public int getUserCount() {
        return userDAO.getUserCount();
    }

    public List<User> getRecentUsers(int limit) {
        return userDAO.getRecentUsers(limit);
    }

    /**
     * Update an existing user (for admin use)
     * @param user User to update
     * @return true if successful, false otherwise
     */
    public boolean updateUser(User user) {
        // Get existing user to check if password has changed
        User existingUser = userDAO.getUserById(user.getId());

        if (existingUser == null) {
            return false;
        }

        // If password has changed and is not already hashed, hash it
        if (!user.getPassword().equals(existingUser.getPassword()) && !user.getPassword().startsWith("$2a$")) {
            user.setPassword(PasswordHasher.hashPassword(user.getPassword()));
        }

        // Set updated timestamp
        user.setUpdatedAt(new Timestamp(new Date().getTime()));

        return userDAO.updateUser(user);
    }
}