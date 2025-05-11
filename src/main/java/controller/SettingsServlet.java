package controller;

import java.io.IOException;
import java.io.File;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import model.User;
import dao.UserDAO;

/**
 * Servlet implementation class SettingsServlet
 */
// Servlet mapping defined in web.xml
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
                 maxFileSize = 1024 * 1024 * 10, // 10 MB
                 maxRequestSize = 1024 * 1024 * 50) // 50 MB
public class SettingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public SettingsServlet() {
        super();
        userDAO = new UserDAO();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in and is admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Redirect to settings page
        response.sendRedirect(request.getContextPath() + "/admin/settings.jsp");
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in and is admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/settings.jsp");
            return;
        }

        switch (action) {
            case "updateSecurity":
                updateSecuritySettings(request, response, user);
                break;
            case "updateProfile":
                updateProfileSettings(request, response, user);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin/settings.jsp");
        }
    }

    /**
     * Update security settings
     */
    private void updateSecuritySettings(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate inputs
        if (currentPassword == null || newPassword == null || confirmPassword == null ||
            currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/admin/security-settings.jsp").forward(request, response);
            return;
        }

        // Check if current password is correct
        if (!userDAO.validatePassword(user.getId(), currentPassword)) {
            request.setAttribute("error", "Current password is incorrect");
            request.getRequestDispatcher("/admin/security-settings.jsp").forward(request, response);
            return;
        }

        // Check if new passwords match
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New passwords do not match");
            request.getRequestDispatcher("/admin/security-settings.jsp").forward(request, response);
            return;
        }

        // Update password
        boolean success = userDAO.updatePassword(user.getId(), newPassword);

        if (success) {
            request.getSession().setAttribute("successMessage", "Password updated successfully");
            response.sendRedirect(request.getContextPath() + "/admin/settings.jsp");
        } else {
            request.setAttribute("error", "Failed to update password");
            request.getRequestDispatcher("/admin/security-settings.jsp").forward(request, response);
        }
    }

    /**
     * Update profile settings
     */
    private void updateProfileSettings(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        // Validate inputs
        if (firstName == null || lastName == null || email == null ||
            firstName.isEmpty() || lastName.isEmpty() || email.isEmpty()) {
            request.setAttribute("error", "First name, last name, and email are required");
            request.getRequestDispatcher("/admin/profile-settings.jsp").forward(request, response);
            return;
        }

        // Update user profile
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);

        // Handle profile image upload if present
        Part filePart = null;
        try {
            filePart = request.getPart("profileImage");
        } catch (Exception e) {
            // No file uploaded, continue with profile update
        }

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = getSubmittedFileName(filePart);
            if (fileName != null && !fileName.isEmpty()) {
                // Check if file is an image
                String fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
                if (fileExtension.equals("jpg") || fileExtension.equals("jpeg") ||
                    fileExtension.equals("png") || fileExtension.equals("gif")) {

                    // Create directory if it doesn't exist
                    String uploadPath = getServletContext().getRealPath("/images/profiles/");
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }

                    // Generate unique filename
                    String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                    String filePath = uploadPath + uniqueFileName;

                    // Save file
                    filePart.write(filePath);

                    // Update user profile image path
                    user.setProfileImage("images/profiles/" + uniqueFileName);
                } else {
                    request.setAttribute("error", "Only image files (jpg, jpeg, png, gif) are allowed");
                    request.getRequestDispatcher("/admin/profile-settings.jsp").forward(request, response);
                    return;
                }
            }
        }

        // Save user to database
        boolean success = userDAO.updateUser(user);

        HttpSession session = request.getSession();
        if (success) {
            // Update session user
            session.setAttribute("user", user);
            session.setAttribute("successMessage", "Profile updated successfully");
            response.sendRedirect(request.getContextPath() + "/admin/settings.jsp");
        } else {
            request.setAttribute("error", "Failed to update profile");
            request.getRequestDispatcher("/admin/profile-settings.jsp").forward(request, response);
        }
    }


    /**
     * Helper method to get the submitted file name
     */
    private String getSubmittedFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}