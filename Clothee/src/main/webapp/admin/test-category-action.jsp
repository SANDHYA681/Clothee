<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="model.Category" %>
<%@ page import="dao.CategoryDAO" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Add Category Result</title>
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin.css">
    <style>
        .result-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .result-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        
        .result-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }
        
        .result-content {
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
        
        .btn {
            padding: 8px 15px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin-top: 10px;
        }
        
        .btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="result-container">
        <h1>Test Add Category Result</h1>
        
        <%
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        boolean success = false;
        String errorMessage = "";
        int newCategoryId = -1;
        
        if (name == null || name.trim().isEmpty()) {
        %>
        <div class="result-section">
            <div class="result-content error">
                Error: Category name is required
            </div>
        </div>
        <%
        } else {
            try {
                // First check if category exists
                Connection conn = DBConnection.getConnection();
                PreparedStatement checkStmt = conn.prepareStatement("SELECT COUNT(*) FROM categories WHERE name = ?");
                checkStmt.setString(1, name);
                ResultSet rs = checkStmt.executeQuery();
                rs.next();
                int count = rs.getInt(1);
                rs.close();
                checkStmt.close();
                
                if (count > 0) {
        %>
        <div class="result-section">
            <div class="result-content error">
                Error: A category with name '<%= name %>' already exists
            </div>
        </div>
        <%
                } else {
                    // Try to add the category directly with SQL
                    PreparedStatement stmt = conn.prepareStatement(
                        "INSERT INTO categories (name, description) VALUES (?, ?)",
                        Statement.RETURN_GENERATED_KEYS
                    );
                    stmt.setString(1, name);
                    stmt.setString(2, description);
                    
                    int rowsAffected = stmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        ResultSet generatedKeys = stmt.getGeneratedKeys();
                        if (generatedKeys.next()) {
                            newCategoryId = generatedKeys.getInt(1);
                            success = true;
                        }
                        generatedKeys.close();
                    }
                    
                    stmt.close();
                    conn.close();
                }
            } catch (Exception e) {
                errorMessage = e.getMessage();
                e.printStackTrace();
            }
            
            if (success) {
        %>
        <div class="result-section">
            <div class="result-content success">
                Success! Category added with ID: <%= newCategoryId %>
            </div>
            <div class="result-content">
                Name: <%= name %>
                Description: <%= description %>
            </div>
        </div>
        <%
            } else if (!errorMessage.isEmpty()) {
        %>
        <div class="result-section">
            <div class="result-content error">
                Error: <%= errorMessage %>
            </div>
        </div>
        <%
            }
        }
        %>
        
        <div>
            <a href="test-category.jsp" class="btn">Back to Test Page</a>
            <a href="categories.jsp" class="btn">Back to Categories</a>
        </div>
    </div>
</body>
</html>
