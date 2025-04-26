<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Category" %>

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
    <title>Add Category - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-style.css">

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .form-control:focus {
            border-color: #4a6bdf;
            outline: none;
            box-shadow: 0 0 0 2px rgba(74, 107, 223, 0.2);
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 30px;
        }

        .btn-cancel {
            background-color: #f5f5f5;
            color: #333;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
        }

        .btn-submit {
            background-color: #4a6bdf;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
        }

        .alert {
            padding: 10px 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%= request.getContextPath() %>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <img src="../images/default-profile.jpg" alt="Admin">
                    </div>
                    <div class="user-details">
                        <h4><%= user.getFirstName() + " " + user.getLastName() %></h4>
                        <p>Administrator</p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a href="<%= request.getContextPath() %>/admin/products.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-box"></i></span>
                    Products
                </a>
                <a href="<%= request.getContextPath() %>/admin/categories.jsp" class="menu-item active">
                    <span class="menu-icon"><i class="fas fa-tags"></i></span>
                    Categories
                </a>
                <a href="<%= request.getContextPath() %>/admin/orders.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
                    Orders
                </a>
                <a href="<%= request.getContextPath() %>/admin/customers.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-users"></i></span>
                    Customers
                </a>
                <a href="<%= request.getContextPath() %>/admin/reviews.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-star"></i></span>
                    Reviews
                </a>
                <a href="<%= request.getContextPath() %>/admin/profile.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-user-cog"></i></span>
                    Profile
                </a>
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <button id="sidebarToggle" class="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>

                <div class="header-actions">
                    <div class="search-box">
                        <input type="text" placeholder="Search...">
                        <button><i class="fas fa-search"></i></button>
                    </div>

                    <div class="notifications">
                        <button class="notification-btn">
                            <i class="fas fa-bell"></i>
                            <span class="badge">3</span>
                        </button>
                    </div>
                </div>
            </div>

            <div class="content">
                <div class="content-header">
                    <h1>Add New Category</h1>
                    <button class="btn-back" onclick="location.href='<%= request.getContextPath() %>/admin/categories.jsp'">
                        <i class="fas fa-arrow-left"></i> Back to Categories
                    </button>
                </div>

                <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
                %>
                <div class="alert alert-danger">
                    <%= error %>
                </div>
                <% } %>

                <div class="form-container">
                    <form action="<%= request.getContextPath() %>/admin/AdminCategoryServlet" method="post">
                        <input type="hidden" name="action" value="add">

                        <%
                        // Get previously entered values if validation failed
                        String categoryName = (String) request.getAttribute("categoryName");
                        String categoryDescription = (String) request.getAttribute("categoryDescription");

                        // Set default values if not provided
                        if (categoryName == null) categoryName = "";
                        if (categoryDescription == null) categoryDescription = "";
                        %>

                        <div class="form-group">
                            <label for="name" class="form-label">Category Name</label>
                            <input type="text" id="name" name="name" class="form-control" value="<%= categoryName %>" required>
                        </div>

                        <div class="form-group">
                            <label for="description" class="form-label">Description</label>
                            <textarea id="description" name="description" class="form-control"><%= categoryDescription %></textarea>
                        </div>

                        <div class="form-actions">
                            <button type="button" class="btn-cancel" onclick="location.href='<%= request.getContextPath() %>/admin/categories.jsp'">Cancel</button>
                            <button type="submit" class="btn-submit">Add Category</button>
                        </div>
                    </form>

                    <div class="form-note">
                        <p><i class="fas fa-info-circle"></i> You can upload an image for this category after creating it.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle - UI enhancement only
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });
    </script>
</body>
</html>
