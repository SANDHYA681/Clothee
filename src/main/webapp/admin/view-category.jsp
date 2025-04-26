<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
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

// Get category from request attribute
Category category = (Category) request.getAttribute("category");
if (category == null) {
    response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=Category+not+found");
    return;
}

// Get products in this category
List<Product> products = (List<Product>) request.getAttribute("products");

// Format date
SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Category - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/admin-unified.css">
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
                        <p>Administrator</p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="dashboard.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a href="products.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-box"></i></span>
                    Products
                </a>
                <a href="categories.jsp" class="menu-item active">
                    <span class="menu-icon"><i class="fas fa-tags"></i></span>
                    Categories
                </a>
                <a href="orders.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
                    Orders
                </a>
                <a href="customers.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-users"></i></span>
                    Customers
                </a>
                <a href="reviews.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-star"></i></span>
                    Reviews
                </a>
                <a href="messages.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-envelope"></i></span>
                    Messages
                </a>
                <a href="settings.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-cog"></i></span>
                    Settings
                </a>
                <a href="../LogoutServlet" class="menu-item">
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
                    <h1>Category Details: <%= category.getName() %></h1>
                    <div>
                        <button class="btn-edit" onclick="location.href='../admin/CategoryServlet?action=edit&id=<%= category.getId() %>'">
                            <i class="fas fa-edit"></i> Edit Category
                        </button>
                        <button class="btn-back" onclick="location.href='categories.jsp'">
                            <i class="fas fa-arrow-left"></i> Back to Categories
                        </button>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Category Information</h2>
                    </div>
                    <div class="card-body">
                        <div class="info-group">
                            <div class="info-label">ID:</div>
                            <div class="info-value"><%= category.getId() %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Name:</div>
                            <div class="info-value"><%= category.getName() %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Description:</div>
                            <div class="info-value"><%= category.getDescription() != null ? category.getDescription() : "-" %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Created At:</div>
                            <div class="info-value"><%= category.getCreatedAt() != null ? dateFormat.format(category.getCreatedAt()) : "-" %></div>
                        </div>
                        <div class="info-group">
                            <div class="info-label">Product Count:</div>
                            <div class="info-value"><%= category.getProductCount() %></div>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Products in this Category</h2>
                        <button class="btn-add" onclick="location.href='add-product.jsp?category=<%= category.getName() %>'">
                            <i class="fas fa-plus"></i> Add New Product
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Image</th>
                                        <th>Name</th>
                                        <th>Price</th>
                                        <th>Stock</th>
                                        <th>Type</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (products != null && !products.isEmpty()) { %>
                                        <% for (Product product : products) { %>
                                            <tr>
                                                <td><%= product.getId() %></td>
                                                <td>
                                                    <div class="product-image">
                                                        <img src="../<%= product.getImageUrl() != null ? product.getImageUrl() : "images/products/placeholder.jpg" %>" alt="<%= product.getName() %>">
                                                    </div>
                                                </td>
                                                <td><%= product.getName() %></td>
                                                <td><%= product.getFormattedPrice() %></td>
                                                <td><%= product.getStock() %></td>
                                                <td><%= product.getType() != null ? product.getType() : "-" %></td>
                                                <td>
                                                    <div class="action-buttons">
                                                        <a href="view-product.jsp?id=<%= product.getId() %>" class="btn-view" title="View">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <a href="edit-product.jsp?id=<%= product.getId() %>" class="btn-edit" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <a href="../ProductServlet?action=delete&id=<%= product.getId() %>" class="btn-delete" title="Delete" onclick="return confirm('Are you sure you want to delete this product?')">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    <% } else { %>
                                        <tr>
                                            <td colspan="7" class="text-center">No products found in this category.</td>
                                        </tr>
                                    <% } %>
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
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });
    </script>
</body>
</html>
