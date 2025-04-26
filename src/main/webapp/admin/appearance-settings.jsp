<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="includes/header.jsp" />

<!-- Main Content Area -->
<div class="admin-card">
    <div class="admin-card-header">
        <h2 class="admin-card-title">Appearance Settings</h2>
    </div>
    <div class="admin-card-body">
        <form action="<%= request.getContextPath() %>/admin/SettingsServlet" method="post">
            <input type="hidden" name="action" value="updateAppearance">
            
            <div class="admin-form-group">
                <label class="admin-form-label">Color Theme</label>
                <div style="display: flex; gap: 15px; margin-top: 10px;">
                    <div class="admin-form-check">
                        <input type="radio" id="themeBlue" name="colorTheme" value="blue" class="admin-form-check-input" checked>
                        <label for="themeBlue" style="display: flex; align-items: center;">
                            <span style="display: inline-block; width: 20px; height: 20px; background-color: #4361ee; border-radius: 50%; margin-right: 8px;"></span>
                            Blue
                        </label>
                    </div>
                    <div class="admin-form-check">
                        <input type="radio" id="themeGreen" name="colorTheme" value="green" class="admin-form-check-input">
                        <label for="themeGreen" style="display: flex; align-items: center;">
                            <span style="display: inline-block; width: 20px; height: 20px; background-color: #2ecc71; border-radius: 50%; margin-right: 8px;"></span>
                            Green
                        </label>
                    </div>
                    <div class="admin-form-check">
                        <input type="radio" id="themePurple" name="colorTheme" value="purple" class="admin-form-check-input">
                        <label for="themePurple" style="display: flex; align-items: center;">
                            <span style="display: inline-block; width: 20px; height: 20px; background-color: #9b59b6; border-radius: 50%; margin-right: 8px;"></span>
                            Purple
                        </label>
                    </div>
                    <div class="admin-form-check">
                        <input type="radio" id="themeOrange" name="colorTheme" value="orange" class="admin-form-check-input">
                        <label for="themeOrange" style="display: flex; align-items: center;">
                            <span style="display: inline-block; width: 20px; height: 20px; background-color: #e67e22; border-radius: 50%; margin-right: 8px;"></span>
                            Orange
                        </label>
                    </div>
                </div>
            </div>
            
            <div class="admin-form-group">
                <label class="admin-form-label">Layout Options</label>
                <div class="admin-form-check">
                    <input type="checkbox" id="compactSidebar" name="compactSidebar" class="admin-form-check-input">
                    <label for="compactSidebar">Compact Sidebar</label>
                </div>
                <div class="admin-form-check">
                    <input type="checkbox" id="fixedHeader" name="fixedHeader" class="admin-form-check-input" checked>
                    <label for="fixedHeader">Fixed Header</label>
                </div>
                <div class="admin-form-check">
                    <input type="checkbox" id="darkMode" name="darkMode" class="admin-form-check-input">
                    <label for="darkMode">Dark Mode</label>
                </div>
            </div>
            
            <div class="admin-form-group">
                <label for="fontSize" class="admin-form-label">Font Size</label>
                <select id="fontSize" name="fontSize" class="admin-form-select">
                    <option value="small">Small</option>
                    <option value="medium" selected>Medium</option>
                    <option value="large">Large</option>
                </select>
            </div>
            
            <div class="admin-form-actions">
                <button type="button" class="admin-btn admin-btn-outline-primary" onclick="location.href='<%= request.getContextPath() %>/admin/settings.jsp'">Cancel</button>
                <button type="submit" class="admin-btn admin-btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
