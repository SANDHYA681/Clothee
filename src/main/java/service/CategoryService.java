package service;

import java.util.List;

import dao.CategoryDAO;
import model.Category;

/**
 * Service class for category-related operations
 */
public class CategoryService {
    private CategoryDAO categoryDAO;

    /**
     * Constructor
     */
    public CategoryService() {
        this.categoryDAO = new CategoryDAO();
    }

    /**
     * Add a new category
     * @param name Category name
     * @param description Category description
     * @return true if addition successful, false otherwise
     */
    public boolean addCategory(String name, String description) {
        // Check if category already exists
        if (categoryDAO.getCategoryByName(name) != null) {
            return false;
        }

        // Create category
        Category category = new Category();
        category.setName(name);
        category.setDescription(description);

        return categoryDAO.addCategory(category);
    }

    /**
     * Update an existing category
     * @param categoryId Category ID
     * @param name Category name
     * @param description Category description
     * @return true if update successful, false otherwise
     */
    public boolean updateCategory(int categoryId, String name, String description) {
        // Get category
        Category category = categoryDAO.getCategoryById(categoryId);

        if (category == null) {
            return false;
        }

        // Check if name is already used by another category
        Category existingCategory = categoryDAO.getCategoryByName(name);
        if (existingCategory != null && existingCategory.getId() != categoryId) {
            return false;
        }

        // Update category
        category.setName(name);
        category.setDescription(description);

        return categoryDAO.updateCategory(category);
    }

    /**
     * Delete a category
     * @param categoryId Category ID
     * @return true if deletion successful, false otherwise
     */
    public boolean deleteCategory(int categoryId) {
        return categoryDAO.deleteCategory(categoryId);
    }

    /**
     * Get category by ID
     * @param categoryId Category ID
     * @return Category object if found, null otherwise
     */
    public Category getCategoryById(int categoryId) {
        return categoryDAO.getCategoryById(categoryId);
    }

    /**
     * Get category by name
     * @param name Category name
     * @return Category object if found, null otherwise
     */
    public Category getCategoryByName(String name) {
        return categoryDAO.getCategoryByName(name);
    }

    /**
     * Get all categories
     * @return List of all categories
     */
    public List<Category> getAllCategories() {
        System.out.println("CategoryService - Getting all categories");
        List<Category> categories = categoryDAO.getAllCategories();
        System.out.println("CategoryService - Retrieved " + categories.size() + " categories");
        return categories;
    }
}
