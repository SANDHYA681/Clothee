            </div> <!-- End of admin-main -->
        </div> <!-- End of admin-container -->
        
        <!-- JavaScript for sidebar toggle and other functionality -->
        <script>
            // Sidebar toggle
            document.getElementById('sidebarToggle').addEventListener('click', function() {
                document.getElementById('sidebar').classList.toggle('collapsed');
                document.getElementById('main').classList.toggle('expanded');
            });
            
            // Auto-hide alerts after 5 seconds
            setTimeout(function() {
                const alerts = document.querySelectorAll('.admin-alert');
                alerts.forEach(function(alert) {
                    alert.style.display = 'none';
                });
            }, 5000);
        </script>
    </body>
</html>
