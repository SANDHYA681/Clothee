package filter;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import model.CartItem;
import service.CartService;

/**
 * Filter to ensure users have items in their cart before proceeding to checkout
 * Note: This filter is configured in web.xml, so we don't need the WebFilter annotation
 */
public class CheckoutFilter implements Filter {

    private CartService cartService;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialize the CartService
        cartService = new CartService();
        System.out.println("CheckoutFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        try {
            // Only apply filter to checkout action
            String action = httpRequest.getParameter("action");
            if ("checkout".equals(action)) {
                // Check if user is logged in
                if (session == null || session.getAttribute("user") == null) {
                    // User not logged in, redirect to login page
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/LoginServlet");
                    return;
                }

                User user = (User) session.getAttribute("user");

                // Check if cart has items
                List<CartItem> cartItems = cartService.getUserCartItems(user.getId());

                if (cartItems == null || cartItems.isEmpty()) {
                    // Cart is empty, redirect to cart page with message
                    session.setAttribute("errorMessage", "Your cart is empty. Please add items to your cart before checkout.");
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/CartServlet?action=view");
                    return;
                }

                // Log for debugging
                System.out.println("CheckoutFilter: All validations passed, proceeding to checkout for user " + user.getId());
            }

            // Continue the filter chain
            chain.doFilter(request, response);
        } catch (Exception e) {
            // Log any exceptions
            System.err.println("Error in CheckoutFilter: " + e.getMessage());
            e.printStackTrace();

            // Continue the filter chain even if there's an error
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {
        // Cleanup code, if needed
    }
}
