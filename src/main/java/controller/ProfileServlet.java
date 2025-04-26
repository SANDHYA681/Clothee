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



import dao.UserDAO;
import model.User;

/**
 * Servlet implementation class ProfileServlet
 */
// Servlet mapping defined in web.xml
@MultipartConfig
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ProfileServlet() {
        super();
        userDAO = new UserDAO();
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
        // Get form data
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        // Validate input
        if (firstName == null || lastName == null || email == null ||
            firstName.trim().isEmpty() || lastName.trim().isEmpty() || email.trim().isEmpty()) {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Required+fields+are+missing");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Required+fields+are+missing");
            }
            return;
        }

        // Update user object
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPhone(phone);

        // Update in database
        boolean success = userDAO.updateUser(user);

        if (success) {
            // Get the updated user from the database to ensure all data is current
            User updatedUser = userDAO.getUserById(user.getId());

            // Update session with the fresh user data
            session.setAttribute("user", updatedUser);
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?success=Profile+updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?success=Profile+updated+successfully");
            }
        } else {
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Failed+to+update+profile");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Failed+to+update+profile");
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
            // Handle file upload
            Part filePart = request.getPart("profileImage");
            if (filePart == null || filePart.getSize() <= 0) {
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=No+image+file+selected");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=No+image+file+selected");
                }
                return;
            }

            // Process the uploaded file
            String fileName = getSubmittedFileName(filePart);
            if (fileName == null || fileName.isEmpty()) {
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Invalid+file+name");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Invalid+file+name");
                }
                return;
            }

            String fileExtension = fileName.substring(fileName.lastIndexOf("."));
            String newFileName = "user_" + user.getId() + fileExtension;

            // Save the file to the server
            String uploadPath = request.getServletContext().getRealPath("/") + "images/profiles/";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

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
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile.jsp?error=Error+uploading+image:+" + e.getMessage());
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/profile.jsp?error=Error+uploading+image:+" + e.getMessage());
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
