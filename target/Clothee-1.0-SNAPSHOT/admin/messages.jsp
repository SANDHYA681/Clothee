<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Message" %>
<%@ page import="service.MessageService" %>
<%@ page import="java.text.SimpleDateFormat" %>

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

// Get all messages using the service layer (following MVC pattern)
MessageService messageService = new MessageService();
List<Message> messages = messageService.getAllMessages();

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Message Management</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        * {
            font-family: Arial, sans-serif;
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            background-color: #f5f5f5;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .back-button {
            display: inline-block;
            margin-bottom: 20px;
            padding: 8px 16px;
            background-color: #ffffff;
            color: #000000;
            border: 1px solid #000000;
            border-radius: 4px;
            text-decoration: none;
            font-weight: bold;
        }
        .back-button:hover {
            background-color: #000000;
            color: #ffffff;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }
        tr:hover {
            background-color: #f9f9f9;
        }
        .message-text {
            max-width: 200px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .view-link {
            display: inline-block;
            padding: 5px 10px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 3px;
        }
        .view-link:hover {
            background-color: #45a049;
        }

        .delete-link {
            display: inline-block;
            padding: 5px 10px;
            background-color: #f44336;
            color: white;
            text-decoration: none;
            border-radius: 3px;
            margin-left: 5px;
        }

        .delete-link:hover {
            background-color: #d32f2f;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Message Management</h1>

        <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="back-button"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
        <table>
            <thead>
                <tr>
                    <th>User ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Subject</th>
                    <th>Message</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (messages.isEmpty()) { %>
                <tr>
                    <td colspan="7" style="text-align: center;">No messages found</td>
                </tr>
            <% } else {
                for (Message msg : messages) {
            %>
                <tr>
                    <td><%= msg.getUserId() %></td>
                    <td><%= msg.getName() %></td>
                    <td><%= msg.getEmail() %></td>
                    <td><%= msg.getSubject() %></td>
                    <td><div class="message-text"><%= msg.getMessage().length() > 50 ? msg.getMessage().substring(0, 47) + "..." : msg.getMessage() %></div></td>
                    <td><%= dateFormat.format(msg.getCreatedAt()) %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=view&id=<%= msg.getId() %>" class="view-link"><i class="fas fa-eye"></i> View</a>
                        <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=delete&id=<%= msg.getId() %>" class="delete-link" onclick="return confirm('Are you sure you want to delete this message?')"><i class="fas fa-trash"></i> Delete</a>
                    </td>
                </tr>
            <% }
            } %>
            </tbody>
        </table>
    </div>
</body>
</html>
