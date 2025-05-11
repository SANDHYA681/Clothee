package service;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import dao.ReviewDAO;
import model.Review;

/**
 * Service class for review-related operations
 */
public class ReviewService {
    private ReviewDAO reviewDAO;

    /**
     * Constructor
     */
    public ReviewService() {
        this.reviewDAO = new ReviewDAO();
    }

    /**
     * Add a new review
     * @param productId Product ID
     * @param userId User ID
     * @param rating Rating (1-5)
     * @param comment Review comment
     * @return true if addition successful, false otherwise
     */
    public boolean addReview(int productId, int userId, int rating, String comment) {
        // Check if user has already reviewed this product
        if (reviewDAO.hasUserReviewedProduct(userId, productId)) {
            return false;
        }

        // Validate rating
        if (rating < 1 || rating > 5) {
            return false;
        }

        // Create review
        Review review = new Review();
        review.setProductId(productId);
        review.setUserId(userId);
        review.setRating(rating);
        review.setComment(comment);
        review.setCreatedAt(new Timestamp(new Date().getTime()));

        return reviewDAO.addReview(review);
    }

    /**
     * Update an existing review
     * @param reviewId Review ID
     * @param rating Rating (1-5)
     * @param comment Review comment
     * @param userId User ID (for authorization)
     * @param userRole User role (for authorization)
     * @return true if update successful, false otherwise
     */
    public boolean updateReview(int reviewId, int rating, String comment, int userId, String userRole) {
        // Get review
        Review review = reviewDAO.getReviewById(reviewId);

        if (review == null) {
            return false;
        }

        // Check if user is authorized to update this review
        if (review.getUserId() != userId && !"admin".equals(userRole)) {
            return false;
        }

        // Validate rating
        if (rating < 1 || rating > 5) {
            return false;
        }

        // Update review
        review.setRating(rating);
        review.setComment(comment);
        // Update the reviewed_date to current time
        review.setCreatedAt(new Timestamp(new Date().getTime()));

        return reviewDAO.updateReview(review);
    }

    /**
     * Delete a review
     * @param reviewId Review ID
     * @param userId User ID (for authorization)
     * @param userRole User role (for authorization)
     * @return true if deletion successful, false otherwise
     */
    public boolean deleteReview(int reviewId, int userId, String userRole) {
        // Get review
        Review review = reviewDAO.getReviewById(reviewId);

        if (review == null) {
            return false;
        }

        // Check if user is authorized to delete this review
        if (review.getUserId() != userId && !"admin".equals(userRole)) {
            return false;
        }

        return reviewDAO.deleteReview(reviewId);
    }

    /**
     * Get review by ID
     * @param reviewId Review ID
     * @return Review object if found, null otherwise
     */
    public Review getReviewById(int reviewId) {
        return reviewDAO.getReviewById(reviewId);
    }

    /**
     * Get reviews by product ID
     * @param productId Product ID
     * @return List of reviews for the product
     */
    public List<Review> getReviewsByProductId(int productId) {
        return reviewDAO.getReviewsByProductId(productId);
    }

    /**
     * Get reviews by user ID
     * @param userId User ID
     * @return List of reviews by the user
     */
    public List<Review> getReviewsByUserId(int userId) {
        return reviewDAO.getReviewsByUserId(userId);
    }

    /**
     * Get all reviews
     * @return List of all reviews
     */
    public List<Review> getAllReviews() {
        return reviewDAO.getAllReviews();
    }

    /**
     * Check if user has reviewed a product
     * @param userId User ID
     * @param productId Product ID
     * @return true if user has reviewed the product, false otherwise
     */
    public boolean hasUserReviewedProduct(int userId, int productId) {
        return reviewDAO.hasUserReviewedProduct(userId, productId);
    }

    /**
     * Get user's review for a product
     * @param userId User ID
     * @param productId Product ID
     * @return Review object if found, null otherwise
     */
    public Review getUserReviewForProduct(int userId, int productId) {
        return reviewDAO.getUserReviewForProduct(userId, productId);
    }

    /**
     * Get average rating for a product
     * @param productId Product ID
     * @return Average rating (0-5)
     */
    public double getAverageRatingForProduct(int productId) {
        return reviewDAO.getAverageRatingForProduct(productId);
    }

    /**
     * Get review count for a product
     * @param productId Product ID
     * @return Number of reviews
     */
    public int getReviewCountForProduct(int productId) {
        return reviewDAO.getReviewCountForProduct(productId);
    }
}
