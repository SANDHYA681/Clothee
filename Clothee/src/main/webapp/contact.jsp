<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%@ include file="includes/header.jsp" %>
<link rel="stylesheet" type="text/css" href="css/contact.css">

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');">
    <div class="page-header-content">
        <h1 class="page-title">CONTACT</h1>
        <p class="page-subtitle">We'd love to hear from you. Get in touch with our team for any inquiries or feedback.</p>
    </div>
</div>

<section class="section">
    <div class="container">
        <div style="display: flex; flex-wrap: wrap; gap: 30px;">
            <div style="flex: 1; min-width: 300px;">
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

                        <a href="tel:+12345678901" class="contact-item clickable">
                            <i class="fas fa-phone"></i>
                            <div>
                                <h4>Phone Number</h4>
                                <p>+1 234 567 8901</p>
                            </div>
                        </a>

                        <a href="mailto:info@clothee.com" class="contact-item clickable">
                            <i class="fas fa-envelope"></i>
                            <div>
                                <h4>Email Address</h4>
                                <p>info@clothee.com</p>
                            </div>
                        </a>

                        <div class="contact-item">
                            <i class="fas fa-clock"></i>
                            <div>
                                <h4>Working Hours</h4>
                                <p>Monday - Friday: 9am - 6pm<br>Saturday: 10am - 4pm</p>
                            </div>
                        </div>
                    </div>

                    <div class="social-links" style="margin-top: 30px;">
                        <a href="#" class="social-link"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-pinterest"></i></a>
                    </div>
                </div>
            </div>

            <div style="flex: 1; min-width: 300px;">
                <div class="card">
                    <h2 class="section-title" style="text-align: left; margin-bottom: 30px;">Send Us a Message</h2>

                    <%
                    String successMessage = (String) request.getAttribute("success");
                    String errorMessage = (String) request.getAttribute("error");

                    if (successMessage != null && !successMessage.isEmpty()) {
                    %>
                    <div class="message-response success">
                        <%= successMessage %>
                    </div>
                    <% } %>

                    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div class="message-response error">
                        <%= errorMessage %>
                    </div>
                    <% } %>

                    <form action="<%= request.getContextPath() %>/ContactServlet" method="post" class="contact-form" style="display: flex; flex-direction: column; gap: 20px;">
                    <input type="hidden" name="action" value="sendMessage">
                        <%
                        // Check if user is logged in
                        User user = (User) session.getAttribute("user");
                        Integer userId = null;
                        String userName = null;
                        String userEmail = null;

                        if (user != null) {
                            userId = user.getId();
                            userName = user.getFullName();
                            userEmail = user.getEmail();
                        }

                        if (user == null) {
                        // Show name and email fields for guest users
                        %>
                        <div class="form-group">
                            <label class="form-label" for="name" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Your Name</label>
                            <input type="text" id="name" name="name" class="form-control" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px;">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="email" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Email Address</label>
                            <input type="email" id="email" name="email" class="form-control" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px;">
                        </div>
                        <% } else { %>
                        <div class="form-group">
                            <p>You are sending this message as: <strong><%= userName %></strong> (<%= userEmail %>)</p>
                            <input type="hidden" name="name" value="<%= userName %>">
                            <input type="hidden" name="email" value="<%= userEmail %>">
                        </div>
                        <% } %>

                        <div class="form-group">
                            <label class="form-label" for="subject" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Subject</label>
                            <input type="text" id="subject" name="subject" class="form-control" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px;">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="message" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Your Message</label>
                            <textarea id="message" name="message" class="form-control" rows="5" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px; min-height: 150px;"></textarea>
                        </div>

                        <button type="submit" class="btn" style="display: inline-block; padding: 15px 35px; background: linear-gradient(135deg, #ff6b6b 0%, #ff8c8c 100%); color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s ease; text-align: center; text-decoration: none; box-shadow: 0 10px 20px rgba(255, 107, 107, 0.2); margin-top: 10px;">Send Message</button>
                    </form>


                </div>
            </div>
        </div>
    </div>
</section>

<!-- Map section removed as requested -->

<style>
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

    /* Additional styles to ensure proper display */
    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }

    .section {
        padding: 80px 0;
    }

    .card {
        background-color: white;
        border-radius: 15px;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08);
        padding: 40px;
        height: 100%;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        border: 1px solid rgba(0, 0, 0, 0.05);
    }

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
</style>

<%@ include file="includes/footer.jsp" %>
