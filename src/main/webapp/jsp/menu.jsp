<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%--
    MVC Guard: This JSP must ONLY be reached via MenuServlet (/menu?id=X).
    MenuServlet sets: restaurant (Restaurant), menuItems (List<MenuItem>)
    If directly accessed, restaurant will be null — redirect to /restaurants.
--%>
<c:if test="${empty restaurant}">
    <c:redirect url="/restaurants" />
</c:if>

<!DOCTYPE html>
<html lang="en" id="root-html-menu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Order from ${restaurant.name} — Browse the menu and add to cart on TindiTime.">
    <title><c:out value="${restaurant.name}" /> | TindiTime Delivery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/jsp/style.css?v=2" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-menu">

    <jsp:include page="navbar.jsp" />

    <%-- Restaurant address set from DB via restaurant.id — use a generic fallback --%>
    <c:set var="restaurantAddress" value="Mumbai, Maharashtra, India" />

    <main class="container py-4" id="menu-main-section">
        <%-- Breadcrumb --%>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-4 fs-7">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/index" class="text-orange text-decoration-none">Home</a>
                </li>
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/restaurants" class="text-orange text-decoration-none">Restaurants</a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">
                    <c:out value="${restaurant.name}" />
                </li>
            </ol>
        </nav>

        <%-- Restaurant Meta Banner — all data from MenuServlet → RestaurantDAOImpl --%>
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-5" id="rest-meta-banner">
            <div class="row g-0">
                <div class="col-md-5">
                    <img src="${restaurant.imageUrl}"
                         alt="<c:out value='${restaurant.name}' /> Cover Image"
                         class="w-100 h-100 object-fit-cover"
                         style="min-height: 240px; max-height: 280px;">
                </div>
                <div class="col-md-7 d-flex flex-column justify-content-center p-4 p-lg-5">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="badge bg-orange px-2 py-1 fs-8 fw-bold" style="color: var(--color-deep-forest) !important; background-color: var(--color-lime-glow) !important;">PROMOTED</span>
                        <div class="badge bg-success d-flex align-items-center gap-1">
                            <i class="bi bi-star-fill text-white fs-8"></i>
                            <c:out value="${restaurant.rating}" /> (500+ ratings)
                        </div>
                    </div>
                    <h1 class="fw-bold text-dark font-display mb-1">
                        <c:out value="${restaurant.name}" />
                    </h1>
                    <p class="text-muted small mb-3">
                        <c:out value="${restaurant.cuisineType}" />
                    </p>
                    <p class="text-muted small mb-0">
                        <i class="bi bi-geo-alt-fill text-orange me-1"></i>
                        <c:out value="${restaurantAddress}" />
                    </p>

                    <hr class="my-3 opacity-25">

                    <div class="row text-center text-md-start gy-2">
                        <div class="col-6 col-sm-3">
                            <span class="fs-8 text-muted d-block font-medium">DELIVERY</span>
                            <span class="fw-bold text-dark">
                                <i class="bi bi-clock me-1"></i><c:out value="${restaurant.deliveryTimeMins}" /> mins
                            </span>
                        </div>
                        <div class="col-6 col-sm-3">
                            <span class="fs-8 text-muted d-block font-medium">COST FOR TWO</span>
                            <span class="fw-bold text-dark">₹<c:out value="${restaurant.costForTwo}" /> for two</span>
                        </div>
                        <div class="col-12 col-sm-6 mt-lg-0 mt-2">
                            <div class="d-flex align-items-center gap-2 bg-light p-2 rounded-3 border">
                                <i class="bi bi-percent text-danger fs-4 ms-1"></i>
                                <div class="text-start">
                                    <h6 class="mb-0 fs-8 fw-bold">USE CODE "QKBITE20"</h6>
                                    <p class="mb-0 text-muted" style="font-size:11px;">get flat ₹100 discount on your order</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Menu Grid --%>
        <div class="row" id="menu-grid-row">
            <%-- Category Sidebar --%>
            <div class="col-lg-3 d-none d-lg-block">
                <div class="card border-0 shadow-sm p-3 sticky-top rounded-3" style="top: 100px;" id="menu-cat-sidebar">
                    <h6 class="fw-bold text-dark mb-3 text-uppercase border-bottom pb-2 fs-7">Categories</h6>
                    <ul class="nav flex-column gap-2 font-medium fs-7" id="sidebar-categories-list">
                        <li><a href="#section-recommended" class="nav-link p-2 rounded hover-orange" style="color: var(--color-deep-forest) !important; font-weight: 700;"><i class="bi bi-bookmark-star-fill me-2"></i>Recommended</a></li>
                        <li><a href="#section-combos"      class="nav-link text-dark p-2 rounded hover-orange"><i class="bi bi-bag-plus me-2"></i>Saver Combos</a></li>
                        <li><a href="#section-beverages"   class="nav-link text-dark p-2 rounded hover-orange"><i class="bi bi-cup-straw me-2"></i>Beverages</a></li>
                    </ul>
                </div>
            </div>

            <%-- Menu Items Column — data from MenuServlet → MenuItemDAOImpl --%>
            <div class="col-lg-9">
                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                    <h2 class="h3 fw-bold text-dark mb-0 font-display" id="section-recommended">Recommended Dishes</h2>
                    <div class="form-check form-switch bg-white border px-4 py-2 rounded-pill shadow-sm" style="padding-left: 2.8rem;">
                        <input class="form-check-input accent-orange" type="checkbox"
                               id="veg-only-switch" onchange="toggleVegOnly()">
                        <label class="form-check-label text-muted small fw-bold" for="veg-only-switch">Veg Only</label>
                    </div>
                </div>

                <div class="d-flex flex-column gap-2" id="food-items-container">
                    <%-- menuItems set by MenuServlet from MenuItemDAOImpl.getMenuItemsByRestaurant() --%>
                    <c:forEach var="item" items="${menuItems}">
                        <div class="card border-0 shadow-sm rounded-4 p-3 mb-3 food-item-row-card"
                             data-veg="${item.vegetarian}" id="menu-item-${item.id}">
                            <div class="row align-items-center">
                                <div class="col-8 col-sm-9 text-start">
                                    <c:choose>
                                        <c:when test="${item.vegetarian}">
                                            <span class="veg-badge" title="Vegetarian"></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="nonveg-badge" title="Non-Vegetarian"></span>
                                        </c:otherwise>
                                    </c:choose>
                                    <h5 class="fw-bold text-dark mb-1"><c:out value="${item.name}" /></h5>
                                    <div class="fw-bold mb-2 font-mono" style="color: var(--color-deep-forest) !important;">₹<c:out value="${item.price}" /></div>
                                    <p class="text-muted small mb-0 d-none d-sm-block">
                                        <c:out value="${item.description}" />
                                    </p>
                                </div>
                                <div class="col-4 col-sm-3 d-flex flex-column align-items-center justify-content-center">
                                    <div class="menu-item-img-container mb-2">
                                        <img src="${item.imageUrl}" alt="<c:out value='${item.name}' />">
                                    </div>
                                    <%-- Add to cart → POST /cart → CartServlet.doPost(action=add) --%>
                                    <form action="${pageContext.request.contextPath}/cart" method="POST">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="id"    value="${item.id}">
                                        <input type="hidden" name="name"  value="${item.name}">
                                        <input type="hidden" name="price" value="${item.price}">
                                        <input type="hidden" name="img"   value="${item.imageUrl}">
                                        <button type="submit" class="btn btn-sm btn-outline-orange px-3 py-1 rounded-2 fw-bold text-uppercase shadow-sm">
                                            Add <i class="bi bi-plus"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

                    <%-- Empty menu state --%>
                    <c:if test="${empty menuItems}">
                        <div class="text-center py-5" id="menu-empty-state">
                            <i class="bi bi-egg-fried text-muted fs-1 mb-3"></i>
                            <h5 class="text-secondary fw-bold">No Menu Items Available</h5>
                            <p class="text-muted small mb-0">Check back later or try another restaurant.</p>
                            <a href="${pageContext.request.contextPath}/restaurants"
                               class="btn btn-outline-orange mt-3 rounded-3 px-4 fw-bold">Browse Other Restaurants</a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        /* ── Veg-only filter ─────────────────────────────────── */
        function toggleVegOnly() {
            var isChecked = document.getElementById('veg-only-switch').checked;
            document.querySelectorAll('.food-item-row-card').forEach(function(card) {
                var isVeg = card.getAttribute('data-veg') === 'true';
                card.classList.toggle('d-none', isChecked && !isVeg);
            });
        }

        /* ── AJAX Add-to-Cart handler ────────────────────────── */
        document.addEventListener('DOMContentLoaded', function () {

            /* Find every "Add to cart" form on this page */
            document.querySelectorAll('form').forEach(function (form) {
                var actionInput = form.querySelector('input[name="action"]');
                var formAction  = form.getAttribute('action') || '';
                if (!actionInput || actionInput.value !== 'add') return;
                if (formAction.indexOf('/cart') === -1) return;

                form.addEventListener('submit', function (e) {
                    e.preventDefault();

                    var btn      = form.querySelector('button[type="submit"]');
                    var origHtml = btn ? btn.innerHTML : '';
                    var isOutline = btn ? btn.classList.contains('btn-outline-orange') : false;

                    /* 1. Loading state */
                    if (btn) {
                        btn.disabled = true;
                        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>Adding…';
                    }

                    /* 2. POST via fetch — AJAX */
                    fetch(form.getAttribute('action'), {
                        method : 'POST',
                        body   : new URLSearchParams(new FormData(form)),
                        headers: {
                            'X-Requested-With': 'XMLHttpRequest',
                            'Accept'          : 'application/json',
                            'Content-Type'    : 'application/x-www-form-urlencoded'
                        }
                    })
                    .then(function (resp) {
                        /* 401 = not logged in → redirect to login */
                        if (resp.status === 401) {
                            return resp.json().then(function (d) {
                                window.location.href = d.redirect || '${pageContext.request.contextPath}/login?msg=auth_required';
                                throw new Error('auth');
                            });
                        }
                        return resp.json();
                    })
                    .then(function (data) {
                        if (!data) return;

                        if (data.success) {
                            /* 3a. Green "✓ Added!" on the button */
                            if (btn) {
                                btn.classList.remove('btn-outline-orange', 'btn-orange');
                                btn.classList.add('btn-success');
                                btn.innerHTML = '<i class="bi bi-check-lg"></i> Added!';
                                setTimeout(function () {
                                    btn.disabled = false;
                                    btn.innerHTML = origHtml;
                                    btn.classList.remove('btn-success');
                                    btn.classList.add(isOutline ? 'btn-outline-orange' : 'btn-orange');
                                }, 1800);
                            }

                            /* 3b. Update floating bar + navbar badge */
                            var cartSize = data.cartSize;

                            /* Navbar badge */
                            var badge = document.getElementById('nav-cart-badge');
                            if (badge) {
                                badge.textContent = cartSize;
                                badge.classList.remove('pulse-animation');
                                void badge.offsetWidth; /* restart CSS animation */
                                badge.classList.add('pulse-animation');
                            }

                            /* Floating bottom bar */
                            var bar = document.getElementById('floating-cart-bar');
                            if (bar) {
                                var txt = document.getElementById('floating-cart-text');
                                if (txt) {
                                    txt.innerHTML =
                                        '<span id="floating-cart-qty" class="font-mono">' + cartSize + '</span>&nbsp;' +
                                        (cartSize === 1 ? 'Item' : 'Items') + ' Selected';
                                }
                                bar.classList.remove('d-none');
                                setTimeout(function () { bar.classList.add('show'); }, 10);
                            }

                        } else if (data.redirect) {
                            window.location.href = data.redirect;
                        }
                    })
                    .catch(function (err) {
                        if (err.message !== 'auth') {
                            /* Restore button on network errors */
                            if (btn) {
                                btn.disabled = false;
                                btn.innerHTML = origHtml;
                            }
                        }
                    });
                });
            });
        });
    </script>
</body>
</html>
