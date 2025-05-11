<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.User" %>
<%@ page import="service.UserService" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Debug Users</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            line-height: 1.6;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        h1, h2 {
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
        <h1>Debug Users</h1>
        
        <h2>1. Database Connection Test</h2>
        <%
        boolean connectionSuccess = false;
        try {
            Connection conn = DBConnection.getConnection();
            connectionSuccess = conn != null && !conn.isClosed();
            if (connectionSuccess) {
                conn.close();
            }
        %>
            <p class="success">✅ Database connection successful!</p>
        <%
        } catch (Exception e) {
        %>
            <p class="error">❌ Database connection failed: <%= e.getMessage() %></p>
            <pre><%= e.toString() %></pre>
        <%
        }
        %>
        
        <h2>2. Users Table Structure</h2>
        <%
        if (connectionSuccess) {
            try (Connection conn = DBConnection.getConnection()) {
                DatabaseMetaData metaData = conn.getMetaData();
                ResultSet columns = metaData.getColumns(null, null, "users", null);
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
                    <td><%= defaultValue != null ? defaultValue : "NULL" %></td>
                </tr>
        <%
                }
        %>
            </table>
        <%
            } catch (Exception e) {
        %>
            <p class="error">❌ Error getting users table structure: <%= e.getMessage() %></p>
            <pre><%= e.toString() %></pre>
        <%
            }
        } else {
        %>
            <p class="error">Cannot retrieve users table structure because connection failed.</p>
        <%
        }
        %>
        
        <h2>3. Direct SQL Query for Users</h2>
        <%
        if (connectionSuccess) {
            try (Connection conn = DBConnection.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT * FROM users")) {
        %>
            <table>
                <tr>
                    <th>ID</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Is Admin</th>
                </tr>
        <%
                while (rs.next()) {
        %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getString("first_name") %></td>
                    <td><%= rs.getString("last_name") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td><%= rs.getString("role") %></td>
                    <td><%= rs.getBoolean("is_admin") %></td>
                </tr>
        <%
                }
        %>
            </table>
        <%
            } catch (Exception e) {
        %>
            <p class="error">❌ Error executing direct SQL query: <%= e.getMessage() %></p>
            <pre><%= e.toString() %></pre>
        <%
            }
        } else {
        %>
            <p class="error">Cannot execute direct SQL query because connection failed.</p>
        <%
        }
        %>
        
        <h2>4. UserService.getAllUsers()</h2>
        <%
        if (connectionSuccess) {
            try {
                UserService userService = new UserService();
                List<User> users = userService.getAllUsers();
        %>
            <p>Retrieved <%= users.size() %> users from UserService.getAllUsers()</p>
            <table>
                <tr>
                    <th>ID</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Is Admin</th>
                </tr>
        <%
                for (User user : users) {
        %>
                <tr>
                    <td><%= user.getId() %></td>
                    <td><%= user.getFirstName() %></td>
                    <td><%= user.getLastName() %></td>
                    <td><%= user.getEmail() %></td>
                    <td><%= user.getRole() %></td>
                    <td><%= user.isAdmin() %></td>
                </tr>
        <%
                }
        %>
            </table>
        <%
            } catch (Exception e) {
        %>
            <p class="error">❌ Error calling UserService.getAllUsers(): <%= e.getMessage() %></p>
            <pre><%= e.toString() %></pre>
        <%
            }
        } else {
        %>
            <p class="error">Cannot call UserService.getAllUsers() because connection failed.</p>
        <%
        }
        %>
        
        <h2>5. Back to Admin Dashboard</h2>
        <p><a href="<%= request.getContextPath() %>/admin/dashboard.jsp">Go back to Admin Dashboard</a></p>
    </div>
</body>
</html>
