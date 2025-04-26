<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Methods - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/orange-sidebar.css?v=1.1">

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect("../admin/dashboard.jsp");
        return;
    }

    // Get success or error message if any
    String successMessage = (String) session.getAttribute("paymentSuccessMessage");
    String errorMessage = (String) session.getAttribute("paymentErrorMessage");

    // Clear messages after displaying
    if (successMessage != null) {
        session.removeAttribute("paymentSuccessMessage");
    }

    if (errorMessage != null) {
        session.removeAttribute("paymentErrorMessage");
    }
%>

<style>
    :root {
        --primary-color: #ff8800;
        --secondary-color: #ffa640;
        --dark-color: #2d3436;
        --light-color: #f9f9f9;
        --sidebar-width: 250px;
    }

    /* Ensure active menu item is orange */
    .sidebar-menu a.active {
        background-color: #ff8800 !important;
        color: white !important;
    }

    .sidebar-menu a.active i {
        color: white !important;
    }

    body {
        background-color: #f5f5f5;
        padding: 0;
        margin: 0;
        font-family: 'Poppins', sans-serif;
    }

    .dashboard-container {
        display: flex;
        min-height: 100vh;
    }

    .sidebar {
        width: var(--sidebar-width);
        background-color: var(--dark-color);
        color: white;
        position: fixed;
        height: 100vh;
        overflow-y: auto;
        transition: all 0.3s ease;
    }

    .sidebar-header {
        padding: 20px;
        text-align: center;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }

    .logo {
        display: flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        color: white;
        margin-bottom: 10px;
    }

    .logo-icon {
        font-size: 24px;
        color: var(--primary-color);
        margin-right: 10px;
    }

    .logo-text {
        font-size: 24px;
        font-weight: 700;
        letter-spacing: 1px;
    }

    .user-info {
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    .user-avatar {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background-color: var(--primary-color);
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 10px;
        font-size: 32px;
        overflow: hidden;
    }

    .user-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .user-name {
        font-weight: 600;
        margin-bottom: 5px;
    }

    .user-role {
        font-size: 14px;
        color: rgba(255, 255, 255, 0.7);
    }

    .main-content {
        flex: 1;
        margin-left: var(--sidebar-width);
        padding: 20px;
        transition: all 0.3s ease;
    }

    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        background-color: white;
        padding: 15px 20px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    .page-title {
        font-size: 24px;
        font-weight: 600;
    }

    .header-actions {
        display: flex;
        align-items: center;
    }

    .header-action {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: var(--light-color);
        color: var(--dark-color);
        margin-left: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
    }

    .header-action:hover {
        background-color: var(--primary-color);
        color: white;
    }

    .dashboard-section-card {
        background-color: white;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        margin-bottom: 30px;
    }

    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 4px;
    }

    .alert-success {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }

    .alert-danger {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    .btn {
        display: inline-block;
        background-color: var(--primary-color) !important;
        color: white !important;
        padding: 10px 20px;
        border-radius: 5px;
        text-decoration: none;
        font-weight: 500;
        transition: all 0.3s ease;
        border: none;
        cursor: pointer;
    }

    .btn:hover {
        background-color: var(--secondary-color) !important;
        transform: translateY(-3px);
        box-shadow: 0 5px 15px rgba(255, 136, 0, 0.2);
    }

    .btn-secondary {
        background-color: #ff8800 !important;
    }

    .btn-secondary:hover {
        background-color: #ffa640 !important;
    }

    .toggle-sidebar {
        display: none;
        position: fixed;
        top: 20px;
        left: 20px;
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: var(--primary-color);
        color: white;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        z-index: 100;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    }

    @media (max-width: 992px) {
        .sidebar {
            transform: translateX(-100%);
        }

        .sidebar.active {
            transform: translateX(0);
        }

        .main-content {
            margin-left: 0;
        }

        .toggle-sidebar {
            display: flex;
        }
    }
</style>
</head>
<body>
    <div class="dashboard-container">
        <div class="toggle-sidebar" id="toggleSidebar">
            <i class="fas fa-bars"></i>
        </div>

        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="<%=request.getContextPath()%>/index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() != null ? user.getProfileImage() : "default.png" %>" alt="Profile Image">
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">Payment Methods</h1>
                <div class="header-actions">
                    <!-- Wishlist icon removed -->
                    <a href="<%=request.getContextPath()%>/cart.jsp" class="header-action" title="Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="View Store">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

                <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
                <% } %>

                <div class="dashboard-section-card">
                    <div class="payment-methods-list">
                        <h3>Your Saved Payment Methods</h3>

                        <div class="empty-state">
                            <i class="fas fa-credit-card"></i>
                            <p>You don't have any saved payment methods yet.</p>
                        </div>

                        <button class="btn" id="addPaymentBtn" style="background-color: #ff8800 !important;">Add Payment Method</button>
                    </div>

                    <div class="payment-form-container" id="paymentFormContainer" style="display: none;">
                        <h3>Add Payment Method</h3>

                        <form action="../PaymentServlet" method="post" id="paymentForm" class="payment-form">
                            <input type="hidden" name="action" value="add_payment">

                            <div class="form-group">
                                <label for="cardType">Card Type</label>
                                <select id="cardType" name="cardType" required>
                                    <option value="">Select Card Type</option>
                                    <option value="visa">Visa</option>
                                    <option value="mastercard">Mastercard</option>
                                    <option value="amex">American Express</option>
                                    <option value="discover">Discover</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="cardName">Name on Card</label>
                                <input type="text" id="cardName" name="cardName" placeholder="John Doe" required>
                            </div>

                            <div class="form-group">
                                <label for="cardNumber">Card Number</label>
                                <div class="card-number-input">
                                    <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19" required>
                                    <span class="card-icon" id="cardIcon"></span>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label for="expiryDate">Expiry Date</label>
                                    <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" maxlength="5" required>
                                </div>

                                <div class="form-group">
                                    <label for="cvv">CVV</label>
                                    <input type="text" id="cvv" name="cvv" placeholder="123" maxlength="4" required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="billingAddress">Billing Address</label>
                                <textarea id="billingAddress" name="billingAddress" rows="3" required></textarea>
                            </div>

                            <div class="form-group">
                                <label class="checkbox-container">
                                    <input type="checkbox" id="saveCard" name="saveCard" checked>
                                    <span class="checkmark"></span>
                                    Save this card for future purchases
                                </label>
                            </div>

                            <div class="form-actions">
                                <button type="button" class="btn" id="cancelPaymentBtn" style="background-color: #6c757d !important;">Cancel</button>
                                <button type="submit" class="btn" style="background-color: #ff8800 !important;">Add Payment Method</button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="dashboard-section-card payment-security">
                    <h3>Secure Payments</h3>
                    <p>Your payment information is securely processed and stored. We use industry-standard encryption to protect your sensitive data.</p>

                    <div class="security-features">
                        <div class="security-feature">
                            <i class="fas fa-lock"></i>
                            <h4>Encrypted Data</h4>
                            <p>All payment information is encrypted using SSL technology.</p>
                        </div>

                        <div class="security-feature">
                            <i class="fas fa-shield-alt"></i>
                            <h4>PCI Compliant</h4>
                            <p>We follow strict PCI DSS guidelines for secure payment processing.</p>
                        </div>

                        <div class="security-feature">
                            <i class="fas fa-user-shield"></i>
                            <h4>Fraud Protection</h4>
                            <p>Advanced fraud detection systems to protect your transactions.</p>
                        </div>
                    </div>

                    <div class="payment-logos">
                        <img src="../images/payment/visa.png" alt="Visa">
                        <img src="../images/payment/mastercard.png" alt="Mastercard">
                        <img src="../images/payment/amex.png" alt="American Express">
                        <img src="../images/payment/discover.png" alt="Discover">
                        <img src="../images/payment/paypal.png" alt="PayPal">
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
    /* Payment-specific styles that aren't in user-dashboard.css */
    .payment-section {
        padding: 40px 0;
    }

    .empty-state {
        text-align: center;
        padding: 30px 0;
        margin-bottom: 20px;
    }

    .empty-state i {
        font-size: 48px;
        color: #ddd;
        margin-bottom: 15px;
    }

    .empty-state p {
        color: var(--text-medium);
        margin-bottom: 0;
    }

    .payment-methods-container {
        background-color: #fff;
        border-radius: var(--border-radius);
        overflow: hidden;
        box-shadow: var(--shadow-sm);
        margin-bottom: 30px;
    }

    .payment-methods-list {
        padding: 20px;
    }

    .payment-methods-list h3 {
        font-size: 18px;
        margin-bottom: 20px;
        color: var(--text-dark);
    }

    .payment-form-container {
        padding: 20px;
        border-top: 1px solid var(--border-color);
    }

    .payment-form-container h3 {
        font-size: 18px;
        margin-bottom: 20px;
        color: var(--text-dark);
    }

    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 4px;
        transition: var(--transition);
    }

    .form-group select:focus,
    .form-group textarea:focus {
        border-color: #ff8800;
        box-shadow: 0 0 0 3px rgba(255, 136, 0, 0.1);
        outline: none;
    }

    .card-number-input {
        position: relative;
    }

    .card-icon {
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        width: 30px;
        height: 20px;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
    }

    .checkbox-container {
        display: block;
        position: relative;
        padding-left: 30px;
        margin-bottom: 12px;
        cursor: pointer;
        font-size: 14px;
        color: var(--text-dark);
    }

    .checkbox-container input {
        position: absolute;
        opacity: 0;
        cursor: pointer;
        height: 0;
        width: 0;
    }

    .checkmark {
        position: absolute;
        top: 0;
        left: 0;
        height: 20px;
        width: 20px;
        background-color: #eee;
        border-radius: 4px;
    }

    .checkbox-container:hover input ~ .checkmark {
        background-color: #ccc;
    }

    .checkbox-container input:checked ~ .checkmark {
        background-color: #ff8800;
    }

    .checkmark:after {
        content: "";
        position: absolute;
        display: none;
    }

    .checkbox-container input:checked ~ .checkmark:after {
        display: block;
    }

    .checkbox-container .checkmark:after {
        left: 7px;
        top: 3px;
        width: 5px;
        height: 10px;
        border: solid white;
        border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }

    .payment-security {
        background-color: #fff;
        border-radius: var(--border-radius);
        padding: 20px;
        box-shadow: var(--shadow-sm);
    }

    .payment-security h3 {
        font-size: 18px;
        margin-bottom: 15px;
        color: var(--text-dark);
    }

    .payment-security p {
        color: var(--text-medium);
        margin-bottom: 20px;
    }

    .security-features {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        margin-bottom: 30px;
    }

    .security-feature {
        flex: 1;
        min-width: 200px;
        text-align: center;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: var(--border-radius);
        transition: var(--transition);
    }

    .security-feature:hover {
        transform: translateY(-5px);
        box-shadow: var(--shadow-sm);
    }

    .security-feature i {
        font-size: 36px;
        color: #ff8800;
        margin-bottom: 15px;
        transition: all 0.3s ease;
    }

    .security-feature:hover i {
        transform: scale(1.1);
    }

    .security-feature h4 {
        font-size: 16px;
        margin-bottom: 10px;
        color: var(--text-dark);
    }

    .security-feature p {
        font-size: 14px;
        color: var(--text-medium);
        margin-bottom: 0;
    }

    .payment-logos {
        display: flex;
        justify-content: center;
        flex-wrap: wrap;
        gap: 20px;
    }

    .payment-logos img {
        height: 30px;
        object-fit: contain;
        transition: var(--transition);
    }

    .payment-logos img:hover {
        transform: scale(1.1);
    }

    @media (max-width: 992px) {
        .security-features {
            flex-direction: column;
        }
    }

    @media (max-width: 768px) {
        .form-row {
            flex-direction: column;
            gap: 0;
        }
    }
