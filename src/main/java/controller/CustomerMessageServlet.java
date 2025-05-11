package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Message;
import model.User;
import service.MessageService;

/**
 * Servlet implementation class CustomerMessageServlet
 * Handles customer message viewing - Controller component in MVC pattern
 */
public class CustomerMessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MessageService messageService;

    // View paths - centralized for easier maintenance
    private static final String VIEW_MESSAGES_LIST = "/customer/messages-view.jsp";
    private static final String VIEW_MESSAGE_DETAIL = "/customer/view-message.jsp";
    private static final String VIEW_LOGIN = "/login.jsp";

    /**
     * @see HttpServlet#HttpServlet()
     */
    public CustomerMessageServlet() {
        super();
        // Initialize the service layer - following dependency injection principle
        messageService = new MessageService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     *
     * This servlet is now deprecated in favor of the MessageFrontController
     * It simply redirects to the new controller to maintain backward compatibility
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Request routing - Controller responsibility
        String action = request.getParameter("action");
        System.out.println("CustomerMessageServlet: Action parameter = " + action);

        // Default action if none specified
        if (action == null) {
            action = "list"; // Default action
            System.out.println("CustomerMessageServlet: Using default action = " + action);
        }

        try {
            // Authentication check - Controller responsibility
            User user = authenticateUser(request, response);
            if (user == null) {
                // Authentication failed, redirect already handled
                System.out.println("CustomerMessageServlet: Authentication failed, user is null");
                return;
            }

            System.out.println("CustomerMessageServlet: User authenticated successfully, ID = " + user.getId());

            // Handle different actions based on the request parameter
            if ("view".equals(action)) {
                viewMessage(request, response, user);
            } else {
                // Default action is to list messages
                listMessages(request, response, user);
            }
        } catch (Exception e) {
            // Catch any unexpected errors
            System.err.println("Unexpected error in CustomerMessageServlet: " + e.getMessage());
            e.printStackTrace();

            // Send error details to the client for debugging
            response.setContentType("text/html");
            java.io.PrintWriter out = response.getWriter();
            out.println("<html><head><title>Error</title></head><body>");
            out.println("<h1>Unexpected Error in CustomerMessageServlet</h1>");
            out.println("<p>" + e.getMessage() + "</p>");
            out.println("<h2>Stack Trace:</h2>");
            out.println("<pre>");
            for (StackTraceElement element : e.getStackTrace()) {
                out.println(element.toString());
            }
            out.println("</pre>");
            out.println("<p><a href='" + request.getContextPath() + "/index.jsp'>Go to Homepage</a></p>");
            out.println("</body></html>");
        }
    }

    /**
     * Authenticate user and handle redirection if not authenticated
     * @param request HTTP request
     * @param response HTTP response
     * @return User object if authenticated, null otherwise
     */
    private User authenticateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + VIEW_LOGIN);
            return null;
        }

        return user;
    }

    /**
     * List all messages for a customer
     * Controller method that gets data from model and forwards to view
     */
    private void listMessages(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("CustomerMessageServlet: listMessages method called for user ID " + user.getId());

        try {
            // Get data from model via service layer
            System.out.println("CustomerMessageServlet: Calling messageService.getMessagesByUserId");
            List<Message> messages = messageService.getMessagesByUserId(user.getId());

            // Logging
            System.out.println("CustomerMessageServlet: Found " + messages.size() + " messages for user ID " + user.getId());

            // Prepare data for view
            request.setAttribute("messages", messages);

            // Forward to view
            System.out.println("CustomerMessageServlet: Forwarding to " + VIEW_MESSAGES_LIST);
            request.getRequestDispatcher(VIEW_MESSAGES_LIST).forward(request, response);
            System.out.println("CustomerMessageServlet: Forward completed");
        } catch (Exception e) {
            System.err.println("Error in listMessages method: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error listing messages: " + e.getMessage(), e);
        }
    }

    /**
     * View a specific message
     * Controller method that gets data from model and forwards to view
     */
    private void viewMessage(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("CustomerMessageServlet: viewMessage method called for user ID " + user.getId());

        // Input validation - Controller responsibility
        String messageIdStr = request.getParameter("id");
        System.out.println("CustomerMessageServlet: Message ID parameter = " + messageIdStr);

        if (messageIdStr == null || messageIdStr.isEmpty()) {
            System.out.println("CustomerMessageServlet: Message ID is null or empty, redirecting to list");
            redirectWithError(response, request.getContextPath() + "/customer-messages", null);
            return;
        }

        try {
            // Parse and validate input
            int messageId = Integer.parseInt(messageIdStr);
            System.out.println("CustomerMessageServlet: Parsed message ID = " + messageId);

            // Security check using service layer
            System.out.println("CustomerMessageServlet: Checking access for message ID = " + messageId);
            if (!messageService.userHasAccessToMessage(messageId, user.getId(), user.isAdmin())) {
                System.out.println("CustomerMessageServlet: Access denied for message ID = " + messageId);
                redirectWithError(response, request.getContextPath() + "/customer-messages", "Access denied or message not found");
                return;
            }
            System.out.println("CustomerMessageServlet: Access granted for message ID = " + messageId);

            // Get data from model via service layer - this also marks the message as read
            System.out.println("CustomerMessageServlet: Getting message with replies for ID = " + messageId);
            Message message = messageService.getMessageWithReplies(messageId);

            // Validate message exists (should never happen after access check, but just in case)
            if (message == null) {
                System.out.println("CustomerMessageServlet: Message not found for ID = " + messageId + " (after access check)");
                redirectWithError(response, request.getContextPath() + "/customer-messages", "Message not found");
                return;
            }
            System.out.println("CustomerMessageServlet: Message found, ID = " + message.getId() + ", Subject = " + message.getSubject());

            // Get related data from model
            System.out.println("CustomerMessageServlet: Getting replies for message ID = " + messageId);
            List<Message> replies = messageService.getRepliesByParentId(messageId);

            // Log the replies for debugging
            System.out.println("CustomerMessageServlet: Found " + replies.size() + " replies for message ID " + messageId);
            for (Message reply : replies) {
                System.out.println("CustomerMessageServlet: Reply ID: " + reply.getId() + ", From: " + reply.getName() + ", is_reply: " + reply.isReply() + ", parent_id: " + reply.getParentId());
                System.out.println("CustomerMessageServlet: Content: " + (reply.getMessage().length() > 50 ? reply.getMessage().substring(0, 50) + "..." : reply.getMessage()));
            }

            // Prepare data for view
            System.out.println("CustomerMessageServlet: Setting request attributes");
            request.setAttribute("message", message);
            request.setAttribute("replies", replies);

            // Forward to view
            System.out.println("CustomerMessageServlet: Forwarding to " + VIEW_MESSAGE_DETAIL);
            request.getRequestDispatcher(VIEW_MESSAGE_DETAIL).forward(request, response);
            System.out.println("CustomerMessageServlet: Forward completed");

        } catch (NumberFormatException e) {
            System.out.println("CustomerMessageServlet: Invalid message ID format: " + request.getParameter("id"));
            redirectWithError(response, request.getContextPath() + "/customer-messages", "Invalid message ID");
        } catch (Exception e) {
            System.err.println("Error in viewMessage method: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error viewing message: " + e.getMessage(), e);
        }
    }

    /**
     * Helper method to redirect with error message
     * Centralizes redirect logic
     */
    private void redirectWithError(HttpServletResponse response, String url, String errorMessage) throws IOException {
        if (errorMessage != null && !errorMessage.isEmpty()) {
            response.sendRedirect(url + "?error=" + errorMessage);
        } else {
            response.sendRedirect(url);
        }
    }
}
