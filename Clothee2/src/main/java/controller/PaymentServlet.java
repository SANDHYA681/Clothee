package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Order;
import model.User;
import model.Cart;
import service.CartService;
import service.OrderService;
import service.PaymentValidator;
import util.DBConnection;

/**
 * Servlet implementation class PaymentServlet
 * Handles payment processing and checkout
 */
// Servlet mapping defined in web.xml
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CartService cartService;
    private OrderService orderService;
    private PaymentValidator paymentValidator;


    /**
     * @see HttpServlet#HttpServlet()
     */
    public PaymentServlet() {
        super();
    }

    @Override
    public void init() throws ServletException {
        cartService = new CartService();
        orderService = new OrderService();
        paymentValidator = new PaymentValidator();
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

        String action = request.getParameter("action");
        if (action != null && action.equals("checkout")) {
            // Only allow checkout action
            showPaymentPage(request, response);
        } else {
            // Redirect to dashboard for all other actions including payment methods
            response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // Redirect to login page
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action != null && action.equals("process")) {
            // Only allow payment processing for checkout
            processPayment(request, response);
        } else {
            // Redirect to cart for all other actions including adding payment methods
            response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
        }
    }

    /**
     * Show payment page
     */
    private void showPaymentPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get user from session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        // Get checkout information from session
        List<CartItem> cartItems = (List<CartItem>) session.getAttribute("checkoutCartItems");
        Cart cartAddress = (Cart) session.getAttribute("checkoutCartAddress");
        Double subtotal = (Double) session.getAttribute("checkoutSubtotal");
        Double shipping = (Double) session.getAttribute("checkoutShipping");
        Double tax = (Double) session.getAttribute("checkoutTax");
        Double total = (Double) session.getAttribute("checkoutTotal");

        // If checkout information is not in session, get it from the database
        if (cartItems == null || cartAddress == null || subtotal == null || shipping == null || tax == null || total == null) {
            // Get cart items
            cartItems = cartService.getUserCartItems(userId);

            if (cartItems.isEmpty()) {
                // Cart is empty, redirect to cart page with message
                session.setAttribute("errorMessage", "Your cart is empty. Please add items to your cart before checkout.");
                response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
                return;
            }

            // Get cart address
            cartAddress = cartService.getCartAddress(userId);

            if (cartAddress == null || cartAddress.getStreet() == null || cartAddress.getStreet().isEmpty()) {
                // No address, redirect to address page
                session.setAttribute("errorMessage", "Please provide your shipping address before proceeding to payment.");
                response.sendRedirect(request.getContextPath() + "/CartServlet?action=viewAddress");
                return;
            }

            // Calculate totals
            subtotal = cartService.getCartTotal(userId);
            shipping = subtotal > 50 ? 0.00 : 5.99;
            tax = subtotal * 0.1;
            total = subtotal + shipping + tax;
        }

        // Set attributes for the payment page
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartAddress", cartAddress);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("shipping", shipping);
        request.setAttribute("tax", tax);
        request.setAttribute("total", total);

        // Get available payment methods (in a real app, these would come from a database)
        List<String> paymentMethods = new ArrayList<>();
        paymentMethods.add("Credit Card");
        paymentMethods.add("Debit Card");
        paymentMethods.add("PayPal");
        // Note: Cash on Delivery has been removed as a payment option
        request.setAttribute("paymentMethods", paymentMethods);

        // Forward to payment page
        request.getRequestDispatcher("/payment.jsp").forward(request, response);
    }

    /**
     * Process payment
     */
    private void processPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get user from session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        // Get checkout information from session
        List<CartItem> cartItems = (List<CartItem>) session.getAttribute("checkoutCartItems");
        Cart cartAddress = (Cart) session.getAttribute("checkoutCartAddress");
        Double subtotal = (Double) session.getAttribute("checkoutSubtotal");
        Double shipping = (Double) session.getAttribute("checkoutShipping");
        Double tax = (Double) session.getAttribute("checkoutTax");
        Double total = (Double) session.getAttribute("checkoutTotal");

        // If checkout information is not in session, get it from the database
        if (cartItems == null || cartAddress == null || subtotal == null || shipping == null || tax == null || total == null) {
            // Get cart items
            cartItems = cartService.getUserCartItems(userId);

            if (cartItems.isEmpty()) {
                // Cart is empty, redirect to cart page with message
                session.setAttribute("errorMessage", "Your cart is empty. Please add items to your cart before checkout.");
                response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
                return;
            }

            // Get cart address
            cartAddress = cartService.getCartAddress(userId);

            if (cartAddress == null || cartAddress.getStreet() == null || cartAddress.getStreet().isEmpty()) {
                // No address, redirect to address page
                session.setAttribute("errorMessage", "Please provide your shipping address before proceeding to payment.");
                response.sendRedirect(request.getContextPath() + "/CartServlet?action=viewAddress");
                return;
            }

            // Calculate totals
            subtotal = cartService.getCartTotal(userId);
            shipping = subtotal > 50 ? 0.00 : 5.99;
            tax = subtotal * 0.1;
            total = subtotal + shipping + tax;
        }

        // Get payment form data
        String paymentMethod = request.getParameter("paymentMethod");

        // Validate payment form data
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            request.setAttribute("errorMessage", "Please select a payment method");
            showPaymentPage(request, response);
            return;
        }

        // Create shipping address
        String shippingAddress = cartAddress.getFullName() + ", " +
                               cartAddress.getStreet() + ", " +
                               cartAddress.getCity() + ", " +
                               cartAddress.getState() + " " +
                               cartAddress.getZipCode() + ", " +
                               cartAddress.getCountry();

        // Process payment (simplified - always succeeds)
        // In a real application, this would integrate with a payment gateway

        // Place order using the cart items from database
        Order createdOrder = orderService.createOrderFromCart(userId, paymentMethod, shippingAddress);

        if (createdOrder != null) {
            // Order was created successfully
            // Note: Cart is already cleared in the createOrderFromCart method

            // Note: We don't need to create payment or shipping records here because they're already created in OrderDAO.createOrder()

            // Set success message
            session.setAttribute("orderMessage", "Your order has been placed successfully!");

            // Set order in session for order confirmation
            session.setAttribute("confirmedOrder", createdOrder);
            session.setAttribute("orderTotal", total);
            session.setAttribute("orderSubtotal", subtotal);
            session.setAttribute("orderShipping", shipping);
            session.setAttribute("orderTax", tax);

            // Clear checkout information from session
            session.removeAttribute("checkoutCartItems");
            session.removeAttribute("checkoutCartAddress");
            session.removeAttribute("checkoutSubtotal");
            session.removeAttribute("checkoutShipping");
            session.removeAttribute("checkoutTax");
            session.removeAttribute("checkoutTotal");

            // Redirect to order confirmation page
            response.sendRedirect(request.getContextPath() + "/OrderConfirmationServlet?orderId=" + createdOrder.getId());
        } else {
            // Set error message
            request.setAttribute("errorMessage", "Failed to place order. Please try again.");

            // Forward back to payment page
            showPaymentPage(request, response);
        }
    }

    /**
     * Create payment record
     */
    private void createPaymentRecord(int orderId, int userId, String paymentMethod, double amount) {
        try {
            // Create a new payment record in the database
            String query = "INSERT INTO payments (payment_date, payment_method, status, amount, order_id, user_id) VALUES (NOW(), ?, ?, ?, ?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {

                stmt.setString(1, paymentMethod);
                stmt.setString(2, "Completed");
                stmt.setDouble(3, amount);
                stmt.setInt(4, orderId);
                stmt.setInt(5, userId);

                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Create shipping record
     */
    private void createShippingRecord(int orderId, String shippingAddress) {
        try {
            // Create a new shipping record in the database
            String query = "INSERT INTO shipping (shipping_address, shipping_date, shipping_status, order_id) VALUES (?, NOW(), ?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {

                stmt.setString(1, shippingAddress);
                stmt.setString(2, "Pending");
                stmt.setInt(3, orderId);

                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * View payment history
     */
    private void viewPaymentHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This would typically show a list of past payments
        // For now, redirect to orders page
        response.sendRedirect("OrderServlet?action=viewOrders");
    }

    /**
     * View payment details
     */
    private void viewPaymentDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This would typically show details of a specific payment
        // For now, redirect to orders page
        response.sendRedirect("OrderServlet?action=viewOrders");
    }

    /**
     * Verify payment
     */
    private void verifyPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This would typically verify a payment status
        // For now, redirect to orders page
        response.sendRedirect("OrderServlet?action=viewOrders");
    }



}
