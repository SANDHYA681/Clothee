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
 * Filter to redirect admin users from the homepage to the admin dashboard
 */
@WebFilter(filterName = "AdminRedirectFilter", urlPatterns = {"/index.jsp", "/"})
public class AdminRedirectFilter implements Filter {

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
        
        // Check if user is logged in and is an admin
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            
            // If the user is an admin, redirect to admin dashboard
            if (user.isAdmin()) {
                System.out.println("AdminRedirectFilter: Redirecting admin user to admin dashboard");
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/dashboard.jsp");
                return;
            }
        }
        
        // Continue the filter chain for non-admin users
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup code, if needed
    }
}
