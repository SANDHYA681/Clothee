<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="includes/header.jsp" />

<!-- Main Content Area -->
<div class="admin-card">
    <div class="admin-card-header">
        <h2 class="admin-card-title">Settings</h2>
    </div>
    <div class="admin-card-body">
        <div class="admin-settings-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px;">
            <!-- Profile Settings Card -->
            <div class="admin-card" style="box-shadow: var(--shadow-sm);">
                <div class="admin-card-header">
                    <h3 class="admin-card-title" style="font-size: 1.2rem;">Profile Settings</h3>
                </div>
                <div class="admin-card-body">
                    <p>Update your personal information, contact details, and profile image.</p>
                    <div style="margin-top: 15px;">
                        <a href="<%= request.getContextPath() %>/admin/profile-settings.jsp" class="admin-btn admin-btn-primary">
                            <i class="fas fa-user"></i> Manage Profile
                        </a>
                    </div>
                </div>
            </div>

            <!-- Security Settings Card -->
            <div class="admin-card" style="box-shadow: var(--shadow-sm);">
                <div class="admin-card-header">
                    <h3 class="admin-card-title" style="font-size: 1.2rem;">Security Settings</h3>
                </div>
                <div class="admin-card-body">
                    <p>Change your password and manage account security settings.</p>
                    <div style="margin-top: 15px;">
                        <a href="<%= request.getContextPath() %>/admin/security-settings.jsp" class="admin-btn admin-btn-primary">
                            <i class="fas fa-lock"></i> Manage Security
                        </a>
                    </div>
                </div>
            </div>

            <!-- Appearance Settings Card -->
            <div class="admin-card" style="box-shadow: var(--shadow-sm);">
                <div class="admin-card-header">
                    <h3 class="admin-card-title" style="font-size: 1.2rem;">Appearance Settings</h3>
                </div>
                <div class="admin-card-body">
                    <p>Customize the look and feel of your admin dashboard.</p>
                    <div style="margin-top: 15px;">
                        <a href="<%= request.getContextPath() %>/admin/appearance-settings.jsp" class="admin-btn admin-btn-primary">
                            <i class="fas fa-palette"></i> Manage Appearance
                        </a>
                    </div>
                </div>
            </div>

            <!-- Store Settings Card -->
            <div class="admin-card" style="box-shadow: var(--shadow-sm);">
                <div class="admin-card-header">
                    <h3 class="admin-card-title" style="font-size: 1.2rem;">Store Settings</h3>
                </div>
                <div class="admin-card-body">
                    <p>Configure general store settings, contact information, and policies.</p>
                    <div style="margin-top: 15px;">
                        <a href="#" class="admin-btn admin-btn-outline-primary">
                            <i class="fas fa-store"></i> Manage Store
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
