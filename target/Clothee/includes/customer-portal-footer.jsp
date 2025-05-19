            </main>
            
            <!-- Footer -->
            <footer class="footer">
                <div class="footer-container">
                    <div class="footer-copyright">
                        &copy; <%= new java.util.Date().getYear() + 1900 %> CLOTHEE. All rights reserved.
                    </div>
                    <div class="footer-links">
                        <a href="<%=request.getContextPath()%>/about.jsp" class="footer-link">About Us</a>
                        <a href="<%=request.getContextPath()%>/contact.jsp" class="footer-link">Contact Us</a>
                        <a href="<%=request.getContextPath()%>/privacy.jsp" class="footer-link">Privacy Policy</a>
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
            const sidebar = document.getElementById('sidebar');
            
            if (sidebarToggle) {
                sidebarToggle.addEventListener('click', function() {
                    sidebar.classList.toggle('collapsed');
                    
                    // Change icon based on sidebar state
                    const icon = sidebarToggle.querySelector('i');
                    if (sidebar.classList.contains('collapsed')) {
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
                    sidebar.classList.toggle('collapsed');
                });
            }
            
            // Check if sidebar state is saved in localStorage
            const sidebarState = localStorage.getItem('sidebarState');
            if (sidebarState === 'collapsed') {
                sidebar.classList.add('collapsed');
                const icon = sidebarToggle.querySelector('i');
                icon.classList.remove('fa-chevron-left');
                icon.classList.add('fa-chevron-right');
            }
            
            // Save sidebar state to localStorage when changed
            sidebar.addEventListener('transitionend', function() {
                if (sidebar.classList.contains('collapsed')) {
                    localStorage.setItem('sidebarState', 'collapsed');
                } else {
                    localStorage.setItem('sidebarState', 'expanded');
                }
            });
        });
    </script>
</body>
</html>
