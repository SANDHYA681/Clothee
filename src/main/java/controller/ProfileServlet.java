package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import dao.UserDAO;
import model.User;
import service.UserImageService;

/**
 * Servlet implementation class ProfileServlet
 */
// Servlet mapping defined in web.xml
@MultipartConfig
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private UserImageService userImageService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ProfileServlet() {
        super();
        userDAO = new UserDAO();
        userImageService = new UserImageService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Get action parameter
        String action = request.getParameter("action");

        if (action == null) {
            // Default action - show profile
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
            }
            return;
        }

        switch (action) {
            case "showProfile":
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
                }
                break;
            default:
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
                }
        }
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

        User user = (User) session.getAttribute("user");

        // Get action parameter
        String action = request.getParameter("action");

        if (action == null) {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=No+action+specified");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=No+action+specified");
            }
            return;
        }

        switch (action) {
            case "updateProfile":
                updateProfile(request, response, user, session);
                break;
            case "updatePassword":
                updatePassword(request, response, user);
                break;
            case "updateProfileImage":
                updateProfileImage(request, response, user, session);
                break;
            case "deleteAccount":
                deleteAccount(request, response, user, session);
                break;
            default:
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Invalid+action");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Invalid+action");
                }
        }
    }

    /**
     * Update user profile
     */
    private void updateProfile(HttpServletRequest request, HttpServletResponse response, User user, HttpSession session)
            throws ServletException, IOException {
        System.out.println("ProfileServlet.updateProfile - Starting update for user ID: " + user.getId());

        // Get form data
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        System.out.println("ProfileServlet.updateProfile - Form data: firstName=" + firstName + ", lastName=" + lastName + ", email=" + email + ", phone=" + phone);

        // Validate input
        if (firstName == null || lastName == null || email == null ||
            firstName.trim().isEmpty() || lastName.trim().isEmpty() || email.trim().isEmpty()) {
            System.out.println("ProfileServlet.updateProfile - Validation failed: Missing required fields");
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Required+fields+are+missing");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Required+fields+are+missing");
            }
            return;
        }

        try {
            // Update user object
            System.out.println("ProfileServlet.updateProfile - Updating user object");
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setEmail(email);
            user.setPhone(phone);

            // Make sure timestamps are set
            if (user.getCreatedAt() == null) {
                user.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            }
            user.setUpdatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

            // Update in database
            System.out.println("ProfileServlet.updateProfile - Calling userDAO.updateUser");
            boolean success = userDAO.updateUser(user);
            System.out.println("ProfileServlet.updateProfile - Update result: " + success);

            if (success) {
                // Get the updated user from the database to ensure all data is current
                System.out.println("ProfileServlet.updateProfile - Getting updated user from database");
                User updatedUser = userDAO.getUserById(user.getId());

                if (updatedUser != null) {
                    System.out.println("ProfileServlet.updateProfile - Retrieved updated user from database");

                    // Update session with the fresh user data
                    session.setAttribute("user", updatedUser);
                    session.setAttribute("successMessage", "Profile updated successfully");

                    if (user.isAdmin()) {
                        response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
                    }
                } else {
                    System.out.println("ProfileServlet.updateProfile - Failed to retrieve updated user from database");
                    session.setAttribute("errorMessage", "Profile updated but failed to refresh user data");

                    if (user.isAdmin()) {
                        response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
                    }
                }
            } else {
                System.out.println("ProfileServlet.updateProfile - Update failed");
                session.setAttribute("errorMessage", "Failed to update profile");

                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
                }
            }
        } catch (Exception e) {
            System.out.println("ProfileServlet.updateProfile - Exception: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error updating profile: " + e.getMessage());

            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
            }
        }
    }

    /**
     * Update user password
     */
    private void updatePassword(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        // Get form data
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate input
        if (currentPassword == null || newPassword == null || confirmPassword == null ||
            currentPassword.trim().isEmpty() || newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?passwordError=All+password+fields+are+required");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?passwordError=All+password+fields+are+required");
            }
            return;
        }

        // Check if current password is correct
        if (!userDAO.validatePassword(user.getId(), currentPassword)) {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?passwordError=Current+password+is+incorrect");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?passwordError=Current+password+is+incorrect");
            }
            return;
        }

        // Check if new passwords match
        if (!newPassword.equals(confirmPassword)) {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?passwordError=New+passwords+do+not+match");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?passwordError=New+passwords+do+not+match");
            }
            return;
        }

        // Update password
        boolean success = userDAO.updatePassword(user.getId(), newPassword);

        if (success) {
            // Get the updated user from the database to ensure all data is current
            User updatedUser = userDAO.getUserById(user.getId());

            // Get the session and update it with the fresh user data
            HttpSession session = request.getSession();
            session.setAttribute("user", updatedUser);
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?passwordSuccess=Password+updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?passwordSuccess=Password+updated+successfully");
            }
        } else {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?passwordError=Failed+to+update+password");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?passwordError=Failed+to+update+password");
            }
        }
    }

    /**
     * Update profile image
     */
    private void updateProfileImage(HttpServletRequest request, HttpServletResponse response, User user, HttpSession session)
            throws ServletException, IOException {
        try {
            System.out.println("ProfileServlet - updateProfileImage method called");
            System.out.println("ProfileServlet - User ID: " + user.getId());
            System.out.println("ProfileServlet - Request content type: " + request.getContentType());

            // Handle file upload
            Part filePart = request.getPart("profileImage");
            if (filePart == null || filePart.getSize() <= 0) {
                System.out.println("ProfileServlet - No file selected or file is empty");
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=No+image+file+selected");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=No+image+file+selected");
                }
                return;
            }

            System.out.println("ProfileServlet - File size: " + filePart.getSize() + " bytes");

            // Upload the image using the service
            String webappRoot = request.getServletContext().getRealPath("/");
            String imageUrl = userImageService.uploadProfileImage(user.getId(), filePart, webappRoot);

            if (imageUrl == null) {
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Failed+to+upload+image");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Failed+to+upload+image");
                }
                return;
            }

            // Update user profile image in database
            user.setProfileImage(imageUrl);
            boolean success = userImageService.updateUserProfileImage(user.getId(), imageUrl);

            if (success) {
                // Get the updated user from the database to ensure all data is current
                User updatedUser = userDAO.getUserById(user.getId());

                // Update session with the fresh user data
                session.setAttribute("user", updatedUser);
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?success=Profile+image+updated+successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?success=Profile+image+updated+successfully");
                }
            } else {
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Failed+to+update+profile+image");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Failed+to+update+profile+image");
                }
            }
        } catch (Exception e) {
            System.out.println("ProfileServlet - Error in updateProfileImage: " + e.getMessage());
            e.printStackTrace();

            // Set error message in session for better visibility
            session.setAttribute("errorMessage", "Error uploading image: " + e.getMessage());

            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp");
            }
        }
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
     * Delete user account
     */
    private void deleteAccount(HttpServletRequest request, HttpServletResponse response, User user, HttpSession session)
            throws ServletException, IOException {
        // Get form data
        String password = request.getParameter("password");

        // Validate input
        if (password == null || password.trim().isEmpty()) {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Password+is+required+to+deactivate+account");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Password+is+required+to+deactivate+account");
            }
            return;
        }

        // Check if password is correct
        if (!userDAO.validatePassword(user.getId(), password)) {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Incorrect+password");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Incorrect+password");
            }
            return;
        }

        // Deactivate account
        boolean success = userDAO.deactivateUser(user.getId());

        if (success) {
            // Invalidate session
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/index.jsp?message=Your+account+has+been+deactivated");
        } else {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Failed+to+deactivate+account");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Failed+to+deactivate+account");
            }
        }
    }
}
