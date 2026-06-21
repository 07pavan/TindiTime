<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- MVC Guard: Only accessible via HomeServlet (sets featuredRestaurants) --%>
<%-- If accessed directly, redirect to /index servlet --%>
<%-- NOTE: Direct JSP access blocked - must go through HomeServlet --%>

<!DOCTYPE html>
<html lang="en" id="root-html-index">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="HungryGO - Order food online from top-rated restaurants near you. Fast delivery, great offers!">
    <title>HungryGO | Online Food Ordering &amp; Delivery</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/jsp/style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100" id="body-index">

    <!-- Navbar Component -->
    <jsp:include page="navbar.jsp" />

    <!-- ============================================================ -->
    <!-- HERO SECTION                                                  -->
    <!-- ============================================================ -->
    <section class="hero-sec" id="index-hero">
        <div class="container position-relative z-1">
            <div class="row align-items-center gy-5">
                <!-- Left Content -->
                <div class="col-lg-6" id="hero-left-content">
                    <span class="hero-badge"><i class="bi bi-gift-fill me-2"></i>50% Off on your first 3 orders!</span>
                    <h1 class="display-3 text-dark mb-3 tracking-tight">
                        Hungry? Let's get <span class="text-orange">HungryGO</span> deliver it!
                    </h1>
                    <p class="lead text-muted mb-4 fs-5">
                        Discover top-rated local restaurants. Order fresh meals with lightning-fast delivery straight to your door.
                    </p>
                    <!-- Search Bar → Servlet URL /restaurants -->
                    <form action="${pageContext.request.contextPath}/restaurants" method="GET" class="p-2 bg-white rounded-4 shadow-md d-flex flex-column flex-sm-row gap-2" id="hero-search-form">
                        <div class="d-flex align-items-center px-3 flex-grow-1 border-bottom border-sm-0 pb-2 pb-sm-0">
                            <i class="bi bi-search text-muted fs-5 me-2"></i>
                            <input type="text" name="search" class="form-control border-0 shadow-none py-2" placeholder="Search for burgers, pizzas, biryanis..." id="hero-search-input" autocomplete="off">
                        </div>
                        <button type="submit" class="btn btn-orange px-4 py-3 rounded-3 fw-bold fs-6" id="hero-search-btn">Find Restaurants</button>
                    </form>

                    <!-- Popular Cuisine Tags → /restaurants?category=X -->
                    <div class="d-flex align-items-center gap-2 mt-4 flex-wrap" id="popular-cuisines-tags">
                        <span class="small text-muted fw-semibold">Popular Searches:</span>
                        <a href="${pageContext.request.contextPath}/restaurants?category=Burger" class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange" id="tag-burger">Burger</a>
                        <a href="${pageContext.request.contextPath}/restaurants?category=Pizza"  class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange" id="tag-pizza">Pizza</a>
                        <a href="${pageContext.request.contextPath}/restaurants?category=Biryani" class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange" id="tag-biryani">Biryani</a>
                        <a href="${pageContext.request.contextPath}/restaurants?category=Chinese" class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange" id="tag-chinese">Chinese</a>
                    </div>
                </div>

                <!-- Right Illustration -->
                <div class="col-lg-6 position-relative text-center text-lg-end" id="hero-right-illustration">
                    <div class="position-relative d-inline-block">
                        <!-- Floating Cards -->
                        <div class="position-absolute start-0 top-25 bg-white p-3 rounded-4 shadow-lg d-flex align-items-center gap-3 hover-up z-3 text-start animate-float" style="width: 220px;">
                            <div class="bg-warning-subtle text-warning d-flex align-items-center justify-content-center rounded-circle fs-4" style="width: 48px; height: 48px;">
                                <i class="bi bi-star-fill text-warning"></i>
                            </div>
                            <div>
                                <h6 class="mb-0 fw-bold">4.9/5 Rating</h6>
                                <p class="mb-0 fs-8 text-muted">Over 10K+ real reviews</p>
                            </div>
                        </div>
                        <div class="position-absolute end-0 bottom-25 bg-white p-3 rounded-4 shadow-lg d-flex align-items-center gap-3 hover-up z-3 text-start animate-float" style="width: 200px; animation-delay: 1.5s;">
                            <div class="bg-success-subtle text-success d-flex align-items-center justify-content-center rounded-circle fs-4" style="width: 48px; height: 48px;">
                                <i class="bi bi-truck"></i>
                            </div>
                            <div>
                                <h6 class="mb-0 fw-bold">25 Min Delivery</h6>
                                <p class="mb-0 fs-8 text-muted">Lightning Fast Guarantee</p>
                            </div>
                        </div>
                        <!-- Hero Image -->
                        <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80"
                             alt="Delicious spread of dishes"
                             class="img-fluid rounded-4 shadow-lg z-1 position-relative"
                             style="max-height: 440px; width: 100%; object-fit: cover;"
                             id="hero-main-img">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================================ -->
    <!-- FOOD CATEGORIES SLIDER                                        -->
    <!-- ============================================================ -->
    <section class="py-5 bg-white" id="categories-section">
        <div class="container">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h2 class="mb-1 text-dark fs-2 font-display">What's on your mind?</h2>
                    <p class="mb-0 text-muted small">Explore variety of food categories</p>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-light rounded-circle shadow-sm border" onclick="scrollCategories(-200)" aria-label="Scroll left" id="cat-scroll-left"><i class="bi bi-chevron-left"></i></button>
                    <button class="btn btn-light rounded-circle shadow-sm border" onclick="scrollCategories(200)"  aria-label="Scroll right" id="cat-scroll-right"><i class="bi bi-chevron-right"></i></button>
                </div>
            </div>
            <!-- All category links go through /restaurants?category=X Servlet -->
            <div class="d-flex gap-4 overflow-auto pb-3 scrollbar-hidden" id="categories-container" style="scroll-behavior: smooth;">
                <a href="${pageContext.request.contextPath}/restaurants?category=Burger"       class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-burger">
                    <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=150&q=80" alt="Burgers" class="category-img">
                    <div class="mt-2 fw-medium">Burger</div>
                </a>
                <a href="${pageContext.request.contextPath}/restaurants?category=Pizza"        class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-pizza">
                    <img src="https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=150&q=80" alt="Pizzas" class="category-img">
                    <div class="mt-2 fw-medium">Pizza</div>
                </a>
                <a href="${pageContext.request.contextPath}/restaurants?category=Biryani"      class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-biryani">
                    <img src="https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=150&q=80" alt="Biryani" class="category-img">
                    <div class="mt-2 fw-medium">Biryani</div>
                </a>
                <a href="${pageContext.request.contextPath}/restaurants?category=Desserts"     class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-desserts">
                    <img src="https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=150&q=80" alt="Desserts" class="category-img">
                    <div class="mt-2 fw-medium">Desserts</div>
                </a>
                <a href="${pageContext.request.contextPath}/restaurants?category=Chinese"      class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-chinese">
                    <img src="https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=150&q=80" alt="Chinese" class="category-img">
                    <div class="mt-2 fw-medium">Chinese</div>
                </a>
                <a href="${pageContext.request.contextPath}/restaurants?category=Thali" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-north-indian">
                    <img src="https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=150&q=80" alt="Thali" class="category-img">
                    <div class="mt-2 fw-medium">Thali</div>
                </a>
                <a href="${pageContext.request.contextPath}/restaurants?category=South%20Indian" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-south-indian">
                    <img src="https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=150&q=80" alt="South Indian" class="category-img">
                    <div class="mt-2 fw-medium">South Indian</div>
                </a>
                <a href="${pageContext.request.contextPath}/restaurants?category=Japanese"     class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-japanese">
                    <img src="https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=150&q=80" alt="Japanese" class="category-img">
                    <div class="mt-2 fw-medium">Japanese</div>
                </a>
            </div>
        </div>
    </section>

    <!-- ============================================================ -->
    <!-- SPECIAL OFFERS                                                -->
    <!-- ============================================================ -->
    <section class="bg-light py-5" id="offers-carousel-section">
        <div class="container mt-2">
            <h2 class="mb-4 text-dark fs-2 font-display">Special Offers For You</h2>
            <div class="row g-4" id="index-offers-grid">
                <div class="col-md-4" id="offer-card-1">
                    <div class="card border-0 bg-orange text-white p-4 rounded-4 shadow-sm hover-up position-relative overflow-hidden" style="height: 160px;">
                        <i class="bi bi-tag-fill position-absolute end-0 bottom-0 fs-1" style="transform: translate(10px,10px) rotate(-15deg); opacity:.15;"></i>
                        <span class="badge bg-white text-orange fw-bold mb-2 align-self-start">FIRST_BITE</span>
                        <h3 class="mb-1">Flat 50% Off</h3>
                        <p class="small mb-0">Up to ₹800 off on your very first order.</p>
                    </div>
                </div>
                <div class="col-md-4" id="offer-card-2">
                    <div class="card border-0 bg-dark-custom text-white p-4 rounded-4 shadow-sm hover-up position-relative overflow-hidden" style="height: 160px;">
                        <i class="bi bi-truck position-absolute end-0 bottom-0 fs-1" style="transform: translate(10px,10px) rotate(-15deg); opacity:.15;"></i>
                        <span class="badge bg-orange text-white fw-bold mb-2 align-self-start">FREE_DELIVERY</span>
                        <h3 class="mb-1">Free Delivery</h3>
                        <p class="small mb-0">On orders above ₹1200 from partner outlets.</p>
                    </div>
                </div>
                <div class="col-md-4" id="offer-card-3">
                    <div class="card border-0 text-white p-4 rounded-4 shadow-sm hover-up position-relative overflow-hidden" style="background: linear-gradient(135deg, #0984e3 0%, #00cec9 100%); height: 160px;">
                        <i class="bi bi-wallet2 position-absolute end-0 bottom-0 fs-1" style="transform: translate(10px,10px) rotate(-15deg); opacity:.15;"></i>
                        <span class="badge bg-white text-dark fw-bold mb-2 align-self-start">WEEKEND_FEAST</span>
                        <h3 class="mb-1">Feast 30% Off</h3>
                        <p class="small mb-0">Weekend specials with amazing discounts.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================================ -->
    <!-- TOP RATED RESTAURANTS — Data from HomeServlet via DB         -->
    <!-- ============================================================ -->
    <section class="py-5" id="top-rated-restaurants-section">
        <div class="container py-2">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h2 class="mb-1 text-dark fs-2 font-display">Top Rated Restaurants</h2>
                    <p class="mb-0 text-muted small">Verified eateries with premium taste &amp; service</p>
                </div>
                <!-- Link to RestaurantServlet -->
                <a href="${pageContext.request.contextPath}/restaurants" class="btn btn-outline-orange px-4 py-2 rounded-3 fs-7 text-decoration-none" id="view-all-restaurants-btn">View All</a>
            </div>

            <div class="row g-4" id="top-restaurants-grid">
                <%-- featuredRestaurants set by HomeServlet from RestaurantDAOImpl.getAllRestaurants() --%>
                <c:forEach var="restaurant" items="${requestScope.featuredRestaurants}" varStatus="loop">
                    <div class="col-lg-3 col-md-6" id="rest-card-${restaurant.id}">
                        <div class="card restaurant-card hover-up h-100 p-0 border">
                            <div class="restaurant-img-container">
                                <c:if test="${restaurant.rating >= 4.5}">
                                    <span class="badge bg-orange text-white position-absolute top-3 left-3 z-3 shadow-sm px-2 py-1 fs-8 fw-bold">PROMOTED</span>
                                </c:if>
                                <div class="discount-badge">Flat 20% Off</div>
                                <img src="${restaurant.imageUrl}" alt="<c:out value='${restaurant.name}' />">
                            </div>
                            <div class="card-body p-3">
                                <h5 class="card-title text-truncate mb-1 fw-bold text-dark">
                                    <%-- Link goes to /menu?id=X which hits MenuServlet --%>
                                    <a href="${pageContext.request.contextPath}/menu?id=${restaurant.id}" class="text-decoration-none text-dark">
                                        <c:out value="${restaurant.name}" />
                                    </a>
                                </h5>
                                <p class="text-muted small text-truncate mb-2"><c:out value="${restaurant.cuisineType}" /></p>
                                <div class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top">
                                    <div class="badge bg-success d-flex align-items-center gap-1">
                                        <i class="bi bi-star-fill text-white fs-8"></i> <c:out value="${restaurant.rating}" />
                                    </div>
                                    <span class="fs-8 text-muted fw-bold">• <c:out value="${restaurant.deliveryTimeMins}" /> MIN</span>
                                    <span class="fs-8 text-dark fw-bold">₹<c:out value="${restaurant.costForTwo}" /> For Two</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty requestScope.featuredRestaurants}">
                    <div class="col-12 text-center py-5">
                        <i class="bi bi-emoji-frown text-muted display-4"></i>
                        <h5 class="text-secondary mt-2">No Featured Restaurants Available</h5>
                        <p class="text-muted small">Check your database connection or add restaurant data.</p>
                        <a href="${pageContext.request.contextPath}/restaurants" class="btn btn-orange px-4 py-2 mt-2 rounded-3 fw-bold text-white">Browse All Restaurants</a>
                    </div>
                </c:if>
            </div>
        </div>
    </section>

    <!-- ============================================================ -->
    <!-- WHY CHOOSE US                                                 -->
    <!-- ============================================================ -->
    <section class="border-top py-5 bg-white" id="why-choose-us">
        <div class="container my-2">
            <div class="row align-items-center gy-4 text-center text-md-start">
                <div class="col-md-4" id="feature-1">
                    <div class="d-flex flex-column flex-md-row align-items-center align-items-md-start gap-3">
                        <div class="p-3 bg-orange-subtle rounded-4 text-orange fs-2 d-inline-block">
                            <i class="bi bi-clock-history"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold text-dark">No Minimum Order</h5>
                            <p class="small text-muted mb-0">Order for yourself or the whole crew. We place no boundaries on order requirements.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4" id="feature-2">
                    <div class="d-flex flex-column flex-md-row align-items-center align-items-md-start gap-3">
                        <div class="p-3 bg-orange-subtle rounded-4 text-orange fs-2 d-inline-block">
                            <i class="bi bi-geo-fill"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold text-dark">Live Order Tracking</h5>
                            <p class="small text-muted mb-0">Know where your meal is at all times. Track from kitchen to your doorbell.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4" id="feature-3">
                    <div class="d-flex flex-column flex-md-row align-items-center align-items-md-start gap-3">
                        <div class="p-3 bg-orange-subtle rounded-4 text-orange fs-2 d-inline-block">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold text-dark">Safety First Deliveries</h5>
                            <p class="small text-muted mb-0">Vaccinated riders, contact-free options, and full sanitization protocols.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <jsp:include page="footer.jsp" />

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function scrollCategories(amount) {
            const c = document.getElementById('categories-container');
            if (c) c.scrollBy({ left: amount, behavior: 'smooth' });
        }
    </script>
</body>
</html>
