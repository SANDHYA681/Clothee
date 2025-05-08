package service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import jakarta.servlet.http.Part;

import dao.ProductDAO;
import model.Product;

/**
 * Service class for handling product image operations
 */
public class ProductImageService {
    private final ProductDAO productDAO;
    private final ProductService productService;

    /**
     * Constructor
     */
    public ProductImageService() {
        this.productDAO = new ProductDAO();
        this.productService = new ProductService();
    }

    /**
     * Upload a product image
     * @param productId Product ID
     * @param filePart File part from multipart request
     * @param uploadPath Base upload path
     * @return Image URL if successful, null otherwise
     * @throws IOException If an I/O error occurs
     */
    public String uploadProductImage(int productId, jakarta.servlet.http.Part filePart, String uploadPath) throws IOException {
        System.out.println("\n\n\nProductImageService - uploadProductImage called for product ID: " + productId + "\n\n\n");
        System.out.println("ProductImageService - File part name: " + filePart.getName());
        System.out.println("ProductImageService - File part size: " + filePart.getSize());
        System.out.println("ProductImageService - Upload path: " + uploadPath);
        try {
            // Get product from database
            Product product = productService.getProductById(productId);

            if (product == null) {
                return null;
            }

            // Process the uploaded file
            String fileName = getSubmittedFileName(filePart);
            if (fileName == null || fileName.isEmpty()) {
                return null;
            }

            String fileExtension = fileName.substring(fileName.lastIndexOf("."));
            String newFileName = "product_" + productId + fileExtension;

            // Create a simpler directory structure
            String relativePath = "images/products";
            System.out.println("ProductImageService - Relative path: " + relativePath);

            // Ensure the directory exists
            String fullPath = uploadPath + File.separator + relativePath;
            File dir = new File(fullPath);
            if (!dir.exists()) {
                boolean created = dir.mkdirs();
                System.out.println("ProductImageService - Created directory: " + created + " at " + fullPath);
            }

            // Create the deployment directory path
            String deploymentPath = uploadPath + relativePath;

            // Ensure deployment directory exists
            File deploymentDir = new File(deploymentPath);
            if (!deploymentDir.exists()) {
                boolean created = deploymentDir.mkdirs();
                System.out.println("ProductImageService - Created deployment directory: " + created);
            }

            // Get the permanent path (persists across server restarts)
            String permanentPath = getPermanentPath(uploadPath, relativePath);
            System.out.println("ProductImageService - Permanent path: " + permanentPath);

            // Create the permanent directory if it doesn't exist
            boolean dirCreated = ensureDirectoryExists(permanentPath);
            System.out.println("ProductImageService - Created permanent directory: " + dirCreated);

            // Create a simpler file path
            String deploymentFilePath = deploymentPath + "/" + newFileName;
            System.out.println("ProductImageService - Deployment file path: " + deploymentFilePath);

            // Directory existence was already checked above, no need to check again

            // Write the file directly
            try {
                filePart.write(deploymentFilePath);
                System.out.println("ProductImageService - Image saved to deployment path: " + deploymentFilePath);
            } catch (Exception e) {
                System.out.println("ProductImageService - Error writing file: " + e.getMessage());
                e.printStackTrace();
                return null;
            }

            // Verify the file was written successfully
            File deploymentFile = new File(deploymentFilePath);
            if (!deploymentFile.exists()) {
                System.out.println("ProductImageService - WARNING: Deployment file does not exist after writing!");
                return null;
            }

            System.out.println("ProductImageService - Deployment file exists: " + deploymentFile.exists());
            System.out.println("ProductImageService - Deployment file size: " + deploymentFile.length() + " bytes");

            // Return the relative path to the image
            // Always use forward slashes for URLs, regardless of the operating system
            String imageUrl = relativePath.replace("\\", "/") + "/" + newFileName;
            System.out.println("ProductImageService - Final image URL: " + imageUrl);

            // Update the product with the new image URL immediately
            boolean updated = updateProductImageUrl(productId, imageUrl);
            System.out.println("ProductImageService - Product updated with new image URL: " + updated);

            return imageUrl;
        } catch (Exception e) {
            System.out.println("Error in uploadProductImage: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Update product image URL in database
     * @param productId Product ID
     * @param imageUrl Image URL
     * @return true if successful, false otherwise
     */
    public boolean updateProductImageUrl(int productId, String imageUrl) {
        try {
            return productDAO.updateProductImage(productId, imageUrl);
        } catch (Exception e) {
            System.out.println("Error in updateProductImageUrl: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get the submitted file name from a Part
     *
     * @param part The file part
     * @return The submitted file name
     */
    private String getSubmittedFileName(Part part) {
        try {
            String header = part.getHeader("content-disposition");
            System.out.println("ProductImageService - Content-Disposition header: " + header);

            if (header == null || header.isEmpty()) {
                System.out.println("ProductImageService - Content-Disposition header is null or empty");
                return null;
            }

            for (String content : header.split(";")) {
                if (content.trim().startsWith("filename")) {
                    String fileName = content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
                    System.out.println("ProductImageService - Extracted filename: " + fileName);
                    return fileName;
                }
            }
            System.out.println("ProductImageService - No filename found in header");
            return null;
        } catch (Exception e) {
            System.out.println("ProductImageService - Error extracting filename: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
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
            // This path should be outside the deployment directory but accessible by the web server
            // First try the user's home directory
            String userHome = System.getProperty("user.home");
            String fixedPath = userHome + File.separator + "ClotheeImages" + File.separator + relativePath;
            System.out.println("ProductImageService - Using fixed path in user home: " + fixedPath);
            File fixedDir = new File(fixedPath);

            // Ensure the fixed directory exists
            if (!fixedDir.exists()) {
                boolean created = fixedDir.mkdirs();
                System.out.println("ProductImageService - Created fixed directory: " + created + " at " + fixedPath);
                if (!created) {
                    // If we can't create the directory, try using Java NIO which has better error handling
                    try {
                        java.nio.file.Path path = java.nio.file.Paths.get(fixedPath);
                        java.nio.file.Files.createDirectories(path);
                        System.out.println("ProductImageService - Created directory using NIO at " + fixedPath);
                        return fixedPath;
                    } catch (Exception ex) {
                        System.out.println("ProductImageService - Error creating directory using NIO: " + ex.getMessage());
                        // Continue to fallback options
                    }
                } else {
                    return fixedPath;
                }
            } else {
                return fixedPath;
            }

            // If the fixed path doesn't work, try to use the webapp directory
            // This is less reliable but might work as a fallback
            String webappPath = webappRoot + relativePath;
            File webappDir = new File(webappPath);
            if (!webappDir.exists()) {
                boolean created = webappDir.mkdirs();
                System.out.println("ProductImageService - Created webapp directory: " + created + " at " + webappPath);
            }

            return webappPath;
        } catch (Exception e) {
            System.out.println("ProductImageService - Error getting permanent path: " + e.getMessage());
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
                System.out.println("ProductImageService - Error: Directory path is null or empty");
                return false;
            }

            File dir = new File(path);
            if (dir.exists()) {
                if (!dir.isDirectory()) {
                    System.out.println("ProductImageService - Error: Path exists but is not a directory: " + path);
                    return false;
                }
                return true;
            }

            boolean created = dir.mkdirs();
            if (!created) {
                System.out.println("ProductImageService - Error: Failed to create directory: " + path);
                return false;
            }

            System.out.println("ProductImageService - Created directory: " + path);
            return true;
        } catch (Exception e) {
            System.out.println("ProductImageService - Error creating directory: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
