<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // This is a simple redirect page to forward requests to the AdminReviewServlet
    response.sendRedirect(request.getContextPath() + "/admin/AdminReviewServlet");
%>
