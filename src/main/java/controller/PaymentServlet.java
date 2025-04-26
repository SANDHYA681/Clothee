package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
// import jakarta.servlet.annotation.WebServlet;
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
import service.PaymentMethodService;
import service.PaymentValidator;
import util.DBConnection;
import util.DatabaseInitializer;
import model.PaymentMethod;

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
    private PaymentMethodService paymentMethodService;

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
        paymentMethodService = new PaymentMethodService();

        // Initialize the database
        try {
            DatabaseInitializer.initialize();
        } catch (Exception e) {
            System.out.println("Error initializing database: " + e.getMessage());
            e.printStackTrace();
        }
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
        if (action == null) {
            // Default action is to show payment methods page
            showPaymentMethodsPage(request, response);
        } else {
            switch (action) {
                case "checkout":
                    // Show payment page for checkout
                    showPaymentPage(request, response);
                    break;
                case "history":
                    viewPaymentHistory(request, response);
                    break;
                case "details":
                    viewPaymentDetails(request, response);
                    break;
                case "verify":
                    verifyPayment(request, response);
                    break;
                default:
                    showPaymentMethodsPage(request, response);
            }
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
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
            return;
        }

        switch (action) {
            case "process":
                processPayment(request, response);
                break;
            case "add_payment_method":
                addPaymentMethod(request, response);
                break;
            default:
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
        String cardName = request.getParameter("cardName");
        String cardNumber = request.getParameter("cardNumber");
        String expiryDate = request.getParameter("expiryDate");
        String cvv = request.getParameter("cvv");

        // Validate payment form data
        if (paymentMethod == null || paymentMethod.isEmpty() ||
            cardName == null || cardName.isEmpty() ||
            cardNumber == null || cardNumber.isEmpty() ||
            expiryDate == null || expiryDate.isEmpty() ||
            cvv == null || cvv.isEmpty()) {

            request.setAttribute("errorMessage", "Please fill in all payment fields");
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

        // Process payment using the payment validator
        String paymentError = paymentValidator.processPayment(paymentMethod, cardNumber, expiryDate, cvv, total);

        if (paymentError != null) {
            // Payment failed with specific error message
            request.setAttribute("errorMessage", paymentError);
            showPaymentPage(request, response);
            return;
        }

        // Place order using the cart items from database
        Order createdOrder = orderService.createOrderFromCart(userId, paymentMethod, shippingAddress);

        if (createdOrder != null) {
            // Order was created successfully
            // Note: Cart is already cleared in the createOrderFromCart method

            // Create payment record
            createPaymentRecord(createdOrder.getId(), userId, paymentMethod, total);

            // Create shipping record
            createShippingRecord(createdOrder.getId(), shippingAddress);

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

    /**
     * Add payment method
     */
    private void addPaymentMethod(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get user from session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        // Get form data
        String cardType = request.getParameter("cardType");
        String cardName = request.getParameter("cardName");
        String cardNumber = request.getParameter("cardNumber");
        String expiryDate = request.getParameter("expiryDate");
        String cvv = request.getParameter("cvv");
        String billingAddress = request.getParameter("billingAddress");
        String billingCity = request.getParameter("billingCity");
        String billingState = request.getParameter("billingState");
        String billingZip = request.getParameter("billingZip");
        String billingCountry = request.getParameter("billingCountry");
        boolean isDefault = request.getParameter("isDefault") != null;

        // Validate form data
        if (cardType == null || cardType.isEmpty() ||
            cardName == null || cardName.isEmpty() ||
            cardNumber == null || cardNumber.isEmpty() ||
            expiryDate == null || expiryDate.isEmpty() ||
            cvv == null || cvv.isEmpty()) {

            // Set error message
            session.setAttribute("errorMessage", "Please fill in all required fields");
            response.sendRedirect(request.getContextPath() + "/PaymentServlet");
            return;
        }

        try {
            // Add payment method using the service
            String error = paymentMethodService.addPaymentMethod(
                userId, cardType, cardName, cardNumber, expiryDate, cvv,
                billingAddress, billingCity, billingState, billingZip, billingCountry, isDefault
            );

            if (error != null) {
                // Set specific error message
                session.setAttribute("errorMessage", error);
            } else {
                // Set success message
                session.setAttribute("successMessage", "Payment method added successfully");
            }
        } catch (Exception e) {
            // Log the exception
            System.out.println("Error adding payment method: " + e.getMessage());
            e.printStackTrace();

            // Set generic error message
            session.setAttribute("errorMessage", "Failed to save payment method. Please try again. Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/PaymentServlet");
    }

    /**
     * Show payment methods page
     */
    private void showPaymentMethodsPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get user from session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        // Get payment methods for the user
        List<PaymentMethod> paymentMethods = paymentMethodService.getPaymentMethodsByUserId(userId);

        // Set payment methods in request
        request.setAttribute("paymentMethods", paymentMethods);

        // Forward to payment methods page
        request.getRequestDispatcher("/customer/payment-methods.jsp").forward(request, response);
    }
}
