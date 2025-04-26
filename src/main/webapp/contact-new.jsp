<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%@ include file="includes/header.jsp" %>

<!-- Page Header -->
<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');">
    <div class="page-header-content">
        <h1 class="page-title">CONTACT</h1>
        <p class="page-subtitle">We'd love to hear from you. Get in touch with our team for any inquiries or feedback.</p>
    </div>
</div>

<!-- Contact Section -->
<section class="section">
    <div class="container">
        <div class="row">
            <div class="col-2">
                <div class="card">
                    <h2 class="section-title" style="text-align: left; margin-bottom: 30px;">Get In Touch</h2>
                    <p>Have questions about our products, services, or anything else? We're here to help! Fill out the form and we'll get back to you as soon as possible.</p>

                    <div class="contact-info">
                        <div class="contact-item">
                            <i class="fas fa-map-marker-alt"></i>
                            <div>
                                <h4>Our Location</h4>
                                <p>123 Fashion Street, City, Country</p>
                            </div>
                        </div>

                        <div class="contact-item">
                            <i class="fas fa-phone"></i>
                            <div>
                                <h4>Phone Number</h4>
                                <p>+1 (234) 567-8900</p>
                            </div>
                        </div>

                        <div class="contact-item">
                            <i class="fas fa-envelope"></i>
                            <div>
                                <h4>Email Address</h4>
                                <p>info@clothee.com</p>
                            </div>
                        </div>

                        <div class="contact-item">
                            <i class="fas fa-clock"></i>
                            <div>
                                <h4>Working Hours</h4>
                                <p>Monday - Friday: 9am - 5pm</p>
                                <p>Saturday: 10am - 2pm</p>
                            </div>
                        </div>
                    </div>

                    <div class="social-links">
                        <a href="#" class="social-link"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-linkedin-in"></i></a>
                    </div>
                </div>
            </div>

            <div class="col-2">
                <div class="card">
                    <h2 class="section-title" style="text-align: left; margin-bottom: 30px;">Send Us a Message</h2>

                    <%
                    String successMessage = (String) session.getAttribute("successMessage");
                    String errorMessage = (String) session.getAttribute("errorMessage");

                    // Clear messages after displaying
                    session.removeAttribute("successMessage");
                    session.removeAttribute("errorMessage");

                    if (successMessage != null && !successMessage.isEmpty()) {
                    %>
                    <div class="message-response success">
                        <%= successMessage %>
                    </div>
                    <% } else if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div class="message-response error">
                        <%= errorMessage %>
                    </div>
                    <% } %>

                    <form class="contact-form" action="ContactServlet" method="post">
                        <input type="hidden" name="action" value="sendMessage">
                        <%
                        // Check if user is logged in
                        User user = (User) session.getAttribute("user");
                        String userName = null;
                        String userEmail = null;

                        if (user != null) {
                            userName = user.getFullName();
                            userEmail = user.getEmail();
                        }

                        if (user == null) {
                        // Show name and email fields for guest users
                        %>
                        <div class="form-group">
                            <label class="form-label" for="name">Your Name</label>
                            <input type="text" id="name" name="name" class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="email">Email Address</label>
                            <input type="email" id="email" name="email" class="form-control" required>
                        </div>
                        <% } else { %>
                        <div class="form-group">
                            <p>You are sending this message as: <strong><%= userName %></strong> (<%= userEmail %>)</p>
                            <input type="hidden" name="name" value="<%= userName %>">
                            <input type="hidden" name="email" value="<%= userEmail %>">
                        </div>
                        <% } %>

                        <div class="form-group">
                            <label class="form-label" for="subject">Subject</label>
                            <input type="text" id="subject" name="subject" class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="message">Your Message</label>
                            <textarea id="message" name="message" class="form-control" rows="5" required></textarea>
                        </div>

                        <button type="submit" class="btn">Send Message</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
    /* Page Header */
    .page-header {
        position: relative;
        background-size: cover;
        background-position: center;
        padding: 120px 0 60px;
        text-align: center;
        margin-bottom: 80px;
    }

    .page-header::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
    }

    .page-header-content {
        position: relative;
        z-index: 2;
        color: white;
        max-width: 800px;
        margin: 0 auto;
    }

    .page-title {
        font-size: 3.5rem;
        font-weight: 800;
        margin-bottom: 15px;
        text-transform: uppercase;
        letter-spacing: 3px;
        text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
    }

    .page-subtitle {
        font-size: 1.2rem;
        max-width: 600px;
        margin: 20px auto 0;
        line-height: 1.6;
        color: rgba(255, 255, 255, 0.9);
    }

    /* Section */
    .section {
        padding: 80px 0;
    }

    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }

    .row {
        display: flex;
        flex-wrap: wrap;
        gap: 30px;
    }

    .col-2 {
        flex: 1;
        min-width: 300px;
    }

    /* Card */
    .card {
        background-color: white;
        border-radius: 15px;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08);
        padding: 40px;
        height: 100%;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        border: 1px solid rgba(0, 0, 0, 0.05);
    }

    /* Contact Info */
    .contact-info {
        margin-top: 30px;
    }

    .contact-item {
        display: flex;
        align-items: flex-start;
        margin-bottom: 30px;
        text-decoration: none;
        color: inherit;
        transition: all 0.3s ease;
        padding: 15px;
        border-radius: 10px;
        background-color: #f9f9f9;
        border: 1px solid transparent;
    }

    .contact-item i {
        font-size: 22px;
        color: #ff6b6b;
        margin-right: 20px;
        margin-top: 5px;
        transition: all 0.3s ease;
        width: 45px;
        height: 45px;
        background-color: rgba(255, 107, 107, 0.1);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .contact-item h4 {
        font-size: 18px;
        margin-bottom: 5px;
        color: #333;
    }

    .contact-item p {
        color: #666;
        line-height: 1.6;
        margin: 0;
    }

    /* Social Links */
    .social-links {
        display: flex;
        margin-top: 40px;
    }

    .social-link {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 45px;
        height: 45px;
        background-color: #f5f5f5;
        color: #555;
        border-radius: 50%;
        margin-right: 15px;
        transition: all 0.4s ease;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
    }

    .social-link:hover {
        background-color: #ff6b6b;
        color: white;
        transform: translateY(-3px);
        box-shadow: 0 8px 20px rgba(255, 107, 107, 0.3);
    }

    /* Form */
    .form-group {
        margin-bottom: 25px;
    }

    .form-label {
        display: block;
        font-size: 15px;
        font-weight: 600;
        margin-bottom: 10px;
        color: #444;
    }

    .form-control {
        width: 100%;
        padding: 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 16px;
        transition: all 0.3s ease;
        background-color: #f9f9f9;
    }

    .form-control:focus {
        border-color: #ff6b6b;
        box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.2);
        outline: none;
    }

    .btn {
        display: inline-block;
        padding: 15px 35px;
        background: linear-gradient(135deg, #ff6b6b 0%, #ff8c8c 100%);
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        text-align: center;
        text-decoration: none;
        box-shadow: 0 10px 20px rgba(255, 107, 107, 0.2);
    }

    .btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 15px 25px rgba(255, 107, 107, 0.3);
    }

    /* Messages */
    .message-response {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 5px;
        font-weight: 500;
    }

    .message-response.success {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }

    .message-response.error {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .row {
            flex-direction: column;
        }

        .page-title {
            font-size: 2.5rem;
        }
    }
</style>



<%@ include file="includes/footer.jsp" %>
