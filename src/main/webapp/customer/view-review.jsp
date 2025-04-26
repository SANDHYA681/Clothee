<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Review" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="dao.ProductDAO" %>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check if user is not an admin
    if (user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        return;
    }

    // Get review from request attribute (set by ReviewServlet)
    Review review = (Review) request.getAttribute("review");

    // If review is not in request attribute, try to get it from request parameter
    if (review == null) {
        System.out.println("view-review.jsp: Review object is null in request attribute, checking request parameters");

        String reviewIdStr = request.getParameter("reviewId");
        if (reviewIdStr != null && !reviewIdStr.isEmpty()) {
            System.out.println("view-review.jsp: Found reviewId parameter: " + reviewIdStr);

            try {
                int reviewId = Integer.parseInt(reviewIdStr);
                dao.ReviewDAO reviewDAO = new dao.ReviewDAO();
                review = reviewDAO.getReviewById(reviewId);

                if (review == null) {
                    System.out.println("view-review.jsp: Review not found in database for ID: " + reviewId);
                    response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+not+found");
                    return;
                }

                System.out.println("view-review.jsp: Successfully loaded review from database: ID=" + review.getId());
            } catch (Exception e) {
                System.out.println("view-review.jsp: Error loading review: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Error+loading+review");
                return;
            }
        } else {
            System.out.println("view-review.jsp: No reviewId parameter found");
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Review+ID+is+required");
            return;
        }
    } else {
        System.out.println("view-review.jsp: Review found in request attribute: ID=" + review.getId());
    }

    // Add debugging information
    System.out.println("view-review.jsp: Review details: ID=" + review.getId() + ", ProductID=" + review.getProductId() + ", Rating=" + review.getRating());

    // Get product from review
    Product product = review.getProduct();
    if (product == null) {
        // Add debugging information
        System.out.println("view-review.jsp: Product object is null, trying to load from database");

        try {
            ProductDAO productDAO = new ProductDAO();
            product = productDAO.getProductById(review.getProductId());

            if (product == null) {
                System.out.println("view-review.jsp: Product not found in database, creating placeholder");
                // Create a placeholder product
                product = new Product();
                product.setId(review.getProductId());
                product.setName("Product #" + review.getProductId());
                product.setCategory("Unknown");
                product.setPrice(0.0);
                product.setImageUrl("images/product-placeholder.jpg");
            } else {
                System.out.println("view-review.jsp: Product loaded from database: ID=" + product.getId() + ", Name=" + product.getName());
            }

            // Set product in review
            review.setProduct(product);
        } catch (Exception e) {
            System.out.println("view-review.jsp: Error loading product: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/customer/reviews.jsp?error=Error+loading+product");
            return;
        }
    } else {
        // Add debugging information
        System.out.println("view-review.jsp: Product found in review object: ID=" + product.getId() + ", Name=" + product.getName());
    }

    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Review - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/customer/dashboard-pro.css">
    <style>
        .review-container {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            padding: 30px;
            margin-top: 20px;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #f0f0f0;
        }

        .product-info {
            display: flex;
            align-items: center;
        }

        .product-image {
            width: 80px;
            height: 80px;
            border-radius: 8px;
            overflow: hidden;
            margin-right: 20px;
        }

        .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-details h2 {
            font-size: 20px;
            margin-bottom: 5px;
        }

        .product-details p {
            font-size: 14px;
            color: #777;
            margin: 0;
        }

        .review-date {
            font-size: 14px;
            color: #777;
        }

        .review-rating {
            margin-bottom: 20px;
        }

        .review-rating i {
            color: #ddd;
            font-size: 24px;
            margin-right: 5px;
        }

        .review-rating i.filled {
            color: #ffc107;
        }

        .review-content {
            margin-bottom: 30px;
            line-height: 1.8;
            color: #444;
            font-size: 16px;
        }

        .review-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .btn-back, .btn-edit, .btn-delete {
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn-back {
            background-color: #6c757d;
            color: white;
        }

        .btn-back:hover {
            background-color: #5a6268;
        }

        .btn-edit {
            background-color: #f39c12;
            color: white;
        }

        .btn-edit:hover {
            background-color: #e67e22;
        }

        .btn-delete {
            background-color: #e74c3c;
            color: white;
        }

        .btn-delete:hover {
            background-color: #c0392b;
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
                            <img src="<%=request.getContextPath()%>/<%= user.getProfileImage() %>" alt="<%= user.getFullName() %>">
                        <% } else { %>
                            <img src="<%=request.getContextPath()%>/images/user-placeholder.jpg" alt="<%= user.getFullName() %>">
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= user.getFirstName() + " " + user.getLastName() %></h3>
                    <p class="user-role">Customer</p>

                    <!-- Profile Image Upload Form -->
                    <form action="<%=request.getContextPath()%>/ProfileImageServlet" method="post" enctype="multipart/form-data" class="profile-upload-form">
                        <div class="file-upload-container">
                            <input type="file" name="profileImage" id="dashboardProfileImage" class="file-upload-input" accept="image/*">
                            <label for="dashboardProfileImage" class="file-upload-button">
                                <i class="fas fa-camera"></i> Change Photo
                            </label>
                            <button type="submit" class="btn btn-primary btn-sm" style="margin-top: 10px;">
                                <i class="fas fa-upload"></i> Upload
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <%@ include file="sidebar-menu.jsp" %>
        </div>

        <div class="main-content">
            <div class="dashboard-header">
                <h1 class="page-title">View Review</h1>
                <div class="header-actions">
                    <a href="<%=request.getContextPath()%>/customer/dashboard.jsp" class="header-action" title="Dashboard">
                        <i class="fas fa-tachometer-alt"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/CartServlet?action=view" class="header-action" title="Shopping Cart">
                        <i class="fas fa-shopping-cart"></i>
                    </a>
                    <a href="<%=request.getContextPath()%>/ProductServlet" class="header-action" title="Shop Products">
                        <i class="fas fa-tshirt"></i>
                    </a>
                </div>
            </div>

            <div class="section-card">
                <div class="section-header">
                    <h2 class="section-title">Review Details</h2>
                    <a href="<%=request.getContextPath()%>/CustomerReviewServlet" class="btn-back">
                        <i class="fas fa-arrow-left"></i> Back to Reviews
                    </a>
                </div>

                <!-- Debug Information -->
                <div style="background-color: #f8f9fa; padding: 10px; margin-bottom: 20px; border-left: 4px solid #6c757d;">
                    <h3>Debug Information</h3>
                    <p><strong>Review ID:</strong> <%= review.getId() %></p>
                    <p><strong>Product ID:</strong> <%= review.getProductId() %></p>
                    <p><strong>User ID:</strong> <%= review.getUserId() %></p>
                    <p><strong>Rating:</strong> <%= review.getRating() %></p>
                    <p><strong>Comment:</strong> <%= review.getComment() %></p>
                    <p><strong>Date:</strong> <%= review.getReviewDate() %></p>
                    <p><strong>Product Name:</strong> <%= product.getName() %></p>
                </div>

                <div class="review-container">
                    <div class="review-header">
                        <div class="product-info">
                            <div class="product-image">
                                <% if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) { %>
                                    <img src="<%=request.getContextPath()%>/<%= product.getImageUrl() %>" alt="<%= product.getName() %>">
                                <% } else { %>
                                    <img src="<%=request.getContextPath()%>/images/product-placeholder.jpg" alt="<%= product.getName() %>">
                                <% } %>
                            </div>
                            <div class="product-details">
                                <h2><a href="<%=request.getContextPath()%>/ProductServlet?action=detail&id=<%= product.getId() %>"><%= product.getName() %></a></h2>
                                <p><%= product.getCategory() %></p>
                                <p>Price: $<%= String.format("%.2f", product.getPrice()) %></p>
                            </div>
                        </div>
                        <div class="review-date">
                            <p>Reviewed on: <%= dateFormat.format(review.getReviewDate()) %></p>
                        </div>
                    </div>

                    <div class="review-rating">
                        <% for (int i = 1; i <= 5; i++) { %>
                            <i class="fas fa-star <%= i <= review.getRating() ? "filled" : "" %>"></i>
                        <% } %>
                    </div>

                    <div class="review-content">
                        <p><%= review.getComment() %></p>
                    </div>

                    <div class="review-actions">
                        <a href="<%=request.getContextPath()%>/ReviewServlet?action=edit&reviewId=<%= review.getId() %>" class="btn-edit">
                            <i class="fas fa-edit"></i> Edit Review
                        </a>
                        <a href="<%=request.getContextPath()%>/ReviewServlet?action=delete&reviewId=<%= review.getId() %>&productId=<%= review.getProductId() %>" class="btn-delete" onclick="return confirm('Are you sure you want to delete this review?')">
                            <i class="fas fa-trash"></i> Delete Review
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });

        // Auto-submit profile image form when file is selected
        document.getElementById('dashboardProfileImage').addEventListener('change', function() {
            if (this.files.length > 0) {
                document.querySelector('.profile-upload-form button[type="submit"]').style.display = 'inline-block';
            }
        });
    </script>
</body>
</html>
