<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.hungrygo.model.Restaurant" %>
<%@ page import="com.hungrygo.model.MenuItem" %>
<%@ page import="com.hungrygo.model.dao.RestaurantDAO" %>
<%@ page import="com.hungrygo.model.dao.impl.RestaurantDAOImpl" %>
<%@ page import="com.hungrygo.model.dao.MenuItemDAO" %>
<%@ page import="com.hungrygo.model.dao.impl.MenuItemDAOImpl" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    String restIdStr = request.getParameter("id");
    int restaurantId = 1;
    if (restIdStr != null && !restIdStr.trim().isEmpty()) {
        try {
            restaurantId = Integer.parseInt(restIdStr);
        } catch (NumberFormatException e) {
            restaurantId = 1;
        }
    }

    Restaurant restaurant = (Restaurant) request.getAttribute("restaurant");
    List<MenuItem> menuItems = (List<MenuItem>) request.getAttribute("menuItems");

    if (restaurant == null || menuItems == null) {
        RestaurantDAO restaurantDAO = new RestaurantDAOImpl();
        MenuItemDAO menuItemDAO = new MenuItemDAOImpl();
        restaurant = restaurantDAO.getRestaurantById(restaurantId);
        menuItems = menuItemDAO.getMenuItemsByRestaurant(restaurantId);
        request.setAttribute("restaurant", restaurant);
        request.setAttribute("menuItems", menuItems);
    }

    String restId = restaurant != null ? String.valueOf(restaurant.getId()) : "1";
    String restName = restaurant != null ? restaurant.getName() : "Burger Palace";
    String cuisines = restaurant != null ? restaurant.getCuisineType() : "American, Burgers, Fast Food, Milkshakes";
    double rating = restaurant != null && restaurant.getRating() != null ? restaurant.getRating().doubleValue() : 4.5;
    int deliveryTimeMins = restaurant != null ? restaurant.getDeliveryTimeMins() : 20;
    String deliveryTime = deliveryTimeMins + " mins";
    BigDecimal costVal = restaurant != null && restaurant.getCostForTwo() != null ? restaurant.getCostForTwo() : new BigDecimal("8.00");
    String costForTwo = "₹" + costVal + " for two";
    
    String address = "Shop 12, Ground Floor, Carter Road, Bandra West, Mumbai";
    if (restaurant != null) {
        if (restaurant.getId() == 2) {
            address = "Level 2, High Street Phoenix, Lower Parel, Mumbai";
        } else if (restaurant.getId() == 3) {
            address = "Ground Floor, Opp Metro Station, Andheri West, Mumbai";
        } else if (restaurant.getId() == 4) {
            address = "Food Court, Phoenix Marketcity, Kurla West, Mumbai";
        } else if (restaurant.getId() == 5) {
            address = "Plot 24A, Sector 17, Vashi, Navi Mumbai";
        } else if (restaurant.getId() == 6) {
            address = "Shop 3, Shirley Rajan Road, Bandra West, Mumbai";
        } else if (restaurant.getId() == 7) {
            address = "Opp Railway Station Road, Thane West, Mumbai";
        }
    }
    String coverImg = restaurant != null ? restaurant.getImageUrl() : "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80";
