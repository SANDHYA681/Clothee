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
    private CategoryDAO categoryDAO;

    public CategoryImageServlet() {
        super();
        categoryDAO = new CategoryDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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
            String newFileName = "category_" + categoryId + fileExtension;

            // Save the file to the server
            String relativePath = "images/categories";
            String uploadPath = request.getServletContext().getRealPath("/") + relativePath + "/";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            filePart.write(uploadPath + newFileName);

            // Update category image URL in database
            String imageUrl = relativePath + "/" + newFileName;
            boolean success = categoryDAO.updateCategoryImage(categoryId, imageUrl);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?success=true&message=Category+image+updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp?error=true&message=Failed+to+update+category+image");
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
}
