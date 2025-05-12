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
import dao.MessageDAO;

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

            // Initialize success flag
            boolean success = false;

            try {
                // Create message
                Message message = new Message();
                message.setSubject(subject);
                message.setMessage(messageText);
                message.setName(userName);
                message.setEmail(userEmail);

                // Set the user ID
                int userId = user.getId();
                message.setUserId(userId);
                System.out.println("ContactServlet: User object: " + user);
                System.out.println("ContactServlet: User ID: " + userId);
                System.out.println("ContactServlet: Setting user ID to " + userId);
                System.out.println("ContactServlet: Message user ID after setting: " + message.getUserId());

                // Set creation timestamp
                message.setCreatedAt(new Timestamp(new Date().getTime()));

                // Save message
                success = messageService.saveMessage(message);
            } catch (Exception e) {
                System.out.println("ContactServlet: Error sending message: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Failed to send message. Please try again. Error: " + e.getMessage());
                response.sendRedirect("ContactServlet");
                return;
            }

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
