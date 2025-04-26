package controller;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Simple test servlet to verify deployment
 */
public class TestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public TestServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h1>Test Servlet</h1>");
        out.println("<p>This is a test servlet to verify deployment.</p>");
        out.println("<p>If you can see this, your servlet container is working correctly.</p>");
        out.println("<p><a href=\"" + request.getContextPath() + "/CustomerMessageServlet\">Go to Customer Messages</a></p>");
        out.println("</body></html>");
    }
}
