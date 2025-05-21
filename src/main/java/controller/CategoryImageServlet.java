package controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import dao.CategoryDAO;
import model.Category;


/**
 * Servlet for handling category image uploads
 */
// Servlet mapping defined in web.xml
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 10,  // 10 MB
    maxRequestSize = 1024 * 1024 * 50 // 50 MB
)
public class CategoryImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CategoryDAO categoryDAO;

    public CategoryImageServlet() {
        super();
        categoryDAO = new CategoryDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check if user is logged in and is an admin
        jakarta.servlet.http.HttpSession session = request.getSession();
        model.User user = (model.User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            System.out.println("CategoryImageServlet - User not logged in or not admin");
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        System.out.println("CategoryImageServlet - User is admin: " + user.isAdmin());

        // Get category ID from request
        String categoryIdStr = request.getParameter("categoryId");

        if (categoryIdStr == null || categoryIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=true&message=Category+ID+is+required");
            return;
        }

        try {
            int categoryId = Integer.parseInt(categoryIdStr);

            // Get category from database
            Category category = categoryDAO.getCategoryById(categoryId);

            if (category == null) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=true&message=Category+not+found");
                return;
            }

            // Handle file upload
            Part filePart = request.getPart("categoryImage");
            if (filePart == null || filePart.getSize() <= 0) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=true&message=No+image+file+selected");
                return;
            }

            // Process the uploaded file
            String fileName = getSubmittedFileName(filePart);
            if (fileName == null || fileName.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=true&message=Invalid+file+name");
                return;
            }

            String fileExtension = fileName.substring(fileName.lastIndexOf("."));
            // Add timestamp to filename to prevent caching issues
            String timestamp = String.valueOf(System.currentTimeMillis());
            String newFileName = "category_" + categoryId + "_" + timestamp + fileExtension;

            // Save the file to a permanent location
            String relativePath = "images/categories";

            // Get the real path to the web application root directory
            String webappRoot = request.getServletContext().getRealPath("/");

            // Create the deployment directory path
            String deploymentPath = webappRoot + relativePath;

            // Ensure deployment directory exists
            File deploymentDir = new File(deploymentPath);
            if (!deploymentDir.exists()) {
                boolean created = deploymentDir.mkdirs();
                System.out.println("CategoryImageServlet - Created deployment directory: " + created);
            }

            // Get the permanent path (persists across server restarts)
            String permanentPath = getPermanentPath(webappRoot, relativePath);
            System.out.println("CategoryImageServlet - Permanent path: " + permanentPath);

            // Create the permanent directory if it doesn't exist
            boolean dirCreated = ensureDirectoryExists(permanentPath);
            System.out.println("CategoryImageServlet - Created permanent directory: " + dirCreated);

            // Write the file to deployment path
            String deploymentFilePath = deploymentPath + "/" + newFileName;
            filePart.write(deploymentFilePath);
            System.out.println("CategoryImageServlet - Image saved to deployment path: " + deploymentFilePath);

            // Verify the file was written successfully
            File deploymentFile = new File(deploymentFilePath);
            if (deploymentFile.exists()) {
                System.out.println("CategoryImageServlet - Deployment file exists: " + deploymentFile.exists());
                System.out.println("CategoryImageServlet - Deployment file size: " + deploymentFile.length() + " bytes");

                // Copy the file to the permanent location using NIO (more reliable)
                try {
                    // Create permanent file path
                    String permanentFilePath = permanentPath + "/" + newFileName;

                    // Create input stream from the deployment file
                    InputStream input = new FileInputStream(deploymentFile);

                    // Create output stream to the permanent file
                    OutputStream output = new FileOutputStream(permanentFilePath);

                    // Copy the file using traditional I/O
                    byte[] buffer = new byte[1024];
                    int length;
                    while ((length = input.read(buffer)) > 0) {
                        output.write(buffer, 0, length);
                    }

                    // Close streams
                    input.close();
                    output.close();

                    System.out.println("CategoryImageServlet - File copied to permanent path: " + permanentFilePath);

                    // Verify the permanent file was written successfully
                    File permanentFile = new File(permanentFilePath);
                    if (permanentFile.exists()) {
                        System.out.println("CategoryImageServlet - Permanent file exists: " + permanentFile.exists());
                        System.out.println("CategoryImageServlet - Permanent file size: " + permanentFile.length() + " bytes");
                    } else {
                        System.out.println("CategoryImageServlet - WARNING: Permanent file does not exist after writing!");
                        // If permanent file doesn't exist, try direct write as fallback
                        filePart.write(permanentFilePath);
                        System.out.println("CategoryImageServlet - Attempted direct write to permanent path");
                    }
                } catch (Exception e) {
                    System.out.println("CategoryImageServlet - Error copying file to permanent location: " + e.getMessage());
                    e.printStackTrace();
                    // Continue even if permanent copy fails - at least the deployment copy worked
                }
            } else {
                System.out.println("CategoryImageServlet - WARNING: Deployment file does not exist after writing!");
            }

            // Update category image URL in database
            String imageUrl = relativePath + "/" + newFileName;
            boolean success = categoryDAO.updateCategoryImage(categoryId, imageUrl);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/upload-category-image-new.jsp?id=" + categoryId + "&message=Category+image+updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/upload-category-image-new.jsp?id=" + categoryId + "&error=Failed+to+update+category+image");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=true&message=Invalid+category+ID");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=true&message=Error+uploading+image:+" + e.getMessage());
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
     * Get the permanent path for storing images
     * @param webappRoot The webapp root path
     * @param relativePath The relative path within the webapp
     * @return The permanent path
     */
    private String getPermanentPath(String webappRoot, String relativePath) {
        try {
            // First, try to use a fixed, absolute path that will definitely persist
            // This path should be outside the deployment directory but accessible by the web server
            // Use the user's home directory
            String userHome = System.getProperty("user.home");
            String fixedPath = userHome + File.separator + "ClotheeImages" + File.separator + relativePath;
            System.out.println("CategoryImageServlet - Using fixed path in user home: " + fixedPath);
            File fixedDir = new File(fixedPath);

            // Ensure the fixed directory exists
            if (!fixedDir.exists()) {
                boolean created = fixedDir.mkdirs();
                System.out.println("CategoryImageServlet - Created fixed directory: " + created + " at " + fixedPath);
                if (created) {
                    return fixedPath;
                }
            } else {
                return fixedPath;
            }

            // If the fixed path doesn't work, try to find the project root directory
            File deploymentDir = new File(webappRoot);
            File projectRoot = deploymentDir;

            // Try to navigate up to find the project root
            if (deploymentDir.getParentFile() != null) {
                projectRoot = deploymentDir.getParentFile();
                if (projectRoot.getParentFile() != null) {
                    projectRoot = projectRoot.getParentFile();
                    if (projectRoot.getParentFile() != null) {
                        projectRoot = projectRoot.getParentFile();
                    }
                }
            }

            // Create the permanent path
            String permanentPath = projectRoot.getAbsolutePath() + File.separator + "src" + File.separator + "main" + File.separator + "webapp" + File.separator + relativePath;
            System.out.println("CategoryImageServlet - Project root: " + projectRoot.getAbsolutePath());
            System.out.println("CategoryImageServlet - Permanent path: " + permanentPath);

            // Check if the permanent path exists or can be created
            File permanentDir = new File(permanentPath);
            if (!permanentDir.exists()) {
                boolean created = permanentDir.mkdirs();
                System.out.println("CategoryImageServlet - Created permanent directory: " + created);
                if (!created) {
                    // If we can't create the permanent directory, use the deployment path as fallback
                    System.out.println("CategoryImageServlet - Could not create permanent directory, using deployment path as fallback");
                    return webappRoot + relativePath;
                }
            }

            return permanentPath;
        } catch (Exception e) {
            System.out.println("CategoryImageServlet - Error getting permanent path: " + e.getMessage());
            e.printStackTrace();
            return webappRoot + relativePath;
        }
    }

    /**
     * Ensure the directory exists
     * @param path The directory path
     * @return true if the directory exists or was created, false otherwise
     */
    private boolean ensureDirectoryExists(String path) {
        try {
            if (path == null || path.isEmpty()) {
                System.out.println("CategoryImageServlet - Error: Directory path is null or empty");
                return false;
            }

            File dir = new File(path);
            if (dir.exists()) {
                if (!dir.isDirectory()) {
                    System.out.println("CategoryImageServlet - Error: Path exists but is not a directory: " + path);
                    return false;
                }
                return true;
            }

            boolean created = dir.mkdirs();
            if (!created) {
                System.out.println("CategoryImageServlet - Error: Failed to create directory: " + path);
                return false;
            }

            System.out.println("CategoryImageServlet - Created directory: " + path);
            return true;
        } catch (Exception e) {
            System.out.println("CategoryImageServlet - Error creating directory: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
