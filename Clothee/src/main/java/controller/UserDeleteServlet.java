package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import service.UserService;

/**
 * Servlet implementation class UserDeleteServlet
 * Handles user account deletion
 */
// Servlet mapping defined in web.xml
public class UserDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public UserDeleteServlet() {
        super();
        userService = new UserService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect to post method
        doPost(request, response);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String userIdParam = request.getParameter("userId");

        if (userIdParam == null || userIdParam.isEmpty()) {
            // If no userId is provided, assume the user wants to delete their own account
            userIdParam = String.valueOf(currentUser.getId());
        }

        int userId = Integer.parseInt(userIdParam);

        // Only allow users to delete their own account or admins to delete any account
        if (userId != currentUser.getId() && !currentUser.isAdmin()) {
            if (currentUser.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp?error=You+can+only+delete+your+own+account");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp?error=You+can+only+delete+your+own+account");
            }
            return;
        }

        // Don't allow deleting the last admin account
        if (currentUser.isAdmin() && userId == currentUser.getId()) {
            int adminCount = userService.getUsersByRole("admin").size();
            if (adminCount <= 1) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp?error=Cannot+delete+the+last+admin+account");
                return;
            }
        }

        // Delete the account
        boolean success = userService.deleteUser(userId);

        if (success) {
            // If the user deleted their own account, invalidate the session
            if (userId == currentUser.getId()) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/index.jsp?message=Your+account+has+been+deleted");
            } else {
                // Admin deleted another user's account
                response.sendRedirect(request.getContextPath() + "/admin/customers.jsp?message=Account+deleted+successfully");
            }
        } else {
            // Failed to delete account
            if (currentUser.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp?error=Failed+to+delete+account");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp?error=Failed+to+delete+account");
            }
        }
    }
}
