package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Category;
import util.DBConnection;

/**
 * Category Data Access Object
 */
public class CategoryDAO {

    /**
     * Add a new category to the database
     * @param category Category object to add
     * @return true if successful, false otherwise
     */
    public boolean addCategory(Category category) {
        System.out.println("===== ADDING CATEGORY =====");
        System.out.println("Category name: " + category.getName());
        System.out.println("Category description: " + category.getDescription());
        System.out.println("Category imageUrl: " + category.getImageUrl());

        // First check if a category with this name already exists
        if (categoryExists(category.getName())) {
            System.out.println("Category already exists: " + category.getName());
            return false;
        }

        // Try a simpler query without the image_url field
        String query = "INSERT INTO categories (name, description) VALUES (?, ?)";

        try {
            System.out.println("Getting database connection...");
            Connection conn = DBConnection.getConnection();
            System.out.println("Connection obtained: " + (conn != null));

            System.out.println("Preparing statement: " + query);
            PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);

            try {
                stmt.setString(1, category.getName());
                stmt.setString(2, category.getDescription());

                System.out.println("Executing update...");
                int rowsAffected = stmt.executeUpdate();
                System.out.println("Rows affected: " + rowsAffected);

                if (rowsAffected > 0) {
                    System.out.println("Getting generated keys...");
                    ResultSet rs = stmt.getGeneratedKeys();
                    try {
                        if (rs.next()) {
                            int id = rs.getInt(1);
                            System.out.println("Generated ID: " + id);
                            category.setId(id);
                            return true;
                        } else {
                            System.out.println("No generated keys returned");
                        }
                    } finally {
                        if (rs != null) {
                            rs.close();
                        }
                    }
                }

                return false;
            } finally {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            }
        } catch (SQLException e) {
            System.out.println("SQL Error in addCategory: " + e.getMessage());
            System.out.println("SQL State: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update an existing category
     * @param category Category object to update
     * @return true if successful, false otherwise
     */
    public boolean updateCategory(Category category) {
        String query = "UPDATE categories SET name = ?, description = ?, image_url = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, category.getName());
            stmt.setString(2, category.getDescription());
            // Handle null imageUrl
            if (category.getImageUrl() == null) {
                stmt.setNull(3, java.sql.Types.VARCHAR);
            } else {
                stmt.setString(3, category.getImageUrl());
            }
            stmt.setInt(4, category.getId());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error updating category: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update category image URL
     * @param categoryId Category ID
     * @param imageUrl Image URL
     * @return true if successful, false otherwise
     */
    public boolean updateCategoryImage(int categoryId, String imageUrl) {
        String query = "UPDATE categories SET image_url = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            if (imageUrl == null) {
                stmt.setNull(1, java.sql.Types.VARCHAR);
            } else {
                stmt.setString(1, imageUrl);
            }
            stmt.setInt(2, categoryId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete a category
     * @param categoryId Category ID to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteCategory(int categoryId) {
        String query = "DELETE FROM categories WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, categoryId);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get category by ID
     * @param categoryId Category ID
     * @return Category object if found, null otherwise
     */
    public Category getCategoryById(int categoryId) {
        String query = "SELECT * FROM categories WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, categoryId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractCategoryFromResultSet(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get category by name
     * @param name Category name
     * @return Category object if found, null otherwise
     */
    public Category getCategoryByName(String name) {
        String query = "SELECT * FROM categories WHERE name = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, name);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractCategoryFromResultSet(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all categories
     * @return List of all categories
     */
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();

        // Simplified query to ensure we get all categories regardless of products
        String query = "SELECT * FROM categories ORDER BY name";

        System.out.println("Executing getAllCategories query: " + query);

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            int count = 0;
            while (rs.next()) {
                count++;
                Category category = extractCategoryFromResultSet(rs);
                // Set product count to 0 by default
                category.setProductCount(0);
                categories.add(category);
                System.out.println("Found category: " + category.getName());
            }

            System.out.println("Total categories found: " + count);

            // Now get product counts in a separate query
            if (!categories.isEmpty()) {
                String countQuery = "SELECT category, COUNT(*) as count FROM products GROUP BY category";
                try (Statement countStmt = conn.createStatement();
                     ResultSet countRs = countStmt.executeQuery(countQuery)) {

                    while (countRs.next()) {
                        String categoryName = countRs.getString("category");
                        int productCount = countRs.getInt("count");

                        // Update the product count for the matching category
                        for (Category category : categories) {
                            if (category.getName().equals(categoryName)) {
                                category.setProductCount(productCount);
                                break;
                            }
                        }
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("Error in getAllCategories: " + e.getMessage());
            e.printStackTrace();
        }

        return categories;
    }

    /**
     * Helper method to extract category from result set
     * @param rs Result set
     * @return Category object
     * @throws SQLException if error occurs
     */
    private Category extractCategoryFromResultSet(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setId(rs.getInt("id"));
        category.setName(rs.getString("name"));
        category.setDescription(rs.getString("description"));
        category.setImageUrl(rs.getString("image_url"));
        category.setCreatedAt(rs.getTimestamp("created_at"));
        return category;
    }

    /**
     * Get total category count for dashboard
     * @return Total number of categories
     */
    public int getTotalCategoryCount() {
        String query = "SELECT COUNT(*) FROM categories";

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
     * Check if a category with the given name already exists
     * @param name Category name to check
     * @return true if a category with this name exists, false otherwise
     */
    public boolean categoryExists(String name) {
        String query = "SELECT COUNT(*) FROM categories WHERE name = ?";
        System.out.println("Checking if category exists: " + name);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, name);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("Found " + count + " categories with name: " + name);
                    return count > 0;
                }
            }

            System.out.println("No results found for category: " + name);
            return false;

        } catch (SQLException e) {
            System.out.println("SQL Error in categoryExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
