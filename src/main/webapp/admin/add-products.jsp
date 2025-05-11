<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.io.File" %>
<%@ page import="util.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Products - CLOTHEE Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin/style.css">
</head>
<body>
    <%
        // Check if user is logged in and is admin
        User user = (User) session.getAttribute("user");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect("../LoginServlet");
            return;
        }

        String message = null;
        String messageType = null;

        // Check if form is submitted
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");

            if ("add_products".equals(action)) {
                // Execute SQL script to add products
                String sqlFilePath = application.getRealPath("/WEB-INF/sql/add_more_products.sql");
                File sqlFile = new File(sqlFilePath);

                if (sqlFile.exists()) {
                    StringBuilder sqlScript = new StringBuilder();
                    try (BufferedReader reader = new BufferedReader(new FileReader(sqlFile))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            // Skip comments and empty lines
                            if (!line.trim().startsWith("--") && !line.trim().isEmpty()) {
                                sqlScript.append(line);

                                // If line ends with semicolon, execute the statement
                                if (line.trim().endsWith(";")) {
                                    try (Connection conn = DBConnection.getConnection();
                                         Statement stmt = conn.createStatement()) {
                                        stmt.executeUpdate(sqlScript.toString());
                                        sqlScript.setLength(0); // Clear the buffer
                                    } catch (SQLException e) {
                                        // Log the error and continue with the next statement
                                        System.err.println("Error executing SQL: " + e.getMessage());
                                        System.err.println("SQL: " + sqlScript.toString());
                                    }
                                }
                            }
                        }

                        message = "Products added successfully!";
                        messageType = "success";
                    } catch (Exception e) {
                        message = "Error adding products: " + e.getMessage();
                        messageType = "error";
                        e.printStackTrace();
                    }
                } else {
                    message = "SQL file not found: " + sqlFilePath;
                    messageType = "error";
                }
            }
        }
    %>

    <div class="dashboard-container">
        <%@ include file="includes/sidebar.jsp" %>

        <div class="admin-content">
            <%@ include file="includes/header.jsp" %>

            <div class="content-wrapper">
                <div class="page-header">
                    <h1>Add Products</h1>
                    <p>Add sample products to your store</p>
                </div>

                <% if (message != null) { %>
                    <div class="alert alert-<%= messageType %>">
                        <%= message %>
                    </div>
                <% } %>

                <div class="card">
                    <div class="card-header">
                        <h2>Add Sample Products</h2>
                    </div>
                    <div class="card-body">
                        <p>Click the button below to add sample products to your store. This will execute the SQL script to insert products into the database.</p>

                        <form method="post" action="add-products.jsp">
                            <input type="hidden" name="action" value="add_products">
                            <button type="submit" class="btn btn-primary">Add Sample Products</button>
                        </form>

                        <div class="alert alert-info mt-4">
                            <strong>Note:</strong> This will add 20 sample products (5 for each category: Men, Women, Kids, and Accessories).
                        </div>
                    </div>
                </div>

                <div class="card mt-4">
                    <div class="card-header">
                        <h2>Product Images</h2>
                    </div>
                    <div class="card-body">
                        <p>Make sure you have product images in the following directories:</p>

                        <ul>
                            <li><code>images/products/men/</code></li>
                            <li><code>images/products/women/</code></li>
                            <li><code>images/products/kids/</code></li>
                            <li><code>images/products/accessories/</code></li>
                        </ul>

                        <p>If you don't have product images, you can download them using the Image Download tool:</p>

                        <a href="download-images.jsp" class="btn btn-secondary">Go to Image Download</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="../js/admin/script.js"></script>
</body>
</html>
