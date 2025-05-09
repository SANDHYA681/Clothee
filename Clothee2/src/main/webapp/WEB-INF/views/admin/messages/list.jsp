<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Messages</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-simple.css">
</head>
<body>
    <div class="admin-container">
        <!-- Include sidebar -->
        <jsp:include page="../includes/sidebar.jsp" />
        
        <div class="admin-content">
            <div class="admin-header">
                <h1 class="admin-title">Messages</h1>
                <div>
                    <a href="<%=request.getContextPath()%>/admin/messages?filter=all" class="admin-btn ${filter eq 'all' ? 'admin-btn-primary' : 'admin-btn-secondary'}">All Messages</a>
                    <a href="<%=request.getContextPath()%>/admin/messages?filter=unread" class="admin-btn ${filter eq 'unread' ? 'admin-btn-primary' : 'admin-btn-secondary'}">
                        Unread <c:if test="${unreadCount > 0}"><span class="admin-badge">${unreadCount}</span></c:if>
                    </a>
                </div>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="admin-alert admin-alert-success">
                    ${sessionScope.successMessage}
                    <% session.removeAttribute("successMessage"); %>
                </div>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="admin-alert admin-alert-danger">
                    ${sessionScope.errorMessage}
                    <% session.removeAttribute("errorMessage"); %>
                </div>
            </c:if>
            
            <div class="admin-card">
                <div class="admin-card-header">
                    <c:choose>
                        <c:when test="${filter eq 'unread'}">Unread Messages</c:when>
                        <c:otherwise>All Messages</c:otherwise>
                    </c:choose>
                </div>
                <div class="admin-card-body">
                    <c:choose>
                        <c:when test="${empty messages}">
                            <p class="admin-text-center">No messages found.</p>
                        </c:when>
                        <c:otherwise>
                            <ul class="admin-message-list">
                                <c:forEach var="message" items="${messages}">
                                    <li class="admin-message-item ${!message.read ? 'unread' : ''}">
                                        <div class="admin-message-sender">${message.name}</div>
                                        <div class="admin-message-subject">
                                            <a href="<%=request.getContextPath()%>/admin/messages/view?id=${message.id}">
                                                ${message.subject}
                                            </a>
                                        </div>
                                        <div class="admin-message-date">
                                            <fmt:formatDate value="${message.createdAt}" pattern="MMM dd, yyyy HH:mm" />
                                        </div>
                                        <div class="admin-message-actions">
                                            <a href="<%=request.getContextPath()%>/admin/messages/view?id=${message.id}" class="admin-btn admin-btn-sm admin-btn-secondary">View</a>
                                            <a href="<%=request.getContextPath()%>/admin/messages/delete?id=${message.id}" class="admin-btn admin-btn-sm admin-btn-danger" onclick="return confirm('Are you sure you want to delete this message?')">Delete</a>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
