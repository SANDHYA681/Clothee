<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Include the customer panel header with sidebar -->
<jsp:include page="../includes/customer-panel-header.jsp" />

<!-- Breadcrumb -->
<div class="customer-breadcrumb">
    <div class="customer-breadcrumb-item">
        <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="customer-breadcrumb-link">Dashboard</a>
    </div>
    <div class="customer-breadcrumb-item">
        <a href="#" class="customer-breadcrumb-link">Home</a>
    </div>
</div>

<!-- Page Header -->
<div class="customer-page-header">
    <h1 class="customer-page-title">My Dashboard</h1>
    <div class="customer-page-actions">
        <a href="<%=request.getContextPath()%>/index.jsp" class="customer-btn customer-btn-primary">
            <i class="fas fa-shopping-bag"></i> Continue Shopping
        </a>
    </div>
</div>

<!-- Dashboard Cards -->
<div class="customer-dashboard-cards">
    <div class="customer-card">
        <div class="customer-card-header">
            <div class="customer-card-icon">
                <i class="fas fa-shopping-bag"></i>
            </div>
        </div>
        <div class="customer-card-content">
            <div class="customer-card-value">5</div>
            <div class="customer-card-label">Total Orders</div>
        </div>
        <div class="customer-card-footer">
            <a href="<%=request.getContextPath()%>/customer/orders.jsp" class="customer-card-link">
                View All <i class="fas fa-arrow-right"></i>
            </a>
        </div>
    </div>
    
    <div class="customer-card">
        <div class="customer-card-header">
            <div class="customer-card-icon" style="background-color: rgba(76, 175, 80, 0.1); color: #4caf50;">
                <i class="fas fa-box"></i>
            </div>
        </div>
        <div class="customer-card-content">
            <div class="customer-card-value">2</div>
            <div class="customer-card-label">Pending Orders</div>
        </div>
        <div class="customer-card-footer">
            <a href="<%=request.getContextPath()%>/customer/orders.jsp?status=pending" class="customer-card-link">
                View All <i class="fas fa-arrow-right"></i>
            </a>
        </div>
    </div>
    
    <div class="customer-card">
        <div class="customer-card-header">
            <div class="customer-card-icon" style="background-color: rgba(33, 150, 243, 0.1); color: #2196f3;">
                <i class="fas fa-heart"></i>
            </div>
        </div>
        <div class="customer-card-content">
            <div class="customer-card-value">8</div>
            <div class="customer-card-label">Wishlist Items</div>
        </div>
        <div class="customer-card-footer">
            <a href="<%=request.getContextPath()%>/customer/wishlist.jsp" class="customer-card-link">
                View All <i class="fas fa-arrow-right"></i>
            </a>
        </div>
    </div>
    
    <div class="customer-card">
        <div class="customer-card-header">
            <div class="customer-card-icon" style="background-color: rgba(156, 39, 176, 0.1); color: #9c27b0;">
                <i class="fas fa-star"></i>
            </div>
        </div>
        <div class="customer-card-content">
            <div class="customer-card-value">3</div>
            <div class="customer-card-label">My Reviews</div>
        </div>
        <div class="customer-card-footer">
            <a href="<%=request.getContextPath()%>/customer/reviews.jsp" class="customer-card-link">
                View All <i class="fas fa-arrow-right"></i>
            </a>
        </div>
    </div>
</div>

<!-- Recent Orders -->
<div class="customer-table-container">
    <div class="customer-table-header">
        <h2 class="customer-table-title">Recent Orders</h2>
        <div class="customer-table-actions">
            <a href="<%=request.getContextPath()%>/customer/orders.jsp" class="customer-btn customer-btn-secondary">
                View All Orders
            </a>
        </div>
    </div>
    
    <table class="customer-table">
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Date</th>
                <th>Products</th>
                <th>Total</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>#ORD-001</td>
                <td>2023-05-15</td>
                <td>Summer T-Shirt, Casual Jeans</td>
                <td>$125.00</td>
                <td><span class="customer-status customer-status-success">Delivered</span></td>
                <td>
                    <a href="#" class="customer-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="customer-action-btn"><i class="fas fa-download"></i></a>
                </td>
            </tr>
            <tr>
                <td>#ORD-002</td>
                <td>2023-05-14</td>
                <td>Elegant Dress</td>
                <td>$85.50</td>
                <td><span class="customer-status customer-status-warning">Processing</span></td>
                <td>
                    <a href="#" class="customer-action-btn"><i class="fas fa-eye"></i></a>
                </td>
            </tr>
            <tr>
                <td>#ORD-003</td>
                <td>2023-05-13</td>
                <td>Sports Shoes, Running Shorts</td>
                <td>$210.75</td>
                <td><span class="customer-status customer-status-danger">Cancelled</span></td>
                <td>
                    <a href="#" class="customer-action-btn"><i class="fas fa-eye"></i></a>
                </td>
            </tr>
        </tbody>
    </table>
</div>

<!-- Recently Viewed Products -->
<div class="customer-table-container">
    <div class="customer-table-header">
        <h2 class="customer-table-title">Recently Viewed Products</h2>
        <div class="customer-table-actions">
            <a href="<%=request.getContextPath()%>/index.jsp" class="customer-btn customer-btn-secondary">
                Browse Products
            </a>
        </div>
    </div>
    
    <table class="customer-table">
        <thead>
            <tr>
                <th>Product</th>
                <th>Category</th>
                <th>Price</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Summer T-Shirt</td>
                <td>Men's Clothing</td>
                <td>$29.99</td>
                <td><span class="customer-status customer-status-success">In Stock</span></td>
                <td>
                    <a href="#" class="customer-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="customer-action-btn"><i class="fas fa-cart-plus"></i></a>
                    <a href="#" class="customer-action-btn"><i class="fas fa-heart"></i></a>
                </td>
            </tr>
            <tr>
                <td>Casual Jeans</td>
                <td>Men's Clothing</td>
                <td>$49.99</td>
                <td><span class="customer-status customer-status-success">In Stock</span></td>
                <td>
                    <a href="#" class="customer-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="customer-action-btn"><i class="fas fa-cart-plus"></i></a>
                    <a href="#" class="customer-action-btn"><i class="fas fa-heart"></i></a>
                </td>
            </tr>
            <tr>
                <td>Elegant Dress</td>
                <td>Women's Clothing</td>
                <td>$85.50</td>
                <td><span class="customer-status customer-status-warning">Low Stock</span></td>
                <td>
                    <a href="#" class="customer-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="customer-action-btn"><i class="fas fa-cart-plus"></i></a>
                    <a href="#" class="customer-action-btn"><i class="fas fa-heart"></i></a>
                </td>
            </tr>
        </tbody>
    </table>
</div>

<!-- Include the customer panel footer -->
<jsp:include page="../includes/customer-panel-footer.jsp" />
