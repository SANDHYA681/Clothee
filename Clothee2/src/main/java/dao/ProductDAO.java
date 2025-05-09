package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Product;
import util.DBConnection;

/**
 * Product Data Access Object
 */
public class ProductDAO {

    /**
     * Get the total count of products
     * @return Total number of products
     */
    public int getProductCount() {
        String query = "SELECT COUNT(*) FROM products";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get total product count for dashboard
     * @return Total number of products
     */
    public int getTotalProductCount() {
        return getProductCount();
    }

    /**
     * Add a new product to the database
     * @param product Product object to add
     * @return true if successful, false otherwise
     */
    public boolean addProduct(Product product) {
        String query = "INSERT INTO products (name, description, price, stock, category, type, image_url, featured) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        System.out.println("ProductDAO - Adding product: " + product.getName());
        System.out.println("ProductDAO - Featured flag: " + product.isFeatured());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setDouble(3, product.getPrice());
            stmt.setInt(4, product.getStock());
            stmt.setString(5, product.getCategory());
            stmt.setString(6, product.getType());
            stmt.setString(7, product.getImageUrl());
            stmt.setBoolean(8, product.isFeatured());

            System.out.println("ProductDAO - Executing insert query with featured = " + product.isFeatured());
            int rowsAffected = stmt.executeUpdate();
            System.out.println("ProductDAO - Insert affected " + rowsAffected + " rows");

            if (rowsAffected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        int newId = rs.getInt(1);
                        product.setId(newId);
                        System.out.println("ProductDAO - Product added with ID: " + newId + ", Featured: " + product.isFeatured());
                        return true;
                    }
                }
            }

