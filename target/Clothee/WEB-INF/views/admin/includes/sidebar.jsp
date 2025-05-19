<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="admin-sidebar">
    <div class="admin-logo">
        Clothee Admin
    </div>
    <nav class="admin-nav">
        <a href="<%=request.getContextPath()%>/admin/dashboard" class="admin-nav-item ${pageContext.request.requestURI.contains('/admin/dashboard') ? 'active' : ''}">
            Dashboard
        </a>
        <a href="<%=request.getContextPath()%>/admin/products" class="admin-nav-item ${pageContext.request.requestURI.contains('/admin/products') ? 'active' : ''}">
            Products
        </a>
        <a href="<%=request.getContextPath()%>/admin/categories" class="admin-nav-item ${pageContext.request.requestURI.contains('/admin/categories') ? 'active' : ''}">
            Categories
        </a>
        <a href="<%=request.getContextPath()%>/admin/orders" class="admin-nav-item ${pageContext.request.requestURI.contains('/admin/orders') ? 'active' : ''}">
            Orders
        </a>
        <a href="<%=request.getContextPath()%>/admin/customers" class="admin-nav-item ${pageContext.request.requestURI.contains('/admin/customers') ? 'active' : ''}">
            Customers
        </a>
        <a href="<%=request.getContextPath()%>/admin/messages" class="admin-nav-item ${pageContext.request.requestURI.contains('/admin/messages') ? 'active' : ''}">
            Messages
            <c:if test="${unreadCount > 0}">
                <span class="admin-badge">${unreadCount}</span>
            </c:if>
        </a>
        <a href="<%=request.getContextPath()%>/admin/settings" class="admin-nav-item ${pageContext.request.requestURI.contains('/admin/settings') ? 'active' : ''}">
            Settings
        </a>
        <a href="<%=request.getContextPath()%>/logout" class="admin-nav-item">
            Logout
        </a>
    </nav>
</div>
