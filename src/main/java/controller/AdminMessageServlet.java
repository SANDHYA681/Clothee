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
            // Removed markRead and markUnread cases since we removed that functionality
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
            case "editReply":
                editReply(request, response);
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
        // Get all messages - removed filtering since we removed that functionality
        List<Message> messages = messageDAO.getAllMessages();

        // Set attributes for the view
        request.setAttribute("messages", messages);

        // Forward to the messages.jsp page
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

            // No need to mark as read since we removed that functionality

            // Get replies for this message
            List<Message> replies = messageService.getRepliesByParentId(messageId);

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
     * Edit a reply message
     */
    private void editReply(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String replyIdStr = request.getParameter("replyId");
        String replyContent = request.getParameter("replyContent");

        if (replyIdStr == null || replyIdStr.trim().isEmpty() || replyContent == null || replyContent.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Invalid reply data");
            return;
        }

        try {
            int replyId = Integer.parseInt(replyIdStr);

            // Get the message to edit
            Message reply = messageDAO.getMessageById(replyId);

            if (reply == null) {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Reply not found");
                return;
            }

            // Update the reply content
            reply.setMessage(replyContent);

            // Save the updated reply
            boolean success = messageDAO.updateMessage(reply);

            if (success) {
                // Redirect back to the original message view
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + reply.getId() + "&success=Reply updated successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?action=view&id=" + reply.getId() + "&error=Failed to update reply");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/AdminMessageServlet?error=Invalid reply ID format");
        }
    }
}
