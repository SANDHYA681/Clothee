package controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.ProductDAO;
import model.Product;

/**
 * Servlet for serving product images from permanent storage
 */
public class ProductImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProductDAO productDAO;

    public ProductImageServlet() {
        super();
        productDAO = new ProductDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get product ID from request
        String productIdStr = request.getParameter("id");
        
        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Product ID is required");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr);
            
            // Get product from database
            Product product = productDAO.getProductById(productId);
            
            if (product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
                return;
            }
            
            String imageUrl = product.getImageUrl();
            if (imageUrl == null || imageUrl.isEmpty()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product has no image");
                return;
            }
            
            // Get the permanent path to the image
            String userHome = System.getProperty("user.home");
            String permanentPath = userHome + File.separator + "ClotheeImages" + File.separator + imageUrl;
            File imageFile = new File(permanentPath);
            
            if (!imageFile.exists()) {
                // Try the webapp path as fallback
                String webappPath = getServletContext().getRealPath("/") + imageUrl;
                imageFile = new File(webappPath);
                
                if (!imageFile.exists()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image file not found");
                    return;
                }
            }
            
            // Set content type based on file extension
            String fileName = imageFile.getName();
            String contentType = "image/jpeg"; // Default
            
            if (fileName.endsWith(".png")) {
                contentType = "image/png";
            } else if (fileName.endsWith(".gif")) {
                contentType = "image/gif";
            } else if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
                contentType = "image/jpeg";
            }
            
            response.setContentType(contentType);
            
            // Copy the file to the response output stream
            try (FileInputStream in = new FileInputStream(imageFile);
                 OutputStream out = response.getOutputStream()) {
                
                byte[] buffer = new byte[4096];
                int bytesRead;
                
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error serving image: " + e.getMessage());
        }
    }
}
