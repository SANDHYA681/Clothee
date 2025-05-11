package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.Product;
import model.Review;
import model.User;
import service.ProductService;
import service.ReviewService;

/**
 * Servlet implementation class ProductDetailsServlet
 */
// Servlet mapping defined in web.xml
public class ProductDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductService productService;
    private ReviewService reviewService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ProductDetailsServlet() {
        super();
        productService = new ProductService();
        reviewService = new ReviewService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            action = "view";
        }

        switch (action) {
            case "view":
                viewProductDetails(request, response);
                break;
            case "addToCart":
                addToCart(request, response);
                break;
            default:
                viewProductDetails(request, response);
        }
    }

    /**
     * View product details
     */
    private void viewProductDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get product ID from request
            String productIdParam = request.getParameter("id");
            if (productIdParam == null || productIdParam.isEmpty()) {
                response.sendRedirect("ProductServlet");
                return;
            }

            int productId;
            try {
                productId = Integer.parseInt(productIdParam);
            } catch (NumberFormatException e) {
                response.sendRedirect("ProductServlet");
                return;
            }

            // Get product from database
            Product product = productService.getProductById(productId);

            if (product == null) {
                response.sendRedirect("ProductServlet");
                return;
            }

            // Get related products
            List<Product> relatedProducts = productService.getProductsByCategory(product.getCategory());
            // Remove current product from related products
            relatedProducts.removeIf(p -> p.getId() == product.getId());
            // Limit to 4 related products
            if (relatedProducts.size() > 4) {
                relatedProducts = relatedProducts.subList(0, 4);
            }

            // Get tab parameter
            String tab = request.getParameter("tab");
            if (tab == null) {
                tab = "description";
            }

            // Get reviews for this product
            List<Review> reviews = reviewService.getReviewsByProductId(productId);

            // Calculate average rating
            double avgRating = 0;
            if (reviews != null && !reviews.isEmpty()) {
                int totalRating = 0;
                for (Review review : reviews) {
                    totalRating += review.getRating();
                }
                avgRating = (double) totalRating / reviews.size();
            }

            // Check if user has already reviewed this product
            boolean hasReviewed = false;
            Review userReview = null;
            User user = (User) request.getSession().getAttribute("user");
            if (user != null) {
                hasReviewed = reviewService.hasUserReviewedProduct(user.getId(), productId);
                if (hasReviewed) {
                    userReview = reviewService.getUserReviewForProduct(user.getId(), productId);
                }
            }

            // Set attributes
            request.setAttribute("product", product);
            request.setAttribute("relatedProducts", relatedProducts);
            request.setAttribute("tab", tab);
            request.setAttribute("reviews", reviews);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("hasReviewed", hasReviewed);
            request.setAttribute("userReview", userReview);

            // Forward to product details page
            request.getRequestDispatcher("/product-details.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("Error in viewProductDetails: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred while retrieving product details. Please try again later.");
            request.getRequestDispatcher("/error/500.jsp").forward(request, response);
        }
    }

    /**
     * Add product to cart
     */
    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            // Redirect to login page
            String redirectUrl = request.getContextPath() + "/ProductDetailsServlet?id=" + request.getParameter("id");
            response.sendRedirect("LoginServlet?message=" + java.net.URLEncoder.encode("Please login to add items to your cart", "UTF-8") + "&redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        // Check if user is an admin - admins should not use cart functionality
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp?error=Admin+users+cannot+use+cart+functionality");
            return;
        }

        // Get product ID and quantity from request
        String productIdParam = request.getParameter("id");
        String quantityParam = request.getParameter("quantity");

        if (productIdParam == null || productIdParam.isEmpty()) {
            response.sendRedirect("ProductServlet");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("ProductServlet");
            return;
        }

        int quantity = 1;
        if (quantityParam != null && !quantityParam.isEmpty()) {
            try {
                quantity = Integer.parseInt(quantityParam);
                if (quantity < 1) {
                    quantity = 1;
                }
            } catch (NumberFormatException e) {
                // Use default quantity
            }
        }

        // Add product to cart
        response.sendRedirect("CartServlet?action=add&productId=" + productId + "&quantity=" + quantity);
    }
}
