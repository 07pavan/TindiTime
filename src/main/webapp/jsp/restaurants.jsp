<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en" id="root-html-restaurants">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Browse all top-rated restaurants on HungryGO and order food online.">
    <title>All Restaurants | HungryGO Delivery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/jsp/style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-restaurants">

    <jsp:include page="navbar.jsp" />

    <%-- Search and Filters Banner --%>
    <div class="bg-white border-bottom py-4" id="filters-banner">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-2 fs-7">
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/index" class="text-orange text-decoration-none">Home</a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">All Restaurants</li>
                </ol>
            </nav>

            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                <div>
                    <h1 class="h2 fw-bold mb-1 font-display">Discover Tasty Delights</h1>
                    <p class="text-muted small mb-0 fs-7" id="restaurants-count-txt">
                        <%-- restaurants set by RestaurantServlet.getAllRestaurants() --%>
                        Showing <c:out value="${not empty restaurants ? restaurants.size() : 0}" /> restaurants near you
                    </p>
                </div>
                <%-- Quick client-side search — filters already-loaded restaurant cards --%>
                <div style="max-width: 400px; width: 100%;">
                    <div class="input-group border rounded-3 bg-light px-2 py-1 align-items-center">
                        <i class="bi bi-search text-muted ms-1 me-2"></i>
                        <input type="text" id="live-search-input"
                               class="form-control border-0 bg-transparent shadow-none form-control-sm"
                               placeholder="Search dish, restaurant or cuisine..."
                               onkeyup="filterRestaurants()"
                               value="<c:out value='${param.search}' />"
                               autocomplete="off">
                    </div>
                </div>
            </div>

            <%-- Filter Controls --%>
            <div class="d-flex align-items-center gap-2 mt-4 flex-wrap" id="filter-controls-group">
                <button class="btn btn-sm btn-outline-secondary rounded-pill px-3 active-filter" id="filter-all"     onclick="setFilter('all')">All Outlets</button>
                <button class="btn btn-sm btn-outline-secondary rounded-pill px-3"               id="filter-top"     onclick="setFilter('top')"><i class="bi bi-star-fill text-warning me-1"></i>Ratings 4.5+</button>
                <button class="btn btn-sm btn-outline-secondary rounded-pill px-3"               id="filter-fast"    onclick="setFilter('fast')"><i class="bi bi-clock me-1"></i>Fast Delivery (&lt;25m)</button>
                <button class="btn btn-sm btn-outline-secondary rounded-pill px-3"               id="filter-veg"     onclick="setFilter('veg')"><span class="veg-badge me-1" style="transform:scale(0.85);"></span>Pure Veg</button>
                <button class="btn btn-sm btn-outline-secondary rounded-pill px-3"               id="filter-offers"  onclick="setFilter('offers')"><i class="bi bi-percent text-danger me-1"></i>Offers</button>
            </div>
        </div>
    </div>

    <%-- Main Restaurants Grid — populated by RestaurantServlet from DB --%>
    <main class="container py-5" id="restaurants-list-container">

        <%-- Empty state when DB has no restaurants --%>
        <c:if test="${empty restaurants}">
            <div class="text-center py-5" id="db-empty-state">
                <i class="bi bi-emoji-frown text-muted display-1 mb-3"></i>
                <h2 class="h4 text-secondary">No Restaurants Found in Database</h2>
                <p class="text-muted">The restaurant list is empty. Please add data to the <code>restaurants</code> table.</p>
                <a href="${pageContext.request.contextPath}/index" class="btn btn-orange px-4 py-2 mt-2 rounded-3 fw-bold text-white">Go Home</a>
            </div>
        </c:if>

        <%-- Restaurants Grid (only shown when data exists) --%>
        <c:if test="${not empty restaurants}">
            <div class="row g-4" id="restaurants-grid">
                <%-- Each restaurant from DB via RestaurantServlet → RestaurantDAOImpl --%>
                <c:forEach var="restaurant" items="${restaurants}">
                    <div class="col-lg-3 col-md-6 restaurant-item-card"
                         data-rating="${restaurant.rating}"
                         data-time="${restaurant.deliveryTimeMins}"
                         data-veg="${fn:contains(restaurant.cuisineType, 'Veg') or fn:contains(restaurant.cuisineType, 'South Indian') or fn:contains(restaurant.cuisineType, 'Salad') or fn:contains(restaurant.cuisineType, 'Sweets') or fn:contains(restaurant.cuisineType, 'Dessert')}"
                         data-offer="true"
                         data-category="${restaurant.cuisineType}"
                         data-title="${restaurant.name}">
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
                                    <%-- Link → MenuServlet /menu?id=restaurantId --%>
                                    <a href="${pageContext.request.contextPath}/menu?id=${restaurant.id}"
                                       class="text-decoration-none text-dark">
                                        <c:out value="${restaurant.name}" />
                                    </a>
                                </h5>
                                <p class="text-muted small text-truncate mb-2"><c:out value="${restaurant.cuisineType}" /></p>
                                <div class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top">
                                    <div class="badge bg-success d-flex align-items-center gap-1">
                                        <i class="bi bi-star-fill text-white fs-8"></i>
                                        <c:out value="${restaurant.rating}" />
                                    </div>
                                    <span class="fs-8 text-muted fw-bold">• <c:out value="${restaurant.deliveryTimeMins}" /> MIN</span>
                                    <span class="fs-8 text-dark fw-bold">₹<c:out value="${restaurant.costForTwo}" /> For Two</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <%-- No results after client-side filter --%>
            <div class="text-center py-5 d-none" id="no-results-msg">
                <i class="bi bi-emoji-frown text-muted display-1 mb-3"></i>
                <h3>No Restaurants Found</h3>
                <p class="text-muted">Try adjusting your filters or search terms.</p>
                <button class="btn btn-orange px-4 py-2 mt-2 rounded-3 fw-bold" onclick="resetFilters()">Reset All Filters</button>
            </div>
        </c:if>
    </main>

    <jsp:include page="footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        let currentFilter = 'all';

        // Apply search/category from URL params on load
        window.addEventListener('DOMContentLoaded', () => {
            const params = new URLSearchParams(window.location.search);
            const searchVal   = params.get('search');
            const categoryVal = params.get('category');
            const filterVal   = params.get('filter');

            if (searchVal) {
                document.getElementById('live-search-input').value = searchVal;
                filterRestaurants();
            } else if (categoryVal) {
                filterByCategory(categoryVal);
            } else if (filterVal) {
                setFilter(filterVal);
            }
        });

        function setFilter(filterType) {
            currentFilter = filterType;
            document.querySelectorAll('#filter-controls-group button').forEach(btn => {
                btn.classList.remove('btn-orange', 'text-white', 'active-filter');
                btn.classList.add('btn-outline-secondary');
            });
            const activeBtn = document.getElementById('filter-' + filterType);
            if (activeBtn) {
                activeBtn.classList.remove('btn-outline-secondary');
                activeBtn.classList.add('btn-orange', 'text-white', 'active-filter');
            }
            filterRestaurants();
        }

        function filterByCategory(category) {
            const catLower = category.toLowerCase();
            const cards = document.querySelectorAll('.restaurant-item-card');
            let matched = 0;
            cards.forEach(card => {
                const cardCategory = (card.getAttribute('data-category') || '').toLowerCase();
                const cardTitle = (card.getAttribute('data-title') || '').toLowerCase();
                
                // Substring match on cuisine type or restaurant name
                let isMatch = cardCategory.includes(catLower) || cardTitle.includes(catLower);
                
                // Map synonyms for general categories
                if (catLower === 'thali') {
                    isMatch = isMatch || cardCategory.includes('thali') || cardCategory.includes('indian');
                } else if (catLower === 'north indian') {
                    isMatch = isMatch || cardCategory.includes('north indian') || cardCategory.includes('punjabi') || cardCategory.includes('thali');
                } else if (catLower === 'burger') {
                    isMatch = isMatch || cardCategory.includes('burger');
                } else if (catLower === 'pizza') {
                    isMatch = isMatch || cardCategory.includes('pizza');
                } else if (catLower === 'biryani') {
                    isMatch = isMatch || cardCategory.includes('biryani');
                } else if (catLower === 'desserts' || catLower === 'dessert') {
                    isMatch = isMatch || cardCategory.includes('dessert') || cardCategory.includes('sweet') || cardCategory.includes('shake') || cardCategory.includes('bakehouse');
                }
                
                if (isMatch) {
                    card.classList.remove('d-none');
                    matched++;
                } else {
                    card.classList.add('d-none');
                }
            });
            const countEl = document.getElementById('restaurants-count-txt');
            if (countEl) countEl.innerText = `Displaying ${matched} ${category} restaurants`;
            toggleNoResults(matched === 0);
        }

        function filterRestaurants() {
            const searchKeyword = (document.getElementById('live-search-input').value || '').toLowerCase();
            const cards = document.querySelectorAll('.restaurant-item-card');
            let matched = 0;

            cards.forEach(card => {
                const title    = (card.getAttribute('data-title') || '').toLowerCase();
                const category = (card.getAttribute('data-category') || '').toLowerCase();
                const rating   = parseFloat(card.getAttribute('data-rating') || '0');
                const time     = parseInt(card.getAttribute('data-time') || '999');
                const isVeg    = card.getAttribute('data-veg') === 'true';
                const hasOffer = card.getAttribute('data-offer') === 'true';

                let matchesSearch = !searchKeyword || title.includes(searchKeyword) || category.includes(searchKeyword);
                let matchesFilter = true;

                if (currentFilter === 'top'    && rating < 4.5)  matchesFilter = false;
                if (currentFilter === 'fast'   && time > 25)     matchesFilter = false;
                if (currentFilter === 'veg'    && !isVeg)        matchesFilter = false;
                if (currentFilter === 'offers' && !hasOffer)     matchesFilter = false;

                if (matchesSearch && matchesFilter) { card.classList.remove('d-none'); matched++; }
                else                                { card.classList.add('d-none'); }
            });

            const countEl = document.getElementById('restaurants-count-txt');
            if (countEl) countEl.innerText = `Displaying ${matched} restaurants`;
            toggleNoResults(matched === 0);
        }

        function resetFilters() {
            document.getElementById('live-search-input').value = '';
            setFilter('all');
        }

        function toggleNoResults(show) {
            const grid = document.getElementById('restaurants-grid');
            const msg  = document.getElementById('no-results-msg');
            if (!grid || !msg) return;
            if (show) { grid.classList.add('d-none'); msg.classList.remove('d-none'); }
            else      { grid.classList.remove('d-none'); msg.classList.add('d-none'); }
        }
    </script>
</body>
</html>
