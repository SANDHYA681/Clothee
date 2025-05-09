package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import dao.ProductDAO;
import dao.ReviewDAO;
import dao.UserDAO;
import model.Product;
import model.Review;
import model.User;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet implementation class ReviewServlet
 */
// Servlet mapping defined in web.xml
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReviewDAO reviewDAO;
    private ProductDAO productDAO;
    private UserDAO userDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ReviewServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        reviewDAO = new ReviewDAO();
        productDAO = new ProductDAO();
        userDAO = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        System.out.println("ReviewServlet doGet called with action: " + action);

        if (action == null) {
            System.out.println("ReviewServlet: No action parameter, redirecting to ProductDetailsServlet");
            response.sendRedirect("ProductDetailsServlet");
            return;
        }

        switch (action) {
            case "list":
                listReviews(request, response);
                break;
            case "add":
                showAddReviewForm(request, response);
                break;
            case "edit":
                showEditReviewForm(request, response);
                break;
            case "delete":
                deleteReview(request, response);
                break;
            case "view":
                viewReview(request, response);
                break;
            default:
                response.sendRedirect("ProductServlet");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect("ProductDetailsServlet");
            return;
        }

        switch (action) {
            case "add":
                addReview(request, response);
                break;
            case "update":
                updateReview(request, response);
                break;
            default:
                response.sendRedirect("ProductDetailsServlet");
        }
    }

    /**
     * List reviews for a product
     */
    private void listReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productIdStr = request.getParameter("productId");

        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect("ProductServlet");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = productDAO.getProductById(productId);

            if (product == null) {
                response.sendRedirect("ProductServlet");
                return;
            }

            List<Review> reviews = reviewDAO.getReviewsByProductId(productId);

            request.setAttribute("product", product);
            request.setAttribute("reviews", reviews);
            request.getRequestDispatcher("reviews.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect("ProductServlet");
        }
    }

    /**
     * Show add review form
     */
    private void showAddReviewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Guest user, redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=ReviewServlet?action=add&productId=" + request.getParameter("productId"));
            return;
        }

        String productIdStr = request.getParameter("productId");

        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ProductServlet");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = productDAO.getProductById(productId);

            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/ProductServlet");
                return;
            }

            // Check if user has already reviewed this product
            if (reviewDAO.hasUserReviewedProduct(user.getId(), productId)) {
                Review review = reviewDAO.getUserReviewForProduct(user.getId(), productId);
                request.setAttribute("review", review);
                request.setAttribute("product", product);
                request.getRequestDispatcher("/edit-review.jsp").forward(request, response);
                return;
            }

            // Check if user has purchased this product
            // This is optional - you can comment this out if you want to allow all users to review products
            /*
            OrderDAO orderDAO = new OrderDAO();
            if (!orderDAO.hasUserPurchasedProduct(user.getId(), productId)) {
                request.setAttribute("errorMessage", "You can only review products you have purchased");
                response.sendRedirect(request.getContextPath() + "/ProductServlet?action=detail&id=" + productId + "&tab=reviews");
                return;
            }
            */

            request.setAttribute("product", product);
            request.getRequestDispatcher("/add-review.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/ProductServlet");
        }
    }

    /**
     * Add a review
     */
    private void addReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Guest user, redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String productIdStr = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        if (productIdStr == null || productIdStr.isEmpty() || ratingStr == null || ratingStr.isEmpty() ||
            comment == null || comment.isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required");
            showAddReviewForm(request, response);
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            int rating = Integer.parseInt(ratingStr);

            // Validate rating
            if (rating < 1 || rating > 5) {
                request.setAttribute("errorMessage", "Rating must be between 1 and 5");
                showAddReviewForm(request, response);
                return;
            }

            // Check if product exists
            Product product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/ProductServlet");
                return;
            }

            // Check if user has already reviewed this product
            if (reviewDAO.hasUserReviewedProduct(user.getId(), productId)) {
                request.setAttribute("errorMessage", "You have already reviewed this product");
                showAddReviewForm(request, response);
                return;
            }

            // Create review
            Review review = new Review();
            review.setProductId(productId);
            review.setUserId(user.getId());
            review.setRating(rating);
            review.setUserName(user.getFirstName() + " " + user.getLastName());
            review.setComment(comment);
            review.setReviewDate(new Date());
            review.setCreatedAt(new java.sql.Timestamp(new Date().getTime()));

            // Add review
            boolean success = reviewDAO.addReview(review);

            if (success) {
                // Redirect to product detail
                response.sendRedirect(request.getContextPath() + "/ProductDetailsServlet?id=" + productId + "&tab=reviews&message=Review+added+successfully");
            } else {
                // Show error
                request.setAttribute("errorMessage", "Failed to add review");
                showAddReviewForm(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid input");
            showAddReviewForm(request, response);
        }
    }

    /**
     * Show edit review form
     */
    private void showEditReviewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Guest user, redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String reviewIdStr = request.getParameter("reviewId");

        if (reviewIdStr == null || reviewIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+ID+is+required");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+not+found");
                return;
            }

            // Check if user is the owner of the review
            if (review.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=You+do+not+have+permission+to+edit+this+review");
                return;
            }

            // Get product details
            Product product = productDAO.getProductById(review.getProductId());
            if (product == null) {
                // Create a placeholder product if the actual product can't be found
                product = new Product();
                product.setId(review.getProductId());
                product.setName("Product #" + review.getProductId());
                product.setCategory("Unknown");
                product.setPrice(0.0);
                product.setImageUrl("images/product-placeholder.jpg");
            }
            review.setProduct(product);

            // Set review in request
            request.setAttribute("review", review);

            // Forward to edit form
            request.getRequestDispatcher("/customer/edit-review.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+review+ID");
        }
    }

    /**
     * Update a review
     */
    private void updateReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Guest user, redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String reviewIdStr = request.getParameter("reviewId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        if (reviewIdStr == null || reviewIdStr.isEmpty() || ratingStr == null || ratingStr.isEmpty() ||
            comment == null || comment.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/edit-review.jsp?reviewId=" + reviewIdStr + "&error=All+fields+are+required");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            int rating = Integer.parseInt(ratingStr);

            // Validate rating
            if (rating < 1 || rating > 5) {
                response.sendRedirect(request.getContextPath() + "/customer/edit-review.jsp?reviewId=" + reviewId + "&error=Rating+must+be+between+1+and+5");
                return;
            }

            // Get review
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+not+found");
                return;
            }

            // Check if user is the owner of the review
            if (review.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=You+do+not+have+permission+to+edit+this+review");
                return;
            }

            // Update review
            review.setRating(rating);
            review.setComment(comment);
            review.setReviewDate(new Date());
            review.setCreatedAt(new java.sql.Timestamp(new Date().getTime()));

            boolean success = reviewDAO.updateReview(review);

            if (success) {
                // Redirect to customer reviews page
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?message=Review+updated+successfully");
            } else {
                // Show error
                response.sendRedirect(request.getContextPath() + "/customer/edit-review.jsp?reviewId=" + reviewId + "&error=Failed+to+update+review");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+input");
        }
    }

    /**
     * View a review
     */
    private void viewReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Log for debugging
        System.out.println("ReviewServlet: viewReview method called");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Guest user, redirect to login
            System.out.println("ReviewServlet: User not logged in, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String reviewIdStr = request.getParameter("reviewId");
        System.out.println("ReviewServlet: reviewId parameter = " + reviewIdStr);

        if (reviewIdStr == null || reviewIdStr.isEmpty()) {
            System.out.println("ReviewServlet: Review ID is required");
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+ID+is+required");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            System.out.println("ReviewServlet: Looking up review with ID = " + reviewId);

            // Get review from database
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                System.out.println("ReviewServlet: Review not found");
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+not+found");
                return;
            }

            System.out.println("ReviewServlet: Review found with ID = " + review.getId());

            // Check if user is the owner of the review
            if (review.getUserId() != user.getId() && !user.isAdmin()) {
                System.out.println("ReviewServlet: User does not have permission to view this review");
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=You+do+not+have+permission+to+view+this+review");
                return;
            }

            // Get product details
            System.out.println("ReviewServlet: Getting product with ID = " + review.getProductId());
            Product product = productDAO.getProductById(review.getProductId());

            if (product == null) {
                // Create a placeholder product if the actual product can't be found
                System.out.println("ReviewServlet: Product not found, creating placeholder");
                product = new Product();
                product.setId(review.getProductId());
                product.setName("Product #" + review.getProductId());
                product.setCategory("Unknown");
                product.setPrice(0.0);
                product.setImageUrl("images/product-placeholder.jpg");
            } else {
                System.out.println("ReviewServlet: Product found: " + product.getName());
            }

            // Set product in review
            review.setProduct(product);

            // Set review in request
            request.setAttribute("review", review);
            System.out.println("ReviewServlet: Set review in request attribute");

            // Forward to view review page
            System.out.println("ReviewServlet: Forwarding to /customer/view-review.jsp");
            try {
                request.getRequestDispatcher("/customer/view-review.jsp").forward(request, response);
                System.out.println("ReviewServlet: Successfully forwarded to view-review.jsp");
            } catch (Exception e) {
                System.out.println("ReviewServlet: Error forwarding to view-review.jsp: " + e.getMessage());
                e.printStackTrace();
                // Try a different approach - redirect instead of forward
                response.sendRedirect(request.getContextPath() + "/customer/view-review.jsp?reviewId=" + review.getId());
            }
        } catch (NumberFormatException e) {
            System.out.println("ReviewServlet: Invalid review ID format");
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+review+ID");
        } catch (Exception e) {
            System.out.println("ReviewServlet: Exception in viewReview: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Error+viewing+review");
        }
    }

    /**
     * Delete a review
     */
    private void deleteReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Guest user, redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String reviewIdStr = request.getParameter("reviewId");
        String productIdStr = request.getParameter("productId");

        if (reviewIdStr == null || reviewIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ProductServlet");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/ProductServlet");
                return;
            }

            // Check if user is the owner of the review or an admin
            if (review.getUserId() != user.getId() && !user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/ProductServlet");
                return;
            }

            // Delete review
            boolean success = reviewDAO.deleteReview(reviewId);

            // Redirect based on success
            if (success) {
                // Check if request is from admin
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/reviews.jsp?message=Review+deleted+successfully");
                } else {
                    // If productId is provided, redirect to product details
                    if (productIdStr != null && !productIdStr.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/ProductDetailsServlet?id=" + productIdStr + "&tab=reviews&message=Review+deleted+successfully");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/ProductDetailsServlet?id=" + review.getProductId() + "&tab=reviews&message=Review+deleted+successfully");
                    }
                }
            } else {
                // Show error message
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/reviews.jsp?error=Failed+to+delete+review");
                } else {
                    // If productId is provided, redirect to product details
                    if (productIdStr != null && !productIdStr.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/ProductDetailsServlet?id=" + productIdStr + "&tab=reviews&error=Failed+to+delete+review");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/ProductDetailsServlet?id=" + review.getProductId() + "&tab=reviews&error=Failed+to+delete+review");
                    }
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/ProductDetailsServlet");
        }
    }
}
