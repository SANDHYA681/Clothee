package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import model.Review;
import model.Product;
import dao.ReviewDAO;
import dao.ProductDAO;

/**
 * Servlet implementation class CustomerReviewServlet
 */
public class CustomerReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReviewDAO reviewDAO;
    private ProductDAO productDAO;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public CustomerReviewServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        reviewDAO = new ReviewDAO();
        productDAO = new ProductDAO();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Check if user is not an admin
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "list":
                    listUserReviews(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteReview(request, response);
                    break;
                default:
                    listUserReviews(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();

            // Forward to reviews page with error message
            request.setAttribute("errorMessage", "An error occurred while processing your request.");
            request.getRequestDispatcher("/customer/reviews.jsp").forward(request, response);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Check if user is not an admin
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "update":
                    updateReview(request, response);
                    break;
                default:
                    listUserReviews(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();

            // Forward to reviews page with error message
            request.setAttribute("errorMessage", "An error occurred while processing your request.");
            request.getRequestDispatcher("/customer/reviews.jsp").forward(request, response);
        }
    }

    /**
     * List all reviews by the current user
     */
    private void listUserReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get user from session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        try {
            // Get user's reviews
            List<Review> userReviews = reviewDAO.getReviewsByUserId(user.getId());

            // Set reviews attribute even if empty
            if (userReviews == null || userReviews.isEmpty()) {
                request.setAttribute("userReviews", new ArrayList<Review>());
            } else {
                // Load products for each review
                for (Review review : userReviews) {
                    try {
                        Product product = productDAO.getProductById(review.getProductId());
                        review.setProduct(product);
                    } catch (Exception e) {
                        // Create a placeholder product if the actual product can't be loaded
                        // Create a placeholder product
                        Product product = new Product();
                        product.setId(review.getProductId());
                        product.setName("Product #" + review.getProductId());
                        product.setCategory("Unknown");
                        product.setImageUrl("images/product-placeholder.jpg");
                        review.setProduct(product);
                    }
                }

                // Set reviews attribute
                request.setAttribute("userReviews", userReviews);
            }

            // Forward to reviews page
            request.getRequestDispatcher("/customer/reviews.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();

            // Set empty reviews list and error message
            request.setAttribute("userReviews", new ArrayList<Review>());
            request.setAttribute("errorMessage", "An error occurred while retrieving your reviews.");

            // Forward to reviews page
            request.getRequestDispatcher("/customer/reviews.jsp").forward(request, response);
        }
    }

    /**
     * Show edit form for a review
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get review ID from request
        String reviewIdStr = request.getParameter("id");

        if (reviewIdStr == null || reviewIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+review+ID");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);

            // Get review
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+not+found");
                return;
            }

            // Get user from session
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            // Check if user is authorized to edit this review
            if (review.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Unauthorized");
                return;
            }

            // Get product
            Product product = productDAO.getProductById(review.getProductId());
            review.setProduct(product);

            // Set attributes
            request.setAttribute("review", review);

            // Forward to edit form
            request.getRequestDispatcher("/customer/edit-review.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+review+ID");
        } catch (Exception e) {
            // Log error and redirect
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Error+showing+edit+form");
        }
    }

    /**
     * Update a review
     */
    private void updateReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get parameters
        String reviewIdStr = request.getParameter("reviewId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        if (reviewIdStr == null || reviewIdStr.isEmpty() || ratingStr == null || ratingStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+input");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            int rating = Integer.parseInt(ratingStr);

            // Validate rating
            if (rating < 1 || rating > 5) {
                response.sendRedirect(request.getContextPath() + "/customer/edit-review.jsp?id=" + reviewId + "&error=Rating+must+be+between+1+and+5");
                return;
            }

            // Get review
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+not+found");
                return;
            }

            // Get user from session
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            // Check if user is authorized to edit this review
            if (review.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Unauthorized");
                return;
            }

            // Update review
            review.setRating(rating);
            review.setComment(comment);
            review.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

            boolean success = reviewDAO.updateReview(review);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/CustomerReviewServlet?message=Review+updated+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/edit-review.jsp?id=" + reviewId + "&error=Failed+to+update+review");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+input");
        } catch (Exception e) {
            // Log error and redirect
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Error+updating+review");
        }
    }

    /**
     * Delete a review
     */
    private void deleteReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get review ID from request
        String reviewIdStr = request.getParameter("id");

        if (reviewIdStr == null || reviewIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+review+ID");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);

            // Get review
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+not+found");
                return;
            }

            // Get user from session
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            // Check if user is authorized to delete this review
            if (review.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Unauthorized");
                return;
            }

            boolean success = reviewDAO.deleteReview(reviewId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/CustomerReviewServlet?message=Review+deleted+successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Failed+to+delete+review");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Invalid+review+ID");
        } catch (Exception e) {
            // Log error and redirect
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Error+deleting+review");
        }
    }


}
