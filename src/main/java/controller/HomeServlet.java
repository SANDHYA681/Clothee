package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Slide;


/**
 * Servlet implementation class HomeServlet
 */
// Servlet mapping defined in web.xml
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private List<Slide> slides;

    /**
     * Initialize the servlet
     */
    @Override
    public void init() throws ServletException {
        super.init();
        initializeSlides();
    }

    /**
     * Initialize the slides
     */
    private void initializeSlides() {
        slides = new ArrayList<>();

        // Add a single slide with the hero image
        slides.add(new Slide(
            "images/hero-clothes.jpg",
            "Elevate Your Style",
            "Discover the latest trends in fashion and express yourself with our premium collection of clothing and accessories.",
            "ProductServlet?category=new",
            "Shop Now",
            "ProductServlet?category=sale",
            "View Sale"
        ));
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle slide parameter
        String slideParam = request.getParameter("slide");
        int currentSlide = 0;

        if (slideParam != null) {
            if ("next".equals(slideParam)) {
                // Get current slide from session
                Integer sessionSlide = (Integer) request.getSession().getAttribute("currentSlide");
                if (sessionSlide != null) {
                    currentSlide = (sessionSlide + 1) % slides.size();
                }
            } else if ("prev".equals(slideParam)) {
                // Get current slide from session
                Integer sessionSlide = (Integer) request.getSession().getAttribute("currentSlide");
                if (sessionSlide != null) {
                    currentSlide = (sessionSlide - 1 + slides.size()) % slides.size();
                }
            } else {
                try {
                    currentSlide = Integer.parseInt(slideParam);
                    if (currentSlide < 0 || currentSlide >= slides.size()) {
                        currentSlide = 0;
                    }
                } catch (NumberFormatException e) {
                    currentSlide = 0;
                }
            }
        }

        // Store current slide in session
        request.getSession().setAttribute("currentSlide", currentSlide);

        // Set slides
        request.setAttribute("slides", slides);
        request.setAttribute("currentSlide", currentSlide);

        // Forward to index.jsp
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
