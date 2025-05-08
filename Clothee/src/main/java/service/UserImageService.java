package service;

import java.io.File;
import java.io.IOException;
import jakarta.servlet.http.Part;

import dao.UserDAO;
import model.User;

/**
 * Service class for handling user profile image operations
 * Following MVC pattern - this is part of the Model layer (service component)
 */
public class UserImageService {
    private final UserDAO userDAO;

    /**
     * Constructor
     */
    public UserImageService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Upload a user profile image
     * @param userId User ID
     * @param filePart File part from multipart request
     * @param uploadPath Base upload path
     * @return Image URL if successful, null otherwise
     * @throws IOException If an I/O error occurs
     */
    public String uploadProfileImage(int userId, Part filePart, String uploadPath) throws IOException {
        // Ensure userDAO is initialized
        if (userDAO == null) {
            throw new IOException("UserDAO is not initialized");
        }
        System.out.println("UserImageService - uploadProfileImage called for user ID: " + userId);

        if (filePart == null) {
            System.out.println("Error in uploadProfileImage: filePart is null");
            return null;
        }
        System.out.println("UserImageService - filePart size: " + filePart.getSize());

        if (uploadPath == null || uploadPath.isEmpty()) {
            System.out.println("Error in uploadProfileImage: uploadPath is null or empty");
            return null;
        }
        System.out.println("UserImageService - uploadPath: " + uploadPath);

        try {
            // Process the uploaded file
            String fileName = getSubmittedFileName(filePart);
            if (fileName == null || fileName.isEmpty()) {
                return null;
            }

            String fileExtension = getFileExtension(fileName);
            if (!isValidImageExtension(fileExtension)) {
                System.out.println("UserImageService - Invalid image extension: " + fileExtension);
                return null;
            }

            String newFileName = "user_" + userId + fileExtension;

            // Create the relative path
            String relativePath = "images/avatars";

            // Create the deployment directory path
            String deploymentPath = uploadPath + File.separator + relativePath;

            // Ensure deployment directory exists
            boolean deploymentDirCreated = ensureDirectoryExists(deploymentPath);
            System.out.println("UserImageService - Created deployment directory: " + deploymentDirCreated);

            // Get the permanent path (persists across server restarts)
            String permanentPath = getPermanentPath(uploadPath, relativePath);
            System.out.println("UserImageService - Permanent path: " + permanentPath);

            // Create the permanent directory if it doesn't exist
            boolean permanentDirCreated = ensureDirectoryExists(permanentPath);
            System.out.println("UserImageService - Created permanent directory: " + permanentDirCreated);

            // Write the file to deployment path
            String deploymentFilePath = deploymentPath + File.separator + newFileName;
            filePart.write(deploymentFilePath);
            System.out.println("UserImageService - Image saved to deployment path: " + deploymentFilePath);

            // Verify the file was written successfully
            File deploymentFile = new File(deploymentFilePath);
            if (deploymentFile.exists()) {
                System.out.println("UserImageService - Deployment file exists: " + deploymentFile.exists());
                System.out.println("UserImageService - Deployment file size: " + deploymentFile.length() + " bytes");

                // Copy the file to the permanent location
                try {
                    // Create permanent file path
                    String permanentFilePath = permanentPath + File.separator + newFileName;

                    // Copy the file
                    boolean copied = copyFile(deploymentFilePath, permanentFilePath);
                    System.out.println("UserImageService - File copied to permanent path: " + copied);
                } catch (Exception e) {
                    System.out.println("UserImageService - Error copying file to permanent path: " + e.getMessage());
                    // Continue even if permanent copy fails
                }
            } else {
                System.out.println("UserImageService - Deployment file does not exist after writing");
            }

            // Create the final image URL
            String imageUrl = relativePath + "/" + newFileName;
            System.out.println("UserImageService - Final image URL: " + imageUrl);

            // Update the user's profile image URL immediately
            boolean updated = false;
            try {
                updated = updateUserProfileImage(userId, imageUrl);
                System.out.println("UserImageService - User profile updated with new image URL: " + updated);
            } catch (Exception e) {
                System.out.println("UserImageService - Error updating user profile image: " + e.getMessage());
                e.printStackTrace();
                // Continue even if update fails - at least the file was uploaded
            }

            return imageUrl; // Using forward slash for URLs
        } catch (Exception e) {
            System.out.println("Error in uploadProfileImage: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Update user profile image in database
     * @param userId User ID
     * @param imageUrl Image URL
     * @return true if successful, false otherwise
     */
    public boolean updateUserProfileImage(int userId, String imageUrl) {
        try {
            // Ensure userDAO is initialized
            if (userDAO == null) {
                System.out.println("UserImageService - UserDAO is null, creating a new instance");
                return new UserDAO().updateProfileImage(userId, imageUrl);
            }
            return userDAO.updateProfileImage(userId, imageUrl);
        } catch (Exception e) {
            System.out.println("Error in updateUserProfileImage: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Copy a file from source to destination
     * @param sourcePath Source file path
     * @param destinationPath Destination file path
     * @return true if successful, false otherwise
     * @throws IOException If an I/O error occurs
     */
    private boolean copyFile(String sourcePath, String destinationPath) throws IOException {
        try {
            File sourceFile = new File(sourcePath);
            if (!sourceFile.exists()) {
                System.out.println("UserImageService - Source file does not exist: " + sourcePath);
                return false;
            }

            // Ensure the destination directory exists
            File destFile = new File(destinationPath);
            File destDir = destFile.getParentFile();
            if (destDir != null && !destDir.exists()) {
                boolean created = destDir.mkdirs();
                System.out.println("UserImageService - Created destination directory: " + created);
            }

            // Copy the file using Java NIO
            java.nio.file.Files.copy(
                sourceFile.toPath(),
                destFile.toPath(),
                java.nio.file.StandardCopyOption.REPLACE_EXISTING
            );

            System.out.println("UserImageService - File copied from " + sourcePath + " to " + destinationPath);
            return true;
        } catch (IOException e) {
            System.out.println("UserImageService - Error copying file: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * Ensure a directory exists
     * @param directoryPath Directory path
     * @return true if directory exists or was created, false otherwise
     */
    private boolean ensureDirectoryExists(String directoryPath) {
        File directory = new File(directoryPath);
        if (!directory.exists()) {
            return directory.mkdirs();
        }
        return true;
    }

    /**
     * Get the file extension from a file name
     * @param fileName File name
     * @return File extension with dot (e.g., ".jpg")
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return "";
        }
        int lastDotIndex = fileName.lastIndexOf(".");
        if (lastDotIndex < 0) {
            return "";
        }
        return fileName.substring(lastDotIndex).toLowerCase();
    }

    /**
     * Check if a file extension is a valid image extension
     * @param extension File extension with dot (e.g., ".jpg")
     * @return true if valid, false otherwise
     */
    private boolean isValidImageExtension(String extension) {
        if (extension == null || extension.isEmpty()) {
            return false;
        }
        String[] validExtensions = {".jpg", ".jpeg", ".png", ".gif", ".bmp"};
        for (String validExt : validExtensions) {
            if (extension.equalsIgnoreCase(validExt)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Get the submitted file name from Part
     * @param part Part from multipart request
     * @return File name
     */
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf('/') + 1).substring(fileName.lastIndexOf('\\') + 1);
            }
        }
        return null;
    }

    /**
     * Get the permanent path for a file (persists across server restarts)
     *
     * @param deploymentRoot The deployment root path
     * @param relativePath The relative path within the webapp
     * @return The permanent path
     */
    private String getPermanentPath(String deploymentRoot, String relativePath) {
        try {
            // First, try to use a fixed, absolute path that will definitely persist
            // This path should be outside the deployment directory but accessible by the web server
            // Use the user's home directory
            String userHome = System.getProperty("user.home");
            String fixedPath = userHome + File.separator + "ClotheeImages" + File.separator + relativePath;
            System.out.println("UserImageService - Using fixed path in user home: " + fixedPath);
            File fixedDir = new File(fixedPath);

            // Ensure the fixed directory exists
            if (!fixedDir.exists()) {
                boolean created = fixedDir.mkdirs();
                System.out.println("UserImageService - Created fixed directory: " + created + " at " + fixedPath);
                if (created) {
                    return fixedPath;
                }
            } else {
                return fixedPath;
            }

            // If the fixed path doesn't work, try to find the project root directory
            File deploymentDir = new File(deploymentRoot);

            // Check if deployment directory exists
            if (!deploymentDir.exists()) {
                System.out.println("UserImageService - Deployment directory does not exist: " + deploymentRoot);
                // Create a fallback path in the deployment root
                return deploymentRoot + relativePath;
            }

            // Try to navigate up to find the project root
            File projectRoot = deploymentDir;
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
            System.out.println("UserImageService - Project root: " + projectRoot.getAbsolutePath());
            System.out.println("UserImageService - Permanent path: " + permanentPath);

            // Check if the permanent path exists or can be created
            File permanentDir = new File(permanentPath);
            if (!permanentDir.exists()) {
                boolean created = permanentDir.mkdirs();
                System.out.println("UserImageService - Created permanent directory: " + created);
                if (!created) {
                    // If we can't create the permanent directory, use the deployment path as fallback
                    System.out.println("UserImageService - Could not create permanent directory, using deployment path as fallback");
                    return deploymentRoot + relativePath;
                }
            }

            return permanentPath;
        } catch (Exception e) {
            System.out.println("UserImageService - Error getting permanent path: " + e.getMessage());
            e.printStackTrace();
            // Use deployment path as fallback
            return deploymentRoot + relativePath;
        }
    }
}
