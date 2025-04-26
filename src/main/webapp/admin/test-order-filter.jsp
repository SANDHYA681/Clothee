<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Order" %>
<%@ page import="model.User" %>
<%@ page import="service.AdminOrderService" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>

<%
// Check if user is logged in and is an admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User user = (User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get status filter parameter
String statusFilter = request.getParameter("status");
if (statusFilter == null) {
    statusFilter = "all";
}

// Initialize services
AdminOrderService orderService = new AdminOrderService();
OrderDAO orderDAO = new OrderDAO();

// Test variables
boolean connectionSuccess = false;
String connectionError = null;
boolean getAllOrdersSuccess = false;
String getAllOrdersError = null;
boolean getFilteredOrdersSuccess = false;
String getFilteredOrdersError = null;
int totalOrders = 0;
int filteredOrders = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Filter Test</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        
        body {
            background-color: #f5f5f5;
            padding: 20px;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }
        
        h1, h2 {
            color: #333;
        }
        
        .section {
            margin-bottom: 30px;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        .success {
            color: #28a745;
            background-color: #d4edda;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        
        .error {
            color: #dc3545;
            background-color: #f8d7da;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        
        pre {
            background-color: #f8f9fa;
            padding: 10px;
            border-radius: 4px;
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        
        th, td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        th {
            background-color: #f2f2f2;
        }
        
        .filter-form {
            margin-bottom: 20px;
        }
        
        .filter-form select {
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        
        .filter-form button {
            padding: 8px 16px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Order Filter Test Page</h1>
        
        <div class="filter-form">
            <form action="test-order-filter.jsp" method="get">
                <select name="status">
                    <option value="all" <%= "all".equals(statusFilter) ? "selected" : "" %>>All Orders</option>
                    <option value="Pending" <%= "Pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                    <option value="Processing" <%= "Processing".equals(statusFilter) ? "selected" : "" %>>Processing</option>
                    <option value="Shipped" <%= "Shipped".equals(statusFilter) ? "selected" : "" %>>Shipped</option>
                    <option value="Delivered" <%= "Delivered".equals(statusFilter) ? "selected" : "" %>>Delivered</option>
                    <option value="Cancelled" <%= "Cancelled".equals(statusFilter) ? "selected" : "" %>>Cancelled</option>
                </select>
                <button type="submit">Test Filter</button>
            </form>
        </div>
        
        <div class="section">
            <h2>1. Database Connection Test</h2>
            <%
            try {
                Connection conn = DBConnection.getConnection();
                connectionSuccess = conn != null && !conn.isClosed();
                if (connectionSuccess) {
                    conn.close();
                %>
                    <div class="success">Database connection successful!</div>
                <%
                }
            } catch (Exception e) {
                connectionError = e.getMessage();
                %>
                <div class="error">
                    <p>Database connection failed: <%= e.getMessage() %></p>
                    <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                </div>
                <%
            }
            %>
        </div>
        
        <div class="section">
            <h2>2. Get All Orders Test</h2>
            <%
            if (connectionSuccess) {
                try {
                    List<Order> orders = orderService.getAllOrders();
                    totalOrders = orders.size();
                    getAllOrdersSuccess = true;
                    %>
                    <div class="success">Successfully retrieved <%= totalOrders %> orders</div>
                    
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>User ID</th>
                            <th>Status</th>
                            <th>Total</th>
                            <th>Date</th>
                        </tr>
                        <% for (Order order : orders) { %>
                        <tr>
                            <td><%= order.getId() %></td>
                            <td><%= order.getUserId() %></td>
                            <td><%= order.getStatus() %></td>
                            <td>$<%= String.format("%.2f", order.getTotalPrice()) %></td>
                            <td><%= order.getOrderDate() %></td>
                        </tr>
                        <% } %>
                    </table>
                    <%
                } catch (Exception e) {
                    getAllOrdersError = e.getMessage();
                    %>
                    <div class="error">
                        <p>Error getting all orders: <%= e.getMessage() %></p>
                        <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                    </div>
                    <%
                }
            } else {
                %>
                <div class="error">Skipping test because database connection failed</div>
                <%
            }
            %>
        </div>
        
        <div class="section">
            <h2>3. Get Filtered Orders Test</h2>
            <%
            if (connectionSuccess && getAllOrdersSuccess) {
                try {
                    List<Order> orders;
                    if ("all".equals(statusFilter)) {
                        orders = orderService.getAllOrders();
                    } else {
                        orders = orderService.getOrdersByStatus(statusFilter);
                    }
                    filteredOrders = orders.size();
                    getFilteredOrdersSuccess = true;
                    %>
                    <div class="success">Successfully retrieved <%= filteredOrders %> orders with status '<%= statusFilter %>'</div>
                    
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>User ID</th>
                            <th>Status</th>
                            <th>Total</th>
                            <th>Date</th>
                        </tr>
                        <% for (Order order : orders) { %>
                        <tr>
                            <td><%= order.getId() %></td>
                            <td><%= order.getUserId() %></td>
                            <td><%= order.getStatus() %></td>
                            <td>$<%= String.format("%.2f", order.getTotalPrice()) %></td>
                            <td><%= order.getOrderDate() %></td>
                        </tr>
                        <% } %>
                    </table>
                    <%
                } catch (Exception e) {
                    getFilteredOrdersError = e.getMessage();
                    %>
                    <div class="error">
                        <p>Error getting filtered orders: <%= e.getMessage() %></p>
                        <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                    </div>
                    <%
                }
            } else {
                %>
                <div class="error">Skipping test because previous tests failed</div>
                <%
            }
            %>
        </div>
        
        <div class="section">
            <h2>4. Direct SQL Query Test</h2>
            <%
            if (connectionSuccess) {
                try {
                    Connection conn = DBConnection.getConnection();
                    String query = "SELECT * FROM orders";
                    if (!"all".equals(statusFilter)) {
                        query += " WHERE status = ?";
                    }
                    
                    PreparedStatement stmt = conn.prepareStatement(query);
                    if (!"all".equals(statusFilter)) {
                        stmt.setString(1, statusFilter);
                    }
                    
                    ResultSet rs = stmt.executeQuery();
                    int count = 0;
                    %>
                    <div class="success">SQL query executed successfully: <%= query %></div>
                    
                    <table>
                        <tr>
                            <th>ID</th>
                            <th>User ID</th>
                            <th>Status</th>
                            <th>Total</th>
                            <th>Date</th>
                        </tr>
                    <%
                    while (rs.next()) {
                        count++;
                        %>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getInt("user_id") %></td>
                            <td><%= rs.getString("status") %></td>
                            <td>$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
                            <td><%= rs.getTimestamp("order_placed_date") %></td>
                        </tr>
                        <%
                    }
                    %>
                    </table>
                    <p>Found <%= count %> orders with direct SQL query</p>
                    <%
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    %>
                    <div class="error">
                        <p>Error executing direct SQL query: <%= e.getMessage() %></p>
                        <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                    </div>
                    <%
                }
            } else {
                %>
                <div class="error">Skipping test because database connection failed</div>
                <%
            }
            %>
        </div>
        
        <div class="section">
            <h2>Summary</h2>
            <ul>
                <li>Database Connection: <%= connectionSuccess ? "Success" : "Failed - " + connectionError %></li>
                <li>Get All Orders: <%= getAllOrdersSuccess ? "Success - " + totalOrders + " orders" : "Failed - " + getAllOrdersError %></li>
                <li>Get Filtered Orders: <%= getFilteredOrdersSuccess ? "Success - " + filteredOrders + " orders" : "Failed - " + getFilteredOrdersError %></li>
                <li>Current Filter: <%= statusFilter %></li>
            </ul>
        </div>
        
        <p><a href="<%= request.getContextPath() %>/admin/dashboard.jsp">Back to Dashboard</a></p>
    </div>
</body>
</html>
