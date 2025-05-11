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

        // Validate input
        if (firstName == null || lastName == null || email == null || password == null ||
            firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        if (userService.emailExists(email)) {
            request.setAttribute("errorMessage", "Email already exists");
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
