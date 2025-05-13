package controller;

import java.io.File;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;
import dao.UserDAO;
import service.UserImageService;

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
    private final UserDAO userDAO;
    private final UserImageService userImageService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ProfileImageServlet() {
        super();
        userDAO = new UserDAO();
        userImageService = new UserImageService();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("ProfileImageServlet - doGet method called");

        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            System.out.println("ProfileImageServlet - User not logged in");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Forward to the appropriate profile image upload page based on user role
        if (user.isAdmin()) {
            request.getRequestDispatcher("/admin/profile-image-upload.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/customer/profile-image-upload.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("ProfileImageServlet - doPost method called");

        try {
            // Check if user is logged in
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            if (user == null) {
                System.out.println("ProfileImageServlet - User not logged in");
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            System.out.println("ProfileImageServlet - User ID: " + user.getId());
            System.out.println("ProfileImageServlet - Request content type: " + request.getContentType());
            System.out.println("ProfileImageServlet - Context path: " + request.getContextPath());
            System.out.println("ProfileImageServlet - Servlet path: " + request.getServletPath());

            System.out.println("ProfileImageServlet - Attempting to get file part");
            // Handle file upload
            Part filePart = null;
            try {
                filePart = request.getPart("profileImage");
                System.out.println("ProfileImageServlet - File part obtained successfully");
            } catch (Exception e) {
                System.out.println("ProfileImageServlet - Error getting file part: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error processing file upload: " + e.getMessage());
                redirectToProfile(request, response, user);
                return;
            }

            if (filePart == null || filePart.getSize() <= 0) {
                System.out.println("ProfileImageServlet - No file selected or file is empty");
                session.setAttribute("errorMessage", "No image file selected");
                redirectToProfile(request, response, user);
                return;
            }

            System.out.println("ProfileImageServlet - File size: " + filePart.getSize() + " bytes");

            // Process the uploaded file - let UserImageService handle this
            // The validation will be done inside the uploadProfileImage method

            // Upload the image using the service
            String webappRoot = request.getServletContext().getRealPath("/");
            System.out.println("ProfileImageServlet - Webapp root: " + webappRoot);
            System.out.println("ProfileImageServlet - Real path for /images/avatars: " + request.getServletContext().getRealPath("/images/avatars"));

            // Let the ImageService handle directory creation

            String imageUrl = null;
            try {
                // Try to upload the image
                imageUrl = userImageService.uploadProfileImage(user.getId(), filePart, webappRoot);

                if (imageUrl == null) {
                    session.setAttribute("errorMessage", "Failed to upload image");
                    redirectToProfile(request, response, user);
                    return;
                }

                System.out.println("ProfileImageServlet - Image URL: " + imageUrl);

                // Verify the image file exists
                File imageFile = new File(webappRoot + imageUrl);
                System.out.println("ProfileImageServlet - Image file exists: " + imageFile.exists());
                System.out.println("ProfileImageServlet - Image file path: " + imageFile.getAbsolutePath());
                System.out.println("ProfileImageServlet - Image file size: " + (imageFile.exists() ? imageFile.length() : 0) + " bytes");

                // If the file doesn't exist at the full path, try just the filename in the avatars directory
                if (!imageFile.exists() && imageUrl.contains("/")) {
                    String fileName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
                    System.out.println("ProfileImageServlet - Extracted filename from path: " + fileName);
                    imageFile = new File(webappRoot + "images/avatars/" + fileName);
                    System.out.println("ProfileImageServlet - Trying alternate path: " + imageFile.getAbsolutePath());
                    System.out.println("ProfileImageServlet - Alternate file exists: " + imageFile.exists());
                }

            } catch (Exception e) {
                System.out.println("ProfileImageServlet - Error uploading image: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "Error uploading image: " + e.getMessage());
                redirectToProfile(request, response, user);
                return;
            }

            // The user profile image has already been updated in the database by the service
            // Just update the user object in memory
            user.setProfileImage(imageUrl);
            System.out.println("ProfileImageServlet - New profile image URL: " + imageUrl);

            // Get the updated user from the database to ensure all data is current
            User updatedUser = userDAO.getUserById(user.getId());

            // Update session with the fresh user data
            session.setAttribute("user", updatedUser);
            session.setAttribute("successMessage", "Profile image updated successfully");

            // Redirect to profile page
            redirectToProfile(request, response, user);
            return;
        } catch (Exception e) {
            System.out.println("ProfileImageServlet - Unexpected error: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Error uploading profile image: " + e.getMessage());

            // Get user from session again in case the exception happened before user was assigned
            User user = (User) session.getAttribute("user");
            if (user != null) {
                redirectToProfile(request, response, user);
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
            return;
        }
    }



    /**
     * Helper method to redirect to the appropriate profile page
     */
    private void redirectToProfile(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String redirectUrl;
        if (user.isAdmin()) {
            redirectUrl = request.getContextPath() + "/admin/profile.jsp";
        } else {
            redirectUrl = request.getContextPath() + "/customer/profile.jsp";
        }
        System.out.println("ProfileImageServlet - Redirecting to: " + redirectUrl);
        response.sendRedirect(redirectUrl);
    }
}
