package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/clothee?useSSL=false&serverTimezone=UTC";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = ""; // Update with your MySQL password if set

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



    public static Connection getConnection() throws SQLException {
        System.out.println("DBConnection: getConnection called");
        System.out.println("DBConnection: JDBC_URL = " + JDBC_URL);
        System.out.println("DBConnection: JDBC_USER = " + JDBC_USER);

        try {
            System.out.println("DBConnection: Attempting to establish connection");
            Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            if (conn == null) {
                System.out.println("DBConnection: Connection is null");
                throw new SQLException("Connection is null");
            }

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

    // Test-related code removed
}
