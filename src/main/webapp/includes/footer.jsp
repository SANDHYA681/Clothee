    </main>
    <footer class="site-footer">
        <div class="container">
            <div class="footer-container">
                <div class="footer-section footer-about">
                    <h3 class="footer-title">About CLOTHEE</h3>
                    <p>CLOTHEE is your one-stop destination for trendy and affordable fashion. We offer a wide range of clothing for men, women, and children.</p>
                </div>

                <div class="footer-section footer-links">
                    <h3 class="footer-title">Quick Links</h3>
                    <ul>
                        <li><a href="<%=request.getContextPath()%>/index.jsp">Home</a></li>
                        <li><a href="<%=request.getContextPath()%>/about.jsp">About Us</a></li>
                        <li><a href="<%=request.getContextPath()%>/contact.jsp">Contact Us</a></li>
                        <li><a href="<%=request.getContextPath()%>/login.jsp">Login</a></li>
                        <li><a href="<%=request.getContextPath()%>/register.jsp">Register</a></li>
                    </ul>
                </div>

                <div class="footer-section footer-contact">
                    <h3 class="footer-title">Contact Us</h3>
                    <p><i class="fas fa-map-marker-alt"></i> 123 Fashion Street, City, Country</p>
                    <p><i class="fas fa-phone"></i> +1 234 567 8901</p>
                    <p><i class="fas fa-envelope"></i> info@clothee.com</p>
                </div>

                <div class="footer-section footer-social">
                    <h3 class="footer-title">Follow Us</h3>
                    <div class="social-icons">
                        <a href="#" class="social-icon" title="Facebook"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-icon" title="Twitter"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-icon" title="Instagram"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-icon" title="Pinterest"><i class="fab fa-pinterest-p"></i></a>
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <p>&copy; <%= new java.util.Date().getYear() + 1900 %> CLOTHEE. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        // Mobile menu toggle
        document.addEventListener('DOMContentLoaded', function() {
            const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
            const navIcons = document.querySelector('.nav-icons');

            if (mobileMenuBtn) {
                mobileMenuBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    navIcons.classList.toggle('open');
                });
            }
        });
    </script>
</body>
</html>