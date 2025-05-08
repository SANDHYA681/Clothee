package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Order;
import model.User;
import service.OrderService;

/**
 * Servlet implementation class OrderConfirmationServlet
 * Handles order confirmation page
 */
// Servlet mapping defined in web.xml
public class OrderConfirmationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderService orderService;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public OrderConfirmationServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        orderService = new OrderService();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Redirect to login page
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get order ID from request
        String orderIdStr = request.getParameter("orderId");

        if (orderIdStr == null || orderIdStr.isEmpty()) {
            // Redirect to orders page
            response.sendRedirect(request.getContextPath() + "/UserServlet?action=orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);

            // Get order
            Order order = orderService.getOrderById(orderId);

            if (order == null || order.getUserId() != user.getId()) {
                // Order not found or doesn't belong to user
                response.sendRedirect(request.getContextPath() + "/UserServlet?action=orders");
                return;
            }

            // Get order details from session
            Object confirmedOrderObj = session.getAttribute("confirmedOrder");
            Double orderTotal = (Double) session.getAttribute("orderTotal");
            Double orderSubtotal = (Double) session.getAttribute("orderSubtotal");
            Double orderShipping = (Double) session.getAttribute("orderShipping");
            Double orderTax = (Double) session.getAttribute("orderTax");

            // If order details are not in session, use the order from database
            if (confirmedOrderObj == null) {
                // Set order in request
                request.setAttribute("order", order);
            } else {
                // Use order from session
                request.setAttribute("order", confirmedOrderObj);

                // Clear session attributes
                session.removeAttribute("confirmedOrder");
            }

            // Set order totals in request
            if (orderTotal != null) {
                request.setAttribute("orderTotal", orderTotal);
                request.setAttribute("orderSubtotal", orderSubtotal);
                request.setAttribute("orderShipping", orderShipping);
                request.setAttribute("orderTax", orderTax);

                // Clear session attributes
                session.removeAttribute("orderTotal");
                session.removeAttribute("orderSubtotal");
                session.removeAttribute("orderShipping");
                session.removeAttribute("orderTax");
            }

            // Set success message
            request.setAttribute("orderSuccess", true);

            // Forward to order confirmation page
            request.getRequestDispatcher("/order-confirmation.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            // Invalid order ID
            response.sendRedirect(request.getContextPath() + "/UserServlet?action=orders");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
