package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import model.Review;
import model.Product;
import model.User;
import util.DBConnection;

/**
 * Review Data Access Object
 */
public class ReviewDAO {
    private UserDAO userDAO;
    private ProductDAO productDAO;

    public ReviewDAO() {
        this.userDAO = new UserDAO();
        this.productDAO = new ProductDAO();
    }

    /**
     * Add a new review to the database
     * @param review Review object to add
     * @return true if successful, false otherwise
     */
    public boolean addReview(Review review) {
        String query = "INSERT INTO reviews (product_id, user_id, rating, comment, reviewed_date) " +
                       "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, review.getProductId());
            stmt.setInt(2, review.getUserId());
            stmt.setInt(3, review.getRating());
            stmt.setString(4, review.getComment());
            stmt.setTimestamp(5, review.getCreatedAt());

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        review.setId(rs.getInt(1));
                        return true;
                    }
                }
            }

            return false;

        } catch (SQLException e) {
            System.out.println("Error adding review: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update an existing review
     * @param review Review object to update
     * @return true if successful, false otherwise
     */
    public boolean updateReview(Review review) {
        String query = "UPDATE reviews SET rating = ?, comment = ?, reviewed_date = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, review.getRating());
            stmt.setString(2, review.getComment());
            stmt.setTimestamp(3, review.getCreatedAt());
            stmt.setInt(4, review.getId());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error updating review: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete a review
     * @param reviewId Review ID to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteReview(int reviewId) {
        String query = "DELETE FROM reviews WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, reviewId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error deleting review: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get review by ID
     * @param reviewId Review ID
     * @return Review object if found, null otherwise
     */
    public Review getReviewById(int reviewId) {
        System.out.println("ReviewDAO: Getting review with ID = " + reviewId);
        String query = "SELECT * FROM reviews WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            if (conn == null) {
                System.out.println("ReviewDAO: Database connection is null");
                return null;
            }

            stmt.setInt(1, reviewId);
            System.out.println("ReviewDAO: Executing query: " + query + " with ID = " + reviewId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("ReviewDAO: Review found in database");
                    Review review = extractReviewFromResultSet(rs);
                    System.out.println("ReviewDAO: Review extracted: ID=" + review.getId() + ", ProductID=" + review.getProductId() + ", UserID=" + review.getUserId());

                    // Load user
                    User user = userDAO.getUserById(review.getUserId());
                    if (user != null) {
                        System.out.println("ReviewDAO: User found: ID=" + user.getId() + ", Name=" + user.getFirstName() + " " + user.getLastName());
                        review.setUser(user);
                    } else {
                        System.out.println("ReviewDAO: User not found for ID=" + review.getUserId());
                    }

                    // Load product
                    Product product = productDAO.getProductById(review.getProductId());
                    if (product != null) {
                        System.out.println("ReviewDAO: Product found: ID=" + product.getId() + ", Name=" + product.getName());
                        review.setProduct(product);
                    } else {
                        System.out.println("ReviewDAO: Product not found for ID=" + review.getProductId());
                    }

                    return review;
                } else {
                    System.out.println("ReviewDAO: No review found with ID = " + reviewId);
                }
            }

        } catch (SQLException e) {
            System.out.println("ReviewDAO: Error getting review by ID: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.out.println("ReviewDAO: Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all reviews for a product
     * @param productId Product ID
     * @return List of reviews for the product
     */
    public List<Review> getReviewsByProductId(int productId) {
        List<Review> reviews = new ArrayList<>();
        String query = "SELECT r.*, u.first_name, u.last_name, u.profile_image " +
                      "FROM reviews r " +
                      "LEFT JOIN users u ON r.user_id = u.id " +
                      "WHERE r.product_id = ? " +
                      "ORDER BY r.reviewed_date DESC";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                System.out.println("Error: Could not get database connection");
                return reviews;
            }

            stmt = conn.prepareStatement(query);
            stmt.setInt(1, productId);

            rs = stmt.executeQuery();
            while (rs.next()) {
                try {
                    Review review = extractReviewFromResultSet(rs);

                    // If user name wasn't set in extractReviewFromResultSet, load user
                    if (review.getUserName() == null) {
                        User user = userDAO.getUserById(review.getUserId());
                        review.setUser(user);
                        if (user != null) {
                            review.setUserName(user.getFirstName() + " " + user.getLastName());
                        }
                    }

                    reviews.add(review);
                } catch (Exception e) {
                    System.out.println("Error processing review: " + e.getMessage());
                    e.printStackTrace();
                    // Continue processing other reviews
                }
            }
        } catch (SQLException e) {
            System.out.println("Error getting reviews by product ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.out.println("Error closing resources: " + e.getMessage());
                e.printStackTrace();
            }
        }

        return reviews;
    }

    /**
     * Get all reviews by a user
     * @param userId User ID
     * @return List of reviews by the user
     */
    public List<Review> getReviewsByUserId(int userId) {
        List<Review> reviews = new ArrayList<>();

        // First check if the reviews table exists
        try (Connection conn = DBConnection.getConnection()) {
            // Check if the reviews table exists
            try {
                java.sql.DatabaseMetaData dbm = conn.getMetaData();
                java.sql.ResultSet tables = dbm.getTables(null, null, "reviews", null);
                if (!tables.next()) {
                    System.out.println("Warning: reviews table does not exist");
                    return reviews;
                }
            } catch (SQLException e) {
                System.out.println("Error checking if reviews table exists: " + e.getMessage());
                e.printStackTrace();
                return reviews;
            }

            String query = "SELECT r.*, p.name as product_name " +
                          "FROM reviews r " +
                          "LEFT JOIN products p ON r.product_id = p.id " +
                          "WHERE r.user_id = ? " +
                          "ORDER BY r.reviewed_date DESC";

            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, userId);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        try {
                            Review review = extractReviewFromResultSet(rs);

                            // Load product if not already loaded
                            if (review.getProduct() == null) {
                                Product product = productDAO.getProductById(review.getProductId());
                                review.setProduct(product);
                                if (product != null) {
                                    review.setProductName(product.getName());
                                }
                            }

                            reviews.add(review);
                        } catch (Exception e) {
                            System.out.println("Error processing review: " + e.getMessage());
                            e.printStackTrace();
                            // Continue processing other reviews
                        }
                    }
                }
            } catch (SQLException e) {
                System.out.println("Error executing query: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (SQLException e) {
            System.out.println("Error getting reviews by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return reviews;
    }

    /**
     * Get all reviews
     * @return List of all reviews
     */
    public List<Review> getAllReviews() {
        List<Review> reviews = new ArrayList<>();
        String query = "SELECT r.*, u.first_name, u.last_name, p.name as product_name " +
                      "FROM reviews r " +
                      "LEFT JOIN users u ON r.user_id = u.id " +
                      "LEFT JOIN products p ON r.product_id = p.id " +
                      "ORDER BY r.reviewed_date DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                Review review = extractReviewFromResultSet(rs);

                // Set user name if available
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
                if (firstName != null && lastName != null) {
                    User user = new User();
                    user.setFirstName(firstName);
                    user.setLastName(lastName);
                    review.setUser(user);
                }

                // Set product name if available
                String productName = rs.getString("product_name");
                if (productName != null) {
                    Product product = new Product();
                    product.setName(productName);
                    review.setProduct(product);
                }

                reviews.add(review);
            }

        } catch (SQLException e) {
            System.out.println("Error getting all reviews: " + e.getMessage());
            e.printStackTrace();
        }

        return reviews;
    }

    /**
     * Check if a user has reviewed a product
     * @param userId User ID
     * @param productId Product ID
     * @return true if the user has reviewed the product, false otherwise
     */
    public boolean hasUserReviewedProduct(int userId, int productId) {
        String query = "SELECT COUNT(*) FROM reviews WHERE user_id = ? AND product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, productId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            System.out.println("Error checking if user has reviewed product: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get a user's review for a product
     * @param userId User ID
     * @param productId Product ID
     * @return Review object if found, null otherwise
     */
    public Review getUserReviewForProduct(int userId, int productId) {
        String query = "SELECT r.*, u.first_name, u.last_name, p.name as product_name " +
                      "FROM reviews r " +
                      "LEFT JOIN users u ON r.user_id = u.id " +
                      "LEFT JOIN products p ON r.product_id = p.id " +
                      "WHERE r.user_id = ? AND r.product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, productId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Review review = extractReviewFromResultSet(rs);

                    // If user name wasn't set in extractReviewFromResultSet, load user
                    if (review.getUserName() == null) {
                        User user = userDAO.getUserById(review.getUserId());
                        review.setUser(user);
                        if (user != null) {
                            review.setUserName(user.getFirstName() + " " + user.getLastName());
                        }
                    }

                    // If product name wasn't set in extractReviewFromResultSet, load product
                    if (review.getProductName() == null) {
                        Product product = productDAO.getProductById(review.getProductId());
                        review.setProduct(product);
                        if (product != null) {
                            review.setProductName(product.getName());
                        }
                    }

                    return review;
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting user review for product: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get average rating for a product
     * @param productId Product ID
     * @return Average rating (0-5)
     */
    public double getAverageRatingForProduct(int productId) {
        String query = "SELECT AVG(rating) FROM reviews WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, productId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting average rating: " + e.getMessage());
            e.printStackTrace();
        }

        return 0.0;
    }

    /**
     * Get review count for a product
     * @param productId Product ID
     * @return Number of reviews
     */
    public int getReviewCountForProduct(int productId) {
        String query = "SELECT COUNT(*) FROM reviews WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, productId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting review count: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get review count by user ID
     * @param userId User ID
     * @return Number of reviews by the user
     */
    public int getReviewCountByUserId(int userId) {
        String query = "SELECT COUNT(*) FROM reviews WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting review count by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Extract review from result set
     * @param rs Result set
     * @return Review object
     * @throws SQLException if error occurs
     */
    private Review extractReviewFromResultSet(ResultSet rs) throws SQLException {
        System.out.println("ReviewDAO: Extracting review from ResultSet");
        Review review = new Review();

        try {
            review.setId(rs.getInt("id"));
            System.out.println("ReviewDAO: Extracted review ID = " + review.getId());
        } catch (SQLException e) {
            System.out.println("ReviewDAO: Error getting id: " + e.getMessage());
        }

        try {
            review.setProductId(rs.getInt("product_id"));
        } catch (SQLException e) {
            System.out.println("Error getting product_id: " + e.getMessage());
        }

        try {
            review.setUserId(rs.getInt("user_id"));
        } catch (SQLException e) {
            System.out.println("Error getting user_id: " + e.getMessage());
        }

        try {
            review.setRating(rs.getInt("rating"));
        } catch (SQLException e) {
            System.out.println("Error getting rating: " + e.getMessage());
            review.setRating(0); // Default to 0 if rating is not available
        }

        try {
            review.setComment(rs.getString("comment"));
        } catch (SQLException e) {
            System.out.println("Error getting comment: " + e.getMessage());
            review.setComment(""); // Default to empty string if comment is not available
        }

        // Handle different date column names
        try {
            Timestamp reviewedDate = rs.getTimestamp("reviewed_date");
            review.setCreatedAt(reviewedDate);
            review.setReviewDate(reviewedDate); // Set both fields for compatibility
        } catch (SQLException e) {
            try {
                Timestamp createdAt = rs.getTimestamp("created_at");
                review.setCreatedAt(createdAt);
                review.setReviewDate(createdAt); // Set both fields for compatibility
            } catch (SQLException ex) {
                // If neither column exists, set current time
                Timestamp currentTime = new Timestamp(System.currentTimeMillis());
                review.setCreatedAt(currentTime);
                review.setReviewDate(currentTime); // Set both fields for compatibility
            }
        }

        // Try to get user name and profile image from result set
        try {
            String firstName = rs.getString("first_name");
            String lastName = rs.getString("last_name");
            String profileImage = rs.getString("profile_image");

            // Create a User object to store the user data
            User reviewUser = new User();
            reviewUser.setId(review.getUserId());
            reviewUser.setFirstName(firstName);
            reviewUser.setLastName(lastName);
            reviewUser.setProfileImage(profileImage);

            // Set the user object in the review
            review.setUser(reviewUser);

            if (firstName != null && lastName != null) {
                review.setUserName(firstName + " " + lastName);
            } else {
                review.setUserName("User #" + review.getUserId()); // Default user name
            }
        } catch (SQLException e) {
            // User name not available in result set, using default name
            review.setUserName("User #" + review.getUserId()); // Default user name
        }

        // Try to get product name from result set
        try {
            String productName = rs.getString("product_name");
            if (productName != null) {
                review.setProductName(productName);
            } else {
                review.setProductName("Product #" + review.getProductId()); // Default product name
            }
        } catch (SQLException e) {
            // Product name not available in result set, using default name
            review.setProductName("Product #" + review.getProductId()); // Default product name
        }

        return review;
    }
}
