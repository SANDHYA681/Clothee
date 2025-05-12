package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.MessageDAO;
import model.Message;
import model.User;
import service.MessageService;

/**
 * Servlet implementation class MessageServlet
 */
// Servlet mapping defined in web.xml
public class MessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MessageService messageService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public MessageServlet() {
        super();
        messageService = new MessageService();

        // Ensure database has required columns
        try {
            MessageDAO messageDAO = new MessageDAO();
            messageDAO.ensureReplyColumns();
        } catch (Exception e) {
            System.out.println("MessageServlet: Error ensuring database columns: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("MessageServlet: doGet called");
        String action = request.getParameter("action");

        // Handle test request
        if (action == null || action.equals("test")) {
            System.out.println("MessageServlet: Handling test request");
            response.setContentType("text/html");
            response.getWriter().println("<html><body>");
            response.getWriter().println("<h1>MessageServlet is working!</h1>");
            response.getWriter().println("<p>This confirms that the MessageServlet is properly mapped and accessible.</p>");
            response.getWriter().println("<p><a href='" + request.getContextPath() + "/contact.jsp'>Return to Contact Form</a></p>");
            response.getWriter().println("</body></html>");
            return;
        }

        // Check if user is logged in and is admin for admin actions
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "view":
                viewMessage(request, response);
                break;
            case "delete":
                deleteMessage(request, response);
                break;
            case "list":
            default:
                listMessages(request, response);
                break;
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        // Check if user is logged in and is admin for admin actions
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (action == null) {
            action = "send";
        }

        switch (action) {
            case "send":
                sendMessage(request, response);
                break;
            case "reply":
                if (user == null || !user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/LoginServlet");
                    return;
                }
                replyToMessage(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/index.jsp");
                break;
        }
    }

    /**
     * List all messages (admin only)
     */
    private void listMessages(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Message> messages = messageService.getAllMessages();

        // Removed unreadCount since we removed that functionality
        request.setAttribute("messages", messages);
        request.getRequestDispatcher("/admin/messages.jsp").forward(request, response);
    }

    /**
     * View a specific message (admin only)
     */
    private void viewMessage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String messageIdStr = request.getParameter("id");

        if (messageIdStr == null || messageIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/MessageServlet");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdStr);
            Message message = messageService.getMessageById(messageId);

            if (message == null) {
                response.sendRedirect(request.getContextPath() + "/MessageServlet?error=Message+not+found");
                return;
            }

            // Get replies for this message
            List<Message> replies = messageService.getRepliesByParentId(messageId);
            request.setAttribute("replies", replies);

            // Forward to the view-message.jsp page
            request.setAttribute("message", message);
            request.getRequestDispatcher("/admin/view-message.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/MessageServlet?error=Invalid+message+ID");
        }
    }

    /**
     * Delete a message (admin only)
     */
    private void deleteMessage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String messageIdStr = request.getParameter("id");

        if (messageIdStr == null || messageIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/messages.jsp");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdStr);
            boolean success = messageService.deleteMessage(messageId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/messages.jsp?message=Message+deleted+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/messages.jsp?error=Failed+to+delete+message");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/messages.jsp?error=Invalid+message+ID");
        }
    }

    /**
     * Send a new message (from contact form)
     */
    private void sendMessage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get form data
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String subject = request.getParameter("subject");
            String content = request.getParameter("message");

            System.out.println("MessageServlet: Received message from " + name + " <" + email + ">");
            System.out.println("MessageServlet: Subject: " + subject);

            // Validate form data (Controller responsibility)
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Please enter your name");
                request.getRequestDispatcher("/contact.jsp").forward(request, response);
                return;
            }

            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Please enter your email address");
                request.getRequestDispatcher("/contact.jsp").forward(request, response);
                return;
            }

            if (subject == null || subject.trim().isEmpty()) {
                request.setAttribute("error", "Please enter a subject");
                request.getRequestDispatcher("/contact.jsp").forward(request, response);
                return;
            }

            if (content == null || content.trim().isEmpty()) {
                request.setAttribute("error", "Please enter your message");
                request.getRequestDispatcher("/contact.jsp").forward(request, response);
                return;
            }

            // Process the message (Model interaction)
            boolean success = messageService.addMessage(name, email, subject, content);

            // Prepare response for the view
            if (success) {
                System.out.println("MessageServlet: Message sent successfully");
                request.setAttribute("success", "Your message has been sent successfully. We'll get back to you soon!");
            } else {
                System.out.println("MessageServlet: Failed to send message");
                request.setAttribute("error", "Failed to send message. Please try again later.");
            }

            // Forward to the view
            request.getRequestDispatcher("/contact.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("MessageServlet: Exception in sendMessage: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing your request.");
            request.getRequestDispatcher("/contact.jsp").forward(request, response);
        }
    }

    /**
     * Reply to a message (admin only)
     */
    private void replyToMessage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String messageIdStr = request.getParameter("messageId");
        String replyContent = request.getParameter("replyContent");

        if (messageIdStr == null || messageIdStr.isEmpty() || replyContent == null || replyContent.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/messages.jsp?error=Invalid+reply+data");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdStr);

            // Get the admin user from the session
            HttpSession session = request.getSession();
            User admin = (User) session.getAttribute("user");

            if (admin == null) {
                response.sendRedirect(request.getContextPath() + "/LoginServlet?error=You+must+be+logged+in+as+an+admin+to+reply+to+messages");
                return;
            }

            // Get admin name and email
            String adminName = admin.getFullName();
            String adminEmail = admin.getEmail();

            if (adminName == null || adminName.trim().isEmpty() ||
                adminEmail == null || adminEmail.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + messageId + "&error=Your+profile+is+incomplete.+Please+update+your+name+and+email+before+replying.");
                return;
            }

            // Use the MessageService to handle the reply
            boolean success = messageService.replyToMessage(messageId, replyContent, adminName, adminEmail, admin.getId());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + messageId + "&success=Reply+sent+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + messageId + "&error=Failed+to+send+reply");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/messages.jsp?error=Invalid+message+ID");
        }
    }
}
