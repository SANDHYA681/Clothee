<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Download Product Images - CLOTHEE Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/admin/style.css">
</head>
<body>
    <%
        // Check if user is logged in and is admin
        User user = (User) session.getAttribute("user");
        if (user == null || !user.isAdmin()) {
            response.sendRedirect("../LoginServlet");
            return;
        }
    %>

    <div class="dashboard-container">
        <%@ include file="includes/sidebar.jsp" %>

        <div class="admin-content">
            <%@ include file="includes/header.jsp" %>

            <div class="content-wrapper">
                <div class="page-header">
                    <h1>Download Product Images</h1>
                    <p>Download sample product images for your store</p>
                </div>

                <%-- Display success message if any --%>
                <% if (session.getAttribute("successMessage") != null) { %>
                    <div class="alert alert-success">
                        <%= session.getAttribute("successMessage") %>
                        <% session.removeAttribute("successMessage"); %>
                    </div>
                <% } %>

                <%-- Display error message if any --%>
                <% if (session.getAttribute("errorMessage") != null) { %>
                    <div class="alert alert-danger">
                        <%= session.getAttribute("errorMessage") %>
                        <% session.removeAttribute("errorMessage"); %>
                    </div>
                <% } %>

                <div class="card">
                    <div class="card-header">
                        <h2>Product Image Categories</h2>
                    </div>
                    <div class="card-body">
                        <p>Click on a category to download sample images for that category, or download all categories at once.</p>

                        <div class="category-grid">
                            <div class="category-card">
                                <div class="category-icon">
                                    <i class="fas fa-male"></i>
                                </div>
                                <h3>Men's Clothing</h3>
                                <p>T-shirts, shirts, jeans, jackets, etc.</p>
                                <a href="../ImageDownloadServlet?action=download&category=men" class="btn btn-primary">Download Men's Images</a>
                            </div>

                            <div class="category-card">
                                <div class="category-icon">
                                    <i class="fas fa-female"></i>
                                </div>
                                <h3>Women's Clothing</h3>
                                <p>Dresses, blouses, jeans, skirts, etc.</p>
                                <a href="../ImageDownloadServlet?action=download&category=women" class="btn btn-primary">Download Women's Images</a>
                            </div>

                            <div class="category-card">
                                <div class="category-icon">
                                    <i class="fas fa-child"></i>
                                </div>
                                <h3>Kids' Clothing</h3>
                                <p>T-shirts, jeans, dresses, etc.</p>
                                <a href="../ImageDownloadServlet?action=download&category=kids" class="btn btn-primary">Download Kids' Images</a>
                            </div>

                            <div class="category-card">
                                <div class="category-icon">
                                    <i class="fas fa-glasses"></i>
                                </div>
                                <h3>Accessories</h3>
                                <p>Belts, sunglasses, watches, etc.</p>
                                <a href="../ImageDownloadServlet?action=download&category=accessories" class="btn btn-primary">Download Accessories Images</a>
                            </div>
                        </div>

                        <div class="download-all">
                            <a href="../ImageDownloadServlet?action=download" class="btn btn-success">Download All Categories</a>
                        </div>
                    </div>
                </div>

                <div class="card mt-4">
                    <div class="card-header">
                        <h2>Image Usage Instructions</h2>
                    </div>
                    <div class="card-body">
                        <ol>
                            <li>Download the images for the categories you need.</li>
                            <li>Images will be saved to the appropriate directories in your web application.</li>
                            <li>Use these images when creating or updating products in your store.</li>
                            <li>The image paths will be relative to your web application root, e.g., <code>images/products/men/men1.jpg</code>.</li>
                        </ol>

                        <div class="alert alert-info">
                            <strong>Note:</strong> These are sample images for demonstration purposes. In a production environment, you should use your own product images.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="../js/admin/script.js"></script>
</body>
</html>
