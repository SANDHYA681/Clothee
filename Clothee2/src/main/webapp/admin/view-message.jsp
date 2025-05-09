<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Message" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.util.Date" %>

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
    response.sendRedirect(request.getContextPath() + "/MessageServlet?error=Message+not+found");
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
    <title>Admin - View Message</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <style>
        .previous-replies {
            margin-top: 20px;
            border-top: 1px solid #e0e7ff;
            padding-top: 20px;
        }

        .previous-replies h3 {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #4361ee;
        }

        .reply-item {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }

        .reply-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .reply-sender {
            font-weight: 600;
            color: #4361ee;
        }

        .reply-date {
            color: #6c757d;
            font-size: 14px;
        }

        .reply-content {
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="user-details">
                        <h4><%= user.getFullName() %></h4>
                        <p>Admin</p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="menu-item">
                    <i class="fas fa-tachometer-alt menu-icon"></i>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/admin/products.jsp" class="menu-item">
                    <i class="fas fa-box menu-icon"></i>
                    Products
                </a>
                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="menu-item">
                    <i class="fas fa-tags menu-icon"></i>
                    Categories
                </a>
                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="menu-item">
                    <i class="fas fa-shopping-bag menu-icon"></i>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="menu-item">
                    <i class="fas fa-users menu-icon"></i>
                    Customers
                </a>
                <a href="<%= request.getContextPath() %>/admin/reviews.jsp" class="menu-item">
                    <i class="fas fa-star menu-icon"></i>
                    Reviews
                </a>
                <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="menu-item active">
                    <i class="fas fa-envelope menu-icon"></i>
                    Messages
                </a>
                <a href="<%= request.getContextPath() %>/admin/settings.jsp" class="menu-item">
                    <i class="fas fa-cog menu-icon"></i>
                    Settings
                </a>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="menu-item">
                    <i class="fas fa-sign-out-alt menu-icon"></i>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Message Details</h1>
                <div class="header-actions">
                    <a href="<%= request.getContextPath() %>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to Messages
            </a>

                <%
                // Get messages from request parameters or attributes
                String successMessage = request.getParameter("success");
                if (successMessage == null) {
                    successMessage = (String) request.getAttribute("success");
                }

                String error = request.getParameter("error");
                if (error == null) {
                    error = (String) request.getAttribute("error");
                }

                // Display success message if present
                if (successMessage != null && !successMessage.isEmpty()) {
                %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <%
                // Display error message if present
                if (error != null && !error.isEmpty()) {
                %>
                <div class="alert alert-danger">
                    <strong>Error:</strong> <%= error %>
                </div>
                <% } %>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title"><%= message.getSubject() %></h2>
                        <% if (!message.isReply()) { %>
                            <span class="status <%= message.isReplied() ? "status-replied" : "status-unread" %>">
                                <%= message.isReplied() ? "Response sent" : "Awaiting response" %>
                            </span>
                        <% } %>
                    </div>
                    <div class="card-body">
                        <div class="message-detail">
                            <div class="message-meta">
                                <div class="info-group">
                                    <div class="info-label"><i class="fas fa-user"></i> From:</div>
                                    <div class="info-value"><strong><%= message.getName() %></strong> (<a href="mailto:<%= message.getEmail() %>"><%= message.getEmail() %></a>)</div>
                                </div>
                                <div class="info-group">
                                    <div class="info-label"><i class="fas fa-envelope"></i> Subject:</div>
                                    <div class="info-value"><strong><%= message.getSubject() %></strong></div>
                                </div>
                                <div class="info-group">
                                    <div class="info-label"><i class="fas fa-calendar-alt"></i> Date:</div>
                                    <div class="info-value"><%= dateFormat.format(message.getCreatedAt()) %></div>
                                </div>
                                <% if (message.getUserId() > 0) { %>
                                <div class="info-group">
                                    <div class="info-label"><i class="fas fa-user-circle"></i> Customer:</div>
                                    <div class="info-value"><a href="<%= request.getContextPath() %>/AdminUserServlet?action=view&id=<%= message.getUserId() %>">View Customer Profile</a></div>
                                </div>
                                <% } %>
                            </div>
                            <div class="message-content">
                                <%
                                String messageText = message.getMessage();
                                // Split message by double newlines to create paragraphs
                                String[] paragraphs = messageText.split("\\n\\n|\\r\\n\\r\\n");
                                for (String paragraph : paragraphs) {
                                    // Replace single newlines with <br> tags
                                    paragraph = paragraph.replaceAll("\\n|\\r\\n", "<br>");
                                    out.println("<p>" + paragraph + "</p>");
                                }
                                %>
                            </div>

                            <%
                            // Display previous replies if any
                            List<Message> replies = (List<Message>) request.getAttribute("replies");
                            if (replies != null && !replies.isEmpty()) {
                            %>
                            <div class="previous-replies">
                                <h3>Previous Replies</h3>
                                <% for (Message reply : replies) { %>
                                <div class="reply-item">
                                    <div class="reply-header">
                                        <div class="reply-sender"><%= reply.getName() %> (<%= reply.getEmail() %>)</div>
                                        <div class="reply-date"><%= dateFormat.format(reply.getCreatedAt()) %></div>
                                    </div>
                                    <div class="reply-content">
                                        <%= reply.getMessage().replace("\n", "<br>") %>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                            <% } %>
                        </div>

                        <div class="reply-form">
                            <h3>Reply to <%= message.getName() %></h3>
                            <form action="<%= request.getContextPath() %>/AdminMessageServlet" method="post" id="replyForm">
                                <input type="hidden" name="action" value="reply">
                                <input type="hidden" name="messageId" value="<%= message.getId() %>">
                                <div class="form-group">
                                    <div class="reply-info">
                                        <div class="info-group">
                                            <div class="info-label"><i class="fas fa-user"></i> Replying as:</div>
                                            <div class="info-value">
                                                <strong><%= user.getFullName() %></strong>
                                                (<%= user.getEmail() %>)
                                            </div>
                                        </div>
                                    </div>
                                    <textarea name="replyContent" rows="5" class="form-control" placeholder="Type your reply here..." required></textarea>
                                    <div class="form-hint">Your reply will be sent to <%= message.getEmail() %></div>
                                </div>
                                <div class="form-actions">
                                    <a href="<%= request.getContextPath() %>/admin/messages.jsp" class="btn-secondary">
                                        <i class="fas fa-times"></i> Cancel
                                    </a>
                                    <button type="submit" class="btn-primary">
                                        <i class="fas fa-paper-plane"></i> Send Reply
                                    </button>
                                    <a href="<%= request.getContextPath() %>/admin/messages/delete?id=<%= message.getId() %>" class="btn-danger" onclick="return confirm('Are you sure you want to delete this message? This action cannot be undone.')">
                                        <i class="fas fa-trash"></i> Delete
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle
        document.getElementById('sidebarToggle') && document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });

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
