package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import model.Product;
import model.Wishlist;
import model.WishlistItem;
import util.DBConnection;

/**
 * Wishlist Data Access Object
 */
public class WishlistDAO {
    private ProductDAO productDAO;
    private CartDAO cartDAO;

    public WishlistDAO() {
        this.productDAO = new ProductDAO();
        this.cartDAO = new CartDAO();
    }

    /**
     * Get wishlist item count by user ID
     * @param userId User ID
     * @return Number of items in the user's wishlist
     */
    public int getWishlistItemCountByUserId(int userId) {
        String query = "SELECT COUNT(*) FROM wishlist WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting wishlist item count by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get wishlist by user ID
     * @param userId User ID
     * @return Wishlist object if found, null otherwise
     */
    public Wishlist getWishlistByUserId(int userId) {
        String query = "SELECT * FROM wishlists WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Wishlist wishlist = extractWishlistFromResultSet(rs);

                    // Load wishlist items
                    List<WishlistItem> items = getWishlistItemsByWishlistId(wishlist.getId());
                    wishlist.setItems(items);

                    return wishlist;
                } else {
                    // Create a new wishlist for the user
                    return createWishlist(userId);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting wishlist by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Create a new wishlist for a user
     * @param userId User ID
     * @return Wishlist object if successful, null otherwise
     */
    private Wishlist createWishlist(int userId) {
        String query = "INSERT INTO wishlists (user_id) VALUES (?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, userId);

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        Wishlist wishlist = new Wishlist();
                        wishlist.setId(rs.getInt(1));
                        wishlist.setUserId(userId);
                        wishlist.setItems(new ArrayList<>());
                        return wishlist;
                    }
                }
            }

        } catch (SQLException e) {
            System.out.println("Error creating wishlist: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get wishlist items by wishlist ID
     * @param wishlistId Wishlist ID
     * @return List of wishlist items
     */
    private List<WishlistItem> getWishlistItemsByWishlistId(int wishlistId) {
        List<WishlistItem> items = new ArrayList<>();
        String query = "SELECT * FROM wishlist_items WHERE wishlist_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, wishlistId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    WishlistItem item = extractWishlistItemFromResultSet(rs);

                    // Get product details
                    Product product = productDAO.getProductById(item.getProductId());
                    item.setProduct(product);

                    items.add(item);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting wishlist items: " + e.getMessage());
            e.printStackTrace();
        }

        return items;
    }

    /**
     * Extract wishlist from result set
     * @param rs Result set
     * @return Wishlist object
     * @throws SQLException If an error occurs
     */
    private Wishlist extractWishlistFromResultSet(ResultSet rs) throws SQLException {
        Wishlist wishlist = new Wishlist();
        wishlist.setId(rs.getInt("id"));
        wishlist.setUserId(rs.getInt("user_id"));
        return wishlist;
    }

    /**
     * Extract wishlist item from result set
     * @param rs Result set
     * @return WishlistItem object
     * @throws SQLException If an error occurs
     */
    private WishlistItem extractWishlistItemFromResultSet(ResultSet rs) throws SQLException {
        WishlistItem item = new WishlistItem();
        item.setId(rs.getInt("id"));
        item.setWishlistId(rs.getInt("wishlist_id"));
        item.setProductId(rs.getInt("product_id"));
        return item;
    }

    /**
     * Add product to wishlist
     * @param userId User ID
     * @param productId Product ID
     * @return true if successful, false otherwise
     */
    public boolean addToWishlist(int userId, int productId) {
        // First check if we need to create a wishlist for the user
        Wishlist wishlist = getWishlistByUserId(userId);

        if (wishlist == null) {
            return false;
        }

        // Check if product already exists in wishlist
        if (isProductInWishlist(userId, productId)) {
            return true; // Product already in wishlist
        }

        String query = "INSERT INTO wishlist (user_id, product_id, added_date) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            Timestamp now = new Timestamp(new Date().getTime());

            stmt.setInt(1, userId);
            stmt.setInt(2, productId);
            stmt.setTimestamp(3, now);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error adding to wishlist: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if product is in wishlist
     * @param userId User ID
     * @param productId Product ID
     * @return true if product is in wishlist, false otherwise
     */
    public boolean isProductInWishlist(int userId, int productId) {
        String query = "SELECT COUNT(*) FROM wishlist WHERE user_id = ? AND product_id = ?";

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
            System.out.println("Error checking if product is in wishlist: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Remove product from wishlist
     * @param wishlistItemId Wishlist item ID
     * @return true if successful, false otherwise
     */
    public boolean removeFromWishlist(int wishlistItemId) {
        String query = "DELETE FROM wishlist WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, wishlistItemId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error removing from wishlist: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get wishlist items for a user
     * @param userId User ID
     * @return List of wishlist items
     */
    public List<WishlistItem> getWishlistItems(int userId) {
        List<WishlistItem> items = new ArrayList<>();
        String query = "SELECT w.*, p.* FROM wishlist w JOIN products p ON w.product_id = p.id WHERE w.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    WishlistItem item = new WishlistItem();
                    item.setId(rs.getInt("id"));
                    item.setUserId(rs.getInt("user_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setAddedDate(rs.getTimestamp("added_date"));

                    // Create product
                    Product product = new Product();
                    product.setId(rs.getInt("product_id"));
                    product.setName(rs.getString("name"));
                    product.setDescription(rs.getString("description"));
                    product.setPrice(rs.getDouble("price"));
                    product.setImageUrl(rs.getString("image_url"));
                    product.setCategory(rs.getString("category"));
                    product.setStock(rs.getInt("stock"));
                    product.setFeatured(rs.getBoolean("featured"));

                    item.setProduct(product);

                    items.add(item);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting wishlist items: " + e.getMessage());
            e.printStackTrace();
        }

        return items;
    }

    /**
     * Clear wishlist for a user
     * @param userId User ID
     * @return true if successful, false otherwise
     */
    public boolean clearWishlist(int userId) {
        String query = "DELETE FROM wishlist WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            int rowsAffected = stmt.executeUpdate();
            return true; // Return true even if no items were in the wishlist

        } catch (SQLException e) {
            System.out.println("Error clearing wishlist: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Move product from wishlist to cart
     * @param wishlistItemId Wishlist item ID
     * @param userId User ID
     * @return true if successful, false otherwise
     */
    public boolean moveToCart(int wishlistItemId, int userId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Get product ID from wishlist item
            String getProductQuery = "SELECT product_id FROM wishlist WHERE id = ?";
            int productId = 0;

            try (PreparedStatement stmt = conn.prepareStatement(getProductQuery)) {
                stmt.setInt(1, wishlistItemId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        productId = rs.getInt("product_id");
                    } else {
                        conn.rollback();
                        return false; // Wishlist item not found
                    }
                }
            }

            // Add product to cart
            boolean addedToCart = cartDAO.addToCart(userId, productId, 1);

            if (!addedToCart) {
                conn.rollback();
                return false;
            }

            // Remove from wishlist
            String removeQuery = "DELETE FROM wishlist WHERE id = ?";

            try (PreparedStatement stmt = conn.prepareStatement(removeQuery)) {
                stmt.setInt(1, wishlistItemId);

                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected == 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            System.out.println("Error moving product to cart: " + e.getMessage());
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                System.out.println("Error rolling back transaction: " + ex.getMessage());
            }

            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.out.println("Error closing connection: " + e.getMessage());
            }
        }
    }
}
