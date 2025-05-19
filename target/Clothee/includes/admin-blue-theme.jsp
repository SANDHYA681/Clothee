<%-- Include this file in admin pages to apply the blue theme --%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-blue-theme-main.css">

<%-- Add page-specific blue theme CSS based on the current page --%>
<% if (pageName.equals("messages.jsp")) { %>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-messages-blue.css">
<% } else if (pageName.equals("reviews.jsp")) { %>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-reviews-blue.css">
<% } else if (pageName.equals("customers.jsp")) { %>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-customers-blue.css">
<% } else if (pageName.equals("orders.jsp")) { %>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-orders-blue.css">
<% } else if (pageName.equals("products.jsp")) { %>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-products-blue.css">
<% } else if (pageName.equals("categories.jsp")) { %>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin-categories-blue.css">
<% } %>
