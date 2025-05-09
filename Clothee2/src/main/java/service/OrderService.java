package service;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import dao.CartDAO;
import dao.OrderDAO;
import dao.ProductDAO;
import model.Cart;
import model.CartItem;
import model.Order;
import model.OrderItem;
import model.Product;

/**
 * Service class for order-related operations
 */
public class OrderService {
    private OrderDAO orderDAO;
    private CartDAO cartDAO;
    private ProductDAO productDAO;
    private ProductService productService;

    /**
     * Constructor
     */
    public OrderService() {
        this.orderDAO = new OrderDAO();
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
        this.productService = new ProductService();
    }

    /**
     * Create a new order from cart
     * @param userId User ID
     * @param paymentMethod Payment method
     * @param shippingAddress Shipping address
     * @return Order object if creation successful, null otherwise
     */
    public Order createOrderFromCart(int userId, String paymentMethod, String shippingAddress) {
        // Get user's cart items
        List<CartItem> cartItems = cartDAO.getCartItemsByUserId(userId);

        // Create a cart object and set the items
        Cart cart = new Cart();
        cart.setUserId(userId);
        cart.setItems(cartItems);

        if (cartItems == null || cartItems.isEmpty()) {
            return null;
        }

        // Check stock for all items
        for (CartItem item : cart.getItems()) {
            if (!productService.hasEnoughStock(item.getProductId(), item.getQuantity())) {
                return null; // Not enough stock
            }
        }

        // Get cart address if not provided
        if (shippingAddress == null || shippingAddress.isEmpty()) {
            Cart cartAddress = cartDAO.getCartAddressByUserId(userId);
            if (cartAddress != null && cartAddress.getStreet() != null && !cartAddress.getStreet().isEmpty()) {
                // Format the address properly
                shippingAddress = cartAddress.getFullName() + ", " +
                                cartAddress.getStreet() + ", " +
                                cartAddress.getCity() + ", " +
                                cartAddress.getState() + " " +
                                cartAddress.getZipCode() + ", " +
                                cartAddress.getCountry() + ", " +
                                cartAddress.getPhone();
            }
        }

        // Create order
        Order order = new Order();
        order.setUserId(userId);
        order.setTotalPrice(cart.getTotal());
        order.setStatus("Processing");
        order.setOrderDate(new Timestamp(new Date().getTime()));
        order.setShippingAddress(shippingAddress);
        order.setPaymentMethod(paymentMethod);

        // Create payment record separately
        // This will be handled by the OrderDAO when creating the order

        // Create order in database
        boolean success = orderDAO.createOrder(order);

        if (!success) {
            return null;
        }

        // Create order items from cart items
        for (CartItem cartItem : cart.getItems()) {
            // Get product information
            model.Product product = productDAO.getProductById(cartItem.getProductId());
            if (product == null) continue;

            OrderItem orderItem = new OrderItem();
            orderItem.setOrderId(order.getId()); // Now the order ID is set
            orderItem.setProductId(cartItem.getProductId());
            orderItem.setProductName(product.getName());
            orderItem.setPrice(product.getPrice());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setImageUrl(product.getImageUrl());

            // Add order item to database
            orderDAO.addOrderItem(orderItem);

            // Update product stock
            productService.updateProductStock(cartItem.getProductId(), cartItem.getQuantity());
        }

        // Clear cart
        cartDAO.clearCart(userId);
        return order;
    }

    /**
     * Get order by ID
     * @param orderId Order ID
     * @return Order object if found, null otherwise
     */
    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    /**
     * Get orders by user ID
     * @param userId User ID
     * @return List of orders for the user
     */
    public List<Order> getOrdersByUserId(int userId) {
        return orderDAO.getOrdersByUserId(userId);
    }

    /**
     * Get orders by user ID and filter by status
     * @param userId User ID
     * @param status Order status to filter by (null for all statuses)
     * @return List of filtered orders for the user
     */
    public List<Order> getOrdersByUserId(int userId, String status) {
        return orderDAO.getOrdersByUserId(userId, status);
    }

