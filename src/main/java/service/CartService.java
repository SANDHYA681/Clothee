package service;

import java.util.List;

import dao.CartDAO;
import dao.ProductDAO;
import model.Cart;
import model.CartItem;
import model.Product;

/**
 * Service class for cart-related operations
 */
public class CartService {
    private CartDAO cartDAO;
    private ProductDAO productDAO;

    // Static map to store shipping addresses by user ID
    private static java.util.Map<Integer, String> shippingAddresses = new java.util.HashMap<>();

    /**
     * Constructor
     */
    public CartService() {
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
    }

    /**
     * Get shipping address for a user
     * @param userId User ID
     * @return Shipping address or empty string if not found
     */
    public static String getShippingAddress(int userId) {
        return shippingAddresses.getOrDefault(userId, "");
    }

    /**
     * Get user's cart items
     * @param userId User ID
     * @return List of cart items
     */
    public List<CartItem> getUserCartItems(int userId) {
        return cartDAO.getCartItemsByUserId(userId);
    }

    /**
     * Add product to cart
     * @param userId User ID
     * @param productId Product ID
     * @param quantity Quantity
     * @return true if addition successful, false otherwise
     */
    public boolean addToCart(int userId, int productId, int quantity) {
        // Get product
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            return false;
        }

        // Check stock
        if (product.getStock() < quantity) {
            return false;
        }

        // Add to cart directly
        return cartDAO.addToCart(userId, productId, quantity);
    }

    /**
     * Update cart item quantity
     * @param cartItemId Cart item ID
     * @param quantity New quantity
     * @return true if update successful, false otherwise
     */
    public boolean updateCartItemQuantity(int cartItemId, int quantity) {
        // Get cart item directly
        CartItem cartItem = cartDAO.getCartItemById(cartItemId);

        if (cartItem == null) {
            return false;
        }

        // Check stock
        Product product = productDAO.getProductById(cartItem.getProductId());
        if (product.getStock() < quantity) {
            return false;
        }

        // Update quantity
        return cartDAO.updateCartItemQuantity(cartItemId, quantity);
    }

    /**
     * Remove item from cart
     * @param cartItemId Cart item ID
     * @return true if removal successful, false otherwise
     */
    public boolean removeFromCart(int cartItemId) {
        return cartDAO.removeFromCart(cartItemId);
    }

    /**
     * Clear cart for a user
     * @param userId User ID
     * @return true if clearing successful, false otherwise
     */
    public boolean clearCart(int userId) {
        return cartDAO.clearCart(userId);
    }

    /**
     * Get cart item count for a user
     * @param userId User ID
     * @return Number of items in cart
     */
    public int getCartItemCount(int userId) {
        return cartDAO.getCartItemCount(userId);
    }

    /**
     * Get total cart price for a user
     * @param userId User ID
     * @return Total price of all items in cart
     */
    public double getCartTotal(int userId) {
        return cartDAO.getCartTotal(userId);
    }

    /**
     * Get cart for a user
     * @param userId User ID
     * @return Cart object
     */
    public Cart getCart(int userId) {
        return cartDAO.getCartByUserId(userId);
    }

    /**
     * Get cart address for a user
     * Note: As per requirements, cart no longer stores address information
     * @param userId User ID
     * @return String containing the shipping address or empty string if not found
     */
    public String getCartAddress(int userId) {
        // Return the shipping address from the static map
        return shippingAddresses.getOrDefault(userId, "");
    }

    /**
     * Update cart address for a user
     * Note: We store this in a static map, not in the cart table
     * @param userId User ID
     * @param fullName Full name
     * @param country Country
     * @param phone Phone number
     * @return Always returns true as we store this in memory
     */
    public boolean updateCartAddress(Integer userId, String fullName, String country, String phone) {
        // Create a simple address string
        StringBuilder addressBuilder = new StringBuilder();
        if (fullName != null && !fullName.isEmpty()) {
            addressBuilder.append(fullName);
        }
        if (country != null && !country.isEmpty()) {
            if (addressBuilder.length() > 0) addressBuilder.append(", ");
            addressBuilder.append(country);
        }
        if (phone != null && !phone.isEmpty()) {
            if (addressBuilder.length() > 0) addressBuilder.append(", ");
            addressBuilder.append("Phone: ").append(phone);
        }

        // Store the shipping address in the static map
        shippingAddresses.put(userId, addressBuilder.toString());

        return true;
    }
}
