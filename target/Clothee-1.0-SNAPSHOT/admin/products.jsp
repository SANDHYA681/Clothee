<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>

<%
// Check if user is logged in and is an admin
Object userObj = session.getAttribute("user");
if (userObj == null) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

User user = (User) userObj;
if (!user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}

// Get success and error messages from both request parameters and session attributes
String successMessage = request.getParameter("success");
String errorMessage = request.getParameter("error");

// Check session attributes as well
String sessionSuccessMessage = (String) session.getAttribute("successMessage");
String sessionErrorMessage = (String) session.getAttribute("errorMessage");

// Use session messages if available
if (sessionSuccessMessage != null) {
    successMessage = sessionSuccessMessage;
    session.removeAttribute("successMessage");
}

if (sessionErrorMessage != null) {
    errorMessage = sessionErrorMessage;
    session.removeAttribute("errorMessage");
}

// Get products from request attribute or redirect to AdminProductServlet
List<Product> products = (List<Product>) request.getAttribute("products");

// If products is null, redirect to AdminProductServlet
if (products == null) {
    response.sendRedirect(request.getContextPath() + "/admin/AdminProductServlet");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Management - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin-style.css">
    <link rel="stylesheet" href="../css/admin-blue-theme-all.css">
    <style>
        .product-image-container {
            width: 80px;
            height: 80px;
            overflow: hidden;
            border-radius: 4px;
            position: relative;
        }

        .product-image-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-image-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            opacity: 0;
            transition: opacity 0.3s;
        }

        .product-image-container:hover .product-image-overlay {
            opacity: 1;
        }

        .btn-change-image {
            background-color: #fff;
            color: #333;
            border: none;
            border-radius: 4px;
            padding: 5px 8px;
            font-size: 12px;
            cursor: pointer;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal-content {
            background-color: #fff;
            margin: 10% auto;
            padding: 20px;
            border-radius: 8px;
            width: 50%;
            max-width: 600px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .modal-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin: 0;
        }

        .close-modal {
            font-size: 1.5rem;
            cursor: pointer;
            color: #777;
        }

        .close-modal:hover {
            color: #333;
        }

        .image-preview {
            width: 100%;
            height: 200px;
            border: 2px dashed #ddd;
            border-radius: 8px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 20px;
            overflow: hidden;
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
        }

        .file-input-container {
            position: relative;
            margin-bottom: 20px;
        }

        .file-input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .btn-cancel {
            background-color: #f5f5f5;
            color: #333;
            border: none;
            border-radius: 4px;
            padding: 10px 15px;
            cursor: pointer;
        }

        .btn-upload {
            background-color: #4a6bdf;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 10px 15px;
            cursor: pointer;
        }

        .btn-upload:disabled {
            background-color: #b3b3b3;
            cursor: not-allowed;
        }

        .alert {
            padding: 10px 15px;
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

        /* Empty state styles */
        .empty-state {
            padding: 40px 20px;
            text-align: center;
        }

        .empty-state i {
            color: #ddd;
            margin-bottom: 15px;
        }

        .empty-state p {
            font-size: 18px;
            color: #777;
            margin-bottom: 20px;
        }

        .text-center {
            text-align: center;
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
                        <% if (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) { %>
                            <% if (user.getProfileImage().startsWith("images/")) { %>
                                <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } else { %>
                                <img src="<%=request.getContextPath()%>/images/avatars/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                            <% } %>
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/avatars/default-avatar.jpg" alt="Default Profile Image">
                        <% } %>
                    </div>
                    <div class="user-details">
                        <h4><%= user.getFirstName() %></h4>
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
                    <h1>Product Management</h1>
                    <div class="header-actions" style="display: flex; gap: 10px;">
                        <button class="btn-add" onclick="location.href='upload-product-image.jsp'">
                            <i class="fas fa-image"></i> Upload Images
                        </button>
                        <button class="btn-add" onclick="location.href='../admin/AdminProductServlet?action=showAddForm'">
                            <i class="fas fa-plus"></i> Add New Product
                        </button>
                    </div>
                </div>

                <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success" id="successAlert">
                    <%= successMessage %>
                </div>
                <% } %>
                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger" id="errorAlert">
                    <%= errorMessage %>
                </div>
                <% } %>

                <!-- No JavaScript used as per requirements -->

                <div class="card">
                    <div class="card-header">
                        <h2>Products</h2>
                    </div>

                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Image</th>
                                        <th>Name</th>
                                        <th>Category</th>
                                        <th>Price</th>
                                        <th>Stock</th>
                                        <th>Featured</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (products.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center">
                                            <div class="empty-state">
                                                <i class="fas fa-box-open fa-3x"></i>
                                                <p>No products found</p>
                                                <a href="../admin/AdminProductServlet?action=showAddForm" class="btn-primary">
                                                    <i class="fas fa-plus"></i> Add New Product
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } else { %>
                                        <% for (Product product : products) { %>
                                        <tr>
                                            <td><%= product.getId() %></td>
                                            <td>
                                                <div class="product-image-container">
                                                    <img src="<%= request.getContextPath() %>/<%= (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) ? product.getImageUrl() : "images/placeholder.jpg" %>" alt="<%= product.getName() %>">
                                                    <div class="product-image-overlay">
                                                        <a href="../admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>" class="btn-change-image">
                                                            <i class="fas fa-camera"></i> Change
                                                        </a>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><%= product.getName() %></td>
                                            <td><%= product.getCategory() %> / <%= product.getType() %></td>
                                            <td>$<%= String.format("%.2f", product.getPrice()) %></td>
                                            <td><%= product.getStock() %></td>
                                            <td>
                                                <% if (product.isFeatured()) { %>
                                                    <span class="badge featured">Featured</span>
                                                <% } else { %>
                                                    <span class="badge">No</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <a href="../admin/AdminProductServlet?action=view&id=<%= product.getId() %>" class="btn-view" title="View">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="../admin/AdminProductServlet?action=showEditForm&id=<%= product.getId() %>" class="btn-edit" title="Edit">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="upload-product-image.jsp?id=<%= product.getId() %>" class="btn-image" title="Upload Image">
                                                        <i class="fas fa-image"></i>
                                                    </a>
                                                    <a href="../admin/AdminProductServlet?action=confirmDelete&id=<%= product.getId() %>" class="btn-delete" title="Delete">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Image Upload Modal -->
    <div id="imageModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Update Product Image</h3>
                <span class="close-modal" onclick="closeImageModal()">&times;</span>
            </div>

            <div class="alert alert-success" id="modalSuccessAlert"></div>
            <div class="alert alert-danger" id="modalErrorAlert"></div>

            <form id="imageUploadForm" action="../ImageServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" id="productId" name="productId" value="">

                <div class="image-preview" id="imagePreview">
                    <div class="image-preview-placeholder">
                        <i class="fas fa-image fa-3x"></i>
                        <p>No image selected</p>
                    </div>
                </div>

                <div class="file-input-container">
                    <input type="file" id="productImage" name="productImage" class="file-input" accept="image/*">
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeImageModal()">Cancel</button>
                    <button type="submit" class="btn-upload" id="uploadButton" disabled>Upload Image</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Sidebar toggle - UI enhancement only
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });

        // Image modal functions - UI enhancement only
        function openImageModal(productId) {
            document.getElementById('productId').value = productId;
            document.getElementById('imageModal').style.display = 'block';
            document.getElementById('imagePreview').innerHTML = '<div class="image-preview-placeholder"><i class="fas fa-image fa-3x"></i><p>No image selected</p></div>';
            document.getElementById('productImage').value = '';
            document.getElementById('uploadButton').disabled = true;
            hideModalAlerts();
        }

        function closeImageModal() {
            document.getElementById('imageModal').style.display = 'none';
        }

        // Close modal when clicking outside - UI enhancement only
        window.onclick = function(event) {
            if (event.target == document.getElementById('imageModal')) {
                closeImageModal();
            }
        }

        // Image preview - UI enhancement only
        document.getElementById('productImage').addEventListener('change', function() {
            const file = this.files[0];
            const imagePreview = document.getElementById('imagePreview');

            if (file) {
                const reader = new FileReader();

                reader.onload = function(e) {
                    imagePreview.innerHTML = '<img src="' + e.target.result + '" alt="Preview">';
                    document.getElementById('uploadButton').disabled = false;
                }

                reader.readAsDataURL(file);
            } else {
                imagePreview.innerHTML = '<div class="image-preview-placeholder"><i class="fas fa-image fa-3x"></i><p>No image selected</p></div>';
                document.getElementById('uploadButton').disabled = true;
            }
        });

        // Hide modal alerts - UI enhancement only
        function hideModalAlerts() {
            document.getElementById('modalSuccessAlert').style.display = 'none';
            document.getElementById('modalErrorAlert').style.display = 'none';
        }

        // Show modal alert - UI enhancement only
        function showModalAlert(type, message) {
            const successAlert = document.getElementById('modalSuccessAlert');
            const errorAlert = document.getElementById('modalErrorAlert');

            hideModalAlerts();

            if (type === 'success') {
                successAlert.textContent = message;
                successAlert.style.display = 'block';
            } else {
                errorAlert.textContent = message;
                errorAlert.style.display = 'block';
            }
        }

        // Image upload form submission - UI enhancement only
        document.getElementById('imageUploadForm').addEventListener('submit', function() {
            // Just update UI to show loading state
            const uploadButton = document.getElementById('uploadButton');
            uploadButton.disabled = true;
            uploadButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Uploading...';
            // Let the form submit normally
        });

        // Alert functions - UI enhancement only
        function showAlert(type, message) {
            const alert = document.getElementById(type === 'success' ? 'successAlert' : 'errorAlert');
            alert.textContent = message;
            alert.style.display = 'block';

            setTimeout(function() {
                alert.style.display = 'none';
            }, 5000);
        }

        // Delete confirmation - UI enhancement only
        function confirmDelete(productId) {
            return confirm('Are you sure you want to delete this product?');
        }

        // jQuery-like contains selector for vanilla JS - UI enhancement only
        Element.prototype.contains = function(text) {
            return this.textContent.trim() === text.toString().trim();
        };

        // Check for URL parameters to show alerts - UI enhancement only
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            const message = urlParams.get('message');
            const error = urlParams.get('error');

            if (message) {
                showAlert('success', decodeURIComponent(message));
            }

            if (error) {
                showAlert('error', decodeURIComponent(error));
            }
        };
    </script>
</body>
</html>
