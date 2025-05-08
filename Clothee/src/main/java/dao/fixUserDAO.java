package dao;

/**
 * This class is created to fix a compilation error where some code is referencing dao.fixUserDAO
 * It extends UserDAO to ensure all methods are available
 */
public class fixUserDAO extends UserDAO {
    /**
     * Check if a username exists in the database
     * Note: In the current schema, we're using email as the username
     *
     * @param username Username to check
     * @return true if username exists, false otherwise
     */
    @Override
    public boolean usernameExists(String username) {
        // Call the parent class implementation
        return super.usernameExists(username);
    }

    /**
     * Check if a first name already exists in the database
     *
     * @param firstName First name to check
     * @return true if the first name exists, false otherwise
     */
    @Override
    public boolean firstNameExists(String firstName) {
        // Call the parent class implementation
        return super.firstNameExists(firstName);
    }
}