            return false;

        } catch (SQLException e) {
            System.out.println("ProductDAO - Error adding product: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update an existing product
     * @param product Product object to update
     * @return true if successful, false otherwise
     */
    public boolean updateProduct(Product product) {
        String query = "UPDATE products SET name = ?, description = ?, price = ?, stock = ?, " +
                       "category = ?, type = ?, image_url = ?, featured = ?, updated_at = CURRENT_TIMESTAMP " +
                       "WHERE id = ?";

        System.out.println("ProductDAO - Updating product: " + product.getName() + " (ID: " + product.getId() + ")");
        System.out.println("ProductDAO - Featured flag: " + product.isFeatured());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setDouble(3, product.getPrice());
            stmt.setInt(4, product.getStock());
            stmt.setString(5, product.getCategory());
            stmt.setString(6, product.getType());
            stmt.setString(7, product.getImageUrl());
            stmt.setBoolean(8, product.isFeatured());
            stmt.setInt(9, product.getId());

            System.out.println("ProductDAO - Executing update query for product ID: " + product.getId() + " with featured = " + product.isFeatured());
            int rowsAffected = stmt.executeUpdate();
            System.out.println("ProductDAO - Update affected " + rowsAffected + " rows");

            // Verify the update by retrieving the product again
            if (rowsAffected > 0) {
                Product updatedProduct = getProductById(product.getId());
                if (updatedProduct != null) {
                    System.out.println("ProductDAO - Verified update: Product ID " + updatedProduct.getId() +
                                     " featured flag is now " + updatedProduct.isFeatured());
                }
            }

            return rowsAffected > 0;

        } catch (SQLException e) {
            System.out.println("ProductDAO - Error updating product: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // This method has been moved to the end of the file

    /**
     * Get product by ID
     * @param productId Product ID
     * @return Product object if found, null otherwise
     */
    public Product getProductById(int productId) {
        // First check if the products table exists
        try (Connection conn = DBConnection.getConnection()) {
            try {
                java.sql.DatabaseMetaData dbm = conn.getMetaData();
                java.sql.ResultSet tables = dbm.getTables(null, null, "products", null);
                if (!tables.next()) {
                    System.out.println("Warning: products table does not exist");
                    return null;
                }
            } catch (SQLException e) {
                System.out.println("Error checking if products table exists: " + e.getMessage());
                e.printStackTrace();
                return null;
            }

            String query = "SELECT * FROM products WHERE id = ?";

            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, productId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        try {
                            Product product = extractProductFromResultSet(rs);

                            // Try to load additional images
                            try {
                                loadProductImages(product);
                            } catch (Exception e) {
                                System.out.println("Warning: Could not load product images: " + e.getMessage());
                                // Continue without additional images
                            }

                            return product;
                        } catch (Exception e) {
                            System.out.println("Error extracting product from result set: " + e.getMessage());
                            e.printStackTrace();
                        }
                    }
                }
            } catch (SQLException e) {
                System.out.println("Error getting product by ID: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (SQLException e) {
            System.out.println("Error connecting to database: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all products
     * @return List of all products
     */
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products ORDER BY id";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                products.add(extractProductFromResultSet(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    /**
     * Get featured products
     * @param limit Number of products to return
     * @return List of featured products
     */
    public List<Product> getFeaturedProducts(int limit) {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products WHERE featured = TRUE ORDER BY id LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(extractProductFromResultSet(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    /**
     * Get all featured products
     * @return List of all featured products
     */
    public List<Product> getFeaturedProducts() {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products WHERE featured = TRUE ORDER BY id";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                products.add(extractProductFromResultSet(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    /**
     * Get out of stock products
     * @return List of products with stock = 0
     */
    public List<Product> getOutOfStockProducts() {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products WHERE stock = 0 ORDER BY id";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                products.add(extractProductFromResultSet(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    /**
     * Get recent products
     * @param limit Number of products to return
     * @return List of recent products
     */
    public List<Product> getRecentProducts(int limit) {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products ORDER BY created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(extractProductFromResultSet(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    /**
     * Get products by category
     * @param category Category to filter by
     * @return List of products in the specified category
     */
    public List<Product> getProductsByCategory(String category) {
        List<Product> products = new ArrayList<>();
        String query;

        // If category is "All", get all products
        if (category == null || category.isEmpty() || "All".equalsIgnoreCase(category)) {
            query = "SELECT * FROM products ORDER BY id";

            try (Connection conn = DBConnection.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(query)) {

                while (rs.next()) {
                    products.add(extractProductFromResultSet(rs));
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            query = "SELECT * FROM products WHERE category = ? ORDER BY id";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {

                stmt.setString(1, category);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        products.add(extractProductFromResultSet(rs));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return products;
    }

    /**
     * Get products by category and type
     * @param category Category to filter by
     * @param type Type to filter by
     * @return List of products in the specified category and type
     */
    public List<Product> getProductsByCategoryAndType(String category, String type) {
        List<Product> products = new ArrayList<>();
        String query;

        // Handle different combinations of category and type
        if ((category == null || category.isEmpty() || "All".equalsIgnoreCase(category)) &&
            (type == null || type.isEmpty() || "All".equalsIgnoreCase(type))) {
            // Both category and type are "All"
            query = "SELECT * FROM products ORDER BY id";

            try (Connection conn = DBConnection.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(query)) {

                while (rs.next()) {
                    products.add(extractProductFromResultSet(rs));
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if (category == null || category.isEmpty() || "All".equalsIgnoreCase(category)) {
            // Only category is "All"
            query = "SELECT * FROM products WHERE type = ? ORDER BY id";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {

                stmt.setString(1, type);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        products.add(extractProductFromResultSet(rs));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if (type == null || type.isEmpty() || "All".equalsIgnoreCase(type)) {
            // Only type is "All"
            query = "SELECT * FROM products WHERE category = ? ORDER BY id";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {

                stmt.setString(1, category);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        products.add(extractProductFromResultSet(rs));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            // Both category and type are specified
            query = "SELECT * FROM products WHERE category = ? AND type = ? ORDER BY id";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {

                stmt.setString(1, category);
                stmt.setString(2, type);

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        products.add(extractProductFromResultSet(rs));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return products;
    }

    /**
     * Search products by name or description
     * @param keyword Keyword to search for
     * @return List of products matching the search criteria
     */
    public List<Product> searchProducts(String keyword) {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM products WHERE name LIKE ? OR description LIKE ? ORDER BY id";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            String searchTerm = "%" + keyword + "%";
            stmt.setString(1, searchTerm);
            stmt.setString(2, searchTerm);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(extractProductFromResultSet(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    /**
     * Helper method to extract product from result set
     * @param rs Result set
     * @return Product object
     * @throws SQLException if error occurs
     */
    private Product extractProductFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();

        try {
            product.setId(rs.getInt("id"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'id' column: " + e.getMessage());
        }

        try {
            product.setName(rs.getString("name"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'name' column: " + e.getMessage());
            product.setName("Unknown Product");
        }

        try {
            product.setDescription(rs.getString("description"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'description' column: " + e.getMessage());
            product.setDescription("No description available");
        }

        try {
            product.setPrice(rs.getDouble("price"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'price' column: " + e.getMessage());
            product.setPrice(0.0);
        }

        try {
            product.setStock(rs.getInt("stock"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'stock' column: " + e.getMessage());
            product.setStock(0);
        }

        try {
            product.setCategory(rs.getString("category"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'category' column: " + e.getMessage());
            product.setCategory("Uncategorized");
        }

        try {
            product.setType(rs.getString("type"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'type' column: " + e.getMessage());
            product.setType("Unknown");
        }

        try {
            product.setImageUrl(rs.getString("image_url"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'image_url' column: " + e.getMessage());
            product.setImageUrl("images/product-placeholder.jpg");
        }

        try {
            product.setFeatured(rs.getBoolean("featured"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'featured' column: " + e.getMessage());
            product.setFeatured(false);
        }

        try {
            product.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'created_at' column: " + e.getMessage());
            product.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
        }

        try {
            product.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (SQLException e) {
            System.out.println("Warning: Could not get 'updated_at' column: " + e.getMessage());
            product.setUpdatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
        }

        return product;
    }

    /**
     * Update product image URL
     * @param productId Product ID
     * @param imageUrl New image URL
     * @return true if successful, false otherwise
     */
    public boolean updateProductImage(int productId, String imageUrl) {
        String query = "UPDATE products SET image_url = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, imageUrl);
            stmt.setInt(2, productId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Load additional images for a product
     * @param product Product to load images for
     */
    private void loadProductImages(Product product) {
        try {
            // In this implementation, we don't have a separate product_images table
            // The main image is stored in the products table's image_url column
            // For now, we'll just use the main image as the only image
            // This method can be expanded later if you add a product_images table

            // Add the main image as the only image if it exists
            String imageUrl = product.getImageUrl();
            if (imageUrl != null && !imageUrl.isEmpty()) {
                product.addAdditionalImage(imageUrl);
            }
        } catch (Exception e) {
            System.out.println("Error in loadProductImages: " + e.getMessage());
            e.printStackTrace();
            // Continue without additional images
        }
    }

    /**
     * Delete a product by ID
     * @param productId Product ID to delete
     * @return true if successful, false otherwise
     * @throws SQLException if a database error occurs
     */
    public boolean deleteProduct(int productId) throws SQLException {
        System.out.println("ProductDAO - Attempting to delete product with ID: " + productId);

        // First check if the product exists
        String checkProductQuery = "SELECT COUNT(*) FROM products WHERE id = ?";

        // Then check if the product is referenced in order_items
        String checkOrderItemsQuery = "SELECT COUNT(*) FROM order_items WHERE product_id = ?";

        // Delete the product
        String deleteProductQuery = "DELETE FROM products WHERE id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // First check if the product exists
            try (PreparedStatement checkProductStmt = conn.prepareStatement(checkProductQuery)) {
                checkProductStmt.setInt(1, productId);
                System.out.println("ProductDAO - Checking if product exists");

                try (ResultSet rs = checkProductStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        System.out.println("ProductDAO - Product with ID " + productId + " does not exist");
                        return false;
                    }
                }
            }

            // Check if product is referenced in order_items
            try (PreparedStatement checkStmt = conn.prepareStatement(checkOrderItemsQuery)) {
                checkStmt.setInt(1, productId);
                System.out.println("ProductDAO - Checking if product is referenced in order_items");

                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        // Product is referenced in order_items, cannot delete
                        int count = rs.getInt(1);
                        System.out.println("ProductDAO - Cannot delete product with ID " + productId +
                                          " because it is referenced in " + count + " order items");
                        conn.rollback();
                        return false;
                    }
                    System.out.println("ProductDAO - Product is not referenced in any orders, proceeding with deletion");
                }
            }

            // If we get here, the product is not referenced in order_items, so we can delete it
            try (PreparedStatement deleteStmt = conn.prepareStatement(deleteProductQuery)) {
                deleteStmt.setInt(1, productId);
                System.out.println("ProductDAO - Executing delete query");
                int rowsAffected = deleteStmt.executeUpdate();
                System.out.println("ProductDAO - Delete affected " + rowsAffected + " rows");

                if (rowsAffected > 0) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            }
        } catch (SQLException e) {
            System.out.println("ProductDAO - Error deleting product: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.out.println("ProductDAO - Error rolling back transaction: " + ex.getMessage());
                }
            }
            throw e; // Rethrow to be handled by the service/controller
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("ProductDAO - Error closing connection: " + e.getMessage());
                }
            }
        }
    }
}
