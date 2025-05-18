<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="dao.ProductDAO" %>

<%
// Check if user is logged in and is admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

model.User user = (model.User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get product from request attribute or parameter
Product product = (Product) request.getAttribute("product");
List<Product> products = (List<Product>) request.getAttribute("products");

// If accessed directly, get product ID from request parameter
String productIdParam = request.getParameter("id");
int productId = 0;

// If product is null and productIdParam is not null, get product from database
if (product == null && productIdParam != null && !productIdParam.isEmpty()) {
    try {
        productId = Integer.parseInt(productIdParam);
        ProductDAO productDAO = new ProductDAO();
        product = productDAO.getProductById(productId);
    } catch (Exception e) {
        // Invalid product ID or error getting product
        e.printStackTrace();
    }
}

// If products is null, get all products from database
if (products == null) {
    ProductDAO productDAO = new ProductDAO();
    products = productDAO.getAllProducts();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Product Image - Admin Dashboard</title>
    <link rel="stylesheet" href="../css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        .upload-container {
            max-width: 600px;
            margin: 0 auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
        }

        .btn-primary {
            background-color: #ff6b6b;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 15px 25px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: block;
            width: 100%;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .btn-primary:hover {
            background-color: #ff5252;
            transform: translateY(-2px);
            box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
        }

        .image-preview {
            width: 100%;
            height: 300px;
            border: 2px dashed #ddd;
            border-radius: 8px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 20px;
            overflow: hidden;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .image-preview:hover {
            border-color: #4a6bdf;
            background-color: #f8f9ff;
        }

        .image-preview img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .image-preview-placeholder {
            color: #777;
            font-size: 14px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 100%;
            height: 100%;
        }

        .alert {
            padding: 15px;
            border-radius: 4px;
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

        .current-image {
            margin-bottom: 20px;
            text-align: center;
        }

        .current-image img {
            max-width: 100%;
            max-height: 200px;
            border-radius: 4px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .image-preview {
            border: 3px dashed #ccc;
            border-radius: 8px;
            padding: 30px;
            text-align: center;
            margin-bottom: 30px;
            transition: all 0.3s ease;
            background-color: #f9f9f9;
            position: relative;
        }

        .image-preview:hover {
            border-color: #ff6b6b;
            background-color: #fff8f8;
            transform: translateY(-5px);
            box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
        }

        .image-preview::after {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 107, 107, 0.05);
            opacity: 0;
            transition: opacity 0.3s ease;
            pointer-events: none;
        }

        .image-preview:hover::after {
            opacity: 1;
        }

        .image-preview-placeholder {
            color: #666;
        }

        .image-preview-placeholder i {
            font-size: 64px;
            color: #999;
            margin-bottom: 20px;
        }

        .image-preview-placeholder p {
            font-size: 18px;
            margin-top: 10px;
            color: #666;
            font-weight: 500;
        }

        .file-label {
            cursor: pointer;
            display: block;
            width: 100%;
            position: relative;
        }

        /* Add a hint that the area is clickable */
        .file-label::before {
            content: "Click to browse";
            position: absolute;
            bottom: 15px;
            right: 15px;
            background-color: rgba(255, 107, 107, 0.9);
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .file-label:hover::before {
            opacity: 1;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <a href="../index.jsp" class="logo">
                    <span class="logo-icon"><i class="fas fa-tshirt"></i></span>
                    <span class="logo-text">CLOTHEE</span>
                </a>
                <div class="user-info">
                    <div class="user-avatar">
                        <img src="../images/default-profile.jpg" alt="Admin">
                    </div>
                    <div class="user-details">
                        <h4><%= session.getAttribute("userName") %></h4>
                        <p>Administrator</p>
                    </div>
                </div>
            </div>

            <div class="sidebar-menu">
                <a href="dashboard.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tachometer-alt"></i></span>
                    Dashboard
                </a>
                <a href="products.jsp" class="menu-item active">
                    <span class="menu-icon"><i class="fas fa-box"></i></span>
                    Products
                </a>
                <a href="categories.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-tags"></i></span>
                    Categories
                </a>
                <a href="orders.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-shopping-bag"></i></span>
                    Orders
                </a>
                <a href="customers.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-users"></i></span>
                    Customers
                </a>
                <a href="reviews.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-star"></i></span>
                    Reviews
                </a>
                <a href="profile.jsp" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-user-cog"></i></span>
                    Profile
                </a>
                <a href="../LogoutServlet" class="menu-item">
                    <span class="menu-icon"><i class="fas fa-sign-out-alt"></i></span>
                    Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <button id="sidebarToggle" class="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>

                <div class="header-actions">
                    <div class="search-box">
                        <input type="text" placeholder="Search...">
                        <button><i class="fas fa-search"></i></button>
                    </div>

                    <div class="notifications">
                        <button class="notification-btn">
                            <i class="fas fa-bell"></i>
                            <span class="badge">3</span>
                        </button>
                    </div>
                </div>
            </div>

            <div class="content">
                <div class="content-header">
                    <h1>Upload Product Image</h1>
                    <button class="btn-add" onclick="location.href='products.jsp'">
                        <i class="fas fa-arrow-left"></i> Back to Products
                    </button>
                </div>

                <% if (request.getParameter("success") != null && request.getParameter("success").equals("true")) { %>
                    <div class="alert alert-success">
                        <%= request.getParameter("message") %>
                    </div>
                <% } %>

                <% if (request.getParameter("error") != null && request.getParameter("error").equals("true")) { %>
                    <div class="alert alert-danger">
                        <%= request.getParameter("message") %>
                    </div>
                <% } %>

                <div class="upload-container">
                    <form action="../ImageServlet" method="post" enctype="multipart/form-data" id="uploadForm">
                        <% if (product != null) { %>
                            <input type="hidden" name="productId" value="<%= product.getId() %>">
                            <input type="hidden" name="category" value="<%= product.getCategory() %>">
                            <input type="hidden" name="type" value="<%= product.getType() %>">

                            <div class="form-group">
                                <label>Product Name</label>
                                <input type="text" class="form-control" value="<%= product.getName() %>" readonly>
                            </div>

                            <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                <div class="current-image">
                                    <h3>Current Image</h3>
                                    <img src="../<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
                                </div>
                            <% } %>
                        <% } else { %>
                            <div class="form-group">
                                <label for="productId">Select Product</label>
                                <select name="productId" id="productId" class="form-control" required onchange="updateProductInfo(this)">
                                    <option value="">-- Select Product --</option>
                                    <%
                                    if (products != null) {
                                        for (Product p : products) {
                                    %>
                                        <option value="<%= p.getId() %>" data-category="<%= p.getCategory() %>" data-type="<%= p.getType() %>"><%= p.getName() %></option>
                                    <%
                                        }
                                    }
                                    %>
                                </select>
                            </div>
                            <input type="hidden" name="category" id="category">
                            <input type="hidden" name="type" id="type">
                        <% } %>

                        <div class="form-group">
                            <label for="productImage">Upload Image</label>
                            <input type="file" id="productImage" name="productImage" accept="image/*" required>
                            <label for="productImage" class="file-label">
                                <div class="image-preview" id="imagePreview">
                                    <div class="image-preview-placeholder">
                                        <i class="fas fa-cloud-upload-alt"></i>
                                        <p>Click here to select an image</p>
                                    </div>
                                </div>
                            </label>
                        </div>

                        <button type="submit" class="btn-primary">
                            <i class="fas fa-cloud-upload-alt"></i> Upload Image
                        </button>
                        <p style="text-align: center; margin-top: 15px; color: #666; font-size: 14px;">Click the area above to select an image, then click the button to upload</p>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle - UI enhancement only
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });

        // Update hidden fields when product is selected
        function updateProductInfo(selectElement) {
            var selectedOption = selectElement.options[selectElement.selectedIndex];
            document.getElementById('category').value = selectedOption.getAttribute('data-category');
            document.getElementById('type').value = selectedOption.getAttribute('data-type');
        }
    </script>
</body>
</html>
