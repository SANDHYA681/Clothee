<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>

<%
    // Get products from request
    List<Product> products = (List<Product>) request.getAttribute("products");

    // Get user from session
    User user = (User) session.getAttribute("user");

    // Get category from request
    String category = request.getParameter("category");
    if (category == null) {
        category = "All Products";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= category %> - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #f4f3f0;
            --secondary-color: #ffa640;
            --dark-color: #2d3436;
            --light-color: #f9f9f9;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f5f5f5;
            color: #333;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        header {
            background-color: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 15px 0;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--dark-color);
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

        .nav-links {
            display: flex;
            align-items: center;
        }

        .nav-link {
            margin-left: 20px;
            text-decoration: none;
            color: var(--dark-color);
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .nav-link:hover {
            color: var(--primary-color);
        }

        .nav-link.active {
            color: var(--primary-color);
        }

        .nav-icon {
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

        .nav-icon:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .page-header {
            background-color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            text-align: center;
        }

        .page-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 10px;
            color: var(--dark-color);
        }

        .page-description {
            font-size: 16px;
            color: #666;
            max-width: 600px;
            margin: 0 auto;
        }

        .filters {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }

        .filter-label {
            margin-right: 10px;
            font-weight: 500;
        }

        .filter-select {
            padding: 8px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            background-color: white;
            font-family: 'Poppins', sans-serif;
        }

        .search-form {
            display: flex;
            align-items: center;
        }

        .search-input {
            padding: 8px 15px;
            border: 1px solid #ddd;
            border-radius: 4px 0 0 4px;
            width: 250px;
            font-family: 'Poppins', sans-serif;
        }

        .search-button {
            padding: 8px 15px;
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 0 4px 4px 0;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .search-button:hover {
            background-color: var(--secondary-color);
        }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 30px;
        }

        .product-card {
            background-color: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
        }

        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .product-image {
            height: 250px;
            overflow: hidden;
            position: relative;
        }

        .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: all 0.5s ease;
        }

        .product-card:hover .product-image img {
            transform: scale(1.05);
        }

        .product-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            background-color: var(--primary-color);
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }

        .product-actions {
            position: absolute;
            top: 10px;
            right: 10px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .product-action {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background-color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--dark-color);
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .product-action:hover {
            background-color: var(--primary-color);
            color: white;
        }

        .product-info {
            padding: 20px;
        }

        .product-category {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .product-name {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--dark-color);
        }

        .product-price {
            font-size: 20px;
            font-weight: 700;
            color: #000000; /* Dark black color */
            margin-bottom: 15px;
        }

        .product-buttons {
            display: flex;
            gap: 10px;
        }

        .btn {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 4px;
            font-weight: 500;
            text-decoration: none;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            flex: 1;
        }

        .btn-primary {
            background-color: #ffffff;
            color: #000000;
            border: 1px solid #000000;
            font-weight: bold;
        }

        .btn-primary:hover {
            background-color: #000000;
            color: #ffffff;
            transform: translateY(-3px);
        }

        .btn-secondary {
            background-color: #ffffff;
            color: #000000;
            border: 1px solid #000000;
            font-weight: bold;
        }

        .btn-secondary:hover {
            background-color: #000000;
            color: #ffffff;
            transform: translateY(-3px);
        }

        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 50px;
        }

        .pagination-item {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 5px;
            border-radius: 50%;
            background-color: white;
            color: var(--dark-color);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .pagination-item:hover {
            background-color: var(--light-color);
        }

        .pagination-item.active {
            background-color: var(--primary-color);
            color: white;
        }

        footer {
            background-color: var(--dark-color);
            color: white;
            padding: 50px 0 20px;
            margin-top: 50px;
        }

        .footer-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 30px;
        }

        .footer-logo {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            text-decoration: none;
            color: white;
        }

        .footer-description {
            color: rgba(255, 255, 255, 0.7);
            margin-bottom: 20px;
            line-height: 1.6;
        }

        .footer-social {
            display: flex;
            gap: 15px;
        }

        .social-link {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background-color: rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .social-link:hover {
            background-color: var(--primary-color);
            transform: translateY(-3px);
        }

        .footer-heading {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            color: white;
        }

        .footer-links {
            list-style: none;
        }

        .footer-link {
            margin-bottom: 10px;
        }

        .footer-link a {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .footer-link a:hover {
            color: var(--primary-color);
        }

        .footer-bottom {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            text-align: center;
            color: rgba(255, 255, 255, 0.5);
            font-size: 14px;
        }

        @media (max-width: 768px) {
            .header-container {
                flex-direction: column;
                align-items: flex-start;
            }

            .nav-links {
                margin-top: 15px;
                width: 100%;
                justify-content: space-between;
            }

            .nav-link {
                margin-left: 0;
            }

            .filters {
                flex-direction: column;
                align-items: flex-start;
            }

            .search-form {
                width: 100%;
                margin-top: 15px;
            }

            .search-input {
                width: 100%;
            }

            .product-grid {
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="page-container header-container">
            <a href="index.jsp" class="logo">
                <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                <span class="logo-text">CLOTHEE</span>
            </a>

            <div class="nav-links">
                <a href="index.jsp" class="nav-link">Home</a>
                <a href="ProductServlet" class="nav-link active">Shop</a>
                <a href="about.jsp" class="nav-link">About</a>
                <a href="contact.jsp" class="nav-link">Contact</a>

                <a href="CartServlet?action=view" class="nav-icon" title="Cart">
                    <i class="fas fa-shopping-cart"></i>
                </a>

                <% if (user != null) { %>
                <a href="<%= user.isAdmin() ? "admin/dashboard.jsp" : "customer/dashboard.jsp" %>" class="nav-icon" title="Dashboard">
                    <i class="fas fa-user"></i>
                </a>
                <% } else { %>
                <a href="login.jsp" class="nav-icon" title="Login">
                    <i class="fas fa-sign-in-alt"></i>
                </a>
                <% } %>
            </div>
        </div>
    </header>

    <div class="page-header">
        <div class="container">
            <h1 class="page-title"><%= category %></h1>
            <p class="page-description">Discover our latest collection of high-quality clothing and accessories.</p>
        </div>
    </div>

    <div class="container">
        <div class="filters">
            <div class="filter-group">
                <label class="filter-label">Category:</label>
                <select class="filter-select" id="categoryFilter" onchange="filterByCategory()">
                    <option value="">All Categories</option>
                    <option value="Men" <%= "Men".equals(category) ? "selected" : "" %>>Men</option>
                    <option value="Women" <%= "Women".equals(category) ? "selected" : "" %>>Women</option>
                    <option value="Kids" <%= "Kids".equals(category) ? "selected" : "" %>>Kids</option>
                    <option value="Accessories" <%= "Accessories".equals(category) ? "selected" : "" %>>Accessories</option>
                </select>
            </div>

            <div class="filter-group">
                <label class="filter-label">Sort By:</label>
                <select class="filter-select" id="sortFilter">
                    <option value="default">Default</option>
                    <option value="price-low">Price: Low to High</option>
                    <option value="price-high">Price: High to Low</option>
                    <option value="name-asc">Name: A to Z</option>
                    <option value="name-desc">Name: Z to A</option>
                </select>
            </div>

            <form class="search-form" action="ProductServlet" method="get">
                <input type="hidden" name="action" value="search">
                <input type="text" name="keyword" class="search-input" placeholder="Search products...">
                <button type="submit" class="search-button"><i class="fas fa-search"></i></button>
            </form>
        </div>

        <div class="product-grid">
            <% if (products != null && !products.isEmpty()) {
                for (Product product : products) { %>
                <div class="product-card">
                    <div class="product-image">
                        <img src="<%= request.getContextPath() %>/<%= product.getImageUrl() != null ? product.getImageUrl() : "images/products/placeholder.jpg" %>" alt="<%= product.getName() %>">
                        <% if (product.isFeatured()) { %>
                        <div class="product-badge" style="background-color: #ffffff; color: #000000; border: 1px solid #000000; font-weight: bold; padding: 5px 10px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);">Featured</div>
                        <% } %>
                        <div class="product-actions">
                            <a href="ProductDetailsServlet?id=<%= product.getId() %>" class="product-action" title="Quick View">
                                <i class="fas fa-eye"></i>
                            </a>
                        </div>
                    </div>
                    <div class="product-info">
                        <div class="product-category" style="color: #000000;"><%= product.getCategory() %></div>
                        <h3 class="product-name" style="color: #000000;"><%= product.getName() %></h3>
                        <div class="product-price" style="color: #000000; font-weight: bold;">$<%= String.format("%.2f", product.getPrice()) %></div>
                        <div class="product-buttons">
                            <a href="CartServlet?action=add&productId=<%= product.getId() %>" class="btn btn-primary" style="color: #000000; background-color: #ffffff; border: 1px solid #000000; font-weight: bold;">Add to Cart</a>
                            <a href="ProductDetailsServlet?id=<%= product.getId() %>" class="btn btn-secondary" style="color: #000000; background-color: #ffffff; border: 1px solid #000000; font-weight: bold;">View</a>
                        </div>
                    </div>
                </div>
            <% }
            } else { %>
                <div style="grid-column: 1 / -1; text-align: center; padding: 50px 0;">
                    <i class="fas fa-search" style="font-size: 48px; color: #ddd; margin-bottom: 20px;"></i>
                    <h2>No Products Found</h2>
                    <p>We couldn't find any products matching your criteria.</p>
                </div>
            <% } %>
        </div>

        <!-- Pagination would go here if needed -->
    </div>

    <footer>
        <div class="container">
            <div class="footer-container">
                <div>
                    <a href="index.jsp" class="footer-logo">
                        <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                        <span class="logo-text">CLOTHEE</span>
                    </a>
                    <p class="footer-description">
                        CLOTHEE offers high-quality clothing and accessories for men, women, and kids.
                        Shop our latest collections and stay stylish.
                    </p>
                    <div class="footer-social">
                        <a href="#" class="social-link"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-pinterest"></i></a>
                    </div>
                </div>

                <div>
                    <h3 class="footer-heading">Quick Links</h3>
                    <ul class="footer-links">
                        <li class="footer-link"><a href="index.jsp">Home</a></li>
                        <li class="footer-link"><a href="ProductServlet">Shop</a></li>
                        <li class="footer-link"><a href="about.jsp">About Us</a></li>
                        <li class="footer-link"><a href="contact.jsp">Contact</a></li>
                    </ul>
                </div>

                <div>
                    <h3 class="footer-heading">Customer Service</h3>
                    <ul class="footer-links">
                        <li class="footer-link"><a href="#">FAQ</a></li>
                        <li class="footer-link"><a href="#">Shipping & Returns</a></li>
                        <li class="footer-link"><a href="#">Terms & Conditions</a></li>
                        <li class="footer-link"><a href="#">Privacy Policy</a></li>
                    </ul>
                </div>

                <div>
                    <h3 class="footer-heading">Contact Us</h3>
                    <ul class="footer-links">
                        <li class="footer-link"><i class="fas fa-map-marker-alt"></i> 123 Fashion St, City</li>
                        <li class="footer-link"><i class="fas fa-phone"></i> +1 234 567 890</li>
                        <li class="footer-link"><i class="fas fa-envelope"></i> info@clothee.com</li>
                    </ul>
                </div>
            </div>

            <div class="footer-bottom">
                <p>&copy; 2023 CLOTHEE. All Rights Reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        function filterByCategory() {
            const category = document.getElementById('categoryFilter').value;
            if (category) {
                window.location.href = 'ProductServlet?category=' + category;
            } else {
                window.location.href = 'ProductServlet';
            }
        }

        document.getElementById('sortFilter').addEventListener('change', function() {
            const sortValue = this.value;
            // Implement sorting logic here
            // This would typically involve reloading the page with a sort parameter
            // or using JavaScript to sort the products on the client side
        });
    </script>
</body>
</html>
