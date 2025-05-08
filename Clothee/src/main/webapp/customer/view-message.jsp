<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Message" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Get data from controller (attributes set in CustomerMessageServlet)
User user = (User) session.getAttribute("user");
Message message = (Message) request.getAttribute("message");
List<Message> replies = (List<Message>) request.getAttribute("replies");

// Null checks - these should never happen if the controller is working correctly
// but it's good practice to handle potential errors in the view
if (user == null || message == null) {
    response.sendRedirect(request.getContextPath() + "/customer-messages");
    return;
}

// Initialize empty list if replies is null
if (replies == null) {
    replies = new java.util.ArrayList<>();
}

// Debug information
System.out.println("view-message.jsp: Message ID = " + message.getId() + ", Subject = " + message.getSubject());
System.out.println("view-message.jsp: Message is_replied = " + message.isReplied());
System.out.println("view-message.jsp: Number of replies = " + replies.size());

// Format date - view responsibility
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Message - Clothee</title>
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

        .message-detail {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 30px;
        }

        .message-detail-header {
            padding: 20px;
            border-bottom: 1px solid #eee;
            background-color: #f9f9f9;
        }

        .message-subject {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .message-info {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            font-size: 14px;
            color: #666;
        }

        .message-content {
            padding: 20px;
            line-height: 1.6;
        }

        .btn-back {
            padding: 8px 20px;
            background-color: #ff8800;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-back:hover {
            background-color: #e67a00;
        }

        .reply-section {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .reply-header {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            background-color: #f9f9f9;
            font-weight: 600;
        }

        .reply-item {
            padding: 20px;
            border-bottom: 1px solid #eee;
        }

        .reply-item:last-child {
            border-bottom: none;
        }

        .reply-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 14px;
        }

        .reply-sender {
            font-weight: 600;
            color: #333;
        }

        .reply-date {
            color: #777;
        }

        .reply-content {
            line-height: 1.6;
        }

        .no-replies {
            padding: 20px;
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
            <h1 class="message-title">Message Details</h1>
            <a href="<%=request.getContextPath()%>/customer-messages" class="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Messages
            </a>
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

        <div class="message-detail">
            <div class="message-detail-header">
                <div class="message-subject"><%= message.getSubject() %></div>
                <div class="message-info">
                    <div><strong>From:</strong> You</div>
                    <div><strong>To:</strong> Clothee Support</div>
                    <div><strong>Date:</strong> <%= dateFormat.format(message.getCreatedAt()) %></div>
                    <div><strong>Status:</strong>
                        <% if (message.isReplied()) { %>
                            <span style="color: #0066cc;">Admin has responded</span>
                        <% } else { %>
                            <span style="color: #777;">Waiting for response</span>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="message-content">
                <%= message.getMessage().replace("\n", "<br>") %>
            </div>
        </div>

        <% if (!replies.isEmpty()) { %>
            <div class="reply-section">
                <div class="reply-header">
                    <i class="fas fa-reply"></i> Responses from Clothee Support
                </div>

                <% for (Message reply : replies) { %>
                    <div class="reply-item">
                        <div class="reply-info">
                            <div class="reply-sender"><%= reply.getName() %> (Clothee Support)</div>
                            <div class="reply-date"><%= dateFormat.format(reply.getCreatedAt()) %></div>
                        </div>
                        <div class="reply-content">
                            <%= reply.getMessage().replace("\n", "<br>") %>
                        </div>
                        <% System.out.println("view-message.jsp: Displaying reply ID = " + reply.getId() + ", From: " + reply.getName()); %>
                    </div>
                <% } %>
            </div>
        <% } else if (message.isReplied()) { %>
            <div class="reply-section">
                <div class="reply-header">
                    <i class="fas fa-reply"></i> Responses from Clothee Support
                </div>
                <div style="padding: 20px; text-align: center; color: #666;">
                    <p>This message has been replied to, but the replies cannot be displayed.</p>
                    <p>Please contact customer support if you need assistance.</p>
                </div>
            </div>
        <% } %>
    </div>

    <!-- Include Footer -->
    <jsp:include page="../includes/footer.jsp" />

    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>
