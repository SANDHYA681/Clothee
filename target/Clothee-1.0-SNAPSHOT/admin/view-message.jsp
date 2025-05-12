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

        <div class="action-buttons">
            <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="back-button">Back to Messages</a>
            <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=delete&id=<%= message.getId() %>" class="delete-button" onclick="return confirm('Are you sure you want to delete this message?')">Delete Message</a>
        </div>

        <%
        // Display error message if there is one
        String error = request.getParameter("error");
        if (error != null && !error.isEmpty()) {
        %>
        <div class="error-message">
            <%= error %>
        </div>
        <% } %>

        <%
        // Display success message if there is one
        String success = request.getParameter("success");
        if (success != null && !success.isEmpty()) {
        %>
        <div class="success-message">
            <%= success %>
        </div>
        <% } %>

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

            <%
            // Only show reply form for original customer messages (not admin replies)
            if (!message.isReply()) {
            %>
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
            <% } %>

            <!-- Replies Section -->
            <%
            List<Message> replies = (List<Message>) request.getAttribute("replies");
            if (replies != null && !replies.isEmpty()) {
            %>
            <div class="replies-section">
                <h3>Previous Replies</h3>
                <% for (Message reply : replies) { %>
                <div class="reply" id="reply-<%= reply.getId() %>">
                    <div class="reply-header">
                        <div class="reply-sender"><%= reply.getName() %> (<%= reply.getEmail() %>)</div>
                        <div class="reply-date"><%= dateFormat.format(reply.getCreatedAt()) %></div>
                    </div>
                    <div class="reply-content" id="reply-content-<%= reply.getId() %>">
                        <%= reply.getMessage() %>
                    </div>
                    <div class="reply-actions">
                        <button onclick="editReply(<%= reply.getId() %>)" class="edit-button">Edit</button>
                        <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=delete&id=<%= reply.getId() %>" class="delete-button" onclick="return confirm('Are you sure you want to delete this reply?')">Delete</a>
                    </div>
                    <div class="edit-form" id="edit-form-<%= reply.getId() %>" style="display: none;">
                        <textarea id="edit-content-<%= reply.getId() %>" rows="5" class="form-control"><%= reply.getMessage() %></textarea>
                        <div class="form-actions">
                            <button onclick="saveEdit(<%= reply.getId() %>)" class="save-button">Save</button>
                            <button onclick="cancelEdit(<%= reply.getId() %>)" class="cancel-button">Cancel</button>
                        </div>
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
        /* Additional styles for action buttons */
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .delete-button {
            display: inline-block;
            padding: 8px 16px;
            background-color: #f44336;
            color: white;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            font-weight: bold;
            cursor: pointer;
        }

        .delete-button:hover {
            background-color: #d32f2f;
        }

        .edit-button {
            display: inline-block;
            padding: 5px 10px;
            background-color: #2196F3;
            color: white;
            border: none;
            border-radius: 3px;
            text-decoration: none;
            cursor: pointer;
            margin-right: 5px;
        }

        .edit-button:hover {
            background-color: #0b7dda;
        }

        .save-button {
            display: inline-block;
            padding: 5px 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 3px;
            text-decoration: none;
            cursor: pointer;
            margin-right: 5px;
        }

        .save-button:hover {
            background-color: #45a049;
        }

        .cancel-button {
            display: inline-block;
            padding: 5px 10px;
            background-color: #9e9e9e;
            color: white;
            border: none;
            border-radius: 3px;
            text-decoration: none;
            cursor: pointer;
        }

        .cancel-button:hover {
            background-color: #757575;
        }

        .reply-actions {
            margin-top: 10px;
        }

        .edit-form {
            margin-top: 10px;
        }

        .error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            border-left: 4px solid #c62828;
        }

        .success-message {
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            border-left: 4px solid #2e7d32;
        }
    </style>

    <script>
        // Function to show edit form for a reply
        function editReply(replyId) {
            document.getElementById('reply-content-' + replyId).style.display = 'none';
            document.getElementById('edit-form-' + replyId).style.display = 'block';
        }

        // Function to cancel editing a reply
        function cancelEdit(replyId) {
            document.getElementById('reply-content-' + replyId).style.display = 'block';
            document.getElementById('edit-form-' + replyId).style.display = 'none';
        }

        // Function to save edited reply
        function saveEdit(replyId) {
            const content = document.getElementById('edit-content-' + replyId).value;

            // Create a form and submit it
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '<%= request.getContextPath() %>/AdminMessageServlet';

            // Add action parameter
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'editReply';
            form.appendChild(actionInput);

            // Add replyId parameter
            const replyIdInput = document.createElement('input');
            replyIdInput.type = 'hidden';
            replyIdInput.name = 'replyId';
            replyIdInput.value = replyId;
            form.appendChild(replyIdInput);

            // Add content parameter
            const contentInput = document.createElement('input');
            contentInput.type = 'hidden';
            contentInput.name = 'replyContent';
            contentInput.value = content;
            form.appendChild(contentInput);

            // Add the form to the body and submit it
            document.body.appendChild(form);
            form.submit();
        }
    </script>
</body>
</html>
