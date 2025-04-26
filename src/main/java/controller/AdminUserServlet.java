package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import model.Order;

import model.Message;
import model.Review;
import service.UserService;
import service.OrderService;
import service.MessageService;
import service.ReviewService;

import util.PasswordHasher;
import java.util.ArrayList;

/**
 * Servlet implementation class AdminUserServlet
 * Handles user management operations for admin
 */
// Servlet mapping defined in web.xml
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;
    private OrderService orderService;
    private MessageService messageService;
    private ReviewService reviewService;


    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminUserServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        super.init();
        userService = new UserService();
        orderService = new OrderService();
        messageService = new MessageService();
        reviewService = new ReviewService();

    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // If no action parameter is provided, default to listing all users
        if (request.getParameter("action") == null) {
            listUsers(request, response);
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "showAddForm":
                showAddUserForm(request, response);
                break;
            case "showEditForm":
                showEditUserForm(request, response);
                break;
            case "view":
                viewUser(request, response);
                break;
            case "delete":
                deleteUser(request, response);
                break;
            default:
                listUsers(request, response);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                addUser(request, response);
                break;
            case "update":
                updateUser(request, response);
                break;
            case "delete":
                deleteUser(request, response);
                break;
            default:
                listUsers(request, response);
        }
    }

    /**
     * List all users
     */
    private void listUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("AdminUserServlet: Listing all users");
        List<User> users = userService.getAllUsers();
        System.out.println("AdminUserServlet: Retrieved " + (users != null ? users.size() : 0) + " users");
        request.setAttribute("users", users);

        // Check for messages from both session and request parameters
        HttpSession session = request.getSession();
        String successMessage = (String) session.getAttribute("successMessage");
        String errorMessage = (String) session.getAttribute("errorMessage");

        // Also check request parameters for messages
        if (successMessage == null || successMessage.isEmpty()) {
            successMessage = request.getParameter("message");
        }
        if (errorMessage == null || errorMessage.isEmpty()) {
            errorMessage = request.getParameter("error");
        }

        // Set messages as request attributes
        if (successMessage != null && !successMessage.isEmpty()) {
            request.setAttribute("successMessage", successMessage);
        }
        if (errorMessage != null && !errorMessage.isEmpty()) {
            request.setAttribute("errorMessage", errorMessage);
        }

        // Clear session messages after reading them
        session.removeAttribute("successMessage");
        session.removeAttribute("errorMessage");

        // Set context path for CSS and JS files
        request.setAttribute("contextPath", request.getContextPath());

        // Set base URL for navigation
        String baseUrl = request.getContextPath() + "/admin/";
        request.setAttribute("baseUrl", baseUrl);

        request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
    }

    /**
     * Show add user form
     */
    private void showAddUserForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Set context path for CSS and JS files
        request.setAttribute("contextPath", request.getContextPath());

        // Set base URL for navigation
        String baseUrl = request.getContextPath() + "/admin/";
        request.setAttribute("baseUrl", baseUrl);

        request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
    }

    /**
     * Show edit user form
     */
    private void showEditUserForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userIdParam = request.getParameter("id");

        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            // Set error message in session for better persistence
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid user ID");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            // Set error message in session for better persistence
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid user ID format");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            return;
        }

        User user = userService.getUserById(userId);

        if (user != null) {
            // Check if user is an admin - don't allow editing admin users
            if (user.isAdmin()) {
                // Set error message in session for better persistence
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Admin users cannot be edited");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            request.setAttribute("user", user);
            // Set context path for CSS and JS files
            request.setAttribute("contextPath", request.getContextPath());

            // Set base URL for navigation
            String baseUrl = request.getContextPath() + "/admin/";
            request.setAttribute("baseUrl", baseUrl);

            request.getRequestDispatcher("/admin/edit-customer.jsp").forward(request, response);
        } else {
            // Set error message in session for better persistence
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "User not found");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }

    /**
     * Add a new user
     */
    private void addUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");

        // Validate input
        if (firstName == null || lastName == null || email == null || password == null ||
            firstName.trim().isEmpty() || lastName.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "All required fields must be filled out");
            request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        if (userService.emailExists(email)) {
            request.setAttribute("error", "Email already exists");
            request.setAttribute("firstName", firstName);
            request.setAttribute("lastName", lastName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
            return;
        }

        // Create user
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        User newUser = userService.registerUser(firstName, lastName, email, password, phone, isAdmin);

        if (newUser != null) {
            // Set success message in session for better persistence
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Customer added successfully");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        } else {
            request.setAttribute("error", "Failed to add customer");
            request.setAttribute("firstName", firstName);
            request.setAttribute("lastName", lastName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
        }
    }

    /**
     * Update an existing user
     */
    private void updateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("id"));
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");
        String password = request.getParameter("password");

        // Validate input
        if (firstName == null || lastName == null || email == null ||
            firstName.trim().isEmpty() || lastName.trim().isEmpty() || email.trim().isEmpty()) {
            request.setAttribute("error", "All required fields must be filled out");
            showEditUserForm(request, response);
            return;
        }

        // Get existing user
        User existingUser = userService.getUserById(userId);
        if (existingUser == null) {
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp?error=User+not+found");
            return;
        }

        // Check if user is an admin - don't allow editing admin users
        if (existingUser.isAdmin()) {
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Admin users cannot be edited");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            return;
        }

        // Check if email already exists and belongs to a different user
        User userWithEmail = userService.getUserByEmail(email);
        if (userWithEmail != null && userWithEmail.getId() != userId) {
            request.setAttribute("error", "Email already exists");
            showEditUserForm(request, response);
            return;
        }

        // Update user
        existingUser.setFirstName(firstName);
        existingUser.setLastName(lastName);
        existingUser.setEmail(email);
        existingUser.setPhone(phone);
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        existingUser.setRole(isAdmin ? "admin" : "user");
        existingUser.setAdmin(isAdmin);
        existingUser.setUpdatedAt(new Timestamp(new Date().getTime()));

        // Update password if provided
        if (password != null && !password.trim().isEmpty()) {
            existingUser.setPassword(PasswordHasher.hashPassword(password));
        }

        boolean success = userService.updateUserProfile(existingUser.getId(), firstName, lastName, email, phone, role);

        // If password was provided, update it separately
        if (success && password != null && !password.trim().isEmpty()) {
            userService.updatePassword(existingUser.getId(), password);
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp?message=Customer+updated+successfully");
        } else {
            request.setAttribute("error", "Failed to update customer");
            showEditUserForm(request, response);
        }
    }

    /**
     * View user details
     */
    private void viewUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
        String userIdParam = request.getParameter("id");
        System.out.println("AdminUserServlet: viewUser called with id=" + userIdParam);

        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            // Set error message in session for better persistence
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid user ID");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            System.out.println("AdminUserServlet: Invalid user ID");
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdParam);
            System.out.println("AdminUserServlet: Parsed user ID: " + userId);
        } catch (NumberFormatException e) {
            // Set error message in session for better persistence
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Invalid user ID format");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            System.out.println("AdminUserServlet: Invalid user ID format");
            return;
        }

        System.out.println("AdminUserServlet: Retrieving user with ID: " + userId);
        User user = userService.getUserById(userId);
        System.out.println("AdminUserServlet: User retrieved: " + (user != null ? "Yes" : "No"));

        if (user != null) {
            // Get user's orders
            System.out.println("AdminUserServlet: Retrieving orders for user ID: " + userId);
            List<Order> orders = orderService.getOrdersByUserId(userId);
            System.out.println("AdminUserServlet: Retrieved " + (orders != null ? orders.size() : 0) + " orders");
            request.setAttribute("orders", orders);

            // Get user's messages
            List<Message> messages = new ArrayList<>();
            try {
                messages = messageService.getMessagesByUserId(userId);
            } catch (Exception e) {
                // If method doesn't exist, ignore
                System.out.println("Error getting messages: " + e.getMessage());
            }
            request.setAttribute("messages", messages);

            // Get user's reviews
            List<Review> reviews = new ArrayList<>();
            try {
                reviews = reviewService.getReviewsByUserId(userId);
            } catch (Exception e) {
                // If method doesn't exist, ignore
                System.out.println("Error getting reviews: " + e.getMessage());
            }
            request.setAttribute("reviews", reviews);

            // Set empty wishlist items to prevent null pointer exception
            request.setAttribute("wishlistItems", new ArrayList<>());

            // Set user attribute
            request.setAttribute("user", user);
            // Also set as viewUser for backward compatibility
            request.setAttribute("viewUser", user);

            // Set context path for CSS and JS files
            request.setAttribute("contextPath", request.getContextPath());

            // Set base URL for navigation
            String baseUrl = request.getContextPath() + "/admin/";
            request.setAttribute("baseUrl", baseUrl);

            // Forward to customer details page
            request.getRequestDispatcher("/admin/customer-details.jsp").forward(request, response);
            System.out.println("AdminUserServlet: Forwarded to customer-details.jsp");
        } else {
            // Set error message in session for better persistence
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "User not found");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
        } catch (Exception e) {
            // Log the full stack trace to help diagnose the issue
            System.out.println("CRITICAL ERROR in viewUser method: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "An error occurred while viewing user details: " + e.getMessage());

            // Redirect to customers page
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }

    /**
     * Delete a user
     */
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userIdParam = request.getParameter("id");
        HttpSession session = request.getSession();

        try {
            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Invalid user ID");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            int userId;
            try {
                userId = Integer.parseInt(userIdParam);
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Invalid user ID format");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            // Get current user
            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/LoginServlet");
                return;
            }

            // Don't allow deleting the current user
            if (currentUser.getId() == userId) {
                session.setAttribute("errorMessage", "Cannot delete your own account");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            // Check if user exists
            User userToDelete = userService.getUserById(userId);
            if (userToDelete == null) {
                session.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            // Don't allow deleting the last admin if the user to delete is an admin
            if (userToDelete.isAdmin()) {
                int adminCount = userService.getUsersByRole("admin").size();
                if (adminCount <= 1) {
                    session.setAttribute("errorMessage", "Cannot delete the last admin account");
                    response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                    return;
                }
            }

            boolean success = userService.deleteUser(userId);

            if (success) {
                session.setAttribute("successMessage", "Customer deleted successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to delete customer. The customer has orders in the system. Please delete the customer's orders first.");
            }

            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");

        } catch (Exception e) {
            // Log the exception
            System.err.println("Error in deleteUser: " + e.getMessage());
            e.printStackTrace();

            // Set error message
            session.setAttribute("errorMessage", "An error occurred while deleting the customer: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }
}
