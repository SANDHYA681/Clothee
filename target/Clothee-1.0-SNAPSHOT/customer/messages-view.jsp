<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Message" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Get data from controller (attributes set in CustomerMessageServlet)
User user = (User) session.getAttribute("user");
List<Message> messages = (List<Message>) request.getAttribute("messages");

// Null checks - these should never happen if the controller is working correctly
// but it's good practice to handle potential errors in the view
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

// Initialize empty list if messages is null
if (messages == null) {
    messages = java.util.Collections.emptyList();
}

// Format date - view responsibility
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Messages - Clothee</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .message-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }

        .message-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .message-title {
            font-size: 24px;
            font-weight: 600;
        }

        .message-list {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .message-item {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            align-items: center;
            transition: background-color 0.2s;
        }

        .message-item:last-child {
            border-bottom: none;
        }

        .message-item:hover {
            background-color: #f9f9f9;
        }

        .message-subject {
            flex: 1;
            font-weight: 500;
        }

        .message-date {
            color: #777;
            margin: 0 20px;
        }

        .message-status {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            margin-right: 15px;
        }

        .status-replied {
            background-color: #e6f7ff;
            color: #0066cc;
        }

        .status-unread {
            background-color: #fff8e6;
            color: #ff8800;
        }

        .message-actions {
            display: flex;
            gap: 10px;
        }

        .btn-view {
            padding: 5px 15px;
            background-color: #ff8800;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
        }

        .btn-view:hover {
            background-color: #e67a00;
        }

        .empty-message {
            padding: 40px 20px;
            text-align: center;
            color: #777;
        }
    </style>
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="../includes/header.jsp" />

    <div class="message-container">
        <div class="message-header">
            <h1 class="message-title">My Messages</h1>
            <a href="<%=request.getContextPath()%>/ContactServlet" class="btn-view">Send New Message</a>
        </div>

        <%
        String successMessage = request.getParameter("message");
        String error = request.getParameter("error");
        if (successMessage != null && !successMessage.isEmpty()) {
        %>
        <div class="alert alert-success">
            <%= successMessage %>
        </div>
        <% } %>

        <% if (error != null && !error.isEmpty()) { %>
        <div class="alert alert-danger">
            <%= error %>
        </div>
        <% } %>

        <div class="message-list">
            <% if (messages.isEmpty()) { %>
                <div class="empty-message">
                    <p>You don't have any messages yet.</p>
                    <p>Need help? <a href="<%=request.getContextPath()%>/ContactServlet">Contact us</a></p>
                </div>
            <% } else { %>
                <% for (Message message : messages) { %>
                    <div class="message-item">
                        <div class="message-subject">
                            <a href="<%=request.getContextPath()%>/customer-messages?action=view&id=<%= message.getId() %>">
                                <%= message.getSubject() %>
                            </a>
                        </div>
                        <div class="message-date"><%= dateFormat.format(message.getCreatedAt()) %></div>
                        <% if (message.isReplied()) { %>
                            <span class="message-status status-replied">Admin responded</span>
                        <% } else if (!message.isRead()) { %>
                            <span class="message-status status-unread">New message</span>
                        <% } %>
                        <div class="message-actions">
                            <a href="<%=request.getContextPath()%>/customer-messages?action=view&id=<%= message.getId() %>" class="btn-view">View</a>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="../includes/footer.jsp" />

</body>
</html>
