<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.hungrygo.model.Cart" %>
<%@ page import="com.hungrygo.model.CartItem" %>
<%@ page import="com.hungrygo.model.MenuItem" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.math.BigDecimal" %>

<%
    Cart cart = (Cart) session.getAttribute("cart");
    if (cart == null) {
        cart = new Cart();
        session.setAttribute("cart", cart);
    }
    
    // Calculate totals dynamically on the server
    BigDecimal subtotal = cart.getTotalPrice();
    BigDecimal discount = BigDecimal.ZERO;
    
    // Check if coupon flat discount of $2.00 is applied
    boolean promoApplied = false;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if (c.getName().equals("promoApplied") && c.getValue().equals("true")) {
                promoApplied = true;
                break;
            }
        }
    }
    
    if (promoApplied && subtotal.compareTo(BigDecimal.ZERO) > 0) {
        discount = new BigDecimal("160.00");
        if (subtotal.compareTo(discount) < 0) {
            discount = subtotal;
        }
    }
    
    BigDecimal deliveryFee = subtotal.compareTo(BigDecimal.ZERO) > 0 ? new BigDecimal("120.00") : BigDecimal.ZERO;
    BigDecimal taxFee = subtotal.compareTo(BigDecimal.ZERO) > 0 ? new BigDecimal("40.00") : BigDecimal.ZERO;
    BigDecimal gtotal = subtotal.subtract(discount).add(deliveryFee).add(taxFee);
    
    // Feed parameters back into request scopes
    request.setAttribute("cartItems", cart.getItems().values());
    request.setAttribute("subtotal", subtotal);
    request.setAttribute("discount", discount);
    request.setAttribute("deliveryFee", deliveryFee);
    request.setAttribute("taxFee", taxFee);
    request.setAttribute("gtotal", gtotal);
    request.setAttribute("promoApplied", promoApplied);
    
    // Synchronize navbar cartCount
    session.setAttribute("cartSize", cart.getCartSize());
%>

