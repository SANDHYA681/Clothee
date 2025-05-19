<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Check if user is logged in and is an admin - this check is also done in the servlet
// but we keep it here as a safety measure
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User currentUser = (User) userObj;
if (!currentUser.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get users from request attribute (set by servlet)
List<User> users = (List<User>) request.getAttribute("users");
if (users == null) {
    // If users not in request, redirect to the servlet to get the data
    response.sendRedirect(request.getContextPath() + "/AdminUserServlet");
    return;
}

// Get messages from request attributes
String successMessage = (String) request.getAttribute("successMessage");
String errorMessage = (String) request.getAttribute("errorMessage");

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Customers</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-dashboard.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-blue-theme-all.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-customers-enhanced.css">
    <!-- Action buttons fix - must be loaded last to override other styles -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/action-buttons-fix.css">
    <style>
        /* Additional compact styles */
        .admin-content {
            padding: 10px;
        }
        .header {
            margin-bottom: 10px;
            padding: 8px 0;
        }
        .header h1 {
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
        }
        /* Reduce spacing in sidebar */
        .sidebar-menu a {
            padding: 8px 15px;
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
                <h1 class="page-title">Customer Management</h1>
                <div class="header-actions">
                    <!-- Notification and message icons removed as requested -->
                </div>
            </div>

            <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success">
                <%= successMessage %>
            </div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
            <% } %>

            <!-- Customer Statistics -->
            <div class="customer-stats">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value"><%= users.size() %></div>
                        <div class="stat-label">Total Customers</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">
                            <%
                            int adminCount = 0;
                            for (User user : users) {
                                if (user.isAdmin()) adminCount++;
                            }
                            %>
                            <%= adminCount %>
                        </div>
                        <div class="stat-label">Administrators</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-user-check"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">
                            <%
                            int regularCount = 0;
                            for (User user : users) {
                                if (!user.isAdmin()) regularCount++;
                            }
                            %>
                            <%= regularCount %>
                        </div>
                        <div class="stat-label">Regular Customers</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">
                            <%
                            int newCustomers = 0;
                            long thirtyDaysInMillis = 30L * 24 * 60 * 60 * 1000;
                            long currentTimeMillis = System.currentTimeMillis();
                            for (User user : users) {
                                if (user.getCreatedAt() != null &&
                                    (currentTimeMillis - user.getCreatedAt().getTime()) <= thirtyDaysInMillis) {
                                    newCustomers++;
                                }
                            }
                            %>
                            <%= newCustomers %>
                        </div>
                        <div class="stat-label">New (Last 30 Days)</div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">All Customers</h2>
                    <a href="<%= request.getContextPath() %>/AdminUserServlet?action=showAddForm" class="btn-add">
                        <i class="fas fa-plus"></i> Add New Customer
                    </a>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">ID</th>
                                    <th style="width: 150px;">Name</th>
                                    <th style="width: 150px;">Email</th>
                                    <th style="width: 100px;">Phone</th>
                                    <th style="width: 80px;">Role</th>
                                    <th style="width: 120px;">Created At</th>
                                    <th style="width: 90px;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (User user : users) { %>
                                <tr>
                                    <td><%= user.getId() %></td>
                                    <td>
                                        <div style="display: flex; align-items: center;">
                                            <div style="width: 24px; height: 24px; border-radius: 50%; background-color: #e0e7ff; display: flex; align-items: center; justify-content: center; margin-right: 6px; color: #4361ee; font-weight: 600; font-size: 10px;">
                                                <%= user.getFirstName().substring(0, 1).toUpperCase() %><%= user.getLastName().substring(0, 1).toUpperCase() %>
                                            </div>
                                            <div style="font-size: 12px;">
                                                <%= user.getFirstName() %> <%= user.getLastName() %>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="font-size: 12px;"><%= user.getEmail() %></td>
                                    <td style="font-size: 12px;"><%= user.getPhone() != null ? user.getPhone() : "-" %></td>
                                    <td>
                                        <% if (user.isAdmin()) { %>
                                            <span class="badge admin"><%= user.getRole() != null ? user.getRole() : "Admin" %></span>
                                        <% } else { %>
                                            <span class="badge customer"><%= user.getRole() != null ? user.getRole() : "Customer" %></span>
                                        <% } %>
                                    </td>
                                    <td style="font-size: 11px;"><%= user.getCreatedAt() != null ? dateFormat.format(user.getCreatedAt()) : "-" %></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="<%= request.getContextPath() %>/AdminUserServlet?action=view&id=<%= user.getId() %>" class="btn-view" title="View">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <!-- Edit functionality removed as per requirements -->
                                            <% if (user.getId() != currentUser.getId() && !user.isAdmin()) { %>
                                                <a href="<%= request.getContextPath() %>/AdminUserServlet?action=confirmDelete&id=<%= user.getId() %>" class="btn-delete" title="Delete">
                                                    <i class="fas fa-trash"></i>
                                                </a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add minimal JavaScript for sidebar toggle and delete confirmation -->
    <script>
        // Sidebar toggle
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });

        // Confirmation for delete
        document.querySelectorAll('.btn-delete').forEach(button => {
            button.addEventListener('click', function(e) {
                if (!confirm('Are you sure you want to delete this user?')) {
                    e.preventDefault();
                }
            });
        });
    </script>
</body>
</html>
