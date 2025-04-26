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
 * Servlet implementation class AdminMessageServlet
 */
// Servlet mapping defined in web.xml
public class AdminMessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MessageDAO messageDAO;
    private MessageService messageService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminMessageServlet() {
        super();
        messageDAO = new MessageDAO();
        messageService = new MessageService();

        // Ensure database has required columns
        try {
            messageDAO.ensureReplyColumns();
        } catch (Exception e) {
            System.out.println("AdminMessageServlet: Error ensuring database columns: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listMessages(request, response);
                break;
            case "view":
                viewMessage(request, response);
                break;
            case "delete":
                deleteMessage(request, response);
                break;
            case "markRead":
                markMessageAsRead(request, response);
                break;
            case "markUnread":
                markMessageAsUnread(request, response);
                break;
            default:
                listMessages(request, response);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        System.out.println("AdminMessageServlet doPost: action = " + action);

        if (action == null) {
            action = "list";
            System.out.println("AdminMessageServlet doPost: action is null, defaulting to list");
        }

        switch (action) {
            case "reply":
                replyToMessage(request, response);
                break;
            default:
                listMessages(request, response);
        }
    }

    /**
     * List messages with optional filtering
     */
    private void listMessages(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String filter = request.getParameter("filter");
        List<Message> messages;

        if ("unread".equals(filter)) {
            // Get only unread messages
            messages = messageDAO.getUnreadMessages();
        } else if ("replied".equals(filter)) {
            // Get only replied messages
            messages = messageDAO.getRepliedMessages();
        } else {
            // Get all messages
            messages = messageDAO.getAllMessages();
        }

        request.setAttribute("messages", messages);
        request.setAttribute("filter", filter);
        request.getRequestDispatcher("/admin/messages.jsp").forward(request, response);
    }

    /**
     * View a specific message
     */
    private void viewMessage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get message ID from request parameter
        String idStr = request.getParameter("id");

        // Validate input
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Invalid message ID");
            return;
        }

        try {
            // Parse message ID
            int messageId = Integer.parseInt(idStr);

            // Get message from the model
            Message message = messageDAO.getMessageById(messageId);

            // Check if message exists
            if (message == null) {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Message not found");
                return;
            }

            // Mark message as read if it's not already
            if (!message.isRead()) {
                messageService.markMessageAsRead(messageId);
                message.setRead(true);
                message.setReadAt(new Timestamp(new Date().getTime()));
            }

            // Get replies to this message
            List<Message> replies = messageDAO.getRepliesByParentId(messageId);

            // Set attributes for the view
            request.setAttribute("message", message);
            request.setAttribute("replies", replies);

            // Forward to the view
            request.getRequestDispatcher("/admin/view-message.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Invalid message ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Error: " + e.getMessage());
        }
    }

    /**
     * Delete a message
     */
    private void deleteMessage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Invalid message ID");
            return;
        }

        try {
            int messageId = Integer.parseInt(idStr);
            boolean success = messageDAO.deleteMessage(messageId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?success=Message deleted successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Failed to delete message");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Invalid message ID format");
        }
    }

    /**
     * Mark a message as read
     */
    private void markMessageAsRead(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Invalid message ID");
            return;
        }

        try {
            int messageId = Integer.parseInt(idStr);
            boolean success = messageService.markMessageAsRead(messageId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?success=Message marked as read");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Failed to mark message as read");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Invalid message ID format");
        }
    }

    /**
     * Mark a message as unread
     */
    private void markMessageAsUnread(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Invalid message ID");
            return;
        }

        try {
            int messageId = Integer.parseInt(idStr);
            boolean success = messageDAO.markMessageAsUnread(messageId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?success=Message marked as unread");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Failed to mark message as unread");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Invalid message ID format");
        }
    }

    /**
     * Reply to a message
     */
    private void replyToMessage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get form parameters
        String idStr = request.getParameter("messageId");
        String replyContent = request.getParameter("replyContent");

        // Basic validation
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?error=Invalid message ID");
            return;
        }

        if (replyContent == null || replyContent.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminMessageServlet?action=view&id=" + idStr + "&error=Reply content cannot be empty");
            return;
        }

        try {
            // Parse message ID
            int messageId = Integer.parseInt(idStr);

            // Get the original message
            Message originalMessage = messageDAO.getMessageById(messageId);
            if (originalMessage == null) {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Message not found");
                return;
            }

            // Get admin info from session
            HttpSession session = request.getSession();
            User admin = (User) session.getAttribute("user");

            if (admin == null) {
                response.sendRedirect(request.getContextPath() + "/LoginServlet?error=You must be logged in as an admin to reply to messages");
                return;
            }

            String adminName = admin.getFullName();
            String adminEmail = admin.getEmail();

            if (adminName == null || adminName.trim().isEmpty() ||
                adminEmail == null || adminEmail.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + messageId + "&error=Your profile is incomplete. Please update your name and email before replying.");
                return;
            }

            // Create a simple reply message
            Message reply = new Message();
            reply.setName(adminName);
            reply.setEmail(adminEmail);
            reply.setSubject("RE: " + originalMessage.getSubject());
            reply.setMessage(replyContent);
            reply.setRead(true);
            reply.setParentId(messageId);
            reply.setReply(true);

            // Add the reply using the service layer
            boolean success = messageService.replyToMessage(messageId, replyContent, adminName, adminEmail);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + messageId + "&success=Reply sent successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + messageId + "&error=Failed to send reply");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Error: " + e.getMessage());
        }
    }
}
