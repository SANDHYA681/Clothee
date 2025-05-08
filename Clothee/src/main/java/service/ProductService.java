package service;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import dao.ProductDAO;
import model.Product;

/**
 * Service class for product-related operations
 */
public class ProductService {
    private ProductDAO productDAO;

    /**
     * Constructor
     */
    public ProductService() {
        this.productDAO = new ProductDAO();
    }

    /**
     * Add a new product
     * @param name Product name
     * @param description Product description
     * @param price Product price
     * @param stock Product stock
     * @param category Product category
     * @param type Product type
     * @param imageUrl Product image URL
     * @param featured Whether the product is featured
     * @return Product object if addition successful, null otherwise
     */
    public Product addProduct(String name, String description, double price, int stock,
                             String category, String type, String imageUrl, boolean featured) {
        Product product = new Product();
        product.setName(name);
        product.setDescription(description);
        product.setPrice(price);
        product.setStock(stock);
        product.setCategory(category);
        product.setType(type);
        product.setImageUrl(imageUrl);
        product.setFeatured(featured);
        product.setCreatedAt(new Timestamp(new Date().getTime()));
        product.setUpdatedAt(new Timestamp(new Date().getTime()));

        boolean success = productDAO.addProduct(product);

        if (success) {
            return product; // The ID is set by the DAO
        } else {
            return null;
        }
    }

    /**
     * Add a new product
     * @param product Product object to add
     * @return true if addition successful, false otherwise
     */
    public boolean addProduct(Product product) {
        // Set timestamps if not already set
        if (product.getCreatedAt() == null) {
            product.setCreatedAt(new Timestamp(new Date().getTime()));
        }
        if (product.getUpdatedAt() == null) {
            product.setUpdatedAt(new Timestamp(new Date().getTime()));
        }

        return productDAO.addProduct(product);
    }

    /**
     * Update an existing product
     * @param productId Product ID
     * @param name Product name
     * @param description Product description
     * @param price Product price
     * @param stock Product stock
     * @param category Product category
     * @param type Product type
     * @param imageUrl Product image URL
     * @param featured Whether the product is featured
     * @return true if update successful, false otherwise
     */
    public boolean updateProduct(int productId, String name, String description, double price, int stock,
                                String category, String type, String imageUrl, boolean featured) {
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            return false;
        }

        product.setName(name);
        product.setDescription(description);
        product.setPrice(price);
        product.setStock(stock);
        product.setCategory(category);
        product.setType(type);
        product.setImageUrl(imageUrl);
        product.setFeatured(featured);
        product.setUpdatedAt(new Timestamp(new Date().getTime()));

        return productDAO.updateProduct(product);
    }

    /**
     * Update an existing product
     * @param product Product object to update
     * @return true if update successful, false otherwise
     */
    public boolean updateProduct(Product product) {
        // Set updated timestamp if not already set
        if (product.getUpdatedAt() == null) {
            product.setUpdatedAt(new Timestamp(new Date().getTime()));
        }

        return productDAO.updateProduct(product);
    }

    /**
     * Delete a product
     * @param productId Product ID
     * @return true if deletion successful, false otherwise
     */
    public boolean deleteProduct(int productId) {
        try {
            System.out.println("ProductService - Attempting to delete product with ID: " + productId);
            boolean result = productDAO.deleteProduct(productId);
            System.out.println("ProductService - Delete result: " + (result ? "Success" : "Failed"));
            return result;
        } catch (Exception e) {
            System.out.println("ProductService - Error deleting product: " + e.getMessage());
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
        return productDAO.getProductById(productId);
    }

    /**
     * Get all products
     * @return List of all products
     */
    public List<Product> getAllProducts() {
        return productDAO.getAllProducts();
    }

    /**
     * Get featured products
     * @param limit Number of products to return
     * @return List of featured products
     */
    public List<Product> getFeaturedProducts(int limit) {
        return productDAO.getFeaturedProducts(limit);
    }

    /**
     * Get all featured products
     * @return List of all featured products
     */
    public List<Product> getFeaturedProducts() {
        return productDAO.getFeaturedProducts();
    }

    /**
     * Get out of stock products
     * @return List of products with stock = 0
     */
    public List<Product> getOutOfStockProducts() {
        return productDAO.getOutOfStockProducts();
    }

    /**
     * Get recent products
     * @param limit Number of products to return
     * @return List of recent products
     */
    public List<Product> getRecentProducts(int limit) {
        return productDAO.getRecentProducts(limit);
    }

    /**
     * Get products by category
     * @param category Category
     * @return List of products in the specified category
     */
    public List<Product> getProductsByCategory(String category) {
        return productDAO.getProductsByCategory(category);
    }

    /**
     * Get products by category and type
     * @param category Category
     * @param type Type
     * @return List of products in the specified category and type
     */
    public List<Product> getProductsByCategoryAndType(String category, String type) {
        return productDAO.getProductsByCategoryAndType(category, type);
    }

    /**
     * Search products by name or description
     * @param keyword Keyword to search for
     * @return List of products matching the search criteria
     */
    public List<Product> searchProducts(String keyword) {
        return productDAO.searchProducts(keyword);
    }

    /**
     * Update product stock
     * @param productId Product ID
     * @param quantity Quantity to reduce from stock
     * @return true if update successful, false otherwise
     */
    public boolean updateProductStock(int productId, int quantity) {
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            return false;
        }

        if (product.getStock() < quantity) {
            return false; // Not enough stock
        }

        product.setStock(product.getStock() - quantity);
        product.setUpdatedAt(new Timestamp(new Date().getTime()));

        return productDAO.updateProduct(product);
    }

    /**
     * Check if product has enough stock
     * @param productId Product ID
     * @param quantity Quantity to check
     * @return true if product has enough stock, false otherwise
     */
    public boolean hasEnoughStock(int productId, int quantity) {
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            return false;
        }

        return product.getStock() >= quantity;
    }

    /**
     * Get product count
     * @return Number of products
     */
    public int getProductCount() {
        return productDAO.getProductCount();
    }

    // This method has been moved to line 93
}
