package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Product;
import model.User;
import service.CartService;
import service.ProductService;

/**
 * Servlet implementation class CartServlet
 */
// Servlet mapping defined in web.xml
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CartService cartService;
    private ProductService productService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public CartServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        cartService = new CartService();
        productService = new ProductService();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Check if user is an admin - admins should not use cart functionality
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp?error=Admin+users+cannot+use+cart+functionality");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "view";
        }

        switch (action) {
            case "view":
                viewCart(request, response);
                break;
            case "add":
                addToCart(request, response);
                break;
            case "update":
                updateCart(request, response);
                break;
            case "remove":
                removeFromCart(request, response);
                break;
            case "clear":
                clearCart(request, response);
                break;
            case "updateAddress":
                updateCartAddress(request, response);
                break;
            case "viewAddress":
                viewCartAddress(request, response);
                break;
            case "editAddress":
                editCartAddress(request, response);
                break;
            case "checkout":
                proceedToPayment(request, response);
                break;
            default:
                viewCart(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * View cart
     */
    private void viewCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        List<CartItem> cartItems = cartService.getUserCartItems(userId);
        double cartTotal = cartService.getCartTotal(userId);
        int cartItemCount = cartService.getCartItemCount(userId);

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("cartItemCount", cartItemCount);
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    /**
     * Add to cart
     */
    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        if (productIdStr == null || productIdStr.isEmpty()) {
            response.sendRedirect("ProductServlet");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            int quantity = 1; // Default quantity

            if (quantityStr != null && !quantityStr.isEmpty()) {
                quantity = Integer.parseInt(quantityStr);
            }

            // Add to cart using service
            boolean success = cartService.addToCart(userId, productId, quantity);

            // Get product for error message if needed
            Product product = productService.getProductById(productId);

            if (product == null) {
                response.sendRedirect("ProductServlet");
                return;
            }

            if (success) {
                // Set success message
                request.setAttribute("cartMessage", product.getName() + " added to cart successfully");
                // Redirect to cart to show the cart history
                response.sendRedirect("CartServlet?action=view");
            } else {
                // Show error
                request.setAttribute("errorMessage", "Failed to add product to cart");
                request.setAttribute("product", product);
                request.getRequestDispatcher("/product-details.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("ProductServlet");
        }
    }

    /**
     * Update cart
     */
    private void updateCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        String cartItemIdStr = request.getParameter("cartItemId");
        String quantityStr = request.getParameter("quantity");

        if (cartItemIdStr == null || cartItemIdStr.isEmpty() || quantityStr == null || quantityStr.isEmpty()) {
            response.sendRedirect("CartServlet");
            return;
        }

        try {
            int cartItemId = Integer.parseInt(cartItemIdStr);
            int quantity = Integer.parseInt(quantityStr);

            // Update cart item quantity using service
            boolean success = cartService.updateCartItemQuantity(cartItemId, quantity);

            if (success) {
                // Set success message
                request.setAttribute("cartMessage", "Cart updated successfully");
                // Redirect to cart
                response.sendRedirect("CartServlet");
            } else {
                // Show error
                request.setAttribute("errorMessage", "Failed to update cart");
                viewCart(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("CartServlet");
        }
    }

    /**
     * Remove from cart
     */
    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        String cartItemIdStr = request.getParameter("cartItemId");

        if (cartItemIdStr == null || cartItemIdStr.isEmpty()) {
            response.sendRedirect("CartServlet");
            return;
        }

        try {
            int cartItemId = Integer.parseInt(cartItemIdStr);

            // Remove from cart using service
            boolean success = cartService.removeFromCart(cartItemId);

            if (success) {
                // Set success message
                request.setAttribute("cartMessage", "Item removed from cart");
            }

            // Redirect to cart
            response.sendRedirect("CartServlet");
        } catch (NumberFormatException e) {
            response.sendRedirect("CartServlet");
        }
    }

    /**
     * Clear cart
     */
    private void clearCart(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        // Clear cart
        boolean success = cartService.clearCart(userId);

        if (success) {
            // Set success message
            request.setAttribute("cartMessage", "Cart cleared successfully");
        }

        // Redirect to cart
        response.sendRedirect("CartServlet");
    }

    /**
     * Update cart address
     */
    private void updateCartAddress(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        // Get form data
        String fullName = request.getParameter("fullName");
        String country = request.getParameter("country");
        String phone = request.getParameter("phone");

        // Validate form data
        if (fullName == null || fullName.trim().isEmpty() ||
            country == null || country.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty()) {

            // Set error message
            session.setAttribute("errorMessage", "Please fill in all required fields");
            response.sendRedirect("CartServlet?action=viewAddress");
            return;
        }

        // Update cart address
        boolean success = cartService.updateCartAddress(userId, fullName, country, phone);

        if (success) {
            // Set success message
            session.setAttribute("addressSuccessMessage", "Address updated successfully");
        } else {
            // Set error message
            session.setAttribute("addressErrorMessage", "Failed to update address");
        }

        // Check if the request came from the edit-addresses.jsp page
        String referer = request.getHeader("Referer");
        if (referer != null && referer.contains("edit-addresses.jsp")) {
            // Redirect back to addresses page
            response.sendRedirect(request.getContextPath() + "/customer/addresses.jsp");
        } else if (referer != null && referer.contains("checkout-address.jsp")) {
            // Coming from checkout-address.jsp, redirect to checkout
            response.sendRedirect(request.getContextPath() + "/checkout.jsp");
        } else {
            // Check if the request has a 'checkout' parameter
            String checkout = request.getParameter("checkout");
            if ("true".equals(checkout)) {
                // Redirect directly to checkout page
                response.sendRedirect(request.getContextPath() + "/checkout.jsp");
            } else {
                // Redirect to addresses page
                response.sendRedirect(request.getContextPath() + "/customer/addresses.jsp");
            }
        }
    }

    /**
     * View cart address
     */
    private void viewCartAddress(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        // Get cart address
        model.Cart cartAddress = cartService.getCartAddress(userId);

        // Set cart address in request
        request.setAttribute("cartAddress", cartAddress);

        // Set a flag to indicate we're coming from checkout
        request.setAttribute("fromCheckout", "true");

        // Forward to customer address page
        request.getRequestDispatcher("/checkout-address.jsp").forward(request, response);
    }

    /**
     * Edit cart address
     */
    private void editCartAddress(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        if (userId == null) {
            // Guest user, redirect to login with the current URL as the redirect parameter
            String redirectUrl = request.getRequestURI();
            if (request.getQueryString() != null) {
                redirectUrl += "?" + request.getQueryString();
            }
            response.sendRedirect("login.jsp?redirectUrl=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        // Get cart address
        model.Cart cartAddress = cartService.getCartAddress(userId);

        // Set cart address in request
        request.setAttribute("cartAddress", cartAddress);

        // Forward to customer address page
        request.getRequestDispatcher("/customer/addresses.jsp").forward(request, response);
    }

    /**
     * Proceed to checkout
     */
    private void proceedToPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = user.getId(); // User is guaranteed to be logged in by the AuthenticationFilter

        // Check if cart is empty
        List<CartItem> cartItems = cartService.getUserCartItems(userId);
        if (cartItems.isEmpty()) {
            // Redirect to cart if empty with a message
            session.setAttribute("cartMessage", "Your cart is empty. Please add items to your cart before checkout.");
            response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
            return;
        }

        // Get cart address
        model.Cart cartAddress = cartService.getCartAddress(userId);

        // Calculate totals
        double subtotal = cartService.getCartTotal(userId);
        double shipping = subtotal > 50 ? 0.00 : 5.99;
        double tax = subtotal * 0.1;
        double total = subtotal + shipping + tax;

        // Store checkout information in session for checkout page
        session.setAttribute("checkoutCartItems", cartItems);
        session.setAttribute("checkoutCartAddress", cartAddress);
        session.setAttribute("checkoutSubtotal", subtotal);
        session.setAttribute("checkoutShipping", shipping);
        session.setAttribute("checkoutTax", tax);
        session.setAttribute("checkoutTotal", total);

        // Redirect to checkout page instead of payment page
        response.sendRedirect(request.getContextPath() + "/checkout.jsp");
    }
}
