<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<%
// Get user from session
User user = (User) session.getAttribute("user");
if (user == null || !user.isAdmin()) {
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Page Title - CLOTHEE</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <!-- Include the sidebar CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/admin-sidebar.css">
    <!-- Include your page-specific CSS here -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin/your-page-specific.css">
</head>
<body>
    <div class="dashboard-container">
        <!-- Include the sidebar -->
        <jsp:include page="includes/sidebar-new.jsp" />

        <!-- Content area -->
        <div class="content">
            <div class="content-header">
                <h1>Your Page Title</h1>
            </div>

            <!-- Your page content goes here -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Section Title</h2>
                </div>
                <div class="card-body">
                    <!-- Your content here -->
                    <p>This is a template for admin pages using the standardized sidebar.</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
