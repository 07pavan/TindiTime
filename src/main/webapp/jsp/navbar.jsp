<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%--
    NAVBAR COMPONENT — Sweetgreen Design System
    MVC: reads from sessionScope ONLY — no DB access, no DAO, no scriptlets.
    All links use contextPath-relative servlet URLs.
    Included via <jsp:include> from every JSP page.
--%>

<style>
/* ── Inline Navbar overrides (highest priority) ── */
#main-navbar {
  background: var(--color-cream-canvas) !important;
  border-bottom: 1px solid rgba(140,140,130,0.25) !important;
  box-shadow: none !important;
  padding: 14px 0 !important;
  position: sticky;
  top: 0;
  z-index: 1000;
}
.navbar-brand-hg {
  display: flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
}
.navbar-brand-hg .logo-icon {
  width: 38px; height: 38px;
  background: var(--color-lime-glow);
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  color: var(--color-forest-shadow);
  font-size: 1.1rem;
  flex-shrink: 0;
}
.navbar-brand-hg .logo-text {
  font-size: 22px;
  font-weight: 800;
  color: var(--color-deep-forest);
  letter-spacing: -0.5px;
}
.navbar-brand-hg .logo-text span { color: var(--color-forest-shadow); }

.nav-delivery-loc {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: var(--color-sage-mist);
  border-radius: 99px;
  font-size: 13px;
  color: var(--color-forest-shadow);
  font-weight: 500;
  max-width: 220px;
}
.nav-delivery-loc i { color: var(--color-deep-forest); flex-shrink:0; }
.nav-delivery-loc span { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }

#main-navbar .nav-link-hg {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border-radius: 99px;
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: var(--color-forest-shadow) !important;
  text-decoration: none;
  opacity: 0.75;
  transition: opacity 0.15s, background-color 0.15s;
  white-space: nowrap;
}
#main-navbar .nav-link-hg:hover,
#main-navbar .nav-link-hg.active {
  opacity: 1;
  background: rgba(0,71,60,0.07);
  color: var(--color-deep-forest) !important;
}
#main-navbar .nav-link-hg i { font-size: 1rem; }

/* Cart button in nav */
.nav-cart-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--color-deep-forest) !important;
  color: #fff !important;
  border: none !important;
  border-radius: 99px !important;
  font-weight: 700;
  font-size: 14px;
  padding: 9px 20px;
  text-decoration: none;
  transition: background-color 0.18s, transform 0.15s;
}
.nav-cart-btn:hover {
  background: var(--color-forest-shadow) !important;
  color: #fff !important;
  transform: translateY(-1px);
}
.nav-cart-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 20px; height: 20px;
  background: var(--color-lime-glow);
  color: var(--color-forest-shadow);
  border-radius: 50%;
  font-size: 10px;
  font-weight: 800;
}

/* User dropdown avatar */
.nav-user-trigger {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border: 1.5px solid rgba(0,71,60,0.3);
  border-radius: 99px;
  background: transparent;
  color: var(--color-forest-shadow) !important;
  font-size: 13px;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
}
.nav-user-trigger:hover {
  border-color: var(--color-deep-forest);
  background: rgba(0,71,60,0.05);
  color: var(--color-deep-forest) !important;
}
.nav-avatar-dot {
  width: 26px; height: 26px;
  background: var(--color-deep-forest);
  color: var(--color-lime-glow);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 11px;
  font-weight: 800;
  flex-shrink: 0;
}

/* Mobile toggler */
.hg-toggler {
  background: transparent;
  border: 1.5px solid rgba(0,71,60,0.3);
  border-radius: 8px;
  padding: 6px 10px;
  cursor: pointer;
  color: var(--color-forest-shadow);
  font-size: 1.2rem;
  line-height: 1;
}
.hg-toggler:hover { background: rgba(0,71,60,0.06); }
</style>

