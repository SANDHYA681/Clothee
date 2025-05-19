        </div>
    </main>
    
    <footer class="admin-footer">
        <div class="container admin-footer-container">
            <div class="admin-footer-text">
                &copy; <%= new java.util.Date().getYear() + 1900 %> CLOTHEE Admin Panel. All rights reserved.
            </div>
            <div class="admin-footer-links">
                <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="admin-footer-link">Dashboard</a>
                <a href="<%=request.getContextPath()%>/admin/settings.jsp" class="admin-footer-link">Settings</a>
                <a href="<%=request.getContextPath()%>/admin/help.jsp" class="admin-footer-link">Help</a>
            </div>
        </div>
    </footer>
    
    <script>
        // Mobile menu toggle
        document.addEventListener('DOMContentLoaded', function() {
            const mobileToggle = document.getElementById('adminMobileToggle');
            const navMenu = document.getElementById('adminNavMenu');
            
            if (mobileToggle) {
                mobileToggle.addEventListener('click', function() {
                    navMenu.classList.toggle('active');
                    
                    // Change icon based on menu state
                    const icon = mobileToggle.querySelector('i');
                    if (navMenu.classList.contains('active')) {
                        icon.classList.remove('fa-bars');
                        icon.classList.add('fa-times');
                    } else {
                        icon.classList.remove('fa-times');
                        icon.classList.add('fa-bars');
                    }
                });
            }
        });
    </script>
</body>
</html>
