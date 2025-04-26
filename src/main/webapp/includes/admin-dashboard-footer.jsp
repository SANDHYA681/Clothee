            </main>
            
            <!-- Footer -->
            <footer class="admin-footer">
                <div class="admin-footer-container">
                    <div class="admin-footer-copyright">
                        &copy; <%= new java.util.Date().getYear() + 1900 %> CLOTHEE Admin Panel. All rights reserved.
                    </div>
                    <div class="admin-footer-links">
                        <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="admin-footer-link">Dashboard</a>
                        <a href="<%=request.getContextPath()%>/admin/settings.jsp" class="admin-footer-link">Settings</a>
                        <a href="<%=request.getContextPath()%>/admin/help.jsp" class="admin-footer-link">Help</a>
                    </div>
                </div>
            </footer>
        </div>
    </div>
    
    <script>
        // Sidebar toggle
        document.addEventListener('DOMContentLoaded', function() {
            const sidebarToggle = document.getElementById('sidebarToggle');
            const mobileToggle = document.getElementById('mobileToggle');
            const adminSidebar = document.getElementById('adminSidebar');
            
            if (sidebarToggle) {
                sidebarToggle.addEventListener('click', function() {
                    adminSidebar.classList.toggle('collapsed');
                    
                    // Change icon based on sidebar state
                    const icon = sidebarToggle.querySelector('i');
                    if (adminSidebar.classList.contains('collapsed')) {
                        icon.classList.remove('fa-chevron-left');
                        icon.classList.add('fa-chevron-right');
                    } else {
                        icon.classList.remove('fa-chevron-right');
                        icon.classList.add('fa-chevron-left');
                    }
                });
            }
            
            if (mobileToggle) {
                mobileToggle.addEventListener('click', function() {
                    adminSidebar.classList.toggle('collapsed');
                });
            }
            
            // Check if sidebar state is saved in localStorage
            const sidebarState = localStorage.getItem('adminSidebarState');
            if (sidebarState === 'collapsed') {
                adminSidebar.classList.add('collapsed');
                const icon = sidebarToggle.querySelector('i');
                icon.classList.remove('fa-chevron-left');
                icon.classList.add('fa-chevron-right');
            }
            
            // Save sidebar state to localStorage when changed
            adminSidebar.addEventListener('transitionend', function() {
                if (adminSidebar.classList.contains('collapsed')) {
                    localStorage.setItem('adminSidebarState', 'collapsed');
                } else {
                    localStorage.setItem('adminSidebarState', 'expanded');
                }
            });
        });
    </script>
</body>
</html>
