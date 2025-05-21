<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blue Theme Demo - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-blue-theme-unified.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f0f5ff;
            margin: 0;
            padding: 0;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            color: #1e3a8a;
            margin: 0;
        }
        
        .section {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
        }
        
        .section-title {
            color: #1e3a8a;
            margin-top: 0;
            margin-bottom: 20px;
            border-bottom: 1px solid #e0e7ff;
            padding-bottom: 10px;
        }
        
        .card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }
        
        .card {
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            padding: 20px;
            border-left: 4px solid #4361ee;
        }
        
        .card-title {
            color: #1e3a8a;
            margin-top: 0;
            margin-bottom: 10px;
        }
        
        .card-value {
            font-size: 24px;
            font-weight: 700;
            color: #4361ee;
            margin-bottom: 10px;
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .table th {
            background-color: #f0f5ff;
            color: #1e3a8a;
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
        }
        
        .table td {
            padding: 12px 15px;
            border-bottom: 1px solid #e0e7ff;
        }
        
        .table tr:hover {
            background-color: rgba(67, 97, 238, 0.05);
        }
        
        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-pending {
            background-color: rgba(243, 156, 18, 0.1);
            color: #f39c12;
        }
        
        .status-processing {
            background-color: rgba(52, 152, 219, 0.1);
            color: #3498db;
        }
        
        .status-completed {
            background-color: rgba(46, 204, 113, 0.1);
            color: #2ecc71;
        }
        
        .status-cancelled {
            background-color: rgba(231, 76, 60, 0.1);
            color: #e74c3c;
        }
        
        .btn {
            display: inline-block;
            padding: 8px 15px;
            border-radius: 5px;
            font-weight: 500;
            text-decoration: none;
            cursor: pointer;
        }
        
        .btn-primary {
            background-color: #4361ee;
            color: #ffffff;
            border: none;
        }
        
        .btn-primary:hover {
            background-color: #3a56d4;
        }
        
        .btn-secondary {
            background-color: #4cc9f0;
            color: #ffffff;
            border: none;
        }
        
        .btn-secondary:hover {
            background-color: #3ab7de;
        }
        
        .btn-danger {
            background-color: #e74c3c;
            color: #ffffff;
            border: none;
        }
        
        .btn-danger:hover {
            background-color: #c0392b;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #1e3a8a;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #e0e7ff;
            border-radius: 5px;
        }
        
        .form-control:focus {
            border-color: #4361ee;
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(67, 97, 238, 0.25);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Blue Theme Demo</h1>
            <a href="dashboard.jsp" class="btn btn-primary">Back to Dashboard</a>
        </div>
        
        <div class="section">
            <h2 class="section-title">Dashboard Cards</h2>
            <div class="card-grid">
                <div class="card">
                    <h3 class="card-title">Total Orders</h3>
                    <div class="card-value">256</div>
                    <p>Last 30 days</p>
                </div>
                <div class="card">
                    <h3 class="card-title">Total Products</h3>
                    <div class="card-value">128</div>
                    <p>Active products</p>
                </div>
                <div class="card">
                    <h3 class="card-title">Total Customers</h3>
                    <div class="card-value">512</div>
                    <p>Registered users</p>
                </div>
                <div class="card">
                    <h3 class="card-title">Total Revenue</h3>
                    <div class="card-value">$12,345</div>
                    <p>Last 30 days</p>
                </div>
            </div>
        </div>
        
        <div class="section">
            <h2 class="section-title">Table Example</h2>
            <table class="table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Customer</th>
                        <th>Date</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>#1001</td>
                        <td>John Doe</td>
                        <td>2023-06-15</td>
                        <td>$125.00</td>
                        <td><span class="status status-completed">Completed</span></td>
                        <td>
                            <a href="#" class="btn btn-primary">View</a>
                            <a href="#" class="btn btn-secondary">Edit</a>
                            <a href="#" class="btn btn-danger">Delete</a>
                        </td>
                    </tr>
                    <tr>
                        <td>#1002</td>
                        <td>Jane Smith</td>
                        <td>2023-06-16</td>
                        <td>$85.50</td>
                        <td><span class="status status-processing">Processing</span></td>
                        <td>
                            <a href="#" class="btn btn-primary">View</a>
                            <a href="#" class="btn btn-secondary">Edit</a>
                            <a href="#" class="btn btn-danger">Delete</a>
                        </td>
                    </tr>
                    <tr>
                        <td>#1003</td>
                        <td>Bob Johnson</td>
                        <td>2023-06-17</td>
                        <td>$210.75</td>
                        <td><span class="status status-pending">Pending</span></td>
                        <td>
                            <a href="#" class="btn btn-primary">View</a>
                            <a href="#" class="btn btn-secondary">Edit</a>
                            <a href="#" class="btn btn-danger">Delete</a>
                        </td>
                    </tr>
                    <tr>
                        <td>#1004</td>
                        <td>Alice Brown</td>
                        <td>2023-06-18</td>
                        <td>$45.25</td>
                        <td><span class="status status-cancelled">Cancelled</span></td>
                        <td>
                            <a href="#" class="btn btn-primary">View</a>
                            <a href="#" class="btn btn-secondary">Edit</a>
                            <a href="#" class="btn btn-danger">Delete</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <div class="section">
            <h2 class="section-title">Form Example</h2>
            <form>
                <div class="form-group">
                    <label class="form-label">Name</label>
                    <input type="text" class="form-control" placeholder="Enter name">
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" placeholder="Enter email">
                </div>
                <div class="form-group">
                    <label class="form-label">Message</label>
                    <textarea class="form-control" rows="5" placeholder="Enter message"></textarea>
                </div>
                <button type="submit" class="btn btn-primary">Submit</button>
            </form>
        </div>
    </div>
</body>
</html>
