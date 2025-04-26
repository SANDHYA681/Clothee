package util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.stream.Collectors;

/**
 * Database initializer
 * Executes SQL scripts to initialize the database
 */
public class DatabaseInitializer {
    
    /**
     * Initialize the database
     * @return true if successful, false otherwise
     */
    public static boolean initialize() {
        try {
            // Execute payment_methods.sql
            executeScript("sql/payment_methods.sql");
            
            return true;
        } catch (Exception e) {
            System.out.println("Error initializing database: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Execute a SQL script
     * @param scriptPath Path to the script
     * @throws Exception If an error occurs
     */
    private static void executeScript(String scriptPath) throws Exception {
        // Load the script
        InputStream inputStream = DatabaseInitializer.class.getClassLoader().getResourceAsStream(scriptPath);
        if (inputStream == null) {
            throw new Exception("Script not found: " + scriptPath);
        }
        
        // Read the script
        String script = new BufferedReader(new InputStreamReader(inputStream))
                .lines()
                .collect(Collectors.joining("\n"));
        
        // Split the script into statements
        String[] statements = script.split(";");
        
        // Execute each statement
        try (Connection conn = DBConnection.getConnection()) {
            for (String statement : statements) {
                // Skip empty statements
                if (statement.trim().isEmpty()) {
                    continue;
                }
                
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute(statement);
                }
            }
        }
    }
}
