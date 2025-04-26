<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Clothee</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-simple-style.css">
    <!-- Font Awesome for icons (optional) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body>
    <div class="admin-container">
        <!-- Sidebar -->
        <div class="admin-sidebar">
            <div class="admin-logo">
                Clothee <span>Admin</span>
            </div>
            
            <div class="admin-user">
                <div class="admin-user-avatar">
                    <img src="<%=request.getContextPath()%>/images/admin-avatar.jpg" alt="Admin">
                </div>
                <div class="admin-user-name">Admin User</div>
                <div class="admin-user-role">Administrator</div>
            </div>
            
            <div class="admin-menu">
                <a href="<%=request.getContextPath()%>/admin/dashboard" class="admin-menu-item active">
                    <i class="admin-menu-icon fas fa-tachometer-alt"></i>
                    <span>Dashboard</span>
                </a>
                <a href="<%=request.getContextPath()%>/admin/products" class="admin-menu-item">
                    <i class="admin-menu-icon fas fa-box"></i>
                    <span>Products</span>
                </a>
                <a href="<%=request.getContextPath()%>/admin/categories" class="admin-menu-item">
                    <i class="admin-menu-icon fas fa-tags"></i>
                    <span>Categories</span>
                </a>
                <a href="<%=request.getContextPath()%>/admin/orders" class="admin-menu-item">
                    <i class="admin-menu-icon fas fa-shopping-cart"></i>
                    <span>Orders</span>
                </a>
                <a href="<%=request.getContextPath()%>/admin/customers" class="admin-menu-item">
                    <i class="admin-menu-icon fas fa-users"></i>
                    <span>Customers</span>
                </a>
                <a href="<%=request.getContextPath()%>/admin/messages" class="admin-menu-item">
                    <i class="admin-menu-icon fas fa-envelope"></i>
                    <span>Messages</span>
                </a>
                <a href="<%=request.getContextPath()%>/admin/settings" class="admin-menu-item">
                    <i class="admin-menu-icon fas fa-cog"></i>
                    <span>Settings</span>
                </a>
                <a href="<%=request.getContextPath()%>/logout" class="admin-menu-item">
                    <i class="admin-menu-icon fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="admin-main">
            <!-- Header -->
            <div class="admin-header">
                <h1 class="admin-title">Dashboard</h1>
                <div class="admin-header-actions">
                    <a href="#" class="admin-btn admin-btn-sm">
                        <i class="fas fa-bell"></i> Notifications
                    </a>
                    <a href="#" class="admin-btn admin-btn-sm admin-btn-secondary">
                        <i class="fas fa-user"></i> Profile
                    </a>
                </div>
            </div>
            
            <!-- Alert Messages (if any) -->
            <div class="admin-alert admin-alert-success">
                Welcome to the admin dashboard!
            </div>
            
            <!-- Stats Section -->
            <div class="admin-stats">
                <div class="admin-stat-card">
                    <div class="admin-stat-value">125</div>
                    <div class="admin-stat-label">Total Products</div>
                </div>
                <div class="admin-stat-card">
                    <div class="admin-stat-value">45</div>
                    <div class="admin-stat-label">Total Orders</div>
                </div>
                <div class="admin-stat-card">
                    <div class="admin-stat-value">89</div>
                    <div class="admin-stat-label">Total Customers</div>
                </div>
                <div class="admin-stat-card">
                    <div class="admin-stat-value">$12,456</div>
                    <div class="admin-stat-label">Total Revenue</div>
                </div>
            </div>
            
            <!-- Recent Orders Section -->
            <div class="admin-section">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Recent Orders</h2>
                    <a href="<%=request.getContextPath()%>/admin/orders" class="admin-btn admin-btn-sm">View All</a>
                </div>
                
                <div class="admin-order-list">
                    <div class="admin-order-item">
                        <div class="admin-order-id">#1001</div>
                        <div class="admin-order-date">Jun 15, 2023</div>
                        <div class="admin-order-customer">John Doe</div>
                        <div class="admin-order-total">$125.00</div>
                        <div class="admin-order-status">
                            <span class="admin-status-badge admin-status-delivered">Delivered</span>
                        </div>
                        <div class="admin-order-actions">
                            <a href="#" class="admin-btn admin-btn-sm">View</a>
                        </div>
                    </div>
                    <div class="admin-order-item">
                        <div class="admin-order-id">#1002</div>
                        <div class="admin-order-date">Jun 14, 2023</div>
                        <div class="admin-order-customer">Jane Smith</div>
                        <div class="admin-order-total">$89.50</div>
                        <div class="admin-order-status">
                            <span class="admin-status-badge admin-status-processing">Processing</span>
                        </div>
                        <div class="admin-order-actions">
                            <a href="#" class="admin-btn admin-btn-sm">View</a>
                        </div>
                    </div>
                    <div class="admin-order-item">
                        <div class="admin-order-id">#1003</div>
                        <div class="admin-order-date">Jun 13, 2023</div>
                        <div class="admin-order-customer">Robert Johnson</div>
                        <div class="admin-order-total">$210.75</div>
                        <div class="admin-order-status">
                            <span class="admin-status-badge admin-status-pending">Pending</span>
                        </div>
                        <div class="admin-order-actions">
                            <a href="#" class="admin-btn admin-btn-sm">View</a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recent Products Section -->
            <div class="admin-section">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Recent Products</h2>
                    <a href="<%=request.getContextPath()%>/admin/products" class="admin-btn admin-btn-sm">View All</a>
                </div>
                
                <div class="admin-product-grid">
                    <div class="admin-product-card">
                        <div class="admin-product-image">
                            <img src="<%=request.getContextPath()%>/images/product1.jpg" alt="Product">
                        </div>
                        <div class="admin-product-info">
                            <div class="admin-product-name">Men's T-Shirt</div>
                            <div class="admin-product-price">$29.99</div>
                            <div class="admin-product-actions">
                                <a href="#" class="admin-btn admin-btn-sm">Edit</a>
                                <a href="#" class="admin-btn admin-btn-sm admin-btn-danger">Delete</a>
                            </div>
                        </div>
                    </div>
                    <div class="admin-product-card">
                        <div class="admin-product-image">
                            <img src="<%=request.getContextPath()%>/images/product2.jpg" alt="Product">
                        </div>
                        <div class="admin-product-info">
                            <div class="admin-product-name">Women's Dress</div>
                            <div class="admin-product-price">$49.99</div>
                            <div class="admin-product-actions">
                                <a href="#" class="admin-btn admin-btn-sm">Edit</a>
                                <a href="#" class="admin-btn admin-btn-sm admin-btn-danger">Delete</a>
                            </div>
                        </div>
                    </div>
                    <div class="admin-product-card">
                        <div class="admin-product-image">
                            <img src="<%=request.getContextPath()%>/images/product3.jpg" alt="Product">
                        </div>
                        <div class="admin-product-info">
                            <div class="admin-product-name">Casual Shoes</div>
                            <div class="admin-product-price">$79.99</div>
                            <div class="admin-product-actions">
                                <a href="#" class="admin-btn admin-btn-sm">Edit</a>
                                <a href="#" class="admin-btn admin-btn-sm admin-btn-danger">Delete</a>
                            </div>
                        </div>
                    </div>
                    <div class="admin-product-card">
                        <div class="admin-product-image">
                            <img src="<%=request.getContextPath()%>/images/product4.jpg" alt="Product">
                        </div>
                        <div class="admin-product-info">
                            <div class="admin-product-name">Denim Jeans</div>
                            <div class="admin-product-price">$59.99</div>
                            <div class="admin-product-actions">
                                <a href="#" class="admin-btn admin-btn-sm">Edit</a>
                                <a href="#" class="admin-btn admin-btn-sm admin-btn-danger">Delete</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
