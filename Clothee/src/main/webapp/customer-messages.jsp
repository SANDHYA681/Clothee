<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // This page simply redirects to the new MVC-based message controller
    response.sendRedirect(request.getContextPath() + "/messages");
%>
