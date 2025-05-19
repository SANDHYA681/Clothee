package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;

/**
 * Servlet implementation class ActionServlet
 * Handles action button requests from the dashboard
 */
// Servlet mapping defined in web.xml
public class ActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ActionServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            request.setAttribute("errorMessage", "You are not logged in");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if (action == null) {
            request.setAttribute("errorMessage", "No action specified");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        switch (action) {
            case "getUserRole":
                getUserRole(request, response, user);
                break;
            case "viewProfile":
                viewProfile(request, response, user);
                break;
            case "editProfile":
                editProfile(request, response, user);
                break;
            case "deleteAccount":
                deleteAccount(request, response, user);
                break;
            default:
                request.setAttribute("errorMessage", "Invalid action");
                request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Get user role information
     */
    private void getUserRole(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        // Set user information as request attributes
        request.setAttribute("userId", user.getId());
        request.setAttribute("name", user.getFirstName());
        request.setAttribute("email", user.getEmail());
        request.setAttribute("role", user.getRole());
        request.setAttribute("isAdmin", user.isAdmin());
        request.setAttribute("successMessage", "User role retrieved successfully");

        // Forward to appropriate dashboard based on user role
        if (user.isAdmin()) {
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/customer/dashboard.jsp").forward(request, response);
        }
    }

    /**
     * View user profile
     */
    private void viewProfile(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        // Redirect to appropriate profile page based on user role
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
        }
    }

    /**
     * Edit user profile
     */
    private void editProfile(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        // Redirect to appropriate profile edit page based on user role
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
        }
    }

    /**
     * Delete user account (this would typically require confirmation)
     */
    private void deleteAccount(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        // Redirect to a confirmation page
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/delete-account-confirm.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/delete-account-confirm.jsp");
        }
    }
}
