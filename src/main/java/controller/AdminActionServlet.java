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
 * Servlet implementation class AdminActionServlet
 * Handles admin action buttons
 */
// Servlet mapping defined in web.xml
public class AdminActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminActionServlet() {
        super();
        userService = new UserService();
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

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            return;
        }

        switch (action) {
            case "viewProfile":
                viewProfile(request, response, user);
                break;
            case "editProfile":
                editProfile(request, response, user);
                break;
            case "deleteAccount":
                deleteAccount(request, response, user);
                break;
            case "addCustomer":
                addCustomer(request, response);
                break;
            case "editCustomer":
                editCustomer(request, response);
                break;
            case "viewCustomer":
                viewCustomer(request, response);
                break;
            case "deleteCustomer":
                deleteCustomer(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * View admin profile
     */
    private void viewProfile(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
    }

    /**
     * Edit admin profile
     */
    private void editProfile(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/edit-profile.jsp");
    }

    /**
     * Delete admin account
     */
    private void deleteAccount(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        // Check if this is the last admin account
        int adminCount = userService.getUsersByRole("admin").size();
        if (adminCount <= 1) {
            request.getSession().setAttribute("errorMessage", "Cannot delete the last admin account");
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/delete-account-confirm.jsp");
    }

    /**
     * Add new customer
     */
    private void addCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/AdminUserServlet?action=showAddForm");
    }

    /**
     * Edit customer
     */
    private void editCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String customerId = request.getParameter("id");
        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/edit-customer.jsp?id=" + customerId);
    }

    /**
     * View customer details
     */
    private void viewCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String customerId = request.getParameter("id");
        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/customer-details.jsp?id=" + customerId);
    }

    /**
     * Delete customer
     */
    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String customerId = request.getParameter("id");
        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            return;
        }

        int id = Integer.parseInt(customerId);

        // Get current user
        User currentUser = (User) request.getSession().getAttribute("user");

        // Don't allow deleting the current user
        if (currentUser.getId() == id) {
            request.getSession().setAttribute("errorMessage", "Cannot delete your own account from this page");
            response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
            return;
        }

        boolean success = userService.deleteUser(id);

        if (success) {
            request.getSession().setAttribute("successMessage", "Customer deleted successfully");
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to delete customer");
        }

        response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
    }
}
