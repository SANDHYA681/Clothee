package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database connection utility class that manages connections to the MySQL database.
 * This class provides a centralized way to establish database connections
 * throughout the application.
 */
public class DBConnection {
    /** The JDBC URL for connecting to the MySQL database */
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/clothee?useSSL=false&serverTimezone=UTC";

    /** The MySQL database username */
    private static final String JDBC_USER = "root";

    /** The MySQL database password - empty by default */
    private static final String JDBC_PASSWORD = ""; // Update with your MySQL password if set

    /**
     * Static initialization block that loads the MySQL JDBC driver when the class is loaded.
     * This ensures the driver is available before any connection attempts are made.
     */
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC driver loaded successfully");

        } catch (ClassNotFoundException e) {
            System.err.println("Error loading MySQL JDBC driver: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to load MySQL JDBC driver", e);
        } catch (Exception e) {
            System.err.println("Error initializing database: " + e.getMessage());
            e.printStackTrace();
        }
    }



    /**
     * Establishes and returns a connection to the MySQL database.
     * This method performs validation to ensure the connection is valid before returning it.
     *
     * @return A valid Connection object to the database
     * @throws SQLException If a database access error occurs or the connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        System.out.println("DBConnection: getConnection called");
        System.out.println("DBConnection: JDBC_URL = " + JDBC_URL);
        System.out.println("DBConnection: JDBC_USER = " + JDBC_USER);

        try {
            System.out.println("DBConnection: Attempting to establish connection");
            Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            // Validate that the connection is not null
            if (conn == null) {
                System.out.println("DBConnection: Connection is null");
                throw new SQLException("Connection is null");
            }

            // Validate that the connection is not closed
            if (conn.isClosed()) {
                System.out.println("DBConnection: Connection is closed");
                throw new SQLException("Connection is closed");
            }

            System.out.println("DBConnection: Database connection established successfully for clothee");
            return conn;
        } catch (SQLException e) {
            System.err.println("DBConnection: Error establishing database connection: " + e.getMessage());
            e.printStackTrace();
            throw new SQLException("Failed to connect to database: " + e.getMessage(), e);
        } catch (Exception e) {
            System.err.println("DBConnection: Unexpected error: " + e.getMessage());
            e.printStackTrace();
            throw new SQLException("Unexpected error: " + e.getMessage(), e);
        }
    }

    // Database connection testing and validation methods can be added here
}