package controller;

import java.io.File;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;
import dao.UserDAO;

/**
 * Servlet implementation class ProfileImageServlet
 * Handles profile image uploads without JavaScript
 */
// Servlet mapping defined in web.xml
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 5,   // 5 MB
    maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class ProfileImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ProfileImageServlet() {
        super();
        userDAO = new UserDAO();
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

        try {
            // Handle file upload
            Part filePart = request.getPart("profileImage");
            if (filePart == null || filePart.getSize() <= 0) {
                session.setAttribute("errorMessage", "No image file selected");
                redirectToProfile(request, response, user);
                return;
            }

            // Process the uploaded file
            String fileName = getSubmittedFileName(filePart);
            if (fileName == null || fileName.isEmpty()) {
                session.setAttribute("errorMessage", "Invalid file name");
                redirectToProfile(request, response, user);
                return;
            }

            // Validate file type
            String fileExtension = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
            if (!isValidImageExtension(fileExtension)) {
                session.setAttribute("errorMessage", "Invalid file type. Only JPG, JPEG, PNG, and GIF files are allowed.");
                redirectToProfile(request, response, user);
                return;
            }

            // Generate new file name
            String newFileName = "user_" + user.getId() + fileExtension;

            // Create directory if it doesn't exist
            String uploadPath = request.getServletContext().getRealPath("/") + "images/profiles/";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Save the file
            filePart.write(uploadPath + newFileName);

            // Update user profile image in database
            String profileImagePath = "images/profiles/" + newFileName;
            user.setProfileImage(profileImagePath);

            boolean success = userDAO.updateProfileImage(user.getId(), profileImagePath);

            if (success) {
                // Get the updated user from the database to ensure all data is current
                User updatedUser = userDAO.getUserById(user.getId());

                // Update session with the fresh user data
                session.setAttribute("user", updatedUser);
                session.setAttribute("successMessage", "Profile image updated successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to update profile image");
            }

        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error uploading profile image: " + e.getMessage());
        }

        redirectToProfile(request, response, user);
    }

    /**
     * Helper method to get the submitted file name from a Part
     */
    private String getSubmittedFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    /**
     * Helper method to validate image file extension
     */
    private boolean isValidImageExtension(String extension) {
        return extension.equals(".jpg") || extension.equals(".jpeg") ||
               extension.equals(".png") || extension.equals(".gif");
    }

    /**
     * Helper method to redirect to the appropriate profile page
     */
    private void redirectToProfile(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
        }
    }
}
