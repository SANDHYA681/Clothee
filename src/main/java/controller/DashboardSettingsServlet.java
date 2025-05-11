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
 * Servlet implementation class DashboardSettingsServlet
 * Handles dashboard settings operations
 */
// Servlet mapping defined in web.xml
public class DashboardSettingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public DashboardSettingsServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Redirect to edit dashboard page
        response.sendRedirect(request.getContextPath() + "/customer/edit-dashboard.jsp");
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("updateSettings".equals(action)) {
            // Get form data
            String displayName = request.getParameter("displayName");
            String dashboardLayout = request.getParameter("dashboardLayout");
            String colorTheme = request.getParameter("colorTheme");
            String[] widgets = request.getParameterValues("widgets");

            // Store settings in session
            session.setAttribute("dashboardLayout", dashboardLayout);
            session.setAttribute("colorTheme", colorTheme);
            session.setAttribute("dashboardWidgets", widgets);

            // Set success message
            session.setAttribute("successMessage", "Dashboard settings updated successfully");

            // Redirect back to dashboard
            response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
        } else {
            // Invalid action, redirect to dashboard
            response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
        }
    }
}
