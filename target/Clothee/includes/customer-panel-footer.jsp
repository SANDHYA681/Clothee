            </main>
            
            <!-- Footer -->
            <footer class="customer-footer">
                <div class="customer-footer-container">
                    <div class="customer-footer-copyright">
                        &copy; <%= new java.util.Date().getYear() + 1900 %> CLOTHEE. All rights reserved.
                    </div>
                    <div class="customer-footer-links">
                        <a href="<%=request.getContextPath()%>/about.jsp" class="customer-footer-link">About Us</a>
                        <a href="<%=request.getContextPath()%>/contact.jsp" class="customer-footer-link">Contact Us</a>
                        <a href="<%=request.getContextPath()%>/privacy.jsp" class="customer-footer-link">Privacy Policy</a>
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
            const customerSidebar = document.getElementById('customerSidebar');
            
            if (sidebarToggle) {
                sidebarToggle.addEventListener('click', function() {
                    customerSidebar.classList.toggle('collapsed');
                    
                    // Change icon based on sidebar state
                    const icon = sidebarToggle.querySelector('i');
                    if (customerSidebar.classList.contains('collapsed')) {
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
                    customerSidebar.classList.toggle('collapsed');
                });
            }
            
            // Check if sidebar state is saved in localStorage
            const sidebarState = localStorage.getItem('customerSidebarState');
            if (sidebarState === 'collapsed') {
                customerSidebar.classList.add('collapsed');
                const icon = sidebarToggle.querySelector('i');
                icon.classList.remove('fa-chevron-left');
                icon.classList.add('fa-chevron-right');
            }
            
            // Save sidebar state to localStorage when changed
            customerSidebar.addEventListener('transitionend', function() {
                if (customerSidebar.classList.contains('collapsed')) {
                    localStorage.setItem('customerSidebarState', 'collapsed');
                } else {
                    localStorage.setItem('customerSidebarState', 'expanded');
                }
            });
        });
    </script>
</body>
</html>
