<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.PaymentMethod" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

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

    // Get success and error messages from session
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");

    // Clear messages from session
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Methods - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/dashboard-pro.css">
    <style>
        /* Payment Methods Styles */
        .payment-methods-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .payment-method-card {
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: all 0.3s ease;
            position: relative;
        }

        .payment-method-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
        }

        .payment-method-card.default {
            border: 2px solid #4CAF50;
        }

        .card-header {
            padding: 15px;
            background-color: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .card-type {
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }

        .card-type i {
            font-size: 24px;
        }

        .default-badge {
            background-color: #4CAF50;
            color: white;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }

        .card-body {
            padding: 15px;
        }

        .card-info {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .card-number {
            font-size: 18px;
            font-weight: 600;
            letter-spacing: 1px;
        }

        .card-name {
            color: #666;
        }

        .card-expiry {
            color: #666;
            font-size: 14px;
        }

        .card-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            padding: 10px 15px;
            background-color: #f8f9fa;
            border-top: 1px solid #e9ecef;
        }

        .card-action {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            background-color: #fff;
            border: 1px solid #ddd;
            transition: all 0.2s ease;
        }

        .card-action:hover {
            transform: scale(1.1);
        }

        .edit-action:hover {
            color: #007bff;
            border-color: #007bff;
        }

        .default-action:hover {
            color: #4CAF50;
            border-color: #4CAF50;
        }

        .delete-action:hover {
            color: #dc3545;
            border-color: #dc3545;
        }

        /* Empty State Styles */
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            color: #ddd;
        }

        /* Form Styles */
        .payment-form {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-top: 20px;
            border: 1px solid #e9ecef;
        }

        .payment-form h3 {
            margin-top: 0;
            margin-bottom: 20px;
            color: #333;
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }

        .checkbox-group input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .checkbox-group label {
            cursor: pointer;
            font-weight: normal;
        }

        /* Alert Styles */
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
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
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default.png" alt="<%= user.getFullName() %>">
                        <% } %>
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
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <!-- Wishlist icon removed -->
                    <a href="<%=request.getContextPath()%>/index.jsp" class="header-action" title="Back to Shop">
                        <i class="fas fa-store"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-section">
                <div class="dashboard-section-header">
                    <h2 class="section-title">Your Payment Methods</h2>
                </div>

                <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success">
                    <%= successMessage %>
                </div>
                <% } %>

                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= errorMessage %>
                </div>
                <% } %>

                <div class="payment-methods-list">
                    <%
                    List<PaymentMethod> paymentMethods = (List<PaymentMethod>) request.getAttribute("paymentMethods");
                    if (paymentMethods == null || paymentMethods.isEmpty()) {
                    %>
                    <div class="empty-state">
                        <i class="fas fa-credit-card"></i>
                        <p>You don't have any saved payment methods yet.</p>
                    </div>
                    <% } else { %>
                    <div class="payment-methods-grid">
                        <% for (PaymentMethod method : paymentMethods) { %>
                        <div class="payment-method-card <%= method.isDefault() ? "default" : "" %>">
                            <div class="card-header">
                                <div class="card-type">
                                    <i class="fab <%= method.getCardIconClass() %>"></i>
                                    <span><%= method.getCardType() %></span>
                                </div>
                                <% if (method.isDefault()) { %>
                                <div class="default-badge">Default</div>
                                <% } %>
                            </div>
                            <div class="card-body">
                                <div class="card-info">
                                    <div class="card-number"><%= method.getMaskedCardNumber() %></div>
                                    <div class="card-name"><%= method.getCardName() %></div>
                                    <div class="card-expiry">Expires: <%= method.getExpiryDate() %></div>
                                </div>
                            </div>
                            <div class="card-actions">
                                <a href="#" class="card-action edit-action" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <% if (!method.isDefault()) { %>
                                <a href="#" class="card-action default-action" title="Set as Default">
                                    <i class="fas fa-check-circle"></i>
                                </a>
                                <% } %>
                                <a href="#" class="card-action delete-action" title="Delete">
                                    <i class="fas fa-trash-alt"></i>
                                </a>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>

                <div class="dashboard-section-header">
                    <h2 class="section-title">Add New Payment Method</h2>
                </div>

                <div class="payment-form">
                    <form action="<%=request.getContextPath()%>/PaymentServlet" method="post">
                        <input type="hidden" name="action" value="add_payment_method">

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
                            <input type="text" id="cardName" name="cardName" required>
                        </div>

                        <div class="form-group">
                            <label for="cardNumber">Card Number</label>
                            <input type="text" id="cardNumber" name="cardNumber" placeholder="XXXX XXXX XXXX XXXX" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="expiryDate">Expiry Date</label>
                                <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" required>
                            </div>

                            <div class="form-group">
                                <label for="cvv">CVV</label>
                                <input type="text" id="cvv" name="cvv" placeholder="XXX" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="billingAddress">Billing Address</label>
                            <input type="text" id="billingAddress" name="billingAddress" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="billingCity">City</label>
                                <input type="text" id="billingCity" name="billingCity" required>
                            </div>

                            <div class="form-group">
                                <label for="billingState">State</label>
                                <input type="text" id="billingState" name="billingState" required>
                            </div>

                            <div class="form-group">
                                <label for="billingZip">Zip Code</label>
                                <input type="text" id="billingZip" name="billingZip" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="billingCountry">Country</label>
                            <input type="text" id="billingCountry" name="billingCountry" required>
                        </div>

                        <div class="form-group checkbox-group">
                            <input type="checkbox" id="isDefault" name="isDefault">
                            <label for="isDefault">Set as default payment method</label>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Add Payment Method</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

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
