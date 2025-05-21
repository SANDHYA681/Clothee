<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>


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


    // Get error message if any
    String errorMessage = (String) request.getAttribute("addressErrorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Address - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/orange-sidebar.css?v=1.1">

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

    .alert-danger {
        background-color: #ffebcc;
        color: #ff8800;
        border: 1px solid #ffcc80;
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
        background-color: #6c757d !important;
    }

    .btn-secondary:hover {
        background-color: #5a6268 !important;
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

    .form-group {
        margin-bottom: 15px;
    }

    .form-group label {
        display: block;
        margin-bottom: 5px;
        font-weight: 500;
        color: #333;
    }

    .form-group input,
    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 10px 15px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
        transition: all 0.3s ease;
    }

    .form-group input:focus,
    .form-group select:focus,
    .form-group textarea:focus {
        border-color: #ff8800;
        box-shadow: 0 0 0 3px rgba(255, 136, 0, 0.1);
        outline: none;
    }

    .form-row {
        display: flex;
        gap: 15px;
    }

    .form-row .form-group {
        flex: 1;
    }

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 20px;
    }

    .checkbox-container {
        display: block;
        position: relative;
        padding-left: 30px;
        margin-bottom: 12px;
        cursor: pointer;
        font-size: 14px;
        color: #333;
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

        .form-row {
            flex-direction: column;
            gap: 0;
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
                <h1 class="page-title">Edit Address</h1>
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

            <% if (errorMessage != null) { %>
            <div class="alert alert-danger">
                <%= errorMessage %>
            </div>
            <% } %>

            <div class="dashboard-section-card">
                <h3>Edit Address</h3>

                <form action="<%=request.getContextPath()%>/AddressServlet" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= address.getId() %>">

                    <div class="form-group">
                        <label for="street">Street Address</label>
                        <input type="text" id="street" name="street" value="<%= address.getStreet() %>" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="city">City</label>
                            <input type="text" id="city" name="city" value="<%= address.getCity() %>" required>
                        </div>

                        <div class="form-group">
                            <label for="state">State/Province</label>
                            <input type="text" id="state" name="state" value="<%= address.getState() %>" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="zipCode">Zip/Postal Code</label>
                            <input type="text" id="zipCode" name="zipCode" value="<%= address.getZipCode() %>" required>
                        </div>

                        <div class="form-group">
                            <label for="country">Country</label>
                            <select id="country" name="country" required>
                                <option value="">Select Country</option>
                                <option value="United States" <%= "United States".equals(address.getCountry()) ? "selected" : "" %>>United States</option>
                                <option value="Canada" <%= "Canada".equals(address.getCountry()) ? "selected" : "" %>>Canada</option>
                                <option value="United Kingdom" <%= "United Kingdom".equals(address.getCountry()) ? "selected" : "" %>>United Kingdom</option>
                                <option value="Australia" <%= "Australia".equals(address.getCountry()) ? "selected" : "" %>>Australia</option>
                                <option value="India" <%= "India".equals(address.getCountry()) ? "selected" : "" %>>India</option>
                                <option value="Germany" <%= "Germany".equals(address.getCountry()) ? "selected" : "" %>>Germany</option>
                                <option value="France" <%= "France".equals(address.getCountry()) ? "selected" : "" %>>France</option>
                                <option value="Japan" <%= "Japan".equals(address.getCountry()) ? "selected" : "" %>>Japan</option>
                                <option value="China" <%= "China".equals(address.getCountry()) ? "selected" : "" %>>China</option>
                                <option value="Brazil" <%= "Brazil".equals(address.getCountry()) ? "selected" : "" %>>Brazil</option>
                                <option value="Mexico" <%= "Mexico".equals(address.getCountry()) ? "selected" : "" %>>Mexico</option>
                                <option value="South Africa" <%= "South Africa".equals(address.getCountry()) ? "selected" : "" %>>South Africa</option>
                                <option value="Other" <%= "Other".equals(address.getCountry()) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="checkbox-container">
                            <input type="checkbox" id="isDefault" name="isDefault" <%= address.isDefault() ? "checked" : "" %>>
                            <span class="checkmark"></span>
                            Set as default address
                        </label>
                    </div>

                    <div class="form-actions">
                        <a href="addresses.jsp" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn">Update Address</button>
                    </div>
                </form>
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
