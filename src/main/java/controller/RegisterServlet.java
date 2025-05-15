package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.UserService;
import util.ValidationUtil;

/**
 * Servlet implementation class RegisterServlet
 */
// Servlet mapping defined in web.xml
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public RegisterServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        showRegisterForm(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        register(request, response);
    }

    /**
     * Show registration form
     */
    private void showRegisterForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    /**
     * User registration
     */
    private void register(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");
        String redirectUrl = request.getParameter("redirectUrl");

        // Validate required fields
        if (firstName == null || lastName == null || email == null || password == null ||
            firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate name format (alphabetic characters only)
        if (!ValidationUtil.isValidName(firstName)) {
            request.setAttribute("errorMessage", "First name must contain only alphabetic characters");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtil.isValidName(lastName)) {
            request.setAttribute("errorMessage", "Last name must contain only alphabetic characters");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate email format
        if (!ValidationUtil.isValidEmail(email)) {
            request.setAttribute("errorMessage", "Please enter a valid email address");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate password (at least 6 characters)
        if (!ValidationUtil.isValidPassword(password)) {
            request.setAttribute("errorMessage", "Password must be at least 6 characters long");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate password confirmation
        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate phone number format (only digits allowed)
        if (!ValidationUtil.isValidPhone(phone)) {
            request.setAttribute("errorMessage", "Phone number must contain only digits");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Check if first name already exists (unique username)
        if (userService.firstNameExists(firstName)) {
            request.setAttribute("errorMessage", "Username already exists. Please choose a different first name");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        if (userService.emailExists(email)) {
            request.setAttribute("errorMessage", "Email already exists");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Check if phone number already exists (only if phone is provided)
        if (phone != null && !phone.isEmpty() && userService.phoneExists(phone)) {
            request.setAttribute("errorMessage", "Phone number already exists");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Register user as a customer (not admin)
        User user = userService.registerUser(firstName, lastName, email, password, phone, false);

        if (user != null) {
            // Set success message
            request.getSession().setAttribute("successMessage", "Registration successful. Please login.");

            // Redirect to login page
            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                response.sendRedirect("login.jsp?message=" + URLEncoder.encode("Registration successful. Please login.", StandardCharsets.UTF_8) + "&redirectUrl=" + redirectUrl);
            } else {
                response.sendRedirect("login.jsp?message=" + URLEncoder.encode("Registration successful. Please login.", StandardCharsets.UTF_8));
            }
        } else {
            request.setAttribute("errorMessage", "Registration failed. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
