<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<jsp:include page="includes/header.jsp" />

<!-- Main Content Area -->
<div class="admin-card">
    <div class="admin-card-header">
        <h2 class="admin-card-title">Profile Settings</h2>
    </div>
    <div class="admin-card-body">
        <form action="<%= request.getContextPath() %>/admin/SettingsServlet" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="updateProfile">
            
            <div class="admin-form-group">
                <label for="firstName" class="admin-form-label">First Name</label>
                <input type="text" id="firstName" name="firstName" class="admin-form-control" value="${user.firstName}" required>
            </div>
            
            <div class="admin-form-group">
                <label for="lastName" class="admin-form-label">Last Name</label>
                <input type="text" id="lastName" name="lastName" class="admin-form-control" value="${user.lastName}" required>
            </div>
            
            <div class="admin-form-group">
                <label for="email" class="admin-form-label">Email Address</label>
                <input type="email" id="email" name="email" class="admin-form-control" value="${user.email}" required>
            </div>
            
            <div class="admin-form-group">
                <label for="phone" class="admin-form-label">Phone Number</label>
                <input type="tel" id="phone" name="phone" class="admin-form-control" value="${user.phone}">
            </div>
            
            <div class="admin-form-group">
                <label for="profileImage" class="admin-form-label">Profile Image</label>
                <input type="file" id="profileImage" name="profileImage" class="admin-form-control" accept="image/*">
                <small class="admin-text-muted">Leave empty to keep current image</small>
            </div>
            
            <div class="admin-form-actions">
                <button type="button" class="admin-btn admin-btn-outline-primary" onclick="location.href='<%= request.getContextPath() %>/admin/settings.jsp'">Cancel</button>
                <button type="submit" class="admin-btn admin-btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
