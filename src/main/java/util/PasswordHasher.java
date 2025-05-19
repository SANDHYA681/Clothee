package util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility class for secure password hashing and verification using BCrypt.
 * BCrypt is a password-hashing function designed by Niels Provos and David Mazières.
 */
public class PasswordHasher {

    /**
     * Hashes a password using BCrypt with a work factor of 12.
     * The work factor determines the computational complexity and
     * provides protection against brute force attacks.
     *
     * @param password The plain text password to hash
     * @return A BCrypt hashed password string
     */
    public static String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    /**
     * Verifies if a plain text password matches a previously hashed password.
     *
     * @param password The plain text password to check
     * @param hashedPassword The previously hashed password to compare against
     * @return true if the password matches the hash, false otherwise
     */
    public static boolean checkPassword(String password, String hashedPassword) {
        return BCrypt.checkpw(password, hashedPassword);
    }
}