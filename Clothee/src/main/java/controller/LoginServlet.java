package controller;

import java.io.IOException;
import java.net.URLEncoder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.UserService;

// Servlet mapping defined in web.xml
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "showLoginForm";
        }

        switch (action) {
            case "showLoginForm":
                showLoginForm(request, response);
                break;
            case "logout":
                logout(request, response);
                break;
            default:
                showLoginForm(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "login";
        }

        switch (action) {
            case "login":
                login(request, response);
                break;
            default:
                showLoginForm(request, response);
        }
    }

    private void showLoginForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String tab = request.getParameter("tab");
        String error = request.getParameter("error");
        String message = request.getParameter("message");
        String redirectUrl = request.getParameter("redirectUrl");

        if (tab == null) {
            tab = "customer";
        }

        request.setAttribute("activeTab", tab);
        if (error != null) {
            request.setAttribute("error", error);
        }
        if (message != null) {
            request.setAttribute("message", message);
        }
        if (redirectUrl != null) {
            request.setAttribute("redirectUrl", redirectUrl);
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    private void login(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String userType = request.getParameter("userType");
        String redirectUrl = request.getParameter("redirectUrl");

        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            log("Login failed: Empty email or password");
            request.setAttribute("error", "Email and password are required");
            request.setAttribute("activeTab", userType);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            User user = userService.authenticateUser(email, password);
            if (user == null) {
                log("Login failed: Invalid email or password for " + email);
                request.setAttribute("error", "Invalid email or password");
                request.setAttribute("activeTab", userType);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Always get the most up-to-date user data from the database
            // This ensures any profile changes are reflected when logging in
            user = userService.getUserById(user.getId());

            log("Login successful: " + user.getEmail() + ", Role: " + user.getRole());

            // Check user type
            if (userType != null && "admin".equals(userType) && !user.isAdmin()) {
                log("Login failed: User " + email + " is not an admin (role: " + user.getRole() + ")");
                request.setAttribute("error", "Invalid admin credentials");
                request.setAttribute("activeTab", "admin");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Create session
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userName", user.getFirstName());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60);

            // Remember Me functionality has been removed

            // Redirect
            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                log("Redirecting to: " + redirectUrl);
                response.sendRedirect(redirectUrl);
            } else if (user.isAdmin()) {
                log("Redirecting to admin dashboard for " + email);
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            } else {
                log("Redirecting to customer dashboard for " + email);
                response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
            }
        } catch (Exception e) {
            log("Login error for " + email + ": " + e.getMessage(), e);
            request.setAttribute("error", "Server error: " + e.getMessage());
            request.setAttribute("activeTab", userType);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("userId") || cookie.getName().equals("userEmail") ||
                    cookie.getName().equals("userName") || cookie.getName().equals("userRole")) {
                    cookie.setMaxAge(0);
                    cookie.setPath("/");
                    response.addCookie(cookie);
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/login.jsp?message=" +
                URLEncoder.encode("You have been successfully logged out.", "UTF-8"));
    }
}