package model;

import java.sql.Timestamp;

/**
 * WishlistItem model class
 */
public class WishlistItem {
    private int id;
    private int wishlistId;
    private int userId;
    private int productId;
    private Timestamp addedDate;
    private Product product;

    public WishlistItem() {
    }

    public WishlistItem(int id, int wishlistId, int userId, int productId, Timestamp addedDate) {
        this.id = id;
        this.wishlistId = wishlistId;
        this.userId = userId;
        this.productId = productId;
        this.addedDate = addedDate;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getWishlistId() {
        return wishlistId;
    }

    public void setWishlistId(int wishlistId) {
        this.wishlistId = wishlistId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Timestamp getAddedDate() {
        return addedDate;
    }

    public void setAddedDate(Timestamp addedDate) {
        this.addedDate = addedDate;
    }
}