</style>

<script>
    // Show/hide payment form - UI enhancement only
    const addPaymentBtn = document.getElementById('addPaymentBtn');
    const cancelPaymentBtn = document.getElementById('cancelPaymentBtn');
    const paymentFormContainer = document.getElementById('paymentFormContainer');

    addPaymentBtn.addEventListener('click', function() {
        paymentFormContainer.style.display = 'block';
        this.style.display = 'none';
    });

    cancelPaymentBtn.addEventListener('click', function() {
        paymentFormContainer.style.display = 'none';
        addPaymentBtn.style.display = 'block';
    });

    // Card number formatting - UI enhancement only
    const cardNumberInput = document.getElementById('cardNumber');
    const cardIcon = document.getElementById('cardIcon');

    cardNumberInput.addEventListener('input', function(e) {
        // Remove non-digit characters
        let value = this.value.replace(/\D/g, '');

        // Add spaces after every 4 digits
        let formattedValue = '';
        for (let i = 0; i < value.length; i++) {
            if (i > 0 && i % 4 === 0) {
                formattedValue += ' ';
            }
            formattedValue += value[i];
        }

        // Update input value
        this.value = formattedValue;

        // Update card icon based on first digit
        if (value.length > 0) {
            const firstDigit = value[0];

            if (firstDigit === '4') {
                cardIcon.style.backgroundImage = 'url("../images/payment/visa.png")';
            } else if (firstDigit === '5') {
                cardIcon.style.backgroundImage = 'url("../images/payment/mastercard.png")';
            } else if (firstDigit === '3') {
                cardIcon.style.backgroundImage = 'url("../images/payment/amex.png")';
            } else if (firstDigit === '6') {
                cardIcon.style.backgroundImage = 'url("../images/payment/discover.png")';
            } else {
                cardIcon.style.backgroundImage = 'none';
            }
        } else {
            cardIcon.style.backgroundImage = 'none';
        }
    });

    // Expiry date formatting - UI enhancement only
    const expiryDateInput = document.getElementById('expiryDate');

    expiryDateInput.addEventListener('input', function(e) {
        // Remove non-digit characters
        let value = this.value.replace(/\D/g, '');

        // Format as MM/YY
        if (value.length > 0) {
            if (value.length <= 2) {
                this.value = value;
            } else {
                this.value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
        }
    });

    // CVV formatting - UI enhancement only
    const cvvInput = document.getElementById('cvv');

    cvvInput.addEventListener('input', function(e) {
        // Remove non-digit characters
        this.value = this.value.replace(/\D/g, '');
    });

    // Form validation removed - will be handled by server-side validation
</script>

    <script>
        // Toggle sidebar on mobile
        const toggleSidebar = document.getElementById('toggleSidebar');
        const sidebar = document.getElementById('sidebar');

        toggleSidebar.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    </script>
</body>
</html>