%>
<!DOCTYPE html>
<html lang="en" id="root-html-menu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= restName %> | HungryGO Delivery</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-menu">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <!-- Restaurant Header Details -->
    <main class="container py-4" id="menu-main-section">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-4 fs-7">
                <li class="breadcrumb-item"><a href="index.jsp" class="text-orange text-decoration-none">Home</a></li>
                <li class="breadcrumb-item"><a href="restaurants.jsp" class="text-orange text-decoration-none">Restaurants</a></li>
                <li class="breadcrumb-item active" aria-current="page"><%= restName %></li>
            </ol>
        </nav>

        <!-- Restaurant Showcase Meta Banner -->
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-5" id="rest-meta-banner">
            <div class="row g-0">
                <div class="col-md-5">
                    <img src="<%= coverImg %>" alt="<%= restName %> Cover Image" class="w-100 h-100 object-fit-cover" style="min-height: 240px; max-height: 280px;">
                </div>
                <div class="col-md-7 d-flex flex-column justify-content-center p-4 p-lg-5">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="badge bg-orange px-2 py-1 fs-8 fw-bold">PROMOTED</span>
                        <div class="badge bg-success d-flex align-items-center gap-1"><i class="bi bi-star-fill text-white fs-8"></i> <%= rating %> (500+ ratings)</div>
                    </div>
                    <h1 class="fw-bold text-dark font-display mb-1"><%= restName %></h1>
                    <p class="text-muted small mb-3"><%= cuisines %></p>
                    <p class="text-muted small mb-0"><i class="bi bi-geo-alt-fill text-orange me-1"></i> <%= address %></p>
                    
                    <hr class="my-3 opacity-25">
                    
                    <div class="row text-center text-md-start gy-2">
                        <div class="col-6 col-sm-3">
                            <span class="fs-8 text-muted d-block font-medium">DELIVERY</span>
                            <span class="fw-bold text-dark"><i class="bi bi-clock me-1"></i> <%= deliveryTime %></span>
                        </div>
                        <div class="col-6 col-sm-3">
                            <span class="fs-8 text-muted d-block font-medium">COST FOR TWO</span>
                            <span class="fw-bold text-dark"><%= costForTwo %></span>
                        </div>
                        <div class="col-12 col-sm-6 mt-lg-0 mt-2">
                            <div class="d-flex align-items-center gap-2 bg-light p-2 rounded-3 border">
                                <i class="bi bi-percent text-danger fs-4 ms-1"></i>
                                <div class="text-start">
                                    <h6 class="mb-0 fs-8 fw-bold">USE CODE "QKBITE20"</h5>
                                    <p class="mb-0 fs-9 text-muted" style="font-size: 11px;">get 20% discount up to ₹400</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Menu Title and Filters -->
        <div class="row" id="menu-grid-row">
            <!-- Sidebar Navigation Menu Categories -->
            <div class="col-lg-3 d-none d-lg-block">
                <div class="card border-0 shadow-sm p-3 sticky-top rounded-3" style="top: 100px;" id="menu-cat-sidebar">
                    <h6 class="fw-bold text-dark mb-3 text-uppercase border-bottom pb-2 fs-7">Categories</h6>
                    <ul class="nav flex-column gap-2 font-medium fs-7" id="sidebar-categories-list">
                        <li><a href="#section-recommended" class="nav-link text-orange p-2 rounded hover-orange"><i class="bi bi-bookmark-star-fill me-2"></i>Recommended Special</a></li>
                        <li><a href="#section-combos" class="nav-link text-dark p-2 rounded hover-orange"><i class="bi bi-bag-plus me-2"></i>Saver Combos</a></li>
                        <li><a href="#section-beverages" class="nav-link text-dark p-2 rounded hover-orange"><i class="bi bi-cup-straw me-2"></i>Refreshing Drinks</a></li>
                    </ul>
                </div>
            </div>

            <!-- Food Items Grid Column -->
            <div class="col-lg-9">
                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                    <h3 class="fw-bold text-dark mb-0 font-display">Recommended Dishes</h3>
                    <div class="form-check form-switch bg-white border px-4 py-2 rounded-pill shadow-sm" style="padding-left: 2.8rem;">
                        <input class="form-check-input accent-orange" type="checkbox" id="veg-only-switch" onchange="toggleVegOnly()">
                        <label class="form-check-label text-muted small fw-bold" for="veg-only-switch">Veg Only</label>
                    </div>
                </div>

                <div class="d-flex flex-column gap-2" id="food-items-container">
                    
                    <c:forEach var="item" items="${menuItems}">
                        <div class="card border-0 shadow-sm rounded-4 p-3 mb-3 food-item-row-card" data-veg="${item.vegetarian}">
                            <div class="row align-items-center">
                                <div class="col-8 col-sm-9 text-start">
                                    <c:if test="${item.vegetarian}">
                                        <span class="veg-badge" title="Veg"></span>
                                    </c:if>
                                    <c:if test="${!item.vegetarian}">
                                        <span class="nonveg-badge" title="Non-Veg"></span>
                                    </c:if>
                                    <h5 class="fw-bold text-dark mb-1">${item.name}</h5>
                                    <div class="fw-bold text-orange mb-2 font-mono">₹${item.price}</div>
                                    <p class="text-muted small mb-0 d-none d-sm-block">
                                        ${item.description}
                                    </p>
                                </div>
                                <div class="col-4 col-sm-3 d-flex flex-column align-items-center justify-content-center">
                                    <div class="menu-item-img-container mb-2">
                                        <img src="${item.imageUrl}" alt="${item.name}">
                                    </div>
                                    <form action="${pageContext.request.contextPath}/cart" method="POST">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="id" value="${item.id}">
                                        <input type="hidden" name="name" value="${item.name}">
                                        <input type="hidden" name="price" value="${item.price}">
                                        <input type="hidden" name="img" value="${item.imageUrl}">
                                        <button type="submit" class="btn btn-sm btn-outline-orange px-3 py-1 rounded-2 fw-bold text-uppercase shadow-sm">Add <i class="bi bi-plus"></i></button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    <% if (menuItems == null || menuItems.isEmpty()) { %>
                        <div class="text-center py-5">
                            <i class="bi bi-egg-fried text-muted fs-1 mb-3"></i>
                            <h5 class="text-secondary fw-bold">No Menu Items Available</h5>
                            <p class="text-muted small mb-0">Check back later or try another restaurant.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Filter Toggle Logic -->
    <script>
        function toggleVegOnly() {
            const isChecked = document.getElementById('veg-only-switch').checked;
            const itemCards = document.querySelectorAll('.food-item-row-card');
            
            itemCards.forEach(card => {
                const isVeg = card.getAttribute('data-veg') === 'true';
                if (isChecked && !isVeg) {
                    card.classList.add('d-none');
                } else {
                    card.classList.remove('d-none');
                }
            });
        }
    </script>
</body>
</html>
