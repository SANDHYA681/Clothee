package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet implementation class LogoutServlet
 */
// Servlet mapping defined in web.xml
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public LogoutServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get the session
        HttpSession session = request.getSession(false);

        // Invalidate the session if it exists
        if (session != null) {
            // Clear all session attributes first
            session.removeAttribute("userId");
            session.removeAttribute("userEmail");
            session.removeAttribute("userName");
            session.removeAttribute("userRole");
            session.removeAttribute("user");
            session.removeAttribute("cart");

            // Then invalidate the session
            session.invalidate();
        }

        // Clear any cookies related to authentication
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("userId") || cookie.getName().equals("userEmail") ||
                    cookie.getName().equals("userName") || cookie.getName().equals("userRole")) {
                    cookie.setMaxAge(0);
                    cookie.setPath("/");
                    response.addCookie(cookie);
                }
            }
        }

        // Redirect to home page with a message
        response.sendRedirect("index.jsp?message=" + java.net.URLEncoder.encode("You have been successfully logged out.", "UTF-8"));
    }
}
