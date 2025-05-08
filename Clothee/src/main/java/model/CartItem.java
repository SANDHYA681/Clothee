package model;

/**
 * Cart Item model class
 */
public class CartItem {
    private int id;
    private int cartId;
    private int productId;
    private int quantity;
    private Product product; // Reference to the product

    // Default constructor
    public CartItem() {
    }

    // Constructor with fields
    public CartItem(int id, int cartId, int productId, int quantity) {
        this.id = id;
        this.cartId = cartId;
        this.productId = productId;
        this.quantity = quantity;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    /**
     * Calculate the subtotal for this cart item
     * @return The subtotal (price * quantity)
     */
    public double getSubtotal() {
        if (product != null) {
            return product.getPrice() * quantity;
        }
        return 0.0;
    }

    @Override
    public String toString() {
        return "CartItem{" +
                "id=" + id +
                ", cartId=" + cartId +
                ", productId=" + productId +
                ", quantity=" + quantity +
                ", product=" + (product != null ? product.getName() : "null") +
                ", subtotal=" + getSubtotal() +
                '}';
    }
}
