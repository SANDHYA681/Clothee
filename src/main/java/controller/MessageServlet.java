package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.MessageDAO;
import model.Message;
import model.User;
import service.MessageService;

/**
 * Consolidated MessageServlet that handles all message-related operations
 * Combines functionality from MessageServlet, MessageFrontController, MessageController,
 * AdminMessageServlet, and CustomerMessageServlet
 */
public class MessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MessageService messageService;

    // View paths - centralized for easier maintenance
    private static final String VIEW_ADMIN_MESSAGES_LIST = "/admin/messages.jsp";
    private static final String VIEW_ADMIN_MESSAGE_DETAIL = "/admin/view-message.jsp";
    private static final String VIEW_CUSTOMER_MESSAGES_LIST = "/customer/messages.jsp";
    private static final String VIEW_CUSTOMER_MESSAGE_DETAIL = "/customer/view-message.jsp";
    private static final String VIEW_CONTACT_FORM = "/contact.jsp";
    private static final String VIEW_LOGIN = "/login.jsp";

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
        System.out.println("MessageServlet: Request URI = " + request.getRequestURI());
        System.out.println("MessageServlet: Context Path = " + request.getContextPath());
        System.out.println("MessageServlet: Servlet Path = " + request.getServletPath());
        System.out.println("MessageServlet: Path Info = " + request.getPathInfo());

        try {
            // Get action from request parameter or path info
            String action = getActionFromRequest(request);
            System.out.println("MessageServlet: Action = " + action);

            // Get user from session
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            // Handle different URL patterns
            String servletPath = request.getServletPath();

            // Handle contact form (no authentication required)
            if ("/ContactServlet".equals(servletPath)) {
                showContactForm(request, response);
                return;
            }

            // For all other operations, authentication is required
            if (user == null) {
                response.sendRedirect(request.getContextPath() + VIEW_LOGIN);
                return;
            }

            // Admin message operations
            if ("/AdminMessageServlet".equals(servletPath) || "/admin/AdminMessageServlet".equals(servletPath) ||
                "/admin/messages".equals(servletPath) || servletPath.startsWith("/admin/messages/")) {
                if (!user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + VIEW_LOGIN);
                    return;
                }
                handleAdminMessageAction(action, request, response, user);
                return;
            }

            // Customer message operations
            if ("/CustomerMessageServlet".equals(servletPath) || "/customer-messages".equals(servletPath) ||
                "/messages".equals(servletPath) || servletPath.startsWith("/messages/")) {
                handleCustomerMessageAction(action, request, response, user);
                return;
            }

            // Default message operations
            if ("/MessageServlet".equals(servletPath)) {
                if ("send".equals(action)) {
                    showContactForm(request, response);
                } else {
                    // For other actions, redirect to appropriate servlet based on user role
                    if (user.isAdmin()) {
                        response.sendRedirect(request.getContextPath() + "/admin/messages.jsp");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/customer/messages.jsp");
                    }
                }
                return;
            }

            // If we get here, the URL pattern is not recognized
            response.sendError(HttpServletResponse.SC_NOT_FOUND);

        } catch (Exception e) {
            // Centralized error handling
            System.err.println("Error in MessageServlet: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(request, response, e);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("MessageServlet: doPost called");
        System.out.println("MessageServlet: Request URI = " + request.getRequestURI());

        try {
            // Get action from request parameter
            String action = request.getParameter("action");
            if (action == null) {
                action = "send"; // Default action for POST is send
            }
            System.out.println("MessageServlet: Action = " + action);

            // Get user from session
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            // Handle different actions
            switch (action) {
                case "send":
                    sendMessage(request, response);
                    break;
                case "reply":
                    if (user == null || !user.isAdmin()) {
                        response.sendRedirect(request.getContextPath() + VIEW_LOGIN);
                        return;
                    }
                    replyToMessage(request, response, user);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                    break;
            }
        } catch (Exception e) {
            // Centralized error handling
            System.err.println("Error in MessageServlet doPost: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(request, response, e);
        }
    }

    /**
     * Helper method to get action from request
     */
    private String getActionFromRequest(HttpServletRequest request) {
        // First check for action parameter in the query string
        String action = request.getParameter("action");
        System.out.println("MessageServlet: Action parameter from query string = " + action);

        // If no action parameter, try to get it from the path
        if (action == null) {
            String pathInfo = request.getPathInfo();
            System.out.println("MessageServlet: Path info = " + pathInfo);

            if (pathInfo != null && !pathInfo.equals("/")) {
                // Remove leading slash and get the first path segment
                String[] pathParts = pathInfo.substring(1).split("/");
                if (pathParts.length > 0) {
                    action = pathParts[0];
                    System.out.println("MessageServlet: Action from path = " + action);
                }
            }
        }

        // If still no action, use default based on servlet path
        if (action == null) {
            String servletPath = request.getServletPath();
            if (servletPath.contains("Admin")) {
                action = "list"; // Default action for admin
            } else if (servletPath.contains("Contact")) {
                action = "send"; // Default action for contact
            } else {
                action = "list"; // Default action for customer
            }
            System.out.println("MessageServlet: Using default action = " + action);
        }

        return action;
    }

    /**
     * Handle admin message actions
     */
    private void handleAdminMessageAction(String action, HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Handling admin message action: " + action);

        switch (action.toLowerCase()) {
            case "view":
                viewAdminMessage(request, response, user);
                break;
            case "delete":
                deleteMessage(request, response, user);
                break;
            case "list":
            default:
                listAdminMessages(request, response, user);
                break;
        }
    }

    /**
     * Handle customer message actions
     */
    private void handleCustomerMessageAction(String action, HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Handling customer message action: " + action);

        switch (action.toLowerCase()) {
            case "view":
                viewCustomerMessage(request, response, user);
                break;
            case "list":
            default:
                listCustomerMessages(request, response, user);
                break;
        }
    }

    /**
     * Show contact form
     */
    private void showContactForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Showing contact form");
        request.getRequestDispatcher(VIEW_CONTACT_FORM).forward(request, response);
    }

    /**
     * List all messages (admin only)
     */
    private void listAdminMessages(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Listing all messages for admin");

        List<Message> messages = messageService.getAllMessages();
        System.out.println("MessageServlet: Found " + messages.size() + " messages");

        request.setAttribute("messages", messages);
        request.getRequestDispatcher(VIEW_ADMIN_MESSAGES_LIST).forward(request, response);
    }

    /**
     * List messages for a customer
     */
    private void listCustomerMessages(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Listing messages for customer ID " + user.getId());

        List<Message> messages = messageService.getMessagesByUserId(user.getId());
        System.out.println("MessageServlet: Found " + messages.size() + " messages for user ID " + user.getId());

        request.setAttribute("messages", messages);
        request.getRequestDispatcher(VIEW_CUSTOMER_MESSAGES_LIST).forward(request, response);
    }

    /**
     * View a specific message (admin view)
     */
    private void viewAdminMessage(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Viewing message (admin view)");

        String messageIdStr = request.getParameter("id");
        if (messageIdStr == null || messageIdStr.isEmpty()) {
            // Try to get it from path parameter
            String pathInfo = request.getPathInfo();
            if (pathInfo != null && pathInfo.startsWith("/view/")) {
                String[] pathParts = pathInfo.split("/");
                if (pathParts.length > 2) {
                    messageIdStr = pathParts[2];
                }
            }
        }

        if (messageIdStr == null || messageIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/messages.jsp");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdStr);
            Message message = messageService.getMessageById(messageId);

            if (message == null) {
                response.sendRedirect(request.getContextPath() + "/admin/messages.jsp?error=Message+not+found");
                return;
            }

            // Get replies for this message
            List<Message> replies = messageService.getRepliesByParentId(messageId);
            request.setAttribute("replies", replies);

            // Forward to the view-message.jsp page
            request.setAttribute("message", message);
            request.getRequestDispatcher(VIEW_ADMIN_MESSAGE_DETAIL).forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/messages.jsp?error=Invalid+message+ID");
        }
    }

    /**
     * View a specific message (customer view)
     */
    private void viewCustomerMessage(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Viewing message (customer view) for user ID " + user.getId());

        String messageIdStr = request.getParameter("id");
        if (messageIdStr == null || messageIdStr.isEmpty()) {
            // Try to get it from path parameter
            String pathInfo = request.getPathInfo();
            if (pathInfo != null && pathInfo.startsWith("/view/")) {
                String[] pathParts = pathInfo.split("/");
                if (pathParts.length > 2) {
                    messageIdStr = pathParts[2];
                }
            }
        }

        if (messageIdStr == null || messageIdStr.isEmpty()) {
            redirectWithError(response, request.getContextPath() + "/customer/messages.jsp", null);
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdStr);

            // Security check - ensure user has access to this message
            if (!messageService.userHasAccessToMessage(messageId, user.getId(), user.isAdmin())) {
                redirectWithError(response, request.getContextPath() + "/customer/messages.jsp", "Access denied or message not found");
                return;
            }

            // Get message with replies
            Message message = messageService.getMessageWithReplies(messageId);
            if (message == null) {
                redirectWithError(response, request.getContextPath() + "/customer/messages.jsp", "Message not found");
                return;
            }

            // Get replies for this message
            List<Message> replies = messageService.getRepliesByParentId(messageId);

            // Prepare data for view
            request.setAttribute("message", message);
            request.setAttribute("replies", replies);

            // Forward to view
            request.getRequestDispatcher(VIEW_CUSTOMER_MESSAGE_DETAIL).forward(request, response);

        } catch (NumberFormatException e) {
            redirectWithError(response, request.getContextPath() + "/customer/messages.jsp", "Invalid message ID");
        }
    }

    /**
     * Delete a message (admin only)
     */
    private void deleteMessage(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Deleting message");

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
            response.sendRedirect(request.getContextPath() + "/admin/messages?error=Invalid+message+ID");
        }
    }

    /**
     * Send a new message (from contact form)
     */
    private void sendMessage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Sending new message");
        System.out.println("MessageServlet: Request method = " + request.getMethod());
        System.out.println("MessageServlet: Request URI = " + request.getRequestURI());
        System.out.println("MessageServlet: Request parameters:");
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            System.out.println("  " + paramName + " = " + request.getParameter(paramName));
        }

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // If user is not logged in, redirect to login page
        if (user == null) {
            System.out.println("MessageServlet: User is not logged in, redirecting to login page");
            // Add a returnUrl parameter to redirect back to contact form after login
            String returnUrl = request.getContextPath() + "/contact.jsp";
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please+login+to+send+a+message&returnUrl=" + java.net.URLEncoder.encode(returnUrl, "UTF-8"));
            return;
        }

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
                request.getRequestDispatcher(VIEW_CONTACT_FORM).forward(request, response);
                return;
            }

            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Please enter your email address");
                request.getRequestDispatcher(VIEW_CONTACT_FORM).forward(request, response);
                return;
            }

            if (subject == null || subject.trim().isEmpty()) {
                request.setAttribute("error", "Please enter a subject");
                request.getRequestDispatcher(VIEW_CONTACT_FORM).forward(request, response);
                return;
            }

            if (content == null || content.trim().isEmpty()) {
                request.setAttribute("error", "Please enter your message");
                request.getRequestDispatcher(VIEW_CONTACT_FORM).forward(request, response);
                return;
            }

            // Process the message (Model interaction)
            // At this point, we know the user is logged in (we checked earlier)
            // Create message with user ID
            Message message = new Message();
            message.setName(user.getFullName());  // Use user's full name from their profile
            message.setEmail(user.getEmail());    // Use user's email from their profile
            message.setSubject(subject);
            message.setMessage(content);
            message.setUserId(user.getId());
            message.setCreatedAt(new Timestamp(new Date().getTime()));

            System.out.println("MessageServlet: Setting user ID to " + user.getId());
            boolean success = messageService.saveMessage(message);

            // Prepare response for the view
            if (success) {
                System.out.println("MessageServlet: Message sent successfully");
                // Redirect to the messages page
                response.sendRedirect(request.getContextPath() + "/messages?message=Your+message+has+been+sent+successfully");
                return;
            } else {
                System.out.println("MessageServlet: Failed to send message");
                request.setAttribute("error", "Failed to send message. Please try again later.");
                // Forward back to the contact form with the error message
                request.getRequestDispatcher(VIEW_CONTACT_FORM).forward(request, response);
            }

        } catch (Exception e) {
            System.out.println("MessageServlet: Exception in sendMessage: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing your request.");
            request.getRequestDispatcher(VIEW_CONTACT_FORM).forward(request, response);
        }
    }

    /**
     * Reply to a message (admin only)
     */
    private void replyToMessage(HttpServletRequest request, HttpServletResponse response, User admin)
            throws ServletException, IOException {
        System.out.println("MessageServlet: Replying to message");

        String messageIdStr = request.getParameter("messageId");
        String replyContent = request.getParameter("replyContent");

        if (messageIdStr == null || messageIdStr.isEmpty() || replyContent == null || replyContent.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/messages?error=Invalid+reply+data");
            return;
        }

        try {
            int messageId = Integer.parseInt(messageIdStr);

            // Get the message to check if it's already a reply
            Message message = messageService.getMessageById(messageId);
            if (message == null) {
                response.sendRedirect(request.getContextPath() + "/admin/messages?error=Message+not+found");
                return;
            }

            // Check if the message is already a reply
            if (message.isReply()) {
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId + "&error=Cannot+reply+to+a+reply");
                return;
            }

            // Get admin name and email
            String adminName = admin.getFullName();
            String adminEmail = admin.getEmail();

            if (adminName == null || adminName.trim().isEmpty() ||
                adminEmail == null || adminEmail.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId + "&error=Your+profile+is+incomplete.+Please+update+your+name+and+email+before+replying.");
                return;
            }

            // Use the MessageService to handle the reply
            boolean success = messageService.replyToMessage(messageId, replyContent, adminName, adminEmail, admin.getId());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId + "&success=Reply+sent+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/messages/view?id=" + messageId + "&error=Failed+to+send+reply");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/messages?error=Invalid+message+ID");
        }
    }

    /**
     * Helper method to redirect with error message
     */
    private void redirectWithError(HttpServletResponse response, String url, String errorMessage) throws IOException {
        if (errorMessage != null && !errorMessage.isEmpty()) {
            response.sendRedirect(url + "?error=" + errorMessage);
        } else {
            response.sendRedirect(url);
        }
    }

    /**
     * Send error response to client
     */
    private void sendErrorResponse(HttpServletRequest request, HttpServletResponse response, Exception e)
            throws IOException {
        response.setContentType("text/html");
        java.io.PrintWriter out = response.getWriter();
        out.println("<html><head><title>Error</title></head><body>");
        out.println("<h1>Error in MessageServlet</h1>");
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
