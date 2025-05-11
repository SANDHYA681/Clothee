<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Order" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Orders</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-dashboard.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            line-height: 1.6;
        }
        h1, h2 {
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 5px;
        }
        .error {
            color: red;
            background-color: #ffeeee;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .success {
            color: green;
            background-color: #eeffee;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        pre {
            background-color: #f5f5f5;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Orders Diagnostic Page</h1>

        <div class="section">
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
                <div class="success">Database connection successful!</div>
            <%
            } catch (Exception e) {
            %>
                <div class="error">
                    <p>Database connection failed: <%= e.getMessage() %></p>
                    <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                </div>
            <%
            }
            %>
        </div>

        <% if (connectionSuccess) { %>
        <div class="section">
            <h2>2. Orders Table Structure</h2>
            <%
            try {
                Connection conn = DBConnection.getConnection();
                DatabaseMetaData metaData = conn.getMetaData();
                ResultSet tables = metaData.getTables(null, null, "orders", null);

                if (tables.next()) {
            %>
                <div class="success">Orders table exists!</div>

                <h3>Columns in Orders Table:</h3>
                <table>
                    <tr>
                        <th>Column Name</th>
                        <th>Type</th>
                        <th>Size</th>
                        <th>Nullable</th>
                    </tr>
                <%
                    ResultSet columns = metaData.getColumns(null, null, "orders", null);
                    while (columns.next()) {
                %>
                    <tr>
                        <td><%= columns.getString("COLUMN_NAME") %></td>
                        <td><%= columns.getString("TYPE_NAME") %></td>
                        <td><%= columns.getInt("COLUMN_SIZE") %></td>
                        <td><%= columns.getInt("NULLABLE") == 1 ? "Yes" : "No" %></td>
                    </tr>
                <%
                    }
                    columns.close();
                %>
                </table>

                <h3>Sample Data:</h3>
                <%
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM orders LIMIT 5");
                    ResultSetMetaData rsmd = rs.getMetaData();
                    int columnCount = rsmd.getColumnCount();
                %>
                <table>
                    <tr>
                    <%
                        for (int i = 1; i <= columnCount; i++) {
                    %>
                        <th><%= rsmd.getColumnName(i) %></th>
                    <%
                        }
                    %>
                    </tr>
                <%
                    while (rs.next()) {
                %>
                    <tr>
                    <%
                        for (int i = 1; i <= columnCount; i++) {
                    %>
                        <td><%= rs.getString(i) != null ? rs.getString(i) : "NULL" %></td>
                    <%
                        }
                    %>
                    </tr>
                <%
                    }
                    rs.close();
                    stmt.close();
                %>
                </table>
            <%
                } else {
            %>
                <div class="error">Orders table does not exist!</div>
            <%
                }
                tables.close();
                conn.close();
            } catch (Exception e) {
            %>
                <div class="error">
                    <p>Error checking orders table: <%= e.getMessage() %></p>
                    <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                </div>
            <%
            }
            %>
        </div>

        <div class="section">
            <h2>3. OrderDAO Test</h2>
            <%
            try {
                OrderDAO orderDAO = new OrderDAO();
                List<Order> orders = orderDAO.getAllOrders();
            %>
                <div class="success">OrderDAO.getAllOrders() returned <%= orders.size() %> orders</div>

                <% if (!orders.isEmpty()) { %>
                <h3>First Order Details:</h3>
                <table>
                    <tr>
                        <th>Property</th>
                        <th>Value</th>
                    </tr>
                    <tr>
                        <td>ID</td>
                        <td><%= orders.get(0).getId() %></td>
                    </tr>
                    <tr>
                        <td>User ID</td>
                        <td><%= orders.get(0).getUserId() %></td>
                    </tr>
                    <tr>
                        <td>Total Price</td>
                        <td><%= orders.get(0).getTotalPrice() %></td>
                    </tr>
                    <tr>
                        <td>Order Date</td>
                        <td><%= orders.get(0).getOrderDate() %></td>
                    </tr>
                    <tr>
                        <td>Status</td>
                        <td><%= orders.get(0).getStatus() %></td>
                    </tr>
                    <tr>
                        <td>Shipping Address</td>
                        <td><%= orders.get(0).getShippingAddress() != null ? orders.get(0).getShippingAddress() : "NULL" %></td>
                    </tr>
                    <tr>
                        <td>Payment Method</td>
                        <td><%= orders.get(0).getPaymentMethod() != null ? orders.get(0).getPaymentMethod() : "NULL" %></td>
                    </tr>
                </table>
                <% } %>
            <%
            } catch (Exception e) {
            %>
                <div class="error">
                    <p>Error using OrderDAO: <%= e.getMessage() %></p>
                    <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                </div>
            <%
            }
            %>
        </div>

        <div class="section">
            <h2>4. AdminOrderServlet Test</h2>
            <p>Click the button below to test the AdminOrderServlet directly:</p>
            <form action="<%= request.getContextPath() %>/AdminOrderServlet" method="get">
                <input type="hidden" name="action" value="list">
                <button type="submit">Test AdminOrderServlet</button>
            </form>
        </div>
        <% } %>

        <div>
            <a href="<%= request.getContextPath() %>/admin/orders.jsp">Go to Orders Page</a> |
            <a href="<%= request.getContextPath() %>/admin/dashboard.jsp">Back to Dashboard</a>
        </div>
    </div>
</body>
</html>