<!DOCTYPE html>
<html lang="en" id="root-html-cart">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Basket | HungryGO Cart</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-cart">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <main class="container py-5" id="cart-main-container">
        <!-- Step Indicator -->
        <div class="row justify-content-center mb-5">
            <div class="col-md-8 col-lg-6">
                <div class="checkout-steps">
                    <div class="checkout-step-item active">
                        <div class="checkout-step-icon">1</div>
                        <span class="fs-8 fw-semibold text-dark">My Cart</span>
                    </div>
                    <div class="checkout-step-item">
                        <div class="checkout-step-icon">2</div>
                        <span class="fs-8 text-muted">Checkout</span>
                    </div>
                    <div class="checkout-step-item">
                        <div class="checkout-step-icon">3</div>
                        <span class="fs-8 text-muted">Success</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cart Grid Layout -->
        <div class="row g-4" id="cart-workspace">
            <!-- Left Cart Items Column -->
            <div class="col-lg-8" id="cart-items-column">
                <div class="card border-0 shadow-sm rounded-4 p-4" id="cart-info-card">
                    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                        <h4 class="fw-bold text-dark mb-0 font-display"><i class="bi bi-cart3 me-2 text-orange"></i> Shopping Cart</h4>
                        <span class="badge bg-light text-dark border px-3 py-1.5 rounded-pill fw-bold" id="cart-item-count">
                            <%= cart.getCartSize() %> <%= (cart.getCartSize() == 1) ? "Item" : "Items" %>
                        </span>
                    </div>

                    <!-- JSTL Dynamic Loop over Cart Items -->
                    <div class="d-flex flex-column gap-3" id="active-cart-rows">
                        <c:forEach var="item" items="${cartItems}">
                            <div class="row align-items-center border-bottom pb-3 g-2">
                                <div class="col-3 col-sm-2">
                                    <img src="${item.menuItem.imageUrl}" alt="${item.menuItem.name}" class="cart-product-img rounded-3" style="width: 100%; max-height: 70px; object-fit: cover;">
                                </div>
                                <div class="col-9 col-sm-4">
                                    <h6 class="fw-bold mb-1 text-dark text-truncate">${item.menuItem.name}</h6>
                                    <span class="fs-8 text-muted fw-bold">₹${item.menuItem.price} each</span>
                                </div>
                                <div class="col-6 col-sm-3 d-flex justify-content-center">
                                    <!-- Qty custom modifier form -->
                                    <form action="cart" method="POST" class="d-inline">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="id" value="${item.menuItem.id}">
                                        <div class="d-flex align-items-center gap-1 border rounded-pill bg-white p-1">
                                            <button type="submit" name="quantity" value="${item.quantity - 1}" class="btn btn-sm btn-light rounded-circle shadow-none py-1 px-2 border-0"><i class="bi bi-dash fs-8"></i></button>
                                            <span class="font-mono px-2 fw-bold text-dark fs-7">${item.quantity}</span>
                                            <button type="submit" name="quantity" value="${item.quantity + 1}" class="btn btn-sm btn-light rounded-circle shadow-none py-1 px-2 border-0"><i class="bi bi-plus fs-8"></i></button>
                                        </div>
                                    </form>
                                </div>
                                <div class="col-4 col-sm-2 text-sm-end text-start">
                                    <span class="fw-bold text-dark font-mono">₹${item.subtotal}</span>
                                </div>
                                <div class="col-2 col-sm-1 text-end">
                                    <form action="cart" method="POST" class="d-inline">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="id" value="${item.menuItem.id}">
                                        <button type="submit" class="btn btn-outline-danger btn-sm border-0 rounded-circle"><i class="bi bi-trash"></i></button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty cartItems}">
                            <div class="text-center py-5">
                                <i class="bi bi-basket-fill text-muted display-4 mb-3 text-orange"></i>
                                <h5 class="fw-bold text-secondary">Your cart is empty!</h5>
                                <p class="text-muted small mb-3">Add some delicious dishes from your favorite local restaurant!</p>
                                <a href="restaurants.jsp" class="btn btn-orange px-4 py-2 rounded-3 fw-bold decoration-none text-white shadow">Explore Restaurants</a>
                            </div>
                        </c:if>
                    </div>

                    <!-- Actions back to menu -->
                    <div class="pt-4 border-top mt-4 d-flex justify-content-between align-items-center">
                        <a href="restaurants.jsp" class="btn btn-outline-secondary px-4 py-2.5 rounded-3 fw-bold fs-7 text-decoration-none">
                            <i class="bi bi-arrow-left me-1"></i> Continue Shopping
                        </a>
                        <form action="cart" method="POST" class="d-inline">
                            <input type="hidden" name="action" value="clear">
                            <button type="submit" class="btn btn-sm btn-link text-danger text-decoration-none fw-bold">
                                <i class="bi bi-trash-fill me-1"></i> Clear Cart
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Right Promo and Billing Summary Column -->
            <div class="col-lg-4" id="cart-billing-column">
                <!-- Promo Code -->
                <div class="card border-0 shadow-sm rounded-4 p-4 mb-4" id="promo-code-card">
                    <h6 class="fw-bold text-dark mb-3">Have a promocode?</h5>
                    <div class="d-flex gap-2">
                        <input type="text" class="form-control rounded-3 py-2.5 text-uppercase fw-bold font-mono text-center border" placeholder="QKBITE20" id="coupon-code-input">
                        <button class="btn btn-orange px-3 py-2.5 rounded-3 fw-bold" onclick="applyPromo()">Apply</button>
                    </div>
                    
                    <c:if test="${promoApplied}">
                        <div class="alert alert-success py-2 px-3 fs-8 mt-3 mb-0 rounded-3 d-flex align-items-center justify-content-between text-success" id="promo-success-box">
                            <span><i class="bi bi-check-circle-fill me-1"></i> Coupon applied! Flat ₹160.00 off.</span>
                            <button class="btn btn-sm text-danger p-0 border-0 bg-transparent fw-bold fs-8" onclick="removePromo()">Remove</button>
                        </div>
                    </c:if>
                </div>

                <!-- Billing breakdown receipt -->
                <div class="card border-0 shadow-sm rounded-4 p-4" id="cart-receipt-card">
                    <h5 class="fw-bold text-dark mb-4 border-bottom pb-2 font-display">Bill Summary</h5>
                    
                    <div class="d-flex flex-column gap-3 border-bottom pb-3 mb-3 fs-7" id="cart-billing-breakdown">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted">Item Subtotal</span>
                            <span class="fw-medium text-dark font-mono" id="val-subtotal">₹${subtotal}</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted">Promo Discount</span>
                            <span class="fw-medium text-success font-mono" id="val-discount">-₹${discount}</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted">Delivery partner fee</span>
                            <span class="fw-medium text-dark font-mono" id="val-delivery">₹${deliveryFee}</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted">Convenience & Restaurant taxes</span>
                            <span class="fw-medium text-dark font-mono" id="val-tax">₹${taxFee}</span>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <span class="fw-bold fs-6 text-dark">Grand Total</span>
                        <span class="fw-extrabold fs-5 text-orange font-mono" id="val-grand-total">₹${gtotal}</span>
                    </div>

                    <a href="checkout.jsp" class="btn btn-orange w-full py-3 rounded-4 fw-bold fs-5 text-decoration-none text-center shadow-md hover-up <c:if test='${empty cartItems}'>disabled</c:if>" id="btn-proceed-checkout">
                        Proceed to Checkout <i class="bi bi-chevron-right ms-1"></i>
                    </a>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Sync browser memory on JSP load to make interactive node views run flawlessly -->
    <script>
        (function() {
            const syncCart = [
                <c:forEach var="item" items="${cartItems}">
                    {
                        id: '${item.menuItem.id}',
                        name: '${item.menuItem.name}',
                        price: ${item.menuItem.price},
                        qty: ${item.quantity},
                        img: '${item.menuItem.imageUrl}'
                    },
                </c:forEach>
            ];
            
            // Set localStorage items
            localStorage.setItem('quickbite_cart', JSON.stringify(syncCart));
            
            // Sync cookie count
            const count = <%= cart.getCartSize() %>;
            document.cookie = `cartCount=${count}; path=/`;
            const badge = document.getElementById('nav-cart-badge');
            if (badge) badge.innerText = count;
        })();

        function applyPromo() {
            const val = document.getElementById('coupon-code-input').value.toUpperCase();
            if (val === 'QKBITE20') {
                document.cookie = "promoApplied=true; path=/";
                window.location.reload();
            } else {
                alert("Invalid Coupon Code! Try using 'QKBITE20'");
            }
        }

        function removePromo() {
            document.cookie = "promoApplied=false; path=/";
            window.location.reload();
        }
    </script>
</body>
</html>
