<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Message" %>
<%@ page import="dao.MessageDAO" %>
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

// Get messages - check if they're already in request attributes first
List<Message> messages = (List<Message>) request.getAttribute("messages");
String filterType = (String) request.getAttribute("filter");

// If not in request attributes, get them from the database
MessageDAO messageDAO = new MessageDAO();
if (messages == null) {
    // Check if there's a filter parameter
    String filter = request.getParameter("filter");

    if ("unread".equals(filter)) {
        messages = messageDAO.getUnreadMessages();
        filterType = "unread";
    } else if ("replied".equals(filter)) {
        messages = messageDAO.getRepliedMessages();
        filterType = "replied";
    } else {
        messages = messageDAO.getAllMessages();
        filterType = "all";
    }
}

// Get unread count
int unreadCount = messageDAO.getUnreadMessageCount();

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Messages</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <style>
        /* Additional compact styles */
        .admin-content {
            padding: 10px;
        }
        .dashboard-header {
            margin-bottom: 10px;
            padding: 8px 0;
        }
        .page-title {
            font-size: 18px;
            margin: 0;
        }
        .dashboard-container {
            min-height: auto;
        }
        .main-content {
            padding: 10px;
        }
        .alert {
            padding: 8px;
            margin-bottom: 10px;
        }
        /* Make table more compact */
        .data-table td, .data-table th {
            padding: 4px 6px;
            font-size: 12px;
        }
        /* Reduce spacing in sidebar */
        .sidebar-menu a {
            padding: 8px 15px;
        }
        /* Compact filter section */
        .section-card {
            margin-bottom: 10px;
        }
        .section-header {
            padding: 8px 10px;
        }
        .section-title {
            font-size: 14px;
        }
        .filter-options {
            padding: 8px 10px;
        }
        .filter-form {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .form-group {
            margin-bottom: 0;
            flex: 1;
        }
        .form-control {
            padding: 4px 8px;
            font-size: 12px;
            height: 30px;
        }
        .form-actions .btn-primary {
            padding: 4px 8px;
            font-size: 12px;
            height: 30px;
        }
        /* Compact card */
        .card {
            margin-bottom: 10px;
        }
        .card-header {
            padding: 8px 10px;
        }
        .card-title {
            font-size: 14px;
        }
        .message-stats {
            gap: 10px;
        }
        .message-stats .stat-item {
            font-size: 12px;
        }
        /* Compact action buttons */
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .btn-view, .btn-delete {
            width: 24px;
            height: 24px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .btn-view i, .btn-delete i {
            font-size: 12px;
        }
        /* Truncate message text */
        .message-text {
            max-width: 150px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        /* Status badge */
        .status {
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 10px;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <!-- Include sidebar -->
        <jsp:include page="sidebar.jsp" />

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Message Management</h1>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Filter Messages</h2>
                    <div class="filter-status">
                        <% if (filterType != null) { %>
                            <span class="badge badge-<%= filterType.equals("all") ? "primary" : (filterType.equals("unread") ? "warning" : "success") %>">
                                <%= filterType.equals("all") ? "All Messages" : (filterType.equals("unread") ? "New Messages" : "Replied Messages") %>
                            </span>
                        <% } %>
                    </div>
                </div>
                <div class="filter-options">
                    <form action="<%= request.getContextPath() %>/AdminMessageServlet" method="get" class="filter-form">
                        <input type="hidden" name="action" value="list">
                        <div class="form-group">
                            <select id="filterSelect" name="filter" class="form-control">
                                <option value="all" <%= (filterType == null || "all".equals(filterType)) ? "selected" : "" %>>All Messages</option>
                                <option value="unread" <%= "unread".equals(filterType) ? "selected" : "" %>>New Messages</option>
                                <option value="replied" <%= "replied".equals(filterType) ? "selected" : "" %>>Replied Messages</option>
                            </select>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">
                                <i class="fas fa-filter"></i> Filter
                            </button>
                        </div>
                    </form>
                </div>
            </div>

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
                        <h2 class="card-title">
                            <% if ("unread".equals(filterType)) { %>
                                New Messages
                            <% } else if ("replied".equals(filterType)) { %>
                                Replied Messages
                            <% } else { %>
                                All Messages
                            <% } %>
                        </h2>
                        <div class="message-stats">
                            <div class="stat-item">
                                <span class="stat-label">Total:</span>
                                <span class="stat-value"><%= messages.size() %></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">Unread:</span>
                                <span class="stat-value"><%= unreadCount %></span>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th style="width: 40px;">ID</th>
                                        <th style="width: 120px;">Name</th>
                                        <th style="width: 150px;">Email</th>
                                        <th style="width: 150px;">Subject</th>
                                        <th style="width: 150px;">Message</th>
                                        <th style="width: 100px;">Date</th>
                                        <th style="width: 80px;">Status</th>
                                        <th style="width: 70px;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% if (messages.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center">
                                            <% if ("unread".equals(filterType)) { %>
                                                No new messages found
                                            <% } else if ("replied".equals(filterType)) { %>
                                                No replied messages found
                                            <% } else { %>
                                                No messages found
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } else {
                                    for (Message msg : messages) {
                                        String statusClass = msg.isReplied() ? "status-replied" : "status-unread";
                                        String statusText = msg.isReplied() ? "Response sent" : "Awaiting response";
                                %>
                                    <tr class="<%= statusClass %>">
                                        <td><%= msg.getId() %></td>
                                        <td><%= msg.getName() %></td>
                                        <td><%= msg.getEmail() %></td>
                                        <td><%= msg.getSubject() %></td>
                                        <td><div class="message-text"><%= msg.getMessage().length() > 30 ? msg.getMessage().substring(0, 27) + "..." : msg.getMessage() %></div></td>
                                        <td><%= dateFormat.format(msg.getCreatedAt()) %></td>
                                        <td><span class="status <%= statusClass %>"><%= statusText %></span></td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=view&id=<%= msg.getId() %>" class="btn-view" title="View Message">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <a href="<%= request.getContextPath() %>/AdminMessageServlet?action=delete&id=<%= msg.getId() %>" class="btn-delete" title="Delete Message" onclick="return confirm('Are you sure you want to delete this message?')">
                                                    <i class="fas fa-trash"></i>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                <% }
                                } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle
        document.getElementById('toggleSidebar').addEventListener('click', function() {
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
