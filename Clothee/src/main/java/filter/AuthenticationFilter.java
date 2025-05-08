package filter;

import java.io.IOException;
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

/**
 * Authentication filter to ensure users are logged in before accessing protected resources
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/CartServlet", "/CheckoutServlet", "/PaymentServlet", "/OrderServlet"})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code, if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        // Get the requested URL and method
        String requestURI = httpRequest.getRequestURI();
        String queryString = httpRequest.getQueryString();
        String fullURL = requestURI + (queryString != null ? "?" + queryString : "");
        String method = httpRequest.getMethod();

        // Allow GET requests to CategoryImageServlet without authentication
        if (requestURI.contains("CategoryImageServlet") && "GET".equals(method)) {
            // Continue the filter chain without authentication check
            chain.doFilter(request, response);
            return;
        }

        // Check if user is logged in
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);

        // If the user is not logged in and trying to access a protected resource
        if (!isLoggedIn) {
            // Save the requested URL for redirect after login
            httpRequest.getSession().setAttribute("redirectURL", fullURL);

            // Redirect to login page
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
            return;
        }

        // For checkout-specific actions, ensure the user has items in cart
        if (requestURI.contains("CartServlet") && "checkout".equals(httpRequest.getParameter("action"))) {
            User user = (User) session.getAttribute("user");

            // Admin users should not use cart functionality
            if (user.isAdmin()) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/dashboard.jsp?error=Admin+users+cannot+use+cart+functionality");
                return;
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
