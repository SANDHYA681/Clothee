package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Cart;
import model.CartItem;
import model.Order;
import model.Product;
import model.User;
import service.CartService;
import service.OrderService;
import service.ProductService;

/**
 * Servlet implementation class CheckoutServlet
 * Handles checkout process
 */
// Servlet mapping defined in web.xml
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderService orderService;
    private ProductService productService;
    private CartService cartService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public CheckoutServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
        productService = new ProductService();
        cartService = new CartService();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Redirect to login page with return URL
            String redirectUrl = "checkout.jsp";
            response.sendRedirect(request.getContextPath() + "/login.jsp?redirectUrl=" + redirectUrl);
            return;
        }

        // Get cart items from database
        List<CartItem> cartItems = cartService.getUserCartItems(user.getId());

        if (cartItems.isEmpty()) {
            // Redirect to cart if empty with a message
            session.setAttribute("cartMessage", "Your cart is empty. Please add items to your cart before checkout.");
            response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
            return;
        }

        // Pre-fill user information
        request.setAttribute("user", user);

        // Calculate totals
        double subtotal = cartService.getCartTotal(user.getId());
        double shipping = subtotal > 50 ? 0.00 : 5.99;
        double tax = subtotal * 0.1;
        double total = subtotal + shipping + tax;

        // Set attributes for the checkout page
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("shipping", shipping);
        request.setAttribute("tax", tax);
        request.setAttribute("total", total);

        // Redirect to checkout page
        response.sendRedirect(request.getContextPath() + "/checkout.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/cart.jsp");
            return;
        }

        if ("placeOrder".equals(action)) {
            placeOrder(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/cart.jsp");
        }
    }

    /**
     * Process checkout and proceed to payment
     */
    private void placeOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get user from session (user is guaranteed to be logged in by the AuthenticationFilter)
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Get shipping information from the form
        String fullName = request.getParameter("fullName");
        String country = request.getParameter("country");
        String phone = request.getParameter("phone");

        // Validate shipping information
        if (fullName == null || fullName.trim().isEmpty() ||
            country == null || country.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty()) {

            // Set error message and redirect back to checkout
            request.setAttribute("errorMessage", "Please fill in all required shipping information fields.");
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            return;
        }

        // Store shipping address in CartService
        cartService.updateCartAddress(user.getId(), fullName, country, phone);

        // Get cart items from database (validation done by CheckoutFilter)
        List<CartItem> cartItems = cartService.getUserCartItems(user.getId());

        // Calculate totals
        double subtotal = cartService.getCartTotal(user.getId());
        double shipping = subtotal > 50 ? 0.00 : 5.99;
        double tax = subtotal * 0.1;
        double total = subtotal + shipping + tax;

        // Set attributes for the payment page
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("shipping", shipping);
        request.setAttribute("tax", tax);
        request.setAttribute("total", total);

        // Store checkout information in session for payment page
        session.setAttribute("checkoutCartItems", cartItems);
        session.setAttribute("checkoutSubtotal", subtotal);
        session.setAttribute("checkoutShipping", shipping);
        session.setAttribute("checkoutTax", tax);
        session.setAttribute("checkoutTotal", total);

        // Redirect to payment page
        response.sendRedirect(request.getContextPath() + "/PaymentServlet?action=checkout");
    }

    /**
     * Calculate subtotal from cart
     */
    private double calculateSubtotal(Map<Integer, Integer> cart) {
        double subtotal = 0.0;

        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            int productId = entry.getKey();
            int quantity = entry.getValue();

            Product product = productService.getProductById(productId);
            if (product != null) {
                subtotal += product.getPrice() * quantity;
            }
        }

        return subtotal;
    }

    /**
     * Get cart from session
     */
    @SuppressWarnings("unchecked")
    private Map<Integer, Integer> getCartFromSession(HttpSession session) {
        Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");

        if (cart == null) {
            cart = new HashMap<>();
            session.setAttribute("cart", cart);
        }

        return cart;
    }
}
