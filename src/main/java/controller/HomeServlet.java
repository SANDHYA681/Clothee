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
     * Initialize the slides
     */
    private void initializeSlides() {
        slides = new ArrayList<>();

        // Add slides
        slides.add(new Slide(
            "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
            "Elevate Your Style",
            "Discover the latest trends in fashion and express yourself with our premium collection of clothing and accessories.",
            "ProductServlet?category=new",
            "Shop Now",
            "ProductServlet?category=sale",
            "View Sale"
        ));

        slides.add(new Slide(
            "https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1771&q=80",
            "Summer Collection 2023",
            "Beat the heat with our cool and comfortable summer collection.",
            "ProductServlet?category=summer",
            "Explore Collection",
            null,
            null
        ));

        slides.add(new Slide(
            "https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
            "Exclusive Discounts",
            "Up to 50% off on selected items. Limited time offer!",
            "ProductServlet?category=sale",
            "Shop Sale",
            null,
            null
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
    }
}
