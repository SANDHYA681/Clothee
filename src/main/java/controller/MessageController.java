package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.MessageDAO;
import model.Message;

/**
 * Controller for handling admin message operations
 */
// Servlet mapping defined in web.xml
public class MessageController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MessageDAO messageDAO;

    public MessageController() {
        super();
        messageDAO = new MessageDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            // List all messages
            listMessages(request, response);
        } else if (pathInfo.equals("/view")) {
            // View a specific message
            viewMessage(request, response);
        } else if (pathInfo.equals("/delete")) {
            // Delete a message
            deleteMessage(request, response);
        } else {
            // 404 - Not found
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("MessageController doPost: pathInfo = " + pathInfo);

        // Check for action parameter
        String action = request.getParameter("action");
        System.out.println("MessageController doPost: action parameter = " + action);

        if ("reply".equals(action)) {
            // Handle reply action
            replyMessage(request, response);
        } else if (pathInfo == null || pathInfo.equals("/")) {
            // Handle message reply (for backward compatibility)
            replyMessage(request, response);
        } else if (pathInfo.equals("/mark-read")) {
            // Mark message as read
            markMessageAsRead(request, response);
        } else {
            // 404 - Not found
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * List all messages
     */
    private void listMessages(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get filter parameter (all, unread)
        String filter = request.getParameter("filter");
        List<Message> messages;

        if ("unread".equals(filter)) {
            messages = messageDAO.getUnreadMessages();
            request.setAttribute("filter", "unread");
        } else {
            messages = messageDAO.getAllMessages();
            request.setAttribute("filter", "all");
        }

        // Get unread count for display in sidebar
        int unreadCount = messageDAO.getUnreadMessageCount();

        request.setAttribute("messages", messages);
        request.setAttribute("unreadCount", unreadCount);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/admin/messages/list.jsp");
        dispatcher.forward(request, response);
    }

    /**
     * View a specific message
     */
    private void viewMessage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get message ID from request parameter
        String messageIdParam = request.getParameter("id");

        if (messageIdParam == null || messageIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/messages");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdParam);
            Message message = messageDAO.getMessageById(messageId);

            if (message == null) {
                response.sendRedirect(request.getContextPath() + "/admin/messages");
                return;
            }

            // Mark message as read if it's not already read
            if (!message.isRead()) {
                messageDAO.markMessageAsRead(messageId);
                // Refresh message to get updated read status
                message = messageDAO.getMessageById(messageId);
            }

            request.setAttribute("message", message);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/admin/messages/view.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/messages");
        }
    }

    /**
     * Delete a message
     */
    private void deleteMessage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get message ID from request parameter
        String messageIdParam = request.getParameter("id");

        if (messageIdParam == null || messageIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/messages");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdParam);
            boolean deleted = messageDAO.deleteMessage(messageId);

            if (deleted) {
                request.getSession().setAttribute("successMessage", "Message deleted successfully");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to delete message");
            }

            response.sendRedirect(request.getContextPath() + "/admin/messages");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/messages");
        }
    }

    /**
     * Mark message as read
     */
    private void markMessageAsRead(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get message ID from request parameter
        String messageIdParam = request.getParameter("id");

        if (messageIdParam == null || messageIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/messages");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdParam);
            boolean marked = messageDAO.markMessageAsRead(messageId);

            // Send plain text response
            response.setContentType("text/plain");
            response.getWriter().write(marked ? "success" : "error");

        } catch (NumberFormatException e) {
            response.setContentType("text/plain");
            response.getWriter().write("error");
        }
    }

    /**
     * Reply to a message
     */
    private void replyMessage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("MessageController: replyMessage method called");

        // Print all request parameters for debugging
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        System.out.println("MessageController: Request parameters:");
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            System.out.println("  " + paramName + " = " + paramValue);
        }

        // Get message ID and reply content from request parameters
        String messageIdParam = request.getParameter("messageId");
        String replyContent = request.getParameter("replyContent");

        System.out.println("MessageController: messageIdParam = " + messageIdParam);
        System.out.println("MessageController: replyContent = " + replyContent);

        if (messageIdParam == null || messageIdParam.isEmpty() || replyContent == null || replyContent.isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Message ID and reply content are required");
            response.sendRedirect(request.getContextPath() + "/admin/messages");
            return;
        }

        try {
            System.out.println("MessageController: Parsing messageId");
            int messageId = Integer.parseInt(messageIdParam);
            System.out.println("MessageController: messageId = " + messageId);

            System.out.println("MessageController: Getting original message from database");
            Message originalMessage = messageDAO.getMessageById(messageId);

            if (originalMessage != null) {
                System.out.println("MessageController: Original message found: ID=" + originalMessage.getId() + ", Subject=" + originalMessage.getSubject());
            } else {
                System.out.println("MessageController: Original message is null");
            }

            if (originalMessage == null) {
                request.getSession().setAttribute("errorMessage", "Original message not found");
                response.sendRedirect(request.getContextPath() + "/admin/messages");
                return;
            }

            // Get admin user from session
            System.out.println("MessageController: Getting admin user from session");
            jakarta.servlet.http.HttpSession session = request.getSession();
            model.User admin = (model.User) session.getAttribute("user");

            // Default admin values
            String adminName = "Admin";
            String adminEmail = "admin@clothee.com";

            // Use admin's actual name and email if available
            if (admin != null) {
                adminName = admin.getFullName() != null ? admin.getFullName() : adminName;
                adminEmail = admin.getEmail() != null ? admin.getEmail() : adminEmail;
            } else {
                System.out.println("MessageController: Warning - admin user is null, using default values");
            }

            // Create a reply message
            System.out.println("MessageController: Creating reply message");
            Message reply = new Message();

            // Set admin name and email
            reply.setName(adminName);
            reply.setEmail(adminEmail);
            System.out.println("MessageController: Replying as " + adminName + " <" + adminEmail + ">");

            reply.setSubject("RE: " + originalMessage.getSubject());
            reply.setMessage(replyContent);
            reply.setRead(true);
            reply.setParentId(messageId);
            reply.setReply(true);
            reply.setReplied(false);

            // Set creation timestamp
            System.out.println("MessageController: Setting creation timestamp");
            reply.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            System.out.println("MessageController: Reply message created successfully");

            // Add the reply to the database
            System.out.println("MessageController: Adding reply to database");
            boolean replyAdded = false;
            try {
                replyAdded = messageDAO.addMessage(reply);
                System.out.println("MessageController: Reply added to database: " + replyAdded);
            } catch (Exception e) {
                System.out.println("MessageController: Error adding reply to database: " + e.getMessage());
                e.printStackTrace();
                request.getSession().setAttribute("errorMessage", "Error adding reply to database: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId);
                return;
            }

            if (!replyAdded) {
                request.getSession().setAttribute("errorMessage", "Failed to send reply");
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId);
                return;
            }

            // Mark the original message as replied
            System.out.println("MessageController: Marking original message as replied");
            boolean marked = false;
            try {
                marked = messageDAO.markMessageAsReplied(messageId);
                System.out.println("MessageController: Original message marked as replied: " + marked);
            } catch (Exception e) {
                System.out.println("MessageController: Error marking message as replied: " + e.getMessage());
                e.printStackTrace();
                request.getSession().setAttribute("errorMessage", "Error marking message as replied: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId);
                return;
            }

            if (!marked) {
                System.out.println("MessageController: Failed to mark message as replied");
                request.getSession().setAttribute("errorMessage", "Failed to mark message as replied");
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId);
                return;
            }

            // In a real application, you would send an email reply here
            System.out.println("Sending reply to: " + originalMessage.getEmail());
            System.out.println("Reply content: " + replyContent);

            request.getSession().setAttribute("successMessage", "Reply sent successfully");
            response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId);

        } catch (NumberFormatException e) {
            System.out.println("MessageController: NumberFormatException: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Invalid message ID");
            response.sendRedirect(request.getContextPath() + "/admin/messages");
        } catch (Exception e) {
            System.out.println("MessageController: Unexpected exception: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "An unexpected error occurred");
            response.sendRedirect(request.getContextPath() + "/admin/messages");
        }
    }
}
