<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Include the customer panel header with sidebar -->
<jsp:include page="includes/customer-panel-header.jsp" />

<div class="customer-breadcrumb">
    <div class="customer-breadcrumb-item">
        <a href="#" class="customer-breadcrumb-link">Test Page</a>
    </div>
</div>

<div class="customer-page-header">
    <h1 class="customer-page-title">Customer Test Page</h1>
</div>

<div class="customer-card">
    <div class="customer-card-header">
        <div class="customer-card-icon">
            <i class="fas fa-user"></i>
        </div>
    </div>
    <div class="customer-card-content">
        <div class="customer-card-value">Test</div>
        <div class="customer-card-label">This is a test page to verify that the customer panel CSS is working correctly.</div>
    </div>
</div>

<!-- Include the customer panel footer -->
<jsp:include page="includes/customer-panel-footer.jsp" />
