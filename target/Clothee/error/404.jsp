<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    <style>
        :root {
            --primary-color: #ff6b6b;
            --secondary-color: #f5f5f5;
            --text-dark: #333;
            --text-medium: #666;
            --text-light: #999;
            --border-color: #ddd;
            --background-light: #f9f9f9;
            --shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            line-height: 1.6;
            color: var(--text-dark);
            background-color: var(--background-light);
        }

        .error-container {
            text-align: center;
            padding: 100px 20px;
            max-width: 800px;
            margin: 0 auto;
        }

        .error-code {
            font-size: 120px;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 20px;
        }

        .error-message {
            font-size: 24px;
            margin-bottom: 30px;
        }

        .error-description {
            font-size: 16px;
            color: var(--text-medium);
            margin-bottom: 40px;
        }

        .btn {
            display: inline-block;
            padding: 12px 24px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-weight: bold;
            transition: background-color 0.3s;
        }

        .btn:hover {
            background-color: #ff5252;
        }

        .error-details {
            margin-top: 40px;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: var(--shadow);
            text-align: left;
        }

        .error-details h2 {
            font-size: 18px;
            margin-bottom: 10px;
            color: var(--primary-color);
        }

        .error-details p {
            margin-bottom: 10px;
            font-size: 14px;
        }

        .error-details code {
            display: block;
            padding: 10px;
            background-color: var(--secondary-color);
            border-radius: 4px;
            margin-bottom: 10px;
            font-family: monospace;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">404</div>
        <h1 class="error-message">Page Not Found</h1>
        <p class="error-description">The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.</p>
        <a href="<%= contextPath %>/index.jsp" class="btn">Go to Homepage</a>

        <div class="error-details">
            <h2>Error Details</h2>
            <p><strong>Requested URL:</strong> <%= request.getAttribute("javax.servlet.error.request_uri") != null ? request.getAttribute("javax.servlet.error.request_uri") : request.getRequestURI() %></p>
            <p><strong>Context Path:</strong> <%= request.getContextPath() %></p>
            <p><strong>Servlet Path:</strong> <%= request.getServletPath() %></p>
            <p>If you believe this is an error, please contact the administrator.</p>

            <h3>Available Resources:</h3>
            <ul style="margin-left: 20px;">
                <li><a href="<%= contextPath %>/index.jsp">Homepage</a></li>
                <!-- Test links removed -->
                <li><a href="<%= contextPath %>/CustomerMessageServlet">Customer Messages</a></li>
                <li><a href="<%= contextPath %>/admin/dashboard.jsp">Admin Dashboard</a></li>
            </ul>

            <h3>Troubleshooting:</h3>
            <ul style="margin-left: 20px;">
                <li>Check if the URL is correct</li>
                <li>Ensure the servlet is properly mapped in web.xml</li>
                <li>Verify that the servlet class exists and is compiled</li>
                <li>Check if the JSP files exist in the correct location</li>
                <li>Restart the Tomcat server</li>
            </ul>
        </div>
    </div>
</body>
</html>
