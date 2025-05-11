<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Include the admin header -->
<jsp:include page="includes/admin-header.jsp" />

<!-- Page Content -->
<div class="admin-card">
    <div class="admin-card-header">
        <h2 class="admin-card-title">Dashboard Overview</h2>
        <a href="#" class="admin-card-action">View All</a>
    </div>
    
    <div class="admin-dashboard-stats">
        <div class="admin-stat-card">
            <div class="admin-stat-title">Total Orders</div>
            <div class="admin-stat-value">254</div>
            <div class="admin-stat-change positive">
                <i class="fas fa-arrow-up"></i> 12.5% from last month
            </div>
        </div>
        
        <div class="admin-stat-card">
            <div class="admin-stat-title">Total Revenue</div>
            <div class="admin-stat-value">$15,245</div>
            <div class="admin-stat-change positive">
                <i class="fas fa-arrow-up"></i> 8.3% from last month
            </div>
        </div>
        
        <div class="admin-stat-card">
            <div class="admin-stat-title">Total Customers</div>
            <div class="admin-stat-value">1,245</div>
            <div class="admin-stat-change positive">
                <i class="fas fa-arrow-up"></i> 5.7% from last month
            </div>
        </div>
        
        <div class="admin-stat-card">
            <div class="admin-stat-title">Total Products</div>
            <div class="admin-stat-value">432</div>
            <div class="admin-stat-change negative">
                <i class="fas fa-arrow-down"></i> 2.1% from last month
            </div>
        </div>
    </div>
</div>

<div class="admin-card">
    <div class="admin-card-header">
        <h2 class="admin-card-title">Recent Orders</h2>
        <a href="#" class="admin-card-action">View All Orders</a>
    </div>
    
    <table class="admin-table">
        <thead>
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>#ORD-001</td>
                <td>John Doe</td>
                <td>2023-05-15</td>
                <td>$125.00</td>
                <td><span class="admin-status-badge success">Completed</span></td>
                <td>
                    <a href="#" class="admin-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="admin-action-btn"><i class="fas fa-edit"></i></a>
                </td>
            </tr>
            <tr>
                <td>#ORD-002</td>
                <td>Jane Smith</td>
                <td>2023-05-14</td>
                <td>$85.50</td>
                <td><span class="admin-status-badge warning">Processing</span></td>
                <td>
                    <a href="#" class="admin-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="admin-action-btn"><i class="fas fa-edit"></i></a>
                </td>
            </tr>
            <tr>
                <td>#ORD-003</td>
                <td>Robert Johnson</td>
                <td>2023-05-13</td>
                <td>$210.75</td>
                <td><span class="admin-status-badge danger">Cancelled</span></td>
                <td>
                    <a href="#" class="admin-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="admin-action-btn"><i class="fas fa-edit"></i></a>
                </td>
            </tr>
            <tr>
                <td>#ORD-004</td>
                <td>Emily Davis</td>
                <td>2023-05-12</td>
                <td>$150.25</td>
                <td><span class="admin-status-badge success">Completed</span></td>
                <td>
                    <a href="#" class="admin-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="admin-action-btn"><i class="fas fa-edit"></i></a>
                </td>
            </tr>
            <tr>
                <td>#ORD-005</td>
                <td>Michael Wilson</td>
                <td>2023-05-11</td>
                <td>$95.00</td>
                <td><span class="admin-status-badge warning">Processing</span></td>
                <td>
                    <a href="#" class="admin-action-btn"><i class="fas fa-eye"></i></a>
                    <a href="#" class="admin-action-btn"><i class="fas fa-edit"></i></a>
                </td>
            </tr>
        </tbody>
    </table>
</div>

<!-- Include the admin footer -->
<jsp:include page="includes/admin-footer.jsp" />
