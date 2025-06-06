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

import model.Cart;
import model.CartItem;
import model.Product;
import util.DBConnection;

/**
 * Cart Data Access Object
 * Updated to work with the cart table from clothee.sql
 */
public class CartDAO {
    private ProductDAO productDAO;

    public CartDAO() {
        this.productDAO = new ProductDAO();
    }

    /**
     * Add item to cart directly using the cart table from clothee.sql
     *
     * @param userId    User ID
     * @param productId Product ID
     * @param quantity  Quantity
     * @return true if successful, false otherwise
     */
    public boolean addToCart(int userId, int productId, int quantity) {
        // First check if the product already exists in the cart
        CartItem existingItem = getCartItemByUserAndProductId(userId, productId);

        if (existingItem != null) {
            // Product already exists in cart, update quantity
            int newQuantity = existingItem.getQuantity() + quantity;
            return updateCartItemQuantity(existingItem.getId(), newQuantity);
        }

        // Product doesn't exist in cart, add it
        String query = "INSERT INTO cart (user_id, product_id, quantity, added_date) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            Timestamp now = new Timestamp(new Date().getTime());

            stmt.setInt(1, userId);
            stmt.setInt(2, productId);
            stmt.setInt(3, quantity);
            stmt.setTimestamp(4, now);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error adding to cart: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get cart items by user ID
     *
     * @param userId User ID
     * @return List of cart items
     */
    public List<CartItem> getCartItemsByUserId(int userId) {
        List<CartItem> items = new ArrayList<>();
        String query = "SELECT c.*, p.* FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getInt("id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));

                    // Get product details directly from the join
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
            System.out.println("Error getting cart items by user ID: " + e.getMessage());
            e.printStackTrace();
        }

        return items;
    }

    /**
     * Get cart item by ID
     *
     * @param cartItemId Cart item ID
     * @return CartItem object if found, null otherwise
     */
    public CartItem getCartItemById(int cartItemId) {
        String query = "SELECT c.*, p.* FROM cart c JOIN products p ON c.product_id = p.id WHERE c.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, cartItemId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getInt("id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));

                    // Get product details directly from the join
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

                    return item;
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting cart item by ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Update cart item quantity
     *
     * @param cartItemId Cart item ID
     * @param quantity   New quantity
     * @return true if successful, false otherwise
     */
    public boolean updateCartItemQuantity(int cartItemId, int quantity) {
        String query = "UPDATE cart SET quantity = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, quantity);
            stmt.setInt(2, cartItemId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error updating cart item quantity: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Check if product exists in user's cart
     *
     * @param userId    User ID
     * @param productId Product ID
     * @return CartItem if found, null otherwise
     */
    public CartItem getCartItemByUserAndProductId(int userId, int productId) {
        String query = "SELECT c.*, p.* FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id = ? AND c.product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, productId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getInt("id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));

                    // Get product details directly from the join
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

                    return item;
                }
            }

        } catch (SQLException e) {
            System.out.println("Error checking if product exists in cart: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Remove item from cart
     *
     * @param cartItemId Cart item ID
     * @return true if successful, false otherwise
     */
    public boolean removeFromCart(int cartItemId) {
        String query = "DELETE FROM cart WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, cartItemId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("Error removing item from cart: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Clear cart for a user
     *
     * @param userId User ID
     * @return true if successful, false otherwise
     */
    public boolean clearCart(int userId) {
        String query = "DELETE FROM cart WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            int rowsAffected = stmt.executeUpdate();
            return true; // Return true even if no items were in the cart

        } catch (SQLException e) {
            System.out.println("Error clearing cart: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get cart count for a user
     *
     * @param userId User ID
     * @return Number of items in cart
     */
    public int getCartItemCount(int userId) {
        String query = "SELECT SUM(quantity) FROM cart WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.out.println("Error getting cart count: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get total cart price for a user
     *
     * @param userId User ID
     * @return Total price of all items in cart
     */
    public double getCartTotal(int userId) {
        String query = "SELECT c.quantity, p.price FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                double total = 0.0;
                while (rs.next()) {
                    int quantity = rs.getInt("quantity");
                    double price = rs.getDouble("price");
                    total += quantity * price;
                }
                return total;
            }

        } catch (SQLException e) {
            System.out.println("Error calculating cart total: " + e.getMessage());
            e.printStackTrace();
        }

        return 0.0;
    }


    /**
     * Get cart object for a user
     *
     * @param userId User ID
     * @return Cart object
     */
    public Cart getCartByUserId(int userId) {
        // Create a default cart object
        Cart cart = new Cart();
        cart.setUserId(userId);

        // Set cart items
        cart.setItems(getCartItemsByUserId(userId));

        return cart;
    }
}
