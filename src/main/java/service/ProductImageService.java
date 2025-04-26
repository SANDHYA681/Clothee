package service;

import java.io.File;
import java.io.IOException;
import jakarta.servlet.http.Part;

import dao.ProductDAO;
import model.Product;

/**
 * Service class for handling product image operations
 */
public class ProductImageService {
    private ProductDAO productDAO;
    private ProductService productService;

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
    public String uploadProductImage(int productId, Part filePart, String uploadPath) throws IOException {
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
            
            // Create directory structure based on product category
            String categoryPath = product.getCategory().toLowerCase().replace(" ", "_");
            String typePath = product.getType() != null ? product.getType().toLowerCase().replace(" ", "_") : "general";
            
            // Create the full path
            String relativePath = "images/products/" + categoryPath + "/" + typePath;
            String fullUploadPath = uploadPath + relativePath + "/";
            
            // Create directories if they don't exist
            File uploadDir = new File(fullUploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Write the file
            filePart.write(fullUploadPath + newFileName);
            
            // Return the relative path to the image
            return relativePath + "/" + newFileName;
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
}
