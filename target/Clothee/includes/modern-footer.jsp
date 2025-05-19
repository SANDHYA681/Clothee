<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/modern-footer.css">

<!-- Modern Footer -->
<footer class="footer">
    <div class="footer-container">
        <div class="footer-grid">
            <!-- About Column -->
            <div class="footer-column footer-about">
                <a href="<%=request.getContextPath()%>/index.jsp" class="footer-logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span>CLOTHEE</span>
                </a>
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
            
            <!-- Quick Links Column -->
            <div class="footer-column">
                <h3 class="footer-title">Quick Links</h3>
                <ul class="footer-links">
                    <li>
                        <a href="<%=request.getContextPath()%>/index.jsp">
                            <i class="fas fa-chevron-right"></i> Home
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/ProductServlet">
                            <i class="fas fa-chevron-right"></i> Shop
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/categories.jsp">
                            <i class="fas fa-chevron-right"></i> Categories
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/about.jsp">
                            <i class="fas fa-chevron-right"></i> About Us
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/contact.jsp">
                            <i class="fas fa-chevron-right"></i> Contact Us
                        </a>
                    </li>
                    <li>
                        <a href="<%=request.getContextPath()%>/faq.jsp">
                            <i class="fas fa-chevron-right"></i> FAQ
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Contact Info Column -->
            <div class="footer-column">
                <h3 class="footer-title">Contact Us</h3>
                <div class="footer-contact-item">
                    <i class="fas fa-map-marker-alt"></i>
                    <div class="contact-details">
                        <div class="contact-title">Our Location</div>
                        <div>123 Fashion Street, City, Country</div>
                    </div>
                </div>
                <div class="footer-contact-item">
                    <i class="fas fa-phone-alt"></i>
                    <div class="contact-details">
                        <div class="contact-title">Phone Number</div>
                        <a href="tel:+12345678901">+1 234 567 8901</a>
                    </div>
                </div>
                <div class="footer-contact-item">
                    <i class="fas fa-envelope"></i>
                    <div class="contact-details">
                        <div class="contact-title">Email Address</div>
                        <a href="mailto:info@clothee.com">info@clothee.com</a>
                    </div>
                </div>
                <div class="footer-contact-item">
                    <i class="fas fa-clock"></i>
                    <div class="contact-details">
                        <div class="contact-title">Working Hours</div>
                        <div>Mon - Fri: 9:00 AM - 6:00 PM</div>
                        <div>Sat: 10:00 AM - 4:00 PM</div>
                    </div>
                </div>
            </div>
            
            <!-- Newsletter Column -->
            <div class="footer-column">
                <h3 class="footer-title">Newsletter</h3>
                <p>Subscribe to our newsletter to get updates on our latest offers and new products.</p>
                <div class="newsletter-form">
                    <div class="newsletter-input">
                        <input type="email" placeholder="Your email address">
                        <button type="submit">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </div>
                    <div class="newsletter-consent">
                        By subscribing, you agree to our Privacy Policy and consent to receive updates from our company.
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Footer Bottom -->
        <div class="footer-bottom">
            <div class="footer-copyright">
                &copy; <%= new java.util.Date().getYear() + 1900 %> CLOTHEE. All rights reserved.
            </div>
            <div class="footer-bottom-links">
                <a href="<%=request.getContextPath()%>/privacy-policy.jsp">Privacy Policy</a>
                <a href="<%=request.getContextPath()%>/terms-of-service.jsp">Terms of Service</a>
                <a href="<%=request.getContextPath()%>/shipping-policy.jsp">Shipping Policy</a>
                <a href="<%=request.getContextPath()%>/return-policy.jsp">Return Policy</a>
            </div>
        </div>
    </div>
</footer>
