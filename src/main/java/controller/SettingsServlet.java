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

                    // Create a unique filename based on user ID and timestamp
                    String timestamp = String.valueOf(System.currentTimeMillis());
                    String uniqueFileName = "admin_" + user.getId() + "_" + timestamp + "." + fileExtension;

                    // Define the relative path for URLs
                    String relativePath = "images/profiles";

                    // Get the webapp root path
                    String webappRoot = getServletContext().getRealPath("/");

                    // Create the deployment directory path
                    String deploymentPath = webappRoot + relativePath;
                    File deploymentDir = new File(deploymentPath);
                    if (!deploymentDir.exists()) {
                        deploymentDir.mkdirs();
                    }

                    // Get the permanent path (persists across server restarts)
                    String permanentPath = getPermanentPath(webappRoot, relativePath);
                    System.out.println("SettingsServlet - Permanent path: " + permanentPath);

                    // Create the permanent directory if it doesn't exist
                    File permanentDir = new File(permanentPath);
                    if (!permanentDir.exists()) {
                        permanentDir.mkdirs();
                    }

                    // Create file paths
                    String permanentFilePath = permanentPath + File.separator + uniqueFileName;
                    String deploymentFilePath = deploymentPath + File.separator + uniqueFileName;

                    try {
                        // Save to permanent location first
                        filePart.write(permanentFilePath);
                        System.out.println("SettingsServlet - Image saved to permanent path: " + permanentFilePath);

                        // Copy to deployment location
                        copyFile(permanentFilePath, deploymentFilePath);
                        System.out.println("SettingsServlet - Image copied to deployment path: " + deploymentFilePath);
                    } catch (Exception e) {
                        System.out.println("SettingsServlet - Error saving image: " + e.getMessage());
                        e.printStackTrace();

                        // Try writing directly to deployment path as fallback
                        try {
                            filePart.write(deploymentFilePath);
                            System.out.println("SettingsServlet - Fallback: Image saved to deployment path: " + deploymentFilePath);
                        } catch (Exception ex) {
                            System.out.println("SettingsServlet - Fallback failed: " + ex.getMessage());
                            ex.printStackTrace();
                        }
                    }

                    // Update user profile image path (always use forward slashes for URLs)
                    String imagePath = relativePath + "/" + uniqueFileName;
                    user.setProfileImage(imagePath);

                    // Log the profile image path for debugging
                    System.out.println("SettingsServlet - Setting profile image path: " + imagePath);
                } else {
                    request.setAttribute("error", "Only image files (jpg, jpeg, png, gif) are allowed");
                    request.getRequestDispatcher("/admin/profile-settings.jsp").forward(request, response);
                    return;
                }
            }
        }

        // Log user details before saving
        System.out.println("SettingsServlet - User details before saving:");
        System.out.println("SettingsServlet - ID: " + user.getId());
        System.out.println("SettingsServlet - Name: " + user.getFirstName() + " " + user.getLastName());
        System.out.println("SettingsServlet - Email: " + user.getEmail());
        System.out.println("SettingsServlet - Profile Image: " + user.getProfileImage());

        // Save user to database
        boolean success = userDAO.updateUser(user);

        // Get updated user from database to verify changes
        User updatedUser = userDAO.getUserById(user.getId());
        System.out.println("SettingsServlet - User details after saving:");
        System.out.println("SettingsServlet - ID: " + updatedUser.getId());
        System.out.println("SettingsServlet - Name: " + updatedUser.getFirstName() + " " + updatedUser.getLastName());
        System.out.println("SettingsServlet - Email: " + updatedUser.getEmail());
        System.out.println("SettingsServlet - Profile Image: " + updatedUser.getProfileImage());

        HttpSession session = request.getSession();
        if (success) {
            // Update session user with the freshly loaded user from the database
            session.setAttribute("user", updatedUser);
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

    /**
     * Get the permanent path for storing images
     * @param webappRoot The webapp root path
     * @param relativePath The relative path within the webapp
     * @return The permanent path
     */
    private String getPermanentPath(String webappRoot, String relativePath) {
        try {
            // Use a fixed, absolute path that will definitely persist
            // This path is in the user's home directory for persistent storage
            String userHome = System.getProperty("user.home");
            String fixedPath = userHome + File.separator + "ClotheeImages" + File.separator + relativePath;
            System.out.println("SettingsServlet - Using fixed path in user home: " + fixedPath);
            File fixedDir = new File(fixedPath);

            // Ensure the fixed directory exists
            if (!fixedDir.exists()) {
                boolean created = fixedDir.mkdirs();
                System.out.println("SettingsServlet - Created fixed directory: " + created + " at " + fixedPath);
                if (created) {
                    return fixedPath;
                }
            } else {
                return fixedPath;
            }

            // If user home directory doesn't work, try the system temp directory
            String tempDir = System.getProperty("java.io.tmpdir");
            String tempPath = tempDir + File.separator + "ClotheeImages" + File.separator + relativePath;
            System.out.println("SettingsServlet - Using temp directory path: " + tempPath);
            File tempDirFile = new File(tempPath);

            // Ensure the temp directory exists
            if (!tempDirFile.exists()) {
                boolean created = tempDirFile.mkdirs();
                System.out.println("SettingsServlet - Created temp directory: " + created + " at " + tempPath);
                if (created) {
                    return tempPath;
                }
            } else {
                return tempPath;
            }

            // If all else fails, use the deployment directory (not persistent)
            System.out.println("SettingsServlet - Using deployment directory as fallback: " + webappRoot + relativePath);
            return webappRoot + relativePath;
        } catch (Exception e) {
            System.out.println("SettingsServlet - Error getting permanent path: " + e.getMessage());
            e.printStackTrace();
            return webappRoot + relativePath;
        }
    }

    /**
     * Copy a file from source to destination
     * @param sourcePath Source file path
     * @param destinationPath Destination file path
     * @return true if successful, false otherwise
     */
    private boolean copyFile(String sourcePath, String destinationPath) {
        try {
            File sourceFile = new File(sourcePath);
            if (!sourceFile.exists()) {
                System.out.println("SettingsServlet - Source file does not exist: " + sourcePath);
                return false;
            }

            // Ensure the destination directory exists
            File destFile = new File(destinationPath);
            File destDir = destFile.getParentFile();
            if (destDir != null && !destDir.exists()) {
                boolean created = destDir.mkdirs();
                System.out.println("SettingsServlet - Created destination directory: " + created);
            }

            // Copy the file using Java NIO
            java.nio.file.Files.copy(
                sourceFile.toPath(),
                destFile.toPath(),
                java.nio.file.StandardCopyOption.REPLACE_EXISTING
            );

            System.out.println("SettingsServlet - File copied from " + sourcePath + " to " + destinationPath);
            return true;
        } catch (IOException e) {
            System.out.println("SettingsServlet - Error copying file: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}