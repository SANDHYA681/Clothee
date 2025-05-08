package util;

import java.io.File;

/**
 * Utility class for handling image paths
 * Following MVC pattern - this is part of the Model layer (utility component)
 */
public class ImagePathUtil {

    /**
     * Get the permanent path for storing images
     * @param webappRoot The webapp root path
     * @param relativePath The relative path within the webapp
     * @return The permanent path
     */
    public static String getPermanentPath(String webappRoot, String relativePath) {
        try {
            // Find the project root directory (outside the deployment directory)
            File deploymentDir = new File(webappRoot);
            File projectRoot = deploymentDir.getParentFile().getParentFile().getParentFile();
            
            // Create the permanent path
            String permanentPath = projectRoot.getAbsolutePath() + "/src/main/webapp/" + relativePath;
            System.out.println("ImagePathUtil - Project root: " + projectRoot.getAbsolutePath());
            System.out.println("ImagePathUtil - Permanent path: " + permanentPath);
            
            return permanentPath;
        } catch (Exception e) {
            System.out.println("ImagePathUtil - Error getting permanent path: " + e.getMessage());
            e.printStackTrace();
            return webappRoot + relativePath;
        }
    }

    /**
     * Ensure the directory exists
     * @param path The directory path
     * @return true if the directory exists or was created, false otherwise
     */
    public static boolean ensureDirectoryExists(String path) {
        try {
            if (path == null || path.isEmpty()) {
                System.out.println("ImagePathUtil - Error: Directory path is null or empty");
                return false;
            }

            File dir = new File(path);
            if (dir.exists()) {
                if (!dir.isDirectory()) {
                    System.out.println("ImagePathUtil - Error: Path exists but is not a directory: " + path);
                    return false;
                }
                return true;
            }

            boolean created = dir.mkdirs();
            if (!created) {
                System.out.println("ImagePathUtil - Error: Failed to create directory: " + path);
                return false;
            }

            System.out.println("ImagePathUtil - Created directory: " + path);
            return true;
        } catch (Exception e) {
            System.out.println("ImagePathUtil - Error creating directory: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