<nav class="navbar navbar-expand-lg" id="main-navbar" aria-label="Main navigation">
    <div class="container">

        <a class="navbar-brand-hg" href="${pageContext.request.contextPath}/index" id="nav-brand-logo">
            <div class="logo-icon" style="background: transparent;">
                <img src="${pageContext.request.contextPath}/jsp/logo.png" alt="TindiTime Logo" style="height: 38px; width: 38px; object-fit: contain; border-radius: 8px;">
            </div>
            <span class="logo-text" style="font-family: 'Outfit', sans-serif; font-weight: 800; letter-spacing: -0.5px; color: var(--color-deep-forest);">Tindi<span style="color: var(--color-forest-shadow);">Time</span></span>
        </a>

        <!-- Delivery Address -->
        <div class="d-none d-lg-flex nav-delivery-loc ms-3" id="nav-location-selector">
            <i class="bi bi-geo-alt-fill"></i>
            <span id="current-delivery-address">
                <c:choose>
                    <c:when test="${not empty sessionScope.address}">
                        <c:out value="${sessionScope.address}" />
                    </c:when>
                    <c:otherwise>Select Location</c:otherwise>
                </c:choose>
            </span>
        </div>

        <!-- Mobile toggler -->
        <button class="hg-toggler d-lg-none ms-auto" type="button"
                data-bs-toggle="collapse" data-bs-target="#navbarContent"
                aria-controls="navbarContent" aria-expanded="false"
                aria-label="Toggle navigation" id="navbar-hamburger-btn">
            <i class="bi bi-list"></i>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav ms-auto align-items-center gap-1 mt-3 mt-lg-0">

                <!-- Search -->
                <li class="nav-item">
                    <a class="nav-link-hg" href="${pageContext.request.contextPath}/restaurants" id="nav-link-search">
                        <i class="bi bi-search"></i>
                        <span>Search</span>
                    </a>
                </li>

                <!-- Orders -->
                <li class="nav-item">
                    <a class="nav-link-hg" href="${pageContext.request.contextPath}/orders" id="nav-link-orders">
                        <i class="bi bi-journal-text"></i>
                        <span>Orders</span>
                    </a>
                </li>

                <!-- User: logged-in dropdown OR Sign In -->
                <c:choose>
                    <c:when test="${not empty sessionScope.username}">
                        <li class="nav-item dropdown">
                            <a class="nav-user-trigger" href="#" id="userDropdown" role="button"
                               data-bs-toggle="dropdown" aria-expanded="false">
                                <span class="nav-avatar-dot">
                                    <c:out value="${fn:substring(sessionScope.username,0,1)}" default="U"/>
                                </span>
                                <span class="d-none d-md-inline text-truncate" style="max-width:90px;">
                                    <c:out value="${sessionScope.username}" />
                                </span>
                                <i class="bi bi-chevron-down" style="font-size:10px;opacity:0.6;"></i>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                        <i class="bi bi-person me-2"></i>My Profile
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/orders">
                                        <i class="bi bi-bag-check me-2"></i>My Orders
                                    </a>
                                </li>
                                <c:if test="${sessionScope.role == 'SUPER_ADMIN' or sessionScope.role == 'RESTAURANT_OWNER'}">
                                <li>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/manage/dashboard">
                                        <i class="bi bi-grid-3x3-gap me-2"></i>Admin Panel
                                    </a>
                                </li>
                                </c:if>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/login?action=logout">
                                        <i class="bi bi-box-arrow-right me-2"></i>Sign Out
                                    </a>
                                </li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="nav-link-hg" href="${pageContext.request.contextPath}/login" id="nav-link-signin">
                                <i class="bi bi-person"></i>
                                <span>Sign In</span>
                            </a>
                        </li>
                    </c:otherwise>
                </c:choose>

                <!-- Cart Button -->
                <li class="nav-item ms-1">
                    <a class="nav-cart-btn" href="${pageContext.request.contextPath}/cart" id="nav-link-cart">
                        <i class="bi bi-cart3"></i>
                        <span>Cart</span>
                        <span class="nav-cart-badge" id="nav-cart-badge">
                            <c:out value="${not empty sessionScope.cartSize ? sessionScope.cartSize : 0}" />
                        </span>
                    </a>
                </li>

            </ul>
        </div>
    </div>
</nav>

