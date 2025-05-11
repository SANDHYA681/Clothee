<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="model.Category" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="java.util.List" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Test</title>
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin.css">
    <style>
        .test-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .test-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        
        .test-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }
        
        .test-result {
            padding: 10px;
            background-color: #f5f5f5;
            border-radius: 4px;
            font-family: monospace;
            white-space: pre-wrap;
            margin-bottom: 10px;
        }
        
        .success {
            color: green;
            background-color: rgba(0, 128, 0, 0.1);
        }
        
        .error {
            color: red;
            background-color: rgba(255, 0, 0, 0.1);
        }
        
        .test-form {
            margin-top: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 4px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        .btn {
            padding: 8px 15px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        
        .btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="test-container">
        <h1>Database Test Page</h1>
        
        <div class="test-section">
            <h2 class="test-title">1. Database Connection Test</h2>
            <%
            boolean connectionSuccess = false;
            try {
                connectionSuccess = DBConnection.testConnection();
            %>
            <div class="test-result <%= connectionSuccess ? "success" : "error" %>">
                Connection Test: <%= connectionSuccess ? "SUCCESS" : "FAILED" %>
            </div>
            <%
            } catch (Exception e) {
            %>
            <div class="test-result error">
                Connection Error: <%= e.getMessage() %>
                <% e.printStackTrace(new java.io.PrintWriter(out)); %>
            </div>
            <%
            }
            %>
        </div>
        
        <% if (connectionSuccess) { %>
        <div class="test-section">
            <h2 class="test-title">2. Categories Table Test</h2>
            <%
            try {
                Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SHOW TABLES LIKE 'categories'");
                boolean tableExists = rs.next();
            %>
            <div class="test-result <%= tableExists ? "success" : "error" %>">
                Categories Table Exists: <%= tableExists ? "YES" : "NO" %>
            </div>
            <%
                if (tableExists) {
                    rs = stmt.executeQuery("DESCRIBE categories");
            %>
            <h3>Table Structure:</h3>
            <div class="test-result">
                <table border="1" cellpadding="5">
                    <tr>
                        <th>Field</th>
                        <th>Type</th>
                        <th>Null</th>
                        <th>Key</th>
                        <th>Default</th>
                        <th>Extra</th>
                    </tr>
                    <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString("Field") %></td>
                        <td><%= rs.getString("Type") %></td>
                        <td><%= rs.getString("Null") %></td>
                        <td><%= rs.getString("Key") %></td>
                        <td><%= rs.getString("Default") %></td>
                        <td><%= rs.getString("Extra") %></td>
                    </tr>
                    <% } %>
                </table>
            </div>
            <%
                    // Count categories
                    rs = stmt.executeQuery("SELECT COUNT(*) FROM categories");
                    rs.next();
                    int categoryCount = rs.getInt(1);
            %>
            <div class="test-result">
                Total Categories: <%= categoryCount %>
            </div>
            <%
                    // List categories
                    if (categoryCount > 0) {
                        rs = stmt.executeQuery("SELECT * FROM categories LIMIT 10");
            %>
            <h3>Sample Categories:</h3>
            <div class="test-result">
                <table border="1" cellpadding="5">
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Description</th>
                        <th>Image URL</th>
                        <th>Created At</th>
                    </tr>
                    <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("description") %></td>
                        <td><%= rs.getString("image_url") %></td>
                        <td><%= rs.getTimestamp("created_at") %></td>
                    </tr>
                    <% } %>
                </table>
            </div>
            <%
                    }
                }
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
            %>
            <div class="test-result error">
                Error: <%= e.getMessage() %>
                <% e.printStackTrace(new java.io.PrintWriter(out)); %>
            </div>
            <%
            }
            %>
        </div>
        
        <div class="test-section">
            <h2 class="test-title">3. Test Add Category</h2>
            <div class="test-form">
                <form action="test-category-action.jsp" method="post">
                    <div class="form-group">
                        <label for="name" class="form-label">Category Name</label>
                        <input type="text" id="name" name="name" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label for="description" class="form-label">Description</label>
                        <textarea id="description" name="description" class="form-control"></textarea>
                    </div>
                    <button type="submit" class="btn">Test Add Category</button>
                </form>
            </div>
        </div>
        <% } %>
        
        <div>
            <a href="categories.jsp" class="btn">Back to Categories</a>
        </div>
    </div>
</body>
</html>
