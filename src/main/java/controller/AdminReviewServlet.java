package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.ProductDAO;
import dao.ReviewDAO;
import dao.UserDAO;
import model.Product;
import model.Review;
import model.User;
import service.ReviewService;

/**
 * Servlet implementation class AdminReviewServlet
 */
// Servlet mapping defined in web.xml
public class AdminReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReviewDAO reviewDAO;
    private UserDAO userDAO;
    private ProductDAO productDAO;
    private ReviewService reviewService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public AdminReviewServlet() {
        super();
        reviewDAO = new ReviewDAO();
        userDAO = new UserDAO();
        productDAO = new ProductDAO();
        reviewService = new ReviewService();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listReviews(request, response);
                break;
            case "view":
                viewReview(request, response);
                break;
            case "delete":
                deleteReview(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "byProduct":
                listReviewsByProduct(request, response);
                break;
            case "byUser":
                listReviewsByUser(request, response);
                break;
            default:
                listReviews(request, response);
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in and is an admin
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "update":
                updateReview(request, response);
                break;
            default:
                listReviews(request, response);
        }
    }

    /**
     * List all reviews
     */
    private void listReviews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Review> reviews = reviewDAO.getAllReviews();
        request.setAttribute("reviews", reviews);
        request.getRequestDispatcher("/admin/reviews.jsp").forward(request, response);
    }

    /**
     * View a specific review
     */
    private void viewReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid review ID");
            return;
        }

        try {
            int reviewId = Integer.parseInt(idStr);
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Review not found");
                return;
            }

            // Load user and product if not already loaded
            if (review.getUser() == null) {
                User reviewUser = userDAO.getUserById(review.getUserId());
                review.setUser(reviewUser);
            }

            if (review.getProduct() == null) {
                Product product = productDAO.getProductById(review.getProductId());
                review.setProduct(product);
            }

            request.setAttribute("review", review);
            request.getRequestDispatcher("/admin/view-review.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid review ID format");
        }
    }

    /**
     * Delete a review
     */
    private void deleteReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid review ID");
            return;
        }

        try {
            int reviewId = Integer.parseInt(idStr);
            boolean success = reviewDAO.deleteReview(reviewId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?success=Review deleted successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Failed to delete review");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid review ID format");
        }
    }

    /**
     * Show edit form for a review
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid review ID");
            return;
        }

        try {
            int reviewId = Integer.parseInt(idStr);
            Review review = reviewDAO.getReviewById(reviewId);

            if (review == null) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Review not found");
                return;
            }

            // Load user and product if not already loaded
            if (review.getUser() == null) {
                User reviewUser = userDAO.getUserById(review.getUserId());
                review.setUser(reviewUser);
            }

            if (review.getProduct() == null) {
                Product product = productDAO.getProductById(review.getProductId());
                review.setProduct(product);
            }

            request.setAttribute("review", review);
            request.getRequestDispatcher("/admin/edit-review.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid review ID format");
        }
    }

    /**
     * Update a review
     */
    private void updateReview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        if (idStr == null || idStr.trim().isEmpty() ||
            ratingStr == null || ratingStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Missing required fields");
            return;
        }

        try {
            int reviewId = Integer.parseInt(idStr);
            int rating = Integer.parseInt(ratingStr);

            // Get the current user (admin)
            HttpSession session = request.getSession();
            User admin = (User) session.getAttribute("user");

            boolean success = reviewService.updateReview(reviewId, rating, comment, admin.getId(), "admin");

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?action=view&id=" + reviewId + "&success=Review updated successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?action=edit&id=" + reviewId + "&error=Failed to update review");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid ID or rating format");
        }
    }

    /**
     * List reviews by product
     */
    private void listReviewsByProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productIdStr = request.getParameter("productId");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid product ID");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = productDAO.getProductById(productId);

            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Product not found");
                return;
            }

            List<Review> reviews = reviewDAO.getReviewsByProductId(productId);

            request.setAttribute("product", product);
            request.setAttribute("reviews", reviews);
            request.getRequestDispatcher("/admin/product-reviews.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid product ID format");
        }
    }

    /**
     * List reviews by user
     */
    private void listReviewsByUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdStr = request.getParameter("userId");

        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid user ID");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdStr);
            User reviewUser = userDAO.getUserById(userId);

            if (reviewUser == null) {
                response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=User not found");
                return;
            }

            List<Review> reviews = reviewDAO.getReviewsByUserId(userId);

            request.setAttribute("reviewUser", reviewUser);
            request.setAttribute("reviews", reviews);
            request.getRequestDispatcher("/admin/user-reviews.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet?error=Invalid user ID format");
        }
    }
}
