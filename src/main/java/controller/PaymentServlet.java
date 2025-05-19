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
        Double subtotal = (Double) session.getAttribute("checkoutSubtotal");
        Double shipping = (Double) session.getAttribute("checkoutShipping");
        Double tax = (Double) session.getAttribute("checkoutTax");
        Double total = (Double) session.getAttribute("checkoutTotal");

        // If checkout information is not in session, get it from the database
        if (cartItems == null || subtotal == null || shipping == null || tax == null || total == null) {
            // Get cart items
            cartItems = cartService.getUserCartItems(userId);

            if (cartItems.isEmpty()) {
                // Cart is empty, redirect to cart page with message
                session.setAttribute("errorMessage", "Your cart is empty. Please add items to your cart before checkout.");
                response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
                return;
            }

            // No need to get or validate shipping address

            // Calculate totals
            subtotal = cartService.getCartTotal(userId);
            shipping = subtotal > 50 ? 0.00 : 5.99;
            tax = subtotal * 0.1;
            total = subtotal + shipping + tax;
        }

        // Set attributes for the payment page
        request.setAttribute("cartItems", cartItems);
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
        Double subtotal = (Double) session.getAttribute("checkoutSubtotal");
        Double shipping = (Double) session.getAttribute("checkoutShipping");
        Double tax = (Double) session.getAttribute("checkoutTax");
        Double total = (Double) session.getAttribute("checkoutTotal");

        // If checkout information is not in session, get it from the database
        if (cartItems == null || subtotal == null || shipping == null || tax == null || total == null) {
            // Get cart items
            cartItems = cartService.getUserCartItems(userId);

            if (cartItems.isEmpty()) {
                // Cart is empty, redirect to cart page with message
                session.setAttribute("errorMessage", "Your cart is empty. Please add items to your cart before checkout.");
                response.sendRedirect(request.getContextPath() + "/CartServlet?action=view");
                return;
            }

            // No need to get or validate shipping address

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

        // No need to create shipping address

        // Process payment (simplified - always succeeds)
        // In a real application, this would integrate with a payment gateway

        // Place order using the cart items from database
        Order createdOrder = orderService.createOrderFromCart(userId);

        // If order was created successfully, process payment
        // Note: A payment record is already created in OrderDAO.createOrder()
        // OrderService.processPayment() will check if a payment record exists before creating a new one
        if (createdOrder != null) {
            orderService.processPayment(createdOrder.getId(), paymentMethod, null);
        }

        if (createdOrder != null) {
            // Order was created successfully
            // Note: Cart is already cleared in the createOrderFromCart method

            // Note: Payment record is created in OrderDAO.createOrder() and OrderService.processPayment() checks for duplicates

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

    // createPaymentRecord method removed to prevent duplicate payment records
    // Payment records are now created in OrderDAO.createOrder() and OrderService.processPayment()

    // Shipping record creation removed as it's no longer needed

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
