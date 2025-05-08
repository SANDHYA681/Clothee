<%@ include file="includes/header.jsp" %>
<link rel="stylesheet" type="text/css" href="css/categories.css">

<div class="page-header" style="background-image: url('https://images.unsplash.com/photo-1558769132-cb1aea458c5e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');">
    <div class="page-header-content">
        <h1 class="page-title">FASHION COLLECTIONS</h1>
        <p class="page-subtitle">Explore our exclusive collections and find your perfect style statement.</p>
    </div>
</div>

<section class="section">
    <div class="container">
        <%
            // Get the active tab from the request parameter
            String activeTab = request.getParameter("tab");
            if (activeTab == null) {
                activeTab = "traditional"; // Default tab
            }
        %>
        <div class="category-tabs">
            <a href="categories.jsp?tab=traditional" class="tab-btn <%= "traditional".equals(activeTab) ? "active" : "" %>">Traditional Dress</a>
            <a href="categories.jsp?tab=aesthetic" class="tab-btn <%= "aesthetic".equals(activeTab) ? "active" : "" %>">Aesthetic Dress</a>
            <a href="categories.jsp?tab=formal" class="tab-btn <%= "formal".equals(activeTab) ? "active" : "" %>">Formal Dress</a>
        </div>

        <div class="tab-content <%= "traditional".equals(activeTab) ? "active" : "" %>" id="traditional">
            <h2 class="category-title">Traditional Dress Collection</h2>
            <p class="category-description">Celebrate cultural heritage with our exquisite collection of traditional attire. Perfect for cultural events, festivals, and special occasions.</p>

            <div class="row">
                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=traditional&type=women" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?ixlib=rb-1.2.1&auto=format&fit=crop&w=772&q=80" alt="Women's Traditional">
                        </div>
                        <div class="category-content">
                            <h3>Women's Traditional</h3>
                            <p>Elegant sarees, lehengas, and ethnic wear for women.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>

                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=traditional&type=men" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1594122230689-45899d9e6f69?ixlib=rb-1.2.1&auto=format&fit=crop&w=774&q=80" alt="Men's Traditional">
                        </div>
                        <div class="category-content">
                            <h3>Men's Traditional</h3>
                            <p>Sophisticated kurtas, sherwanis, and ethnic ensembles.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>

                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=traditional&type=accessories" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1611591437281-460bfbe1220a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1072&q=80" alt="Traditional Accessories">
                        </div>
                        <div class="category-content">
                            <h3>Traditional Accessories</h3>
                            <p>Authentic jewelry and accessories to complete your look.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="tab-content <%= "aesthetic".equals(activeTab) ? "active" : "" %>" id="aesthetic">
            <h2 class="category-title">Aesthetic Dress Collection</h2>
            <p class="category-description">Express your unique style with our aesthetic clothing collection. Trendy, Instagram-worthy outfits for the fashion-forward.</p>

            <div class="row">
                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=aesthetic&type=casual" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1581044777550-4cfa60707c03?ixlib=rb-4.0.3&auto=format&fit=crop&w=772&q=80" alt="Casual Aesthetic">
                        </div>
                        <div class="category-content">
                            <h3>Casual Aesthetic</h3>
                            <p>Effortlessly stylish everyday wear with aesthetic appeal.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>

                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=aesthetic&type=streetwear" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1523398002811-999ca8dec234?ixlib=rb-1.2.1&auto=format&fit=crop&w=774&q=80" alt="Streetwear">
                        </div>
                        <div class="category-content">
                            <h3>Streetwear</h3>
                            <p>Bold, trendy streetwear for making a statement.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>

                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=aesthetic&type=vintage" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1509631179647-0177331693ae?ixlib=rb-1.2.1&auto=format&fit=crop&w=1072&q=80" alt="Vintage Aesthetic">
                        </div>
                        <div class="category-content">
                            <h3>Vintage Aesthetic</h3>
                            <p>Retro-inspired pieces with a modern twist.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="tab-content <%= "formal".equals(activeTab) ? "active" : "" %>" id="formal">
            <h2 class="category-title">Formal Dress Collection</h2>
            <p class="category-description">Make a lasting impression with our sophisticated formal wear. Perfect for business meetings, interviews, and special occasions.</p>

            <div class="row">
                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=formal&type=business" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1580657018950-c7f7d6a6d990?ixlib=rb-1.2.1&auto=format&fit=crop&w=772&q=80" alt="Business Attire">
                        </div>
                        <div class="category-content">
                            <h3>Business Attire</h3>
                            <p>Professional suits and business wear for the workplace.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>

                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=formal&type=evening" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1566174053879-31528523f8ae?ixlib=rb-1.2.1&auto=format&fit=crop&w=774&q=80" alt="Evening Wear">
                        </div>
                        <div class="category-content">
                            <h3>Evening Wear</h3>
                            <p>Elegant gowns and tuxedos for special occasions.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>

                <div class="col-3">
                    <div class="category-card clickable">
                        <a href="products.jsp?category=formal&type=accessories" class="card-link"></a>
                        <div class="category-image">
                            <img src="https://images.unsplash.com/photo-1584917865442-de89df76afd3?ixlib=rb-4.0.3&auto=format&fit=crop&w=870&q=80" alt="Formal Accessories">
                        </div>
                        <div class="category-content">
                            <h3>Formal Accessories</h3>
                            <p>Sophisticated accessories to complete your formal look.</p>
                            <span class="category-btn">Explore</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- JavaScript removed as requested -->

<%@ include file="includes/footer.jsp" %>
