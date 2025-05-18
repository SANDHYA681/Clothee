package service;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import dao.CartDAO;
import dao.OrderDAO;
import dao.ProductDAO;
import dao.ShippingDAO;
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
    private ShippingDAO shippingDAO;

    /**
     * Constructor
     */
    public OrderService() {
        this.orderDAO = new OrderDAO();
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
        this.productService = new ProductService();
        this.shippingDAO = new ShippingDAO();
    }

    /**
     * Create a new order from cart
     * @param userId User ID
     * @return Order object if creation successful, null otherwise
     */
    public Order createOrderFromCart(int userId) {
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

        // No need to get shipping address

        // Calculate total price including tax and shipping
        double subtotal = cart.getSubtotal();
        double shipping = subtotal > 50 ? 0.00 : 5.99; // Apply shipping rule
        double tax = subtotal * 0.1; // 10% tax
        double total = subtotal + shipping + tax;

        // Create order
        Order order = new Order();
        order.setUserId(userId);
        order.setTotalPrice(total); // Use the calculated total with tax and shipping
        order.setStatus("Processing");
        order.setOrderDate(new Timestamp(new Date().getTime()));
        // No shipping address or payment method needed

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

        try {
            // Get the order to get the total price and user ID
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                return false;
            }

            // The order.getTotalPrice() should already include tax and shipping
            // since we've updated the createOrderFromCart and placeOrder methods

            // Check if a payment record already exists for this order
            java.sql.Connection conn = util.DBConnection.getConnection();
            try {
                // First check if a payment record already exists
                String checkQuery = "SELECT id FROM payments WHERE order_id = ?";
                java.sql.PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
                checkStmt.setInt(1, orderId);
                java.sql.ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    // Payment record already exists, no need to create another one
                    System.out.println("OrderService: Payment record already exists for order ID: " + orderId);
                    rs.close();
                    checkStmt.close();
                    return true;
                }
                rs.close();
                checkStmt.close();

                // Create payment record
                String query = "INSERT INTO payments (order_id, payment_method, status, payment_date, amount, user_id) VALUES (?, ?, ?, NOW(), ?, ?)";
                java.sql.PreparedStatement stmt = conn.prepareStatement(query);
                stmt.setInt(1, orderId);
                stmt.setString(2, paymentMethod);
                stmt.setString(3, "Completed");
                stmt.setDouble(4, order.getTotalPrice()); // This now includes tax and shipping
                stmt.setInt(5, order.getUserId());

                int rowsAffected = stmt.executeUpdate();
                stmt.close();
                return rowsAffected > 0;
            } finally {
                if (conn != null) {
                    conn.close();
                }
            }
        } catch (Exception e) {
            System.out.println("Error processing payment: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
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

        // Calculate subtotal from cart items
        double subtotal = 0.0;
        for (java.util.Map.Entry<Integer, Integer> entry : cartItems.entrySet()) {
            int productId = entry.getKey();
            int quantity = entry.getValue();
            Product product = productDAO.getProductById(productId);
            if (product != null) {
                subtotal += product.getPrice() * quantity;
            }
        }

        // Calculate shipping and tax
        double shipping = subtotal > 50 ? 0.00 : 5.99; // Apply shipping rule
        double tax = subtotal * 0.1; // 10% tax
        double total = subtotal + shipping + tax;

        // Update order with the correct total price
        order.setTotalPrice(total);

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

    /**
     * Create or update shipping record
     * @param orderId Order ID
     * @param status Shipping status
     * @return true if successful, false otherwise
     */
    public boolean createOrUpdateShipping(int orderId, String status) {
        return shippingDAO.updateShippingStatus(orderId, status);
    }

    /**
     * Get shipping record by order ID
     * @param orderId Order ID
     * @return Shipping object if found, null otherwise
     */
    public model.Shipping getShippingByOrderId(int orderId) {
        return shippingDAO.getShippingByOrderId(orderId);
    }
}
