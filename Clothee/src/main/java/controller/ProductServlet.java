package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import service.ProductService;

/**
 * Servlet implementation class ProductServlet
 */
// Servlet mapping defined in web.xml
public class ProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProductService productService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ProductServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        productService = new ProductService();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listProducts(request, response);
                break;
            case "detail":
                getProductDetail(request, response);
                break;
            case "category":
                getProductsByCategory(request, response);
                break;
            case "search":
                searchProducts(request, response);
                break;
            default:
                listProducts(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * List all products
     */
    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Product> products = productService.getAllProducts();
            request.setAttribute("products", products);
            request.getRequestDispatcher("/products.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("Error in listProducts: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred while retrieving products. Please try again later.");
            request.getRequestDispatcher("/error/500.jsp").forward(request, response);
        }
    }

    /**
     * Get product detail
     */
    private void getProductDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productIdStr = request.getParameter("id");

        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect("ProductServlet");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            Product product = productService.getProductById(productId);

            if (product == null) {
                response.sendRedirect("ProductServlet");
                return;
            }

            // Get related products
            List<Product> relatedProducts = productService.getProductsByCategory(product.getCategory());
            // Remove current product from related products
            relatedProducts.removeIf(p -> p.getId() == product.getId());
            // Limit to 4 related products
            if (relatedProducts.size() > 4) {
                relatedProducts = relatedProducts.subList(0, 4);
            }

            // Set attributes
            request.setAttribute("product", product);
            request.setAttribute("relatedProducts", relatedProducts);
            request.setAttribute("tab", "description");

            request.getRequestDispatcher("/product-details.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect("ProductServlet");
        }
    }

    /**
     * Get products by category
     */
    private void getProductsByCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String category = request.getParameter("category");

        if (category == null || category.isEmpty()) {
            response.sendRedirect("ProductServlet");
            return;
        }

        List<Product> products = productService.getProductsByCategory(category);
        request.setAttribute("products", products);
        request.setAttribute("category", category);
        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }

    /**
     * Search products
     */
    private void searchProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");

        if (keyword == null || keyword.isEmpty()) {
            response.sendRedirect("ProductServlet");
            return;
        }

        List<Product> products = productService.searchProducts(keyword);
        request.setAttribute("products", products);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }
}
