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
import service.ProductImageService;

/**
 * Servlet implementation class ImageServlet
 * Handles product image uploads
 */
// Servlet mapping defined in web.xml
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 5,   // 5 MB
    maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class ImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductImageService productImageService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ImageServlet() {
        super();
        productImageService = new ProductImageService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Get product ID from request parameter
        String productId = request.getParameter("id");
        if (productId != null && !productId.isEmpty()) {
            // Forward to upload page with product ID
            request.getRequestDispatcher("/admin/product-image-upload.jsp?id=" + productId).forward(request, response);
        } else {
            // Forward to upload page without product ID
            request.getRequestDispatcher("/admin/product-image-upload.jsp").forward(request, response);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("ImageServlet - doPost method called");

        // Check if user is logged in and is an admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        try {
            // Get product ID from request parameter
            String productIdStr = request.getParameter("productId");
            System.out.println("ImageServlet - Product ID: " + productIdStr);

            if (productIdStr == null || productIdStr.isEmpty()) {
                // Check if returnUrl parameter is provided
                String returnUrl = request.getParameter("returnUrl");
                if (returnUrl != null && !returnUrl.isEmpty()) {
                    // Redirect to the specified return URL with error message
                    response.sendRedirect(request.getContextPath() + returnUrl + (returnUrl.contains("?") ? "&" : "?") + "error=true&message=Product+ID+is+required");
                } else {
                    // Redirect to products page with error message
                    response.sendRedirect(request.getContextPath() + "/admin/products.jsp?error=true&message=Product+ID+is+required");
                }
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(productIdStr);
            } catch (NumberFormatException e) {
                // Check if returnUrl parameter is provided
                String returnUrl = request.getParameter("returnUrl");
                if (returnUrl != null && !returnUrl.isEmpty()) {
                    // Redirect to the specified return URL with error message
                    response.sendRedirect(request.getContextPath() + returnUrl + (returnUrl.contains("?") ? "&" : "?") + "error=true&message=Invalid+product+ID");
                } else {
                    // Redirect to products page with error message
                    response.sendRedirect(request.getContextPath() + "/admin/products.jsp?error=true&message=Invalid+product+ID");
                }
                return;
            }

            // Get file part from request
            Part filePart = request.getPart("productImage");
            System.out.println("ImageServlet - File part: " + filePart);

            if (filePart == null || filePart.getSize() <= 0) {
                // Check if returnUrl parameter is provided
                String returnUrl = request.getParameter("returnUrl");
                if (returnUrl != null && !returnUrl.isEmpty()) {
                    // Redirect to the specified return URL with error message
                    response.sendRedirect(request.getContextPath() + returnUrl + (returnUrl.contains("?") ? "&" : "?") + "error=true&message=No+image+file+selected");
                } else {
                    // Redirect to products page with error message
                    response.sendRedirect(request.getContextPath() + "/admin/products.jsp?error=true&message=No+image+file+selected");
                }
                return;
            }

            System.out.println("ImageServlet - File size: " + filePart.getSize() + " bytes");

            // Upload the image using the service
            String webappRoot = request.getServletContext().getRealPath("/");
            System.out.println("ImageServlet - Webapp root: " + webappRoot);

            String imageUrl = productImageService.uploadProductImage(productId, filePart, webappRoot);

            if (imageUrl == null) {
                // Check if returnUrl parameter is provided
                String returnUrl = request.getParameter("returnUrl");
                if (returnUrl != null && !returnUrl.isEmpty()) {
                    // Redirect to the specified return URL with error message
                    response.sendRedirect(request.getContextPath() + returnUrl + (returnUrl.contains("?") ? "&" : "?") + "error=true&message=Failed+to+upload+image");
                } else {
                    // Redirect to products page with error message
                    response.sendRedirect(request.getContextPath() + "/admin/products.jsp?error=true&message=Failed+to+upload+image");
                }
                return;
            }

            System.out.println("ImageServlet - Image URL: " + imageUrl);

            // Verify the image file exists
            File imageFile = new File(webappRoot + imageUrl);
            System.out.println("ImageServlet - Image file exists: " + imageFile.exists());
            System.out.println("ImageServlet - Image file path: " + imageFile.getAbsolutePath());
            System.out.println("ImageServlet - Image file size: " + (imageFile.exists() ? imageFile.length() : 0) + " bytes");

            // Check if returnUrl parameter is provided
            String returnUrl = request.getParameter("returnUrl");
            if (returnUrl != null && !returnUrl.isEmpty()) {
                // Redirect to the specified return URL with success message
                response.sendRedirect(request.getContextPath() + returnUrl + (returnUrl.contains("?") ? "&" : "?") + "success=true&message=Product+image+uploaded+successfully");
            } else {
                // Redirect to products page with success message
                response.sendRedirect(request.getContextPath() + "/admin/products.jsp?success=true&message=Product+image+uploaded+successfully");
            }

        } catch (Exception e) {
            System.out.println("ImageServlet - Error: " + e.getMessage());
            e.printStackTrace();
            // Check if returnUrl parameter is provided
            String returnUrl = request.getParameter("returnUrl");
            if (returnUrl != null && !returnUrl.isEmpty()) {
                // Redirect to the specified return URL with error message
                response.sendRedirect(request.getContextPath() + returnUrl + (returnUrl.contains("?") ? "&" : "?") + "error=true&message=Error+uploading+image:+" + e.getMessage());
            } else {
                // Redirect to products page with error message
                response.sendRedirect(request.getContextPath() + "/admin/products.jsp?error=true&message=Error+uploading+image:+" + e.getMessage());
            }
        }
    }
}
