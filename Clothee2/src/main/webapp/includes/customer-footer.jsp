        </div>
    </main>
    
    <footer class="footer">
        <div class="container">
            <div class="footer-container">
                <div class="footer-section footer-about">
                    <h3>About CLOTHEE</h3>
                    <p>CLOTHEE is your one-stop destination for trendy and affordable fashion. We offer a wide range of clothing for men, women, and children with the latest styles and highest quality.</p>
                    <div class="social-icons">
                        <a href="#" class="social-icon" title="Facebook">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="#" class="social-icon" title="Twitter">
                            <i class="fab fa-twitter"></i>
                        </a>
                        <a href="#" class="social-icon" title="Instagram">
                            <i class="fab fa-instagram"></i>
                        </a>
                        <a href="#" class="social-icon" title="Pinterest">
                            <i class="fab fa-pinterest-p"></i>
                        </a>
                    </div>
                </div>
                
                <div class="footer-section footer-links">
                    <h3>Quick Links</h3>
                    <ul>
                        <li><a href="<%=request.getContextPath()%>/index.jsp">Home</a></li>
                        <li><a href="<%=request.getContextPath()%>/ProductServlet">Shop</a></li>
                        <li><a href="<%=request.getContextPath()%>/about.jsp">About Us</a></li>
                        <li><a href="<%=request.getContextPath()%>/contact.jsp">Contact Us</a></li>
                        <li><a href="<%=request.getContextPath()%>/login.jsp">Login</a></li>
                    </ul>
                </div>
                
                <div class="footer-section footer-contact">
                    <h3>Contact Us</h3>
                    <p><i class="fas fa-map-marker-alt"></i> 123 Fashion Street, City, Country</p>
                    <p><i class="fas fa-phone"></i> +1 234 567 8901</p>
                    <p><i class="fas fa-envelope"></i> info@clothee.com</p>
                </div>
                
                <div class="footer-section footer-newsletter">
                    <h3>Newsletter</h3>
                    <p>Subscribe to our newsletter to get updates on our latest offers!</p>
                    <form action="<%=request.getContextPath()%>/NewsletterServlet" method="post" class="newsletter-form">
                        <input type="email" name="email" placeholder="Enter your email" required>
                        <button type="submit" class="newsletter-btn">Subscribe</button>
                    </form>
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
            const mobileToggle = document.getElementById('mobileToggle');
            const navMenu = document.getElementById('navMenu');
            
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
            
            // Auto-hide alerts after 5 seconds
            setTimeout(function() {
                const alerts = document.querySelectorAll('.alert');
                alerts.forEach(function(alert) {
                    alert.style.display = 'none';
                });
            }, 5000);
        });
    </script>
</body>
</html>