    /**
     * Get all orders
     * @return List of all orders
     */
    public List<Order> getAllOrders() {
        return orderDAO.getAllOrders();
    }

    /**
     * Get recent orders
     * @param limit Number of orders to return
     * @return List of recent orders
     */
    public List<Order> getRecentOrders(int limit) {
        return orderDAO.getRecentOrders(limit);
    }

    /**
     * Update order status
     * @param orderId Order ID
     * @param status New status
     * @return true if update successful, false otherwise
     */
    public boolean updateOrderStatus(int orderId, String status) {
        return orderDAO.updateOrderStatus(orderId, status);
    }

    /**
     * Update an existing order
     * @param order Order object with updated information
     * @return true if update successful, false otherwise
     */
    public boolean updateOrder(Order order) {
        return orderDAO.updateOrder(order);
    }

    /**
     * Update payment status
     * @param orderId Order ID
     * @param paymentStatus New payment status
     * @return true if update successful, false otherwise
     */
    public boolean updatePaymentStatus(int orderId, String paymentStatus) {
        // This should be implemented in the PaymentDAO instead
        // For now, we'll just return true
        return true;
    }

    /**
     * Process payment
     * @param orderId Order ID
     * @param paymentMethod Payment method
     * @param paymentDetails Payment details
     * @return true if payment successful, false otherwise
     */
    public boolean processPayment(int orderId, String paymentMethod, String paymentDetails) {
        // In a real application, this would integrate with a payment gateway
        // For now, we'll just simulate a successful payment

        // This should create a new payment record in the payments table
        // For now, we'll just return true
        return true;
    }

    /**
     * Get order count
     * @return Number of orders
     */
    public int getOrderCount() {
        return orderDAO.getOrderCount();
    }

    /**
     * Get total sales
     * @return Total sales amount
     */
    public double getTotalSales() {
        // Calculate total sales from all orders
        List<Order> orders = getAllOrders();
        double totalSales = 0.0;
        for (Order order : orders) {
            totalSales += order.getTotalPrice();
        }
        return totalSales;
    }

    /**
     * Place an order with cart items from a map
     * @param order Order object with user details
     * @param cartItems Map of product IDs to quantities
     * @return true if order placed successfully, false otherwise
     */
    public boolean placeOrder(Order order, java.util.Map<Integer, Integer> cartItems) {
        if (cartItems == null || cartItems.isEmpty()) {
            return false;
        }

        // Check stock for all items
        for (java.util.Map.Entry<Integer, Integer> entry : cartItems.entrySet()) {
            int productId = entry.getKey();
            int quantity = entry.getValue();

            if (!productService.hasEnoughStock(productId, quantity)) {
                return false; // Not enough stock
            }
        }

        // Create order in database
        boolean success = orderDAO.createOrder(order);

        if (!success) {
            return false;
        }

        // Create order items
        for (java.util.Map.Entry<Integer, Integer> entry : cartItems.entrySet()) {
            int productId = entry.getKey();
            int quantity = entry.getValue();

            // Get product information
            model.Product product = productDAO.getProductById(productId);
            if (product == null) continue;

            OrderItem orderItem = new OrderItem();
            orderItem.setOrderId(order.getId());
            orderItem.setProductId(productId);
            orderItem.setProductName(product.getName());
            orderItem.setPrice(product.getPrice());
            orderItem.setQuantity(quantity);
            orderItem.setImageUrl(product.getImageUrl());

            // Add order item to database
            orderDAO.addOrderItem(orderItem);

            // Update product stock
            productService.updateProductStock(productId, quantity);
        }

        return true;
    }

    // Methods updateOrderStatus and updateOrder are already defined above

    /**
     * Delete order
     * @param orderId Order ID to delete
     * @return true if successful, false otherwise
     */
    public boolean deleteOrder(int orderId) {
        return orderDAO.deleteOrder(orderId);
    }
}
