package model;

import java.util.List;

/**
 * Wishlist model class
 */
public class Wishlist {
    private int id;
    private int userId;
    private List<WishlistItem> items;

    public Wishlist() {
    }

    public Wishlist(int id, int userId, List<WishlistItem> items) {
        this.id = id;
        this.userId = userId;
        this.items = items;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public List<WishlistItem> getItems() {
        return items;
    }

    public void setItems(List<WishlistItem> items) {
        this.items = items;
    }
}
