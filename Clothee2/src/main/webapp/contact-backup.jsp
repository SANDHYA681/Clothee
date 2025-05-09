<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%@ include file="includes/header.jsp" %>

<div style="background-image: url('https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'); background-size: cover; background-position: center; padding: 120px 0 60px; text-align: center; position: relative; margin-bottom: 80px;">
    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); z-index: 1;"></div>
    <div style="position: relative; z-index: 2; color: white; max-width: 800px; margin: 0 auto;">
        <h1 style="font-size: 3.5rem; font-weight: 800; margin-bottom: 15px; text-transform: uppercase; letter-spacing: 3px; text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);">CONTACT</h1>
        <p style="font-size: 1.2rem; max-width: 600px; margin: 20px auto 0; line-height: 1.6; color: rgba(255, 255, 255, 0.9);">We'd love to hear from you. Get in touch with our team for any inquiries or feedback.</p>
    </div>
</div>

<section class="section">
    <div class="container" style="max-width: 1200px; margin: 0 auto; padding: 0 20px;">
        <div style="display: flex; flex-wrap: wrap; gap: 30px;">
            <div style="flex: 1; min-width: 300px;">
                <div class="card" style="background-color: white; border-radius: 15px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08); padding: 40px; height: 100%; transition: transform 0.3s ease, box-shadow 0.3s ease; border: 1px solid rgba(0, 0, 0, 0.05);">
                    <h2 style="font-size: 24px; margin-bottom: 20px; color: #333;">Contact Information</h2>
                    <p style="margin-bottom: 30px; color: #666; line-height: 1.6;">Feel free to reach out to us using any of the following contact methods:</p>
                    
                    <div class="contact-info" style="margin-top: 30px;">
                        <a href="tel:+1234567890" class="contact-item" style="display: flex; align-items: flex-start; margin-bottom: 30px; text-decoration: none; color: inherit; transition: all 0.3s ease; padding: 15px; border-radius: 10px; background-color: #f9f9f9; border: 1px solid transparent;">
                            <i class="fas fa-phone" style="font-size: 22px; color: #ff6b6b; margin-right: 20px; margin-top: 5px; transition: all 0.3s ease; width: 45px; height: 45px; background-color: rgba(255, 107, 107, 0.1); border-radius: 50%; display: flex; align-items: center; justify-content: center;"></i>
                            <div>
                                <h3 style="font-size: 18px; margin-bottom: 5px; color: #333;">Phone</h3>
                                <p style="color: #666; line-height: 1.6;">+1 (234) 567-890</p>
                                <p style="color: #666; line-height: 1.6; font-size: 14px; margin-top: 5px;">Mon-Fri, 9am-5pm EST</p>
                            </div>
                        </a>
                        
                        <a href="mailto:info@clothee.com" class="contact-item" style="display: flex; align-items: flex-start; margin-bottom: 30px; text-decoration: none; color: inherit; transition: all 0.3s ease; padding: 15px; border-radius: 10px; background-color: #f9f9f9; border: 1px solid transparent;">
                            <i class="fas fa-envelope" style="font-size: 22px; color: #ff6b6b; margin-right: 20px; margin-top: 5px; transition: all 0.3s ease; width: 45px; height: 45px; background-color: rgba(255, 107, 107, 0.1); border-radius: 50%; display: flex; align-items: center; justify-content: center;"></i>
                            <div>
                                <h3 style="font-size: 18px; margin-bottom: 5px; color: #333;">Email</h3>
                                <p style="color: #666; line-height: 1.6;">info@clothee.com</p>
                                <p style="color: #666; line-height: 1.6; font-size: 14px; margin-top: 5px;">We'll respond as quickly as possible</p>
                            </div>
                        </a>
                        
                        <div class="contact-item" style="display: flex; align-items: flex-start; margin-bottom: 30px; text-decoration: none; color: inherit; transition: all 0.3s ease; padding: 15px; border-radius: 10px; background-color: #f9f9f9; border: 1px solid transparent;">
                            <i class="fas fa-map-marker-alt" style="font-size: 22px; color: #ff6b6b; margin-right: 20px; margin-top: 5px; transition: all 0.3s ease; width: 45px; height: 45px; background-color: rgba(255, 107, 107, 0.1); border-radius: 50%; display: flex; align-items: center; justify-content: center;"></i>
                            <div>
                                <h3 style="font-size: 18px; margin-bottom: 5px; color: #333;">Address</h3>
                                <p style="color: #666; line-height: 1.6;">123 Fashion Street</p>
                                <p style="color: #666; line-height: 1.6;">New York, NY 10001</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="social-links" style="display: flex; margin-top: 40px;">
                        <a href="#" class="social-link" style="display: flex; align-items: center; justify-content: center; width: 45px; height: 45px; background-color: #f5f5f5; color: #555; border-radius: 50%; margin-right: 15px; transition: all 0.4s ease; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-link" style="display: flex; align-items: center; justify-content: center; width: 45px; height: 45px; background-color: #f5f5f5; color: #555; border-radius: 50%; margin-right: 15px; transition: all 0.4s ease; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-link" style="display: flex; align-items: center; justify-content: center; width: 45px; height: 45px; background-color: #f5f5f5; color: #555; border-radius: 50%; margin-right: 15px; transition: all 0.4s ease; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-link" style="display: flex; align-items: center; justify-content: center; width: 45px; height: 45px; background-color: #f5f5f5; color: #555; border-radius: 50%; margin-right: 15px; transition: all 0.4s ease; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);"><i class="fab fa-linkedin-in"></i></a>
                    </div>
                </div>
            </div>

            <div style="flex: 1; min-width: 300px;">
                <div class="card" style="background-color: white; border-radius: 15px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08); padding: 40px; height: 100%; transition: transform 0.3s ease, box-shadow 0.3s ease; border: 1px solid rgba(0, 0, 0, 0.05);">
                    <h2 style="font-size: 24px; margin-bottom: 20px; color: #333;">Send Us a Message</h2>
                    <p style="margin-bottom: 30px; color: #666; line-height: 1.6;">Have a question or feedback? Fill out the form below and we'll get back to you as soon as possible.</p>
                    
                    <div id="successMessage" class="message-response success" style="display: none; padding: 15px; margin-bottom: 20px; border-radius: 5px; font-weight: 500; background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb;">
                        Your message has been sent successfully!
                    </div>
                    
                    <form id="contactForm" style="display: flex; flex-direction: column; gap: 20px;">
                        <div class="form-group">
                            <label for="name" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Your Name</label>
                            <input type="text" id="name" name="name" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px;">
                        </div>

                        <div class="form-group">
                            <label for="email" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Email Address</label>
                            <input type="email" id="email" name="email" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px;">
                        </div>

                        <div class="form-group">
                            <label for="subject" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Subject</label>
                            <input type="text" id="subject" name="subject" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px;">
                        </div>

                        <div class="form-group">
                            <label for="message" style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">Your Message</label>
                            <textarea id="message" name="message" rows="5" required style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px; min-height: 150px;"></textarea>
                        </div>

                        <button type="submit" style="display: inline-block; padding: 15px 35px; background: linear-gradient(135deg, #ff6b6b 0%, #ff8c8c 100%); color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s ease; text-align: center; text-decoration: none; box-shadow: 0 10px 20px rgba(255, 107, 107, 0.2); margin-top: 10px;">Send Message</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</section>

<script>
    document.getElementById('contactForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        // In a real application, you would send the form data to the server
        // For now, we'll just show a success message
        document.getElementById('successMessage').style.display = 'block';
        
        // Clear the form
        this.reset();
        
        // Scroll to the success message
        document.getElementById('successMessage').scrollIntoView({ behavior: 'smooth' });
    });
</script>

<%@ include file="includes/footer.jsp" %>
