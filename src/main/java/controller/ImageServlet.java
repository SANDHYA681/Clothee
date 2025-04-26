package controller;

import java.io.File;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import service.ProductImageService;
import service.ProductService;
import model.Product;

/**
 * Servlet implementation class ImageServlet
 * Handles product image uploads
 */
// Servlet mapping defined in web.xml
@MultipartConfig
public class ImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductImageService productImageService;
    private ProductService productService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ImageServlet() {
        super();
        productImageService = new ProductImageService();
        productService = new ProductService();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get product ID from request
            String productIdStr = request.getParameter("productId");
            String returnUrl = request.getParameter("returnUrl");

            // Default return URL if not specified
            if (returnUrl == null || returnUrl.isEmpty()) {
                returnUrl = "/admin/AdminProductServlet";
            }

            if (productIdStr == null || productIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + returnUrl + "?error=Product+ID+is+required");
                return;
            }

            try {
                int productId = Integer.parseInt(productIdStr);

                // Get product from database
                Product product = productService.getProductById(productId);

                if (product == null) {
                    response.sendRedirect(request.getContextPath() + returnUrl + "?error=Product+not+found");
                    return;
                }

                // Handle file upload
                Part filePart = request.getPart("productImage");
                if (filePart == null || filePart.getSize() <= 0) {
                    response.sendRedirect(request.getContextPath() + returnUrl + "?error=No+image+file+selected");
                    return;
                }

                // Upload the image using the service
                String uploadPath = request.getServletContext().getRealPath("/");
                String imageUrl = productImageService.uploadProductImage(productId, filePart, uploadPath);

                if (imageUrl == null) {
                    response.sendRedirect(request.getContextPath() + returnUrl + "?error=Failed+to+upload+image");
                    return;
                }

                // Update product image URL in database
                boolean success = productImageService.updateProductImageUrl(productId, imageUrl);

                if (success) {
                    response.sendRedirect(request.getContextPath() + returnUrl + "?success=Product+image+updated+successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + returnUrl + "?error=Failed+to+update+product+image");
                }

            } catch (NumberFormatException e) {
                System.out.println("Error parsing product ID: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + returnUrl + "?error=Invalid+product+ID");
            }
        } catch (Exception e) {
            System.out.println("Error in ImageServlet.doPost: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet?error=Error+uploading+image:+" + e.getMessage());
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
