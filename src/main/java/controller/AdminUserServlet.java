package controller;

import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import service.UserService;
import dao.OrderDAO;
import util.ValidationUtil;

/**
 * Servlet implementation class AdminUserServlet
 * Handles user management operations for admin
 */
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;
    private OrderDAO orderDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminUserServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userService = new UserService();
            orderDAO = new OrderDAO();
            System.out.println("AdminUserServlet: UserService and OrderDAO initialized successfully");
        } catch (Exception e) {
            System.err.println("AdminUserServlet: Error initializing services: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Failed to initialize services", e);
        }
    }

    /**
     * Initialize services if they are null
     */
    private void ensureServicesInitialized() {
        if (userService == null) {
            userService = new UserService();
            System.out.println("AdminUserServlet: UserService initialized in ensureServicesInitialized");
        }
        if (orderDAO == null) {
            orderDAO = new OrderDAO();
            System.out.println("AdminUserServlet: OrderDAO initialized in ensureServicesInitialized");
        }
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

        switch (action) {
            case "view":
                viewUser(request, response);
                break;
            case "confirmDelete":
            case "showDeleteConfirmation":
                showDeleteConfirmation(request, response);
                break;
            case "delete":
                deleteUser(request, response);
                break;
            case "showAddForm":
                showAddForm(request, response);
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
        try {
            System.out.println("AdminUserServlet: Listing all users");

            // Ensure services are initialized
            ensureServicesInitialized();

            // Get all users using direct SQL query to avoid any service layer issues
            List<User> users = new ArrayList<>();
            try {
                users = userService.getAllUsers();
                System.out.println("AdminUserServlet: Retrieved " + users.size() + " users");
            } catch (Exception e) {
                System.out.println("AdminUserServlet: Error getting users from UserService: " + e.getMessage());
                e.printStackTrace();

                // Create a dummy user list for testing
                User adminUser = (User) request.getSession().getAttribute("user");
                if (adminUser != null) {
                    users.add(adminUser);
                    System.out.println("AdminUserServlet: Added current admin user to list");
                }
            }

            request.setAttribute("users", users);

            // Check for messages from session
            HttpSession session = request.getSession();
            String successMessage = (String) session.getAttribute("successMessage");
            String errorMessage = (String) session.getAttribute("errorMessage");

            // Set messages as request attributes
            if (successMessage != null && !successMessage.isEmpty()) {
                request.setAttribute("successMessage", successMessage);
                session.removeAttribute("successMessage");
            }

            if (errorMessage != null && !errorMessage.isEmpty()) {
                request.setAttribute("errorMessage", errorMessage);
                session.removeAttribute("errorMessage");
            }

            // Forward to customers.jsp
            request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("AdminUserServlet: Error in listUsers: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error listing users: " + e.getMessage());

            try {
                // Try to forward to customers.jsp with an empty list
                request.setAttribute("users", new ArrayList<User>());
                request.setAttribute("errorMessage", "Error listing users: " + e.getMessage());
                request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
            } catch (Exception ex) {
                // If forwarding fails, redirect to dashboard
                System.out.println("AdminUserServlet: Error forwarding to customers.jsp: " + ex.getMessage());
                ex.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            }
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
                // Set error message in session
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Invalid user ID");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            int userId = Integer.parseInt(userIdParam);
            User userToView = userService.getUserById(userId);

            if (userToView == null) {
                // Set error message in session
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            // Set user to view in request
            request.setAttribute("userToView", userToView);

            // Forward to view-user.jsp
            request.getRequestDispatcher("/admin/view-user.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("AdminUserServlet: Error in viewUser: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error viewing user: " + e.getMessage());

            // Redirect to customers page
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }

    /**
     * Show delete confirmation page
     */
    private void showDeleteConfirmation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String userIdParam = request.getParameter("id");
            HttpSession session = request.getSession();

            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Invalid user ID");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            int userId = Integer.parseInt(userIdParam);

            // Get current user
            User currentUser = (User) session.getAttribute("user");

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

            // Check if user has placed orders
            try {
                // Ensure OrderDAO is initialized
                if (orderDAO == null) {
                    orderDAO = new OrderDAO();
                }
                int orderCount = orderDAO.getOrderCountByUserId(userId);
                if (orderCount > 0) {
                    session.setAttribute("errorMessage", "Cannot delete user who has placed orders");
                    response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                    return;
                }
            } catch (Exception e) {
                System.out.println("AdminUserServlet: Error checking if user has orders: " + e.getMessage());
                e.printStackTrace();
                // Continue with deletion even if we can't check for orders
            }

            // Set user to delete in request
            request.setAttribute("userToDelete", userToDelete);

            // Forward to confirmation page
            request.getRequestDispatcher("/admin/delete-user-confirmation.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("AdminUserServlet: Error in confirmDeleteUser: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error confirming user deletion: " + e.getMessage());

            // Redirect to customers page
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }

    /**
     * Show the add user form
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Forward to add-customer.jsp
            request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("AdminUserServlet: Error in showAddForm: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error showing add form: " + e.getMessage());

            // Redirect to customers page
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }

    /**
     * Add a new user
     */
    private void addUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get form parameters
            String firstName = request.getParameter("first_name");
            String lastName = request.getParameter("last_name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");
            String profileImage = request.getParameter("profileImage");

            // Validate input
            if (firstName == null || firstName.trim().isEmpty() ||
                lastName == null || lastName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

                // Set form values as request attributes for repopulating the form
                request.setAttribute("firstName", firstName);
                request.setAttribute("lastName", lastName);
                request.setAttribute("email", email);
                request.setAttribute("phone", phone);
                request.setAttribute("error", "All required fields must be filled out");

                // Forward back to the form
                request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
                return;
            }

            // Validate email format
            if (!ValidationUtil.isValidEmail(email)) {
                request.setAttribute("firstName", firstName);
                request.setAttribute("lastName", lastName);
                request.setAttribute("email", email);
                request.setAttribute("phone", phone);
                request.setAttribute("error", "Invalid email format");
                request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
                return;
            }

            // Check if email already exists
            if (userService.emailExists(email)) {
                request.setAttribute("firstName", firstName);
                request.setAttribute("lastName", lastName);
                request.setAttribute("email", email);
                request.setAttribute("phone", phone);
                request.setAttribute("error", "Email already exists");
                request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
                return;
            }

            // Create new user
            User newUser = new User();
            newUser.setFirstName(firstName);
            newUser.setLastName(lastName);
            newUser.setEmail(email);
            newUser.setPassword(password); // Password will be hashed in the service layer
            newUser.setPhone(phone);
            newUser.setRole(role != null ? role : "user");
            newUser.setProfileImage(profileImage != null ? profileImage : "default.jpg");

            // Add user to database
            boolean success = userService.addUser(newUser);

            if (success) {
                // Set success message in session
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "User added successfully");

                // Redirect to customers page
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            } else {
                // Set error message and form values
                request.setAttribute("firstName", firstName);
                request.setAttribute("lastName", lastName);
                request.setAttribute("email", email);
                request.setAttribute("phone", phone);
                request.setAttribute("error", "Failed to add user");

                // Forward back to the form
                request.getRequestDispatcher("/admin/add-customer.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("AdminUserServlet: Error in addUser: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error adding user: " + e.getMessage());

            // Redirect to customers page
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }

    /**
     * Delete user
     */
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String userIdParam = request.getParameter("id");
            HttpSession session = request.getSession();

            if (userIdParam == null || userIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Invalid user ID");
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                return;
            }

            int userId = Integer.parseInt(userIdParam);

            // Get current user
            User currentUser = (User) session.getAttribute("user");

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

            // Check if user has placed orders
            try {
                // Ensure OrderDAO is initialized
                if (orderDAO == null) {
                    orderDAO = new OrderDAO();
                }
                int orderCount = orderDAO.getOrderCountByUserId(userId);
                if (orderCount > 0) {
                    session.setAttribute("errorMessage", "Cannot delete user who has placed orders");
                    response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
                    return;
                }
            } catch (Exception e) {
                System.out.println("AdminUserServlet: Error checking if user has orders: " + e.getMessage());
                e.printStackTrace();
                // Continue with deletion even if we can't check for orders
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

            // Delete user
            boolean success = userService.deleteUser(userId);

            if (success) {
                session.setAttribute("successMessage", "User deleted successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to delete user");
            }

            // Redirect to customers page
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        } catch (Exception e) {
            System.out.println("AdminUserServlet: Error in deleteUser: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error deleting user: " + e.getMessage());

            // Redirect to customers page
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
        }
    }
}
