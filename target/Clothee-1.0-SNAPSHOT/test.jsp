<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Page</title>
</head>
<body>
    <h1>Test Page</h1>
    <p>This is a test page to verify that JSP files are working correctly.</p>
    
    <h2>Links to Test Servlets</h2>
    <ul>
        <li><a href="<%= request.getContextPath() %>/TestServlet">Test Servlet</a></li>
        <li><a href="<%= request.getContextPath() %>/CustomerMessageServlet">Customer Message Servlet</a></li>
    </ul>
    
    <h2>Debug Information</h2>
    <p>Context Path: <%= request.getContextPath() %></p>
    <p>Servlet Path: <%= request.getServletPath() %></p>
    <p>Request URI: <%= request.getRequestURI() %></p>
</body>
</html>
