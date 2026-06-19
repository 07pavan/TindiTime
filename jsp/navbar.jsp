<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    Integer cartSize = (Integer) session.getAttribute("cartSize");
    if (cartSize == null) {
        cartSize = 0;
    }
%>
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top py-2" id="main-navbar">
    <div class="container">
        <!-- Logo -->
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold text-decoration-none" href="index.jsp" id="nav-brand-logo">
            <div class="logo-box d-flex align-items-center justify-content-center text-white rounded-3 shadow-sm bg-orange" style="width: 38px; height: 38px;">
                <i class="bi bi-lightning-charge-fill fs-5"></i>
            </div>
            <span class="fs-4 tracking-tight text-dark">Hungry<span class="text-orange">GO</span></span>
        </a>

        <!-- Location Selector (Swiggy feel) -->
        <div class="d-none d-md-flex align-items-center ms-4 text-truncate" style="max-width: 250px;" id="nav-location-selector">
            <i class="bi bi-geo-alt-fill text-orange me-2"></i>
            <span class="text-muted small fw-medium">Deliver to: </span>
            <span class="ms-1 text-dark small fw-bold text-truncate" id="current-delivery-address">
                <%= (session.getAttribute("address") != null) ? session.getAttribute("address") : "Select Location..." %>
            </span>
        </div>

        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation" id="navbar-hamburger-btn">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-nav ms-auto align-items-center gap-lg-3 mt-3 mt-lg-0">
                <li class="nav-item">
                    <a class="nav-link d-flex align-items-center gap-2 px-3 py-2 rounded-2 fw-medium text-dark hover-orange" href="restaurants.jsp" id="nav-link-search">
                        <i class="bi bi-search fs-5"></i>
                        <span>Search</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link d-flex align-items-center gap-2 px-3 py-2 rounded-2 fw-medium text-dark hover-orange" href="restaurants.jsp?filter=offers" id="nav-link-offers">
                        <i class="bi bi-percent fs-5"></i>
                        <span>Offers</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link d-flex align-items-center gap-2 px-3 py-2 rounded-2 fw-medium text-dark hover-orange" href="orders" id="nav-link-orders">
                        <i class="bi bi-journal-text fs-5"></i>
                        <span>Orders</span>
                    </a>
                </li>

                <!-- User Account Details -->
                <% if (username != null) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle d-flex align-items-center gap-2 px-3 py-2 rounded-2 fw-medium text-dark" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-person-circle fs-5 text-orange"></i>
                            <span class="text-truncate" style="max-width: 100px;"><%= username %></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg p-2 rounded-3" aria-labelledby="userDropdown">
                             <li><a class="dropdown-item rounded-2 py-2" href="profile.jsp"><i class="bi bi-person me-2 text-muted"></i>My Profile</a></li>
                             <li><a class="dropdown-item rounded-2 py-2" href="orders"><i class="bi bi-bag-check me-2 text-muted"></i>My Orders</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item rounded-2 py-2 text-danger" href="login.jsp?action=logout"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
                        </ul>
                    </li>
                <% } else { %>
                    <li class="nav-item">
                        <a class="nav-link d-flex align-items-center gap-2 px-3 py-2 rounded-2 fw-medium text-dark hover-orange" href="login.jsp" id="nav-link-signin">
                            <i class="bi bi-person fs-5"></i>
                            <span>Sign In</span>
                        </a>
                    </li>
                <% } %>

                <!-- Cart Button with Badge -->
                <li class="nav-item ms-lg-2">
                    <a class="btn btn-orange d-flex align-items-center gap-2 px-4 py-2 rounded-3 text-white fw-semibold position-relative shadow-sm hover-up" href="cart.jsp" id="nav-link-cart">
                        <i class="bi bi-cart3 fs-5"></i>
                        <span>Cart</span>
                        <span class="badge bg-white text-orange rounded-pill font-mono fs-7 px-2 py-1" id="nav-cart-badge"><%= cartSize %></span>
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>
