package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import model.Message;
import service.MessageService;

/**
 * Servlet implementation class ContactServlet
 * Handles contact form submissions
 */
// Servlet mapping defined in web.xml
public class ContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MessageService messageService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ContactServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        messageService = new MessageService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to contact page
        request.getRequestDispatcher("/contact-new.jsp").forward(request, response);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        // If no action specified, redirect to contact page
        if (action == null || action.isEmpty()) {
            response.sendRedirect("contact-new.jsp");
            return;
        }

        // Handle sendMessage action
        if ("sendMessage".equals(action)) {
            // Check if user is logged in
            User user = (User) session.getAttribute("user");

            if (user == null) {
                // User is not logged in, redirect to login page with a message
                session.setAttribute("errorMessage", "Please log in to send a message");
                session.setAttribute("redirectUrl", "contact-new.jsp");
                response.sendRedirect("login.jsp");
                return;
            }

            // User is logged in, proceed with sending the message
            String userName = user.getFullName();
            String userEmail = user.getEmail();

            // Get form data
            String subject = request.getParameter("subject");
            String messageText = request.getParameter("message");

            if (subject == null || subject.trim().isEmpty() || messageText == null || messageText.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Subject and message are required");
                response.sendRedirect("ContactServlet");
                return;
            }

            // Create message
            Message message = new Message();
            message.setSubject(subject);
            message.setMessage(messageText);
            message.setName(userName);
            message.setEmail(userEmail);

            // Set message as unread and set creation timestamp
            message.setRead(false);
            message.setCreatedAt(new Timestamp(new Date().getTime()));

            // Save message
            boolean success = messageService.saveMessage(message);

            if (success) {
                session.setAttribute("successMessage", "Your message has been sent successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to send message. Please try again");
            }

            // Redirect to contact form
            response.sendRedirect("ContactServlet");
        }
    }


}
