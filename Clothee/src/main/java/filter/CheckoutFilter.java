package filter;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;
import model.CartItem;
import model.Cart;
import service.CartService;

/**
 * Filter to ensure users have items in their cart and a shipping address before proceeding to checkout
 */
@WebFilter(filterName = "CheckoutFilter", urlPatterns = {"/CartServlet"})
public class CheckoutFilter implements Filter {

    private CartService cartService;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        cartService = new CartService();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        // Only apply filter to checkout action
        String action = httpRequest.getParameter("action");
        if ("checkout".equals(action)) {
            User user = (User) session.getAttribute("user");

            if (user != null) {
                // Check if cart has items
                List<CartItem> cartItems = cartService.getUserCartItems(user.getId());

                if (cartItems == null || cartItems.isEmpty()) {
                    // Cart is empty, redirect to cart page with message
                    session.setAttribute("errorMessage", "Your cart is empty. Please add items to your cart before checkout.");
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/CartServlet?action=view");
                    return;
                }

                // Check if user has a shipping address
                Cart cartAddress = cartService.getCartAddress(user.getId());

                if (cartAddress == null || cartAddress.getStreet() == null || cartAddress.getStreet().isEmpty()) {
                    // No address, redirect to address page
                    session.setAttribute("errorMessage", "Please provide your shipping address before proceeding to checkout.");
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/CartServlet?action=viewAddress");
                    return;
                }

                // All validations passed, continue with checkout
                System.out.println("CheckoutFilter: All validations passed, proceeding to checkout");
            }
        }

        // Continue the filter chain
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup code, if needed
    }
}
