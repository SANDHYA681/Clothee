package util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class TestDBConnection {
    public static void main(String[] args) {
        try {
            // Test database connection
            System.out.println("Testing database connection...");
            boolean connected = DBConnection.testConnection();
            System.out.println("Connection test result: " + (connected ? "SUCCESS" : "FAILED"));
            
            if (connected) {
                // Get table structure
                System.out.println("\nGetting messages table structure...");
                getTableStructure("messages");
                
                // Test query
                System.out.println("\nTesting query...");
                testQuery();
            }
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void getTableStructure(String tableName) {
        try (Connection conn = DBConnection.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            
            // Get table columns
            System.out.println("Columns in " + tableName + " table:");
            try (ResultSet columns = metaData.getColumns(null, null, tableName, null)) {
                while (columns.next()) {
                    String columnName = columns.getString("COLUMN_NAME");
                    String columnType = columns.getString("TYPE_NAME");
                    int columnSize = columns.getInt("COLUMN_SIZE");
                    String nullable = columns.getInt("NULLABLE") == DatabaseMetaData.columnNullable ? "YES" : "NO";
                    
                    System.out.println("  " + columnName + " - " + columnType + 
                                      "(" + columnSize + ") - Nullable: " + nullable);
                }
            }
            
            // Get primary keys
            System.out.println("\nPrimary keys in " + tableName + " table:");
            try (ResultSet primaryKeys = metaData.getPrimaryKeys(null, null, tableName)) {
                while (primaryKeys.next()) {
                    String columnName = primaryKeys.getString("COLUMN_NAME");
                    String pkName = primaryKeys.getString("PK_NAME");
                    
                    System.out.println("  " + columnName + " - PK Name: " + pkName);
                }
            }
            
            // Get foreign keys
            System.out.println("\nForeign keys in " + tableName + " table:");
            try (ResultSet foreignKeys = metaData.getImportedKeys(null, null, tableName)) {
                if (!foreignKeys.next()) {
                    System.out.println("  No foreign keys found");
                } else {
                    do {
                        String fkColumnName = foreignKeys.getString("FKCOLUMN_NAME");
                        String pkTableName = foreignKeys.getString("PKTABLE_NAME");
                        String pkColumnName = foreignKeys.getString("PKCOLUMN_NAME");
                        
                        System.out.println("  " + fkColumnName + " -> " + 
                                          pkTableName + "." + pkColumnName);
                    } while (foreignKeys.next());
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting table structure: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void testQuery() {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Test a simple query
            String query = "SELECT COUNT(*) FROM messages";
            System.out.println("Executing query: " + query);
            
            try (ResultSet rs = stmt.executeQuery(query)) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("Total messages: " + count);
                }
            }
            
            // Test a more complex query
            query = "SELECT id, name, email, subject, created_at FROM messages LIMIT 5";
            System.out.println("\nExecuting query: " + query);
            
            try (ResultSet rs = stmt.executeQuery(query)) {
                System.out.println("Results:");
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String name = rs.getString("name");
                    String email = rs.getString("email");
                    String subject = rs.getString("subject");
                    java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                    
                    System.out.println("  ID: " + id + 
                                      ", Name: " + name + 
                                      ", Email: " + email + 
                                      ", Subject: " + subject + 
                                      ", Created: " + createdAt);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error executing query: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