<!-- Floating Bottom Cart Bar -->
<c:set var="cartSize" value="${not empty sessionScope.cartSize ? sessionScope.cartSize : 0}" />
<div id="floating-cart-bar" class="floating-cart-bar ${cartSize > 0 ? 'show' : 'd-none'}">
    <div class="floating-cart-content">
        <div class="floating-cart-info">
            <span class="cart-icon-wrapper"><i class="bi bi-cart3"></i></span>
            <span id="floating-cart-text" class="fw-bold">
                <span id="floating-cart-qty">${cartSize}</span> ${cartSize == 1 ? 'Item' : 'Items'} in Cart
            </span>
        </div>
        <a href="${pageContext.request.contextPath}/cart" class="btn btn-orange btn-order" id="floating-cart-order-btn">
            View Order <i class="bi bi-arrow-right-short"></i>
        </a>
    </div>
</div>

<script>
/* ============================================================
   GLOBAL CART UI HELPERS — available to every page
   ============================================================ */
(function() {
    var path = window.location.pathname;
    var hidePages = ['/cart', '/checkout', '/success', '/login', '/register'];
    var shouldHide = hidePages.some(function(p) { return path.indexOf(p) !== -1; });

    var bottomBar = document.getElementById('floating-cart-bar');

    if (shouldHide && bottomBar) {
        bottomBar.style.setProperty('display', 'none', 'important');
    }

    window.updateCartUI = function(cartSize) {
        var badge = document.getElementById('nav-cart-badge');
        if (badge) {
            badge.innerText = cartSize;
            badge.classList.remove('pulse-animation');
            void badge.offsetWidth;
            badge.classList.add('pulse-animation');
        }

        var bar = document.getElementById('floating-cart-bar');
        if (bar && !shouldHide) {
            var textSpan = document.getElementById('floating-cart-text');
            if (textSpan) {
                textSpan.innerHTML =
                    '<span id="floating-cart-qty">' + cartSize + '</span> ' +
                    (cartSize === 1 ? 'Item' : 'Items') + ' in Cart';
            }
            if (cartSize > 0) {
                bar.classList.remove('d-none');
                setTimeout(function() { bar.classList.add('show'); }, 10);
            } else {
                bar.classList.remove('show');
                setTimeout(function() { bar.classList.add('d-none'); }, 400);
            }
        }
    };

    window.initCartForms = function() {
        var forms = Array.from(document.querySelectorAll('form')).filter(function(f) {
            var action = f.getAttribute('action') || '';
            var ai = f.querySelector('input[name="action"]');
            return action.indexOf('/cart') !== -1 && ai && ai.value === 'add';
        });

        forms.forEach(function(form) {
            if (form.dataset.ajaxBound === '1') return;
            form.dataset.ajaxBound = '1';

            form.addEventListener('submit', function(e) {
                e.preventDefault();

                var btn = form.querySelector('button[type="submit"]');
                var origHtml = btn ? btn.innerHTML : '';
                var isOutline = btn ? btn.classList.contains('btn-outline-orange') : false;

                if (btn) {
                    btn.disabled = true;
                    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Adding...';
                }

                var params = new URLSearchParams(new FormData(form));

                fetch(form.getAttribute('action'), {
                    method: 'POST',
                    body: params,
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest',
                        'Accept': 'application/json',
                        'Content-Type': 'application/x-www-form-urlencoded'
                    }
                })
                .then(function(response) {
                    if (response.status === 401) {
                        return response.json().then(function(d) {
                            window.location.href = d.redirect || '${pageContext.request.contextPath}/login?msg=auth_required';
                            throw new Error('auth');
                        });
                    }
                    return response.json();
                })
                .then(function(data) {
                    if (data && data.success) {
                        if (btn) {
                            btn.classList.remove('btn-outline-orange', 'btn-orange');
                            btn.classList.add('btn-success');
                            btn.innerHTML = '<i class="bi bi-check-lg"></i> Added!';
                            setTimeout(function() {
                                btn.disabled = false;
                                btn.innerHTML = origHtml;
                                btn.classList.remove('btn-success');
                                btn.classList.add(isOutline ? 'btn-outline-orange' : 'btn-orange');
                            }, 1600);
                        }
                        window.updateCartUI(data.cartSize);
                    } else if (data && data.redirect) {
                        window.location.href = data.redirect;
                    }
                })
                .catch(function(err) {
                    if (err.message !== 'auth') {
                        console.error('Cart error:', err);
                        if (btn) {
                            btn.disabled = false;
                            btn.innerHTML = origHtml;
                        }
                    }
                });
            });
        });
    };
}());
</script>
