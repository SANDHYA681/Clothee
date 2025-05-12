package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Message;
import model.User;
import service.MessageService;

/**
 * Front Controller for all message-related operations
 * Follows MVC pattern by routing requests to appropriate handlers
 */
// Servlet mapping defined in web.xml
public class MessageFrontController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MessageService messageService;

    // View paths - centralized for easier maintenance
    private static final String VIEW_MESSAGES_LIST = "/customer/messages-view.jsp";
    private static final String VIEW_MESSAGE_DETAIL = "/customer/view-message.jsp";
    private static final String VIEW_LOGIN = "/login.jsp";

    /**
     * @see HttpServlet#HttpServlet()
     */
    public MessageFrontController() {
        super();
        // Initialize the service layer
        messageService = new MessageService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("MessageFrontController: doGet method called");
        System.out.println("MessageFrontController: Request URI = " + request.getRequestURI());
        System.out.println("MessageFrontController: Context Path = " + request.getContextPath());
        System.out.println("MessageFrontController: Servlet Path = " + request.getServletPath());
        System.out.println("MessageFrontController: Path Info = " + request.getPathInfo());

        try {
            // Authentication check
            User user = authenticateUser(request, response);
            if (user == null) {
                // Authentication failed, redirect already handled
                System.out.println("MessageFrontController: Authentication failed, user is null");
                return;
            }

            System.out.println("MessageFrontController: User authenticated successfully, ID = " + user.getId());

            // Request routing - Controller responsibility
            // First check for action parameter in the query string
            String action = request.getParameter("action");
            System.out.println("MessageFrontController: Action parameter from query string = " + action);

            // If no action parameter, try to get it from the path
            if (action == null) {
                String pathInfo = request.getPathInfo();
                System.out.println("MessageFrontController: Path info = " + pathInfo);

                if (pathInfo != null && !pathInfo.equals("/")) {
                    // Remove leading slash and get the first path segment
                    String[] pathParts = pathInfo.substring(1).split("/");
                    if (pathParts.length > 0) {
                        action = pathParts[0];
                        System.out.println("MessageFrontController: Action from path = " + action);
                    }
                }
            }

            // If still no action, use default
            if (action == null) {
                action = "list"; // Default action
                System.out.println("MessageFrontController: Using default action = " + action);
            }

            System.out.println("MessageFrontController: Action = " + action);

            // Route to appropriate handler method
            try {
                // Normalize action to lowercase and trim
                action = action.toLowerCase().trim();

                // Handle different action types
                switch (action) {
                    case "view":
                        System.out.println("MessageFrontController: Routing to viewMessage method");
                        viewMessage(request, response, user);
                        break;
                    case "list":
                        System.out.println("MessageFrontController: Routing to listMessages method");
                        listMessages(request, response, user);
                        break;
                    default:
                        System.out.println("MessageFrontController: Unknown action '" + action + "', defaulting to listMessages");
                        listMessages(request, response, user);
                        break;
                }
            } catch (Exception e) {
                // Centralized error handling
                System.err.println("Error in MessageFrontController action handling: " + e.getMessage());
                e.printStackTrace();

                // Send error details to the client for debugging
                response.setContentType("text/html");
                java.io.PrintWriter out = response.getWriter();
                out.println("<html><head><title>Error</title></head><body>");
                out.println("<h1>Error in MessageFrontController</h1>");
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
        } catch (Exception e) {
            // Catch any unexpected errors
            System.err.println("Unexpected error in MessageFrontController: " + e.getMessage());
            e.printStackTrace();

            // Send error details to the client for debugging
            response.setContentType("text/html");
            java.io.PrintWriter out = response.getWriter();
            out.println("<html><head><title>Error</title></head><body>");
            out.println("<h1>Unexpected Error in MessageFrontController</h1>");
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
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Handle POST requests (e.g., for sending messages)
        doGet(request, response);
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
        System.out.println("MessageFrontController: listMessages method called for user ID " + user.getId());

        try {
            // Get data from model via service layer
            System.out.println("MessageFrontController: Calling messageService.getMessagesByUserId");
            List<Message> messages = messageService.getMessagesByUserId(user.getId());

            // Logging
            System.out.println("MessageFrontController: Found " + messages.size() + " messages for user ID " + user.getId());

            // Prepare data for view
            request.setAttribute("messages", messages);

            // Forward to view
            System.out.println("MessageFrontController: Forwarding to " + VIEW_MESSAGES_LIST);
            request.getRequestDispatcher(VIEW_MESSAGES_LIST).forward(request, response);
            System.out.println("MessageFrontController: Forward completed");
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
        System.out.println("MessageFrontController: viewMessage method called for user ID " + user.getId());

        // Input validation - Controller responsibility
        // Try to get message ID from query parameter
        String messageIdStr = request.getParameter("id");
        System.out.println("MessageFrontController: Message ID from query parameter = " + messageIdStr);

        // If not found, try to get it from path parameter
        if (messageIdStr == null || messageIdStr.isEmpty()) {
            String pathInfo = request.getPathInfo();
            System.out.println("MessageFrontController: Path info = " + pathInfo);

            if (pathInfo != null && pathInfo.startsWith("/view/")) {
                // Extract ID from path like /view/123
                String[] pathParts = pathInfo.split("/");
                if (pathParts.length > 2) {
                    messageIdStr = pathParts[2];
                    System.out.println("MessageFrontController: Message ID from path = " + messageIdStr);
                }
            }
        }

        // If still not found, redirect to list
        if (messageIdStr == null || messageIdStr.isEmpty()) {
            System.out.println("MessageFrontController: Message ID is null or empty, redirecting to list");
            redirectWithError(response, request.getContextPath() + "/messages", null);
            return;
        }

        try {
            // Parse and validate input
            int messageId = Integer.parseInt(messageIdStr);
            System.out.println("MessageFrontController: Parsed message ID = " + messageId);

            // Security check using service layer
            System.out.println("MessageFrontController: Checking access for message ID = " + messageId);
            if (!messageService.userHasAccessToMessage(messageId, user.getId(), user.isAdmin())) {
                System.out.println("MessageFrontController: Access denied for message ID = " + messageId);
                redirectWithError(response, request.getContextPath() + "/messages", "Access denied or message not found");
                return;
            }
            System.out.println("MessageFrontController: Access granted for message ID = " + messageId);

            // Get data from model via service layer
            System.out.println("MessageFrontController: Getting message with replies for ID = " + messageId);
            Message message = messageService.getMessageWithReplies(messageId);

            // Get replies for this message
            List<Message> replies = messageService.getRepliesByParentId(messageId);

            // Validate message exists (should never happen after access check, but just in case)
            if (message == null) {
                System.out.println("MessageFrontController: Message not found for ID = " + messageId + " (after access check)");
                redirectWithError(response, request.getContextPath() + "/messages", "Message not found");
                return;
            }
            System.out.println("MessageFrontController: Message found, ID = " + message.getId() + ", Subject = " + message.getSubject());

            // Logging for replies
            System.out.println("MessageFrontController: Found " + replies.size() + " replies for message ID " + messageId);
            for (Message reply : replies) {
                System.out.println("MessageFrontController: Reply ID: " + reply.getId() + ", From: " + reply.getName() + ", Content: " +
                    (reply.getMessage().length() > 50 ? reply.getMessage().substring(0, 50) + "..." : reply.getMessage()));
            }

            // Prepare data for view
            System.out.println("MessageFrontController: Setting request attributes");
            request.setAttribute("message", message);
            request.setAttribute("replies", replies);

            // Forward to view
            System.out.println("MessageFrontController: Forwarding to " + VIEW_MESSAGE_DETAIL);
            request.getRequestDispatcher(VIEW_MESSAGE_DETAIL).forward(request, response);
            System.out.println("MessageFrontController: Forward completed");
        } catch (NumberFormatException e) {
            System.out.println("MessageFrontController: Invalid message ID format: " + request.getParameter("id"));
            redirectWithError(response, request.getContextPath() + "/messages", "Invalid message ID");
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
