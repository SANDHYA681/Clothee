<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - View Message</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin-simple.css">
</head>
<body>
    <div class="admin-container">
        <!-- Include sidebar -->
        <jsp:include page="../includes/sidebar.jsp" />

        <div class="admin-content">
            <div class="admin-header">
                <h1 class="admin-title">View Message</h1>
                <div>
                    <a href="<%=request.getContextPath()%>/admin/messages" class="admin-btn admin-btn-secondary">Back to Messages</a>
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
                    <div class="admin-message-subject">${message.subject}</div>
                </div>
                <div class="admin-card-body">
                    <div class="admin-message-info">
                        <div class="admin-message-sender">
                            <strong>From:</strong> ${message.name} &lt;${message.email}&gt;
                        </div>
                        <div class="admin-message-date">
                            <strong>Date:</strong> <fmt:formatDate value="${message.createdAt}" pattern="MMM dd, yyyy HH:mm" />
                        </div>
                        <c:if test="${message.read}">
                            <div class="admin-message-read">
                                <strong>Read:</strong> <fmt:formatDate value="${message.readAt}" pattern="MMM dd, yyyy HH:mm" />
                            </div>
                        </c:if>
                    </div>

                    <hr class="admin-divider">

                    <div class="admin-message-body">
                        ${message.message}
                    </div>

                    <div class="admin-reply-form">
                        <h3>Reply</h3>
                        <form action="<%=request.getContextPath()%>/admin/messages" method="post">
                            <input type="hidden" name="action" value="reply">
                            <input type="hidden" name="messageId" value="${message.id}">

                            <div class="admin-form-group">
                                <label class="admin-label" for="replyContent">Your Reply</label>
                                <textarea class="admin-textarea" id="replyContent" name="replyContent" rows="5" required></textarea>
                            </div>

                            <div class="admin-form-group admin-text-right">
                                <button type="submit" class="admin-btn admin-btn-primary">Send Reply</button>
                            </div>
                        </form>
                    </div>
                </div>
                <div class="admin-card-footer">
                    <div class="admin-text-right">
                        <a href="<%=request.getContextPath()%>/admin/messages/delete?id=${message.id}" class="admin-btn admin-btn-danger" onclick="return confirm('Are you sure you want to delete this message?')">Delete Message</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
