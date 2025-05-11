<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Database Connection Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            line-height: 1.6;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        h1 {
            color: #333;
        }
        .success {
            color: green;
            font-weight: bold;
        }
        .error {
            color: red;
            font-weight: bold;
        }
        pre {
            background-color: #f5f5f5;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Database Connection Test</h1>
        
        <h2>1. Testing Connection</h2>
        <%
        boolean connectionSuccess = false;
        try {
            boolean testResult = DBConnection.testConnection();
            connectionSuccess = testResult;
            if (testResult) {
        %>
            <p class="success">✅ Database connection successful!</p>
        <%
            } else {
        %>
            <p class="error">❌ Database connection failed!</p>
        <%
            }
        } catch (Exception e) {
            connectionSuccess = false;
        %>
            <p class="error">❌ Error testing database connection: <%= e.getMessage() %></p>
            <pre><%= e.toString() %></pre>
        <%
        }
        %>
        
        <h2>2. Database Information</h2>
        <%
        if (connectionSuccess) {
            try (Connection conn = DBConnection.getConnection()) {
                DatabaseMetaData metaData = conn.getMetaData();
        %>
            <p><strong>Database Product:</strong> <%= metaData.getDatabaseProductName() %> <%= metaData.getDatabaseProductVersion() %></p>
            <p><strong>JDBC Driver:</strong> <%= metaData.getDriverName() %> <%= metaData.getDriverVersion() %></p>
            <p><strong>URL:</strong> <%= metaData.getURL() %></p>
            <p><strong>Username:</strong> <%= metaData.getUserName() %></p>
        <%
            } catch (Exception e) {
        %>
            <p class="error">❌ Error getting database information: <%= e.getMessage() %></p>
            <pre><%= e.toString() %></pre>
        <%
            }
        } else {
        %>
            <p class="error">Cannot retrieve database information because connection failed.</p>
        <%
        }
        %>
        
        <h2>3. Messages Table Structure</h2>
        <%
        if (connectionSuccess) {
            try (Connection conn = DBConnection.getConnection()) {
                DatabaseMetaData metaData = conn.getMetaData();
                ResultSet columns = metaData.getColumns(null, null, "messages", null);
        %>
            <table>
                <tr>
                    <th>Column Name</th>
                    <th>Type</th>
                    <th>Size</th>
                    <th>Nullable</th>
                    <th>Default</th>
                </tr>
        <%
                while (columns.next()) {
                    String columnName = columns.getString("COLUMN_NAME");
                    String columnType = columns.getString("TYPE_NAME");
                    int columnSize = columns.getInt("COLUMN_SIZE");
                    String nullable = columns.getInt("NULLABLE") == DatabaseMetaData.columnNullable ? "Yes" : "No";
                    String defaultValue = columns.getString("COLUMN_DEF");
        %>
                <tr>
                    <td><%= columnName %></td>
                    <td><%= columnType %></td>
                    <td><%= columnSize %></td>
                    <td><%= nullable %></td>
                    <td><%= defaultValue == null ? "NULL" : defaultValue %></td>
                </tr>
        <%
                }
                columns.close();
        %>
            </table>
        <%
            } catch (Exception e) {
        %>
            <p class="error">❌ Error getting messages table structure: <%= e.getMessage() %></p>
            <pre><%= e.toString() %></pre>
        <%
            }
        } else {
        %>
            <p class="error">Cannot retrieve messages table structure because connection failed.</p>
        <%
        }
        %>
        
        <h2>4. Test Message Insertion</h2>
        <%
        if (connectionSuccess) {
            try (Connection conn = DBConnection.getConnection()) {
                // Check if test message already exists
                String checkQuery = "SELECT COUNT(*) FROM messages WHERE subject = 'Test Message from db-test.jsp'";
                boolean testMessageExists = false;
                
                try (Statement checkStmt = conn.createStatement();
                     ResultSet checkRs = checkStmt.executeQuery(checkQuery)) {
                    if (checkRs.next()) {
                        testMessageExists = checkRs.getInt(1) > 0;
                    }
                }
                
                if (!testMessageExists) {
                    // Insert a test message
                    String insertQuery = "INSERT INTO messages (name, email, subject, message, is_read, created_at, parent_id, is_reply, is_replied) " +
                                        "VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?)";
                    
                    try (PreparedStatement pstmt = conn.prepareStatement(insertQuery)) {
                        pstmt.setString(1, "Test User");
                        pstmt.setString(2, "test@example.com");
                        pstmt.setString(3, "Test Message from db-test.jsp");
                        pstmt.setString(4, "This is a test message inserted directly from db-test.jsp");
                        pstmt.setBoolean(5, false);
                        pstmt.setInt(6, 0);
                        pstmt.setBoolean(7, false);
                        pstmt.setBoolean(8, false);
                        
                        int rowsAffected = pstmt.executeUpdate();
                        if (rowsAffected > 0) {
        %>
                            <p class="success">✅ Test message inserted successfully!</p>
        <%
                        } else {
        %>
                            <p class="error">❌ Failed to insert test message (no rows affected).</p>
        <%
                        }
                    }
                } else {
        %>
                    <p>Test message already exists in the database.</p>
        <%
                }
                
                // Show recent messages
                String selectQuery = "SELECT * FROM messages ORDER BY created_at DESC LIMIT 5";
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(selectQuery)) {
        %>
                    <h3>Recent Messages</h3>
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Subject</th>
                            <th>Read</th>
                            <th>Created At</th>
                        </tr>
        <%
                    while (rs.next()) {
        %>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getString("name") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td><%= rs.getString("subject") %></td>
                            <td><%= rs.getBoolean("is_read") ? "Yes" : "No" %></td>
                            <td><%= rs.getTimestamp("created_at") %></td>
                        </tr>
        <%
                    }
        %>
                    </table>
        <%
                }
            } catch (Exception e) {
        %>
                <p class="error">❌ Error testing message insertion: <%= e.getMessage() %></p>
                <pre><%= e.toString() %></pre>
        <%
            }
        } else {
        %>
            <p class="error">Cannot test message insertion because connection failed.</p>
        <%
        }
        %>
        
        <p style="margin-top: 20px;">
            <a href="<%= request.getContextPath() %>/contact.jsp">Return to Contact Form</a>
        </p>
    </div>
</body>
</html>
