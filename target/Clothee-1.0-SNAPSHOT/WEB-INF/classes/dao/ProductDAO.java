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

        return product;
    }

    /**
     * Load additional images for a product
     * @param product Product to load images for
     */
    private void loadProductImages(Product product) {
        try {
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
}
