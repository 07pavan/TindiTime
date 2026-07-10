<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en" id="root-html-burger-detail">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gourmet Cheddar Bacon Burger Details | TindiTime</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/jsp/style.css?v=2" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-burger-detail">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <main class="container py-5" id="burger-detail-main">
        <!-- Breadcrumb back route -->
        <div class="mb-4">
            <a href="${pageContext.request.contextPath}/menu?id=1" class="btn btn-outline-secondary btn-sm rounded-pill px-3"><i class="bi bi-arrow-left me-1"></i> Back to Burger Palace Menu</a>
        </div>

        <div class="card border-0 shadow-sm rounded-4 overflow-hidden" id="burger-detail-showcase-card">
            <div class="row g-0">
                <!-- Large Food Image Column -->
                <div class="col-lg-6" id="burger-image-col">
                    <div class="position-relative h-100" style="min-height: 380px;">
                        <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80" 
                             alt="Gourmet Cheddar Bacon Burger" 
                             class="position-absolute w-100 h-100 object-fit-cover"
                             id="burger-large-showcase-img">
                        <span class="badge bg-danger text-white position-absolute top-3 right-3 px-3 py-2 fs-7 fw-bold shadow-sm rounded-pill"><i class="bi bi-fire me-1"></i>POPULAR ATTRACTION</span>
                    </div>
                </div>

                <!-- Product Specifications Column -->
                <div class="col-lg-6 p-4 p-md-5 d-flex flex-column justify-content-between" id="burger-specs-col">
                    <div class="text-start">
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <span class="nonveg-badge" title="Non-veg"></span>
                            <span class="text-muted small fw-bold tracking-wider uppercase">BURGERS & SLIDERS</span>
                        </div>
                        <h1 class="display-5 text-dark fw-bold font-display mb-2">Gourmet Cheddar Bacon Burger</h1>
                        <h2 class="fw-bold font-mono mb-4 fs-2" style="color: var(--color-deep-forest) !important;" id="burger-display-price">₹440.00</h2>
                        
                        <h6 class="fw-bold text-dark mb-2">Description</h6>
                        <p class="text-muted small leading-relaxed mb-4">
                            Juicy flame-grilled 100% Angus ground beef tenderly loaded with crispy applewood bacon slices, double layers of aged golden cheddar cheese, fresh beefsteak tomatoes, green leaf lettuce, and pickles inside a premium toasted artisan brioche bun. Served with a side of house special smoky BBQ spread.
                        </p>

                        <h6 class="fw-bold text-dark mb-2">Fresh Ingredients</h6>
                        <div class="d-flex flex-wrap gap-2 mb-4" id="ingredients-baglets">
                            <span class="badge bg-white text-muted border px-2.5 py-1.5 rounded-3 fw-medium">Angus Beef Patty</span>
                            <span class="badge bg-white text-muted border px-2.5 py-1.5 rounded-3 fw-medium">Applewood Smoked Bacon</span>
                            <span class="badge bg-white text-muted border px-2.5 py-1.5 rounded-3 fw-medium">Melted Cheddar Cheese</span>
                            <span class="badge bg-white text-muted border px-2.5 py-1.5 rounded-3 fw-medium">Artisan Brioche Bun</span>
                            <span class="badge bg-white text-muted border px-2.5 py-1.5 rounded-3 fw-medium">Smoky Hickory BBQ Sauce</span>
                            <span class="badge bg-white text-muted border px-2.5 py-1.5 rounded-3 fw-medium">Pickle Slices</span>
                        </div>

                        <!-- CUSTOMIZATION OPTIONS FOR CUSTOMER -->
                        <div class="bg-light p-3 rounded-3 border mb-4">
                            <h6 class="fw-bold text-dark mb-2"><i class="bi bi-sliders me-1" style="color: var(--color-deep-forest) !important;"></i> Customize Your Order</h6>
                            
                            <div class="form-check d-flex justify-content-between align-items-center mb-2 fs-7">
                                <div>
                                    <input class="form-check-input accent-orange addon-checkbox" type="checkbox" id="addon-extra-cheese" value="60.00" onchange="calculateTotal()">
                                    <label class="form-check-label text-dark fw-medium" for="addon-extra-cheese">Extra Cheddar Cheese</label>
                                </div>
                                <span class="text-muted font-mono">+₹60.00</span>
                            </div>

                            <div class="form-check d-flex justify-content-between align-items-center mb-2 fs-7">
                                <div>
                                    <input class="form-check-input accent-orange addon-checkbox" type="checkbox" id="addon-extra-bacon" value="120.00" onchange="calculateTotal()">
                                    <label class="form-check-label text-dark fw-medium" for="addon-extra-bacon">Double Applewood Smoked Bacon</label>
                                </div>
                                <span class="text-muted font-mono">+₹120.00</span>
                            </div>
                        </div>
                    </div>

                    <!-- Quantity Counter and Interactive CTA -->
                    <form action="${pageContext.request.contextPath}/cart" method="POST" id="burger-add-form" class="mt-4 pt-4 border-top">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="id" value="1">
                        <input type="hidden" name="name" id="final-item-name" value="Gourmet Cheddar Bacon Burger">
                        <input type="hidden" name="price" id="final-item-price" value="440.00">
                        <input type="hidden" name="img" value="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=150&q=80">
                        
                        <div class="d-flex flex-column flex-sm-row gap-3 align-items-sm-center">
                            <!-- Quantity selector -->
                            <div class="d-flex align-items-center gap-2 border rounded-4 bg-white p-1" style="width: fit-content;" id="qty-selector-container">
                                <button type="button" class="btn btn-light rounded-circle shadow-none border-0" onclick="updateQty(-1)" style="width: 38px; height: 38px;"><i class="bi bi-dash"></i></button>
                                <input type="number" name="quantity" id="qty-input" value="1" min="1" max="10" readonly class="form-control text-center bg-transparent border-0 font-mono fw-bold fs-6 p-0 shadow-none" style="width: 32px;">
                                <button type="button" class="btn btn-light rounded-circle shadow-none border-0" onclick="updateQty(1)" style="width: 38px; height: 38px;"><i class="bi bi-plus"></i></button>
                            </div>

                            <!-- Cart Add Button -->
                            <button type="submit" class="btn btn-forest-primary flex-grow-1 py-3 fs-5 shadow-sm">
                                Add to Basket (<span id="cart-cost-display" class="font-mono">₹440.00</span>)
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Interactive calculation script -->
    <script>
        const basePrice = 440.00;
        let selectedQty = 1;

        function updateQty(val) {
            const input = document.getElementById('qty-input');
            let current = parseInt(input.value);
            current += val;
            if (current >= 1 && current <= 10) {
                input.value = current;
                selectedQty = current;
                calculateTotal();
            }
        }

        function calculateTotal() {
            let itemPrice = basePrice;
            let finalName = "Gourmet Cheddar Bacon Burger";

            // Addons
            const extraCheese = document.getElementById('addon-extra-cheese');
            const extraBacon = document.getElementById('addon-extra-bacon');

            if (extraCheese && extraCheese.checked) {
                itemPrice += parseFloat(extraCheese.value);
                finalName += " + Extra Cheese";
            }
            if (extraBacon && extraBacon.checked) {
                itemPrice += parseFloat(extraBacon.value);
                finalName += " + Extra Bacon";
            }

            const total = itemPrice * selectedQty;
            
            // Update hidden values to send to cart
            document.getElementById('final-item-price').value = itemPrice.toFixed(2);
            document.getElementById('final-item-name').value = finalName;
            
            // Update UI
            document.getElementById('cart-cost-display').innerText = '₹' + total.toFixed(2);
        }
    </script>

    <!-- Self-contained AJAX Add-to-Cart for burger detail page -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var form = document.getElementById('burger-add-form');
            if (!form) return;

            form.addEventListener('submit', function (e) {
                e.preventDefault();

                var btn      = form.querySelector('button[type="submit"]');
                var origHtml = btn ? btn.innerHTML : '';

                if (btn) {
                    btn.disabled = true;
                    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>Adding…';
                }

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
                        if (btn) {
                            btn.classList.remove('btn-forest-primary');
                            btn.classList.add('btn-success');
                            btn.innerHTML = '<i class="bi bi-check-lg"></i> Added to Cart!';
                            setTimeout(function () {
                                btn.disabled = false;
                                btn.innerHTML = origHtml;
                                btn.classList.remove('btn-success');
                                btn.classList.add('btn-forest-primary');
                            }, 1800);
                        }
                        var cartSize = data.cartSize;
                        var badge = document.getElementById('nav-cart-badge');
                        if (badge) {
                            badge.textContent = cartSize;
                            badge.classList.remove('pulse-animation');
                            void badge.offsetWidth;
                            badge.classList.add('pulse-animation');
                        }
                        var bar = document.getElementById('floating-cart-bar');
                        if (bar) {
                            var txt = document.getElementById('floating-cart-text');
                            if (txt) {
                                txt.innerHTML = '<span id="floating-cart-qty" class="font-mono">' + cartSize + '</span>&nbsp;' +
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
                    if (err.message !== 'auth' && btn) {
                        btn.disabled = false;
                        btn.innerHTML = origHtml;
                    }
                });
            });
        });
    </script>
</body>
</html>
