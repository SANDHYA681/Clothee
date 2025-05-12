<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Message" %>
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

// Get message from request attribute
Message message = (Message) request.getAttribute("message");
if (message == null) {
    response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Message+not+found");
    return;
}

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Message</title>
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
            max-width: 800px;
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
        .message-details {
            margin-top: 20px;
        }
        .message-field {
            margin-bottom: 15px;
        }
        .field-label {
            font-weight: bold;
            margin-bottom: 5px;
            color: #555;
        }
        .field-value {
            padding: 10px;
            background-color: #f9f9f9;
            border-radius: 4px;
            border: 1px solid #eee;
        }
        .message-content {
            white-space: pre-wrap;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Message Details</h1>

        <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="back-button">Back to Messages</a>

        <div class="message-details">
            <div class="message-field">
                <div class="field-label">User ID:</div>
                <div class="field-value"><%= message.getUserId() %></div>
            </div>

            <div class="message-field">
                <div class="field-label">Name:</div>
                <div class="field-value"><%= message.getName() %></div>
            </div>

            <div class="message-field">
                <div class="field-label">Email:</div>
                <div class="field-value"><%= message.getEmail() %></div>
            </div>

            <div class="message-field">
                <div class="field-label">Subject:</div>
                <div class="field-value"><%= message.getSubject() %></div>
            </div>

            <div class="message-field">
                <div class="field-label">Date:</div>
                <div class="field-value"><%= dateFormat.format(message.getCreatedAt()) %></div>
            </div>

            <div class="message-field">
                <div class="field-label">Message:</div>
                <div class="field-value message-content"><%= message.getMessage() %></div>
            </div>

            <!-- Reply Form -->
            <div class="reply-form">
                <h3>Reply to this message</h3>
                <form action="<%= request.getContextPath() %>/MessageServlet" method="post">
                    <input type="hidden" name="action" value="reply">
                    <input type="hidden" name="messageId" value="<%= message.getId() %>">
                    <div class="form-group">
                        <textarea name="replyContent" rows="5" class="form-control" placeholder="Type your reply here..." required></textarea>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="reply-button">Send Reply</button>
                    </div>
                </form>
            </div>

            <!-- Replies Section -->
            <%
            List<Message> replies = (List<Message>) request.getAttribute("replies");
            if (replies != null && !replies.isEmpty()) {
            %>
            <div class="replies-section">
                <h3>Previous Replies</h3>
                <% for (Message reply : replies) { %>
                <div class="reply">
                    <div class="reply-header">
                        <div class="reply-sender"><%= reply.getName() %> (<%= reply.getEmail() %>)</div>
                        <div class="reply-date"><%= dateFormat.format(reply.getCreatedAt()) %></div>
                    </div>
                    <div class="reply-content">
                        <%= reply.getMessage() %>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <style>
        /* Additional styles for replies and reply form */
        .reply-form {
            margin-top: 30px;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }

        .reply-form h3 {
            margin-bottom: 15px;
            font-size: 18px;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-family: Arial, sans-serif;
            resize: vertical;
        }

        .form-actions {
            margin-top: 10px;
        }

        .reply-button {
            padding: 8px 16px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
        }

        .reply-button:hover {
            background-color: #45a049;
        }

        .replies-section {
            margin-top: 30px;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }

        .replies-section h3 {
            margin-bottom: 15px;
            font-size: 18px;
        }

        .reply {
            background-color: #f9f9f9;
            border-left: 3px solid #4CAF50;
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 4px;
        }

        .reply-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 14px;
        }

        .reply-sender {
            font-weight: bold;
        }

        .reply-date {
            color: #777;
        }

        .reply-content {
            line-height: 1.5;
        }
    </style>
</body>
</html>
