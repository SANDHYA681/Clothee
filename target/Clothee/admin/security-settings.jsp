<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="includes/header.jsp" />

<!-- Main Content Area -->
<div class="admin-card">
    <div class="admin-card-header">
        <h2 class="admin-card-title">Security Settings</h2>
    </div>
    <div class="admin-card-body">
        <form action="<%= request.getContextPath() %>/admin/SettingsServlet" method="post">
            <input type="hidden" name="action" value="updateSecurity">
            
            <div class="admin-form-group">
                <label for="currentPassword" class="admin-form-label">Current Password</label>
                <input type="password" id="currentPassword" name="currentPassword" class="admin-form-control" required>
            </div>
            
            <div class="admin-form-group">
                <label for="newPassword" class="admin-form-label">New Password</label>
                <input type="password" id="newPassword" name="newPassword" class="admin-form-control" required>
            </div>
            
            <div class="admin-form-group">
                <label for="confirmPassword" class="admin-form-label">Confirm New Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="admin-form-control" required>
            </div>
            
            <div class="admin-card admin-card-body" style="background-color: var(--primary-light-bg); margin-bottom: 20px;">
                <h3 style="font-size: 1rem; margin-bottom: 10px;">Password Requirements:</h3>
                <ul style="padding-left: 20px;">
                    <li>At least 8 characters long</li>
                    <li>Contains at least one uppercase letter</li>
                    <li>Contains at least one lowercase letter</li>
                    <li>Contains at least one number</li>
                    <li>Contains at least one special character</li>
                </ul>
            </div>
            
            <div class="admin-form-actions">
                <button type="button" class="admin-btn admin-btn-outline-primary" onclick="location.href='<%= request.getContextPath() %>/admin/settings.jsp'">Cancel</button>
                <button type="submit" class="admin-btn admin-btn-primary">Update Password</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
