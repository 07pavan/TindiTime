<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en" id="root-html-index">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HungryGO | Online Food Ordering, Delivery Clone of Swiggy</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100" id="body-index">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <!-- Hero Section -->
    <section class="hero-sec" id="index-hero">
        <div class="container position-relative z-1">
            <div class="row align-items-center gy-5">
                <!-- Left Content Column -->
                <div class="col-lg-6" id="hero-left-content">
                    <span class="hero-badge"><i class="bi bi-gift-fill me-2"></i>50% Off on your first 3 orders!</span>
                    <h1 class="display-3 text-dark mb-3 tracking-tight">
                        Hungry? Let's get <span class="text-orange">HungryGO</span> deliver it!
                    </h1>
                    <p class="lead text-muted mb-4 fs-5">
                        Discover top-rated local restaurants. Order yummy, fresh meals with fast deliveries and trace order tracks live.
                    </p>
                    
                    <!-- Real-Time Search Bar -->
                    <form action="restaurants.jsp" method="GET" class="p-2 bg-white rounded-4 shadow-md d-flex flex-column flex-sm-row gap-2" id="hero-search-form">
                        <div class="d-flex align-items-center px-3 flex-grow-1 border-bottom border-sm-0 pb-2 pb-sm-0">
                            <i class="bi bi-search text-muted fs-5 me-2"></i>
                            <input type="text" name="search" class="form-control border-0 shadow-none py-2" placeholder="Search for burgers, pizzas, biryanis or desserts..." required id="hero-search-input">
                        </div>
                        <button type="submit" class="btn btn-orange px-4 py-3 rounded-3 fw-bold fs-6">Find Restaurants</button>
                    </form>

                    <!-- Popular Cuisine Quick badglets -->
                    <div class="d-flex align-items-center gap-2 mt-4 flex-wrap" id="popular-cuisines-tags">
                        <span class="small text-muted fw-semibold">Popular Searches:</span>
                        <a href="restaurants.jsp?category=Burger" class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange">Burger</a>
                        <a href="restaurants.jsp?category=Pizza" class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange">Pizza</a>
                        <a href="restaurants.jsp?category=Biryani" class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange">Biryani</a>
                        <a href="restaurants.jsp?category=Chinese" class="badge bg-light text-dark text-decoration-none px-3 py-2 border rounded-pill hover-orange">Chinese</a>
                    </div>
                </div>

                <!-- Right Food Layout Illustration -->
                <div class="col-lg-6 position-relative text-center text-lg-end" id="hero-right-illustration">
                    <div class="position-relative d-inline-block">
                        <!-- Floating Review Box -->
                        <div class="position-absolute start-0 top-25 bg-white p-3 rounded-4 shadow-lg d-flex align-items-center gap-3 hover-up z-3 text-start animate-float" style="width: 220px;">
                            <div class="bg-warning-subtle text-warning d-flex align-items-center justify-content-center rounded-circle fs-4" style="width: 48px; height: 48px;">
                                <i class="bi bi-star-fill text-warning"></i>
                            </div>
                            <div>
                                <h6 class="mb-0 fw-bold">4.9/5 Rating</h6>
                                <p class="mb-0 fs-8 text-muted">Over 10K+ real reviews</p>
                            </div>
                        </div>

                        <!-- Floating Delivery Time Box -->
                        <div class="position-absolute end-0 bottom-25 bg-white p-3 rounded-4 shadow-lg d-flex align-items-center gap-3 hover-up z-3 text-start animate-float" style="width: 200px; animation-delay: 1.5s;">
                            <div class="bg-success-subtle text-success d-flex align-items-center justify-content-center rounded-circle fs-4" style="width: 48px; height: 48px;">
                                <i class="bi bi-truck"></i>
                            </div>
                            <div>
                                <h6 class="mb-0 fw-bold">25 Min Delivery</h6>
                                <p class="mb-0 fs-8 text-muted">Lightning Fast Guarantee</p>
                            </div>
                        </div>

                        <!-- Main Hero Image -->
                        <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80" 
                             alt="Delicious Spread of Dishes" 
                             class="img-fluid rounded-4 shadow-lg z-1 position-relative" 
                             style="max-height: 440px; width: 100%; object-fit: cover;"
                             id="hero-main-img">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Food Categories Circle Section -->
    <section class="py-5" id="categories-section">
        <div class="container">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h3 class="mb-1 text-dark fs-2 font-display">What's on your mind?</h3>
                    <p class="mb-0 text-muted small">Explore variety of food categories right away</p>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-light rounded-circle shadow-sm border" onclick="scrollCategories(-200)"><i class="bi bi-chevron-left"></i></button>
                    <button class="btn btn-light rounded-circle shadow-sm border" onclick="scrollCategories(200)"><i class="bi bi-chevron-right"></i></button>
                </div>
            </div>

            <!-- Categories Horizontal Slider -->
            <div class="d-flex gap-4 overflow-auto pb-3 scrollbar-hidden" id="categories-container" style="scroll-behavior: smooth;">
                <!-- Category 1 -->
                <a href="restaurants.jsp?category=Burger" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-burger">
                    <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=150&q=80" alt="Burgers" class="category-img">
                    <div class="mt-2 fw-medium">Burger</div>
                </a>
                <!-- Category 2 -->
                <a href="restaurants.jsp?category=Pizza" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-pizza">
                    <img src="https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=150&q=80" alt="Pizzas" class="category-img">
                    <div class="mt-2 fw-medium">Pizza</div>
                </a>
                <!-- Category 3 -->
                <a href="restaurants.jsp?category=Biryani" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-biryani">
                    <img src="https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=150&q=80" alt="Biryani" class="category-img">
                    <div class="mt-2 fw-medium">Biryani</div>
                </a>
                <!-- Category 4 -->
                <a href="restaurants.jsp?category=Cakes" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-cakes">
                    <img src="https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=150&q=80" alt="Desserts" class="category-img">
                    <div class="mt-2 fw-medium">Desserts</div>
                </a>
                <!-- Category 5 -->
                <a href="restaurants.jsp?category=Chinese" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-chinese">
                    <img src="https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=150&q=80" alt="Chinese" class="category-img">
                    <div class="mt-2 fw-medium">Chinese</div>
                </a>
                <!-- Category 6 -->
                <a href="restaurants.jsp?category=North Indian" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-north-indian">
                    <img src="https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=150&q=80" alt="North Indian" class="category-img">
                    <div class="mt-2 fw-medium">Thali</div>
                </a>
                <!-- Category 7 -->
                <a href="restaurants.jsp?category=South Indian" class="category-item text-decoration-none text-dark flex-shrink-0" id="cat-south-indian">
                    <img src="https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=150&q=80" alt="South Indian" class="category-img">
                    <div class="mt-2 fw-medium">South Indian</div>
                </a>
            </div>
        </div>
    </section>

    <!-- Special Offers Carousels -->
    <section class="bg-light py-5" id="offers-carousel-section">
        <div class="container mt-2">
            <h3 class="mb-4 text-dark fs-2 font-display">Special Offers For You</h3>
            <div class="row g-4" id="index-offers-grid">
                <!-- Offer 1 -->
                <div class="col-md-4" id="offer-card-1">
                    <div class="card border-0 bg-orange text-white p-4 rounded-4 shadow-sm hover-up position-relative overflow-hidden" style="height: 160px;">
                        <i class="bi bi-tag-fill position-absolute end-0 bottom-0 text-white-10 fs-1" style="transform: translate(10px, 10px) rotate(-15deg); opacity: 0.15;"></i>
                        <span class="badge bg-white text-orange fw-bold mb-2 align-self-start">FIRST_BITE</span>
                        <h4 class="mb-1">Flat 50% Off</h4>
                        <p class="small mb-0">Up to $10 off on your very first order.</p>
                    </div>
                </div>
                <!-- Offer 2 -->
                <div class="col-md-4" id="offer-card-2">
                    <div class="card border-0 bg-dark-custom text-white p-4 rounded-4 shadow-sm hover-up position-relative overflow-hidden" style="height: 160px;">
                        <i class="bi bi-truck position-absolute end-0 bottom-0 text-white-10 fs-1" style="transform: translate(10px, 10px) rotate(-15deg); opacity: 0.15;"></i>
                        <span class="badge bg-orange text-white fw-bold mb-2 align-self-start">FREE_DELIVERY</span>
                        <h4 class="mb-1">Free Delivery</h4>
                        <p class="small mb-0">On super orders above $15 from partner outlets.</p>
                    </div>
                </div>
                <!-- Offer 3 -->
                <div class="col-md-4" id="offer-card-3">
                    <div class="card border-0 bg-info text-white p-4 rounded-4 shadow-sm hover-up position-relative overflow-hidden" style="background: linear-gradient(135deg, #0984e3 0%, #00cec9 100%) !important; height: 160px;">
                        <i class="bi bi-wallet2 position-absolute end-0 bottom-0 text-white-10 fs-1" style="transform: translate(10px, 10px) rotate(-15deg); opacity: 0.15;"></i>
                        <span class="badge bg-white text-dark fw-bold mb-2 align-self-start">WEEKEND_FEAST</span>
                        <h4 class="mb-1">Feast 30% Off</h4>
                        <p class="small mb-0">Unleash weekend special discounts now.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Top-Rated Restaurants Grid -->
    <section class="py-5" id="top-rated-restaurants-section">
        <div class="container py-2">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h3 class="mb-1 text-dark fs-2 font-display">Top Rated Restaurants</h3>
                    <p class="mb-0 text-muted small font-medium">Verified eateries packing premium taste checkups</p>
                </div>
                <a href="restaurants.jsp" class="btn btn-outline-orange px-4 py-2 rounded-3 fs-7 text-decoration-none">View All Restaurants</a>
            </div>

            <div class="row g-4" id="top-restaurants-grid">
                <!-- Restaurant 1 -->
                <div class="col-lg-3 col-md-6" id="rest-card-1">
                    <div class="card restaurant-card hover-up h-100 p-0 border">
                        <div class="restaurant-img-container">
                            <span class="badge bg-orange text-white position-absolute top-3 left-3 z-3 shadow-sm px-2 py-1 fs-8 fw-bold">PROMOTED</span>
                            <div class="discount-badge">Flat 20% Off</div>
                            <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80" alt="The Gourmet Burger Club">
                        </div>
                        <div class="card-body p-3">
                            <h5 class="card-title text-truncate mb-1 fw-bold text-dark"><a href="menu.jsp?id=1" class="text-decoration-none text-dark">Burger Palace</a></h5>
                            <p class="text-muted small text-truncate mb-2">American • Burgers • Fast Food • Drinks</p>
                            <div class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top">
                                <div class="badge bg-success d-flex align-items-center gap-1"><i class="bi bi-star-fill text-white fs-8"></i> 4.5</div>
                                <span class="fs-8 text-muted fw-bold">• 20-25 MIN</span>
                                <span class="fs-8 text-dark fw-bold">$8 For Two</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Restaurant 2 -->
                <div class="col-lg-3 col-md-6" id="rest-card-2">
                    <div class="card restaurant-card hover-up h-100 p-0 border">
                        <div class="restaurant-img-container">
                            <div class="discount-badge">Free Pizza Bread</div>
                            <img src="https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80" alt="Crust Supreme Woodfired">
                        </div>
                        <div class="card-body p-3">
                            <h5 class="card-title text-truncate mb-1 fw-bold text-dark"><a href="menu.jsp?id=2" class="text-decoration-none text-dark">Pizzeria Bella Vista</a></h5>
                            <p class="text-muted small text-truncate mb-2">Italian • Pizzas • Garlic Breads • Desserts</p>
                            <div class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top">
                                <div class="badge bg-success d-flex align-items-center gap-1"><i class="bi bi-star-fill text-white fs-8"></i> 4.7</div>
                                <span class="fs-8 text-muted fw-bold">• 25-30 MIN</span>
                                <span class="fs-8 text-dark fw-bold">$12 For Two</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Restaurant 3 -->
                <div class="col-lg-3 col-md-6" id="rest-card-3">
                    <div class="card restaurant-card hover-up h-100 p-0 border">
                        <div class="restaurant-img-container">
                            <div class="discount-badge">Flat 30% Off</div>
                            <img src="https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=400&q=80" alt="Royal Biryani">
                        </div>
                        <div class="card-body p-3">
                            <h5 class="card-title text-truncate mb-1 fw-bold text-dark"><a href="menu.jsp?id=3" class="text-decoration-none text-dark">Darbar Palace Royal Biryani</a></h5>
                            <p class="text-muted small text-truncate mb-2">Royal Mughlai • Rice Special • Tikka</p>
                            <div class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top">
                                <div class="badge bg-success d-flex align-items-center gap-1"><i class="bi bi-star-fill text-white fs-8"></i> 4.8</div>
                                <span class="fs-8 text-muted fw-bold">• 35-40 MIN</span>
                                <span class="fs-8 text-dark fw-bold">$15 For Two</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Restaurant 4 -->
                <div class="col-lg-3 col-md-6" id="rest-card-4">
                    <div class="card restaurant-card hover-up h-100 p-0 border">
                        <div class="restaurant-img-container">
                            <span class="badge bg-orange text-white position-absolute top-3 left-3 z-3 shadow-sm px-2 py-1 fs-8 fw-bold">PROMOTED</span>
                            <div class="discount-badge">Flat 15% Off</div>
                            <img src="https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=400&q=80" alt="Mandarin Chow">
                        </div>
                        <div class="card-body p-3">
                            <h5 class="card-title text-truncate mb-1 fw-bold text-dark"><a href="menu.jsp?id=4" class="text-decoration-none text-dark">Golden Wok Dragon</a></h5>
                            <p class="text-muted small text-truncate mb-2">Chinese • Dim Sums • Hakka Noodles</p>
                            <div class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top">
                                <div class="badge bg-success d-flex align-items-center gap-1"><i class="bi bi-star-fill text-white fs-8"></i> 4.4</div>
                                <span class="fs-8 text-muted fw-bold">• 15-20 MIN</span>
                                <span class="fs-8 text-dark fw-bold">$10 For Two</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- App Features Featurettes -->
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
                            <p class="small text-muted mb-0">Order in for yourself or for the whole crew. We place no boundaries on order requirements.</p>
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
                            <p class="small text-muted mb-0">Know where your meal is at all times. Track it right from kitchen checkout up to your doorbells.</p>
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
                            <p class="small text-muted mb-0">Fully vaccinated riders, contact-free options, and sanitization protocols built in deep.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function scrollCategories(amount) {
            const container = document.getElementById('categories-container');
            if (container) {
                container.scrollBy({ left: amount, behavior: 'smooth' });
            }
        }
    </script>
</body>
</html>
