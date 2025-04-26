package util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Utility class to check and update database schema
 */
public class DatabaseUpdater {
    
    /**
     * Check if the messages table has the required columns for replies
     * If not, add them
     * @return true if successful, false otherwise
     */
    public static boolean ensureMessageReplyColumns() {
        System.out.println("DatabaseUpdater: Checking if messages table has reply columns");
        
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                System.out.println("DatabaseUpdater: Failed to get database connection");
                return false;
            }
            
            // Check if parent_id column exists
            boolean hasParentId = columnExists(conn, "messages", "parent_id");
            boolean hasIsReply = columnExists(conn, "messages", "is_reply");
            boolean hasIsReplied = columnExists(conn, "messages", "is_replied");
            
            if (hasParentId && hasIsReply && hasIsReplied) {
                System.out.println("DatabaseUpdater: All required columns exist");
                return true;
            }
            
            // Add missing columns
            try (Statement stmt = conn.createStatement()) {
                if (!hasParentId) {
                    System.out.println("DatabaseUpdater: Adding parent_id column");
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN parent_id INT DEFAULT NULL");
                }
                
                if (!hasIsReply) {
                    System.out.println("DatabaseUpdater: Adding is_reply column");
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN is_reply BOOLEAN DEFAULT FALSE");
                }
                
                if (!hasIsReplied) {
                    System.out.println("DatabaseUpdater: Adding is_replied column");
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN is_replied BOOLEAN DEFAULT FALSE");
                }
                
                System.out.println("DatabaseUpdater: All required columns added successfully");
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println("DatabaseUpdater: Error checking/updating database schema: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Check if a column exists in a table
     * @param conn Database connection
     * @param tableName Table name
     * @param columnName Column name
     * @return true if column exists, false otherwise
     * @throws SQLException if a database error occurs
     */
    private static boolean columnExists(Connection conn, String tableName, String columnName) throws SQLException {
        DatabaseMetaData meta = conn.getMetaData();
        try (ResultSet rs = meta.getColumns(null, null, tableName, columnName)) {
            return rs.next();
        }
    }
}
