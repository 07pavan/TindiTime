<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp?msg=auth_required");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en" id="root-html-checkout">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout | HungryGO Food Delivery</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-checkout">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <main class="container py-5" id="checkout-main-section">
        <!-- Step Indicator -->
        <div class="row justify-content-center mb-5">
            <div class="col-md-8 col-lg-6">
                <div class="checkout-steps">
                    <div class="checkout-step-item completed">
                        <div class="checkout-step-icon"><i class="bi bi-check-lg text-white"></i></div>
                        <span class="fs-8 text-muted">My Cart</span>
                    </div>
                    <div class="checkout-step-item active">
                        <div class="checkout-step-icon">2</div>
                        <span class="fs-8 fw-semibold text-dark">Checkout</span>
                    </div>
                    <div class="checkout-step-item">
                        <div class="checkout-step-icon">3</div>
                        <span class="fs-8 text-muted">Success</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Checkout columns -->
        <div class="row g-4" id="checkout-workspace">
            <!-- Left inputs columns -->
            <div class="col-lg-8">
                <!-- 1. Delivery Address Card -->
                <div class="card border-0 shadow-sm rounded-4 p-4 mb-4" id="checkout-address-card">
                    <h5 class="fw-bold text-dark mb-4 font-display"><i class="bi bi-geo-alt-fill text-orange me-2"></i> 1. Delivery Address</h5>
                    
                    <div class="row g-3 mb-4" id="address-selection">
                        <!-- Option Home -->
                        <div class="col-md-6">
                            <div class="card border border-2 border-orange bg-orange-subtle h-100 p-3 rounded-3 address-box cursor-pointer" onclick="selectAddress('home', 'home-full-address')">
                                <div class="d-flex justify-content-between">
                                    <h6 class="fw-bold mb-1"><i class="bi bi-house-door-fill text-orange me-1"></i> Home</h6>
                                    <i class="bi bi-check-circle-fill text-orange fs-5" id="adr-icon-home"></i>
                                </div>
                                <p class="small text-muted mb-0 mt-2" id="home-full-address">
                                    <%= (session.getAttribute("address") != null) ? session.getAttribute("address") : "Flat 402, Sunset Heights, Bandra West, Mumbai" %>
                                </p>
                            </div>
                        </div>

                        <!-- Option Work -->
                        <div class="col-md-6">
                            <div class="card border h-100 p-3 rounded-3 address-box cursor-pointer" id="addr-card-work" onclick="selectAddress('work', 'work-full-address')">
                                <div class="d-flex justify-content-between">
                                    <h6 class="fw-bold mb-1"><i class="bi bi-briefcase-fill text-muted me-1"></i> Office / Work</h6>
                                    <i class="bi bi-circle text-muted" id="adr-icon-work"></i>
                                </div>
                                <p class="small text-muted mb-0 mt-2" id="work-full-address">
                                    Tower C, 6th Floor, Naman Centre, G-Block BKC, Bandra East, Mumbai
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Custom inputs fields -->
                    <div class="collapse show" id="custom-address-inputs">
                        <label class="form-label text-muted small fw-bold">Custom Delivery Instructions / Notes</label>
                        <input type="text" class="form-control rounded-3 py-2.5 bg-light" placeholder="e.g. Ring doorbell, Leave at front door, call before entering" id="delivery-instructions">
                    </div>
                </div>

                <!-- 2. Choose Payment Method -->
                <div class="card border-0 shadow-sm rounded-4 p-4" id="checkout-payment-card">
                    <h5 class="fw-bold text-dark mb-4 font-display"><i class="bi bi-credit-card-fill text-orange me-2"></i> 2. Select Payment Mode</h5>
                    
                    <div class="d-flex flex-column gap-3" id="payment-options-list">
                        <!-- UPI Radio Option -->
                        <div class="form-check p-3 border rounded-3 d-flex align-items-center justify-content-between bg-white cursor-pointer" onclick="selectPayment('pay_upi')">
                            <div class="d-flex align-items-center gap-3">
                                <input class="form-check-input ms-0 mt-0 flex-shrink-0" type="radio" name="payment_method" id="pay_upi" value="UPI" checked>
                                <label class="form-check-label fw-bold text-dark cursor-pointer" for="pay_upi">
                                    Unified Payment Interface (UPI) / GPay
                                </label>
                            </div>
                            <span class="fs-4 text-primary"><i class="bi bi-phone-vibrate"></i></span>
                        </div>

                        <!-- Card Radio Option -->
                        <div class="form-check p-3 border rounded-3 d-flex align-items-center justify-content-between bg-white cursor-pointer" onclick="selectPayment('pay_card')">
                            <div class="d-flex align-items-center gap-3">
                                <input class="form-check-input ms-0 mt-0 flex-shrink-0" type="radio" name="payment_method" id="pay_card" value="Card">
                                <label class="form-check-label fw-bold text-dark cursor-pointer" for="pay_card">
                                    Credit / Debit Card (Visa, Mastercard, RuPay)
                                </label>
                            </div>
                            <span class="fs-4 text-success"><i class="bi bi-credit-card-2-back"></i></span>
                        </div>

                        <!-- COD Option -->
                        <div class="form-check p-3 border rounded-3 d-flex align-items-center justify-content-between bg-white cursor-pointer" onclick="selectPayment('pay_cod')">
                            <div class="d-flex align-items-center gap-3">
                                <input class="form-check-input ms-0 mt-0 flex-shrink-0" type="radio" name="payment_method" id="pay_cod" value="COD">
                                <label class="form-check-label fw-bold text-dark cursor-pointer" for="pay_cod">
                                    Cash on Delivery / Pay after arrival (COD)
                                </label>
                            </div>
                            <span class="fs-4 text-muted"><i class="bi bi-cash-stack"></i></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column Billing/Place Order Summary -->
            <div class="col-lg-4" id="checkout-summary-column">
                <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 100px;" id="checkout-summary-card">
                    <h5 class="fw-bold text-dark border-bottom pb-2 mb-4 font-display">Order Checkout</h5>
                    
                    <!-- Dynamic items list -->
                    <div class="d-flex flex-column gap-3 mb-4" id="checkout-item-list" style="max-height: 200px; overflow-y: auto;">
                        <!-- Items rendered in LocalStorage -->
                        <span class="text-muted text-center fs-7">Rerouting checkout details...</span>
                    </div>

                    <hr class="opacity-25 my-3">

                    <div class="d-flex flex-column gap-2 fs-7 mb-4">
                        <div class="d-flex justify-content-between">
                            <span class="text-muted">Item Subtotal:</span>
                            <span class="fw-semibold font-mono" id="sum-subtotal">₹0.00</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted">Promo Code applied:</span>
                            <span class="fw-semibold text-success font-mono" id="sum-discount">-₹0.00</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted font-medium">Delivery & Taxes:</span>
                            <span class="font-mono text-dark fw-bold">₹160.00</span>
                        </div>
                        <hr class="my-1 border-dotted">
                        <div class="d-flex justify-content-between align-items-center mt-1">
                            <span class="fw-bold text-dark fs-6">Payable Total:</span>
                            <span class="fw-bold text-orange font-mono fs-5" id="sum-grand-total">₹0.00</span>
                        </div>
                    </div>

                    <!-- Checkout button -->
                    <button class="btn btn-orange w-full py-3 fs-5 rounded-4 fw-bold shadow-md hover-up" onclick="placeOrder()">
                        Place Order <i class="bi bi-wallet2 ms-1"></i>
                    </button>
                    <form id="real-checkout-form" action="checkout" method="POST" style="display:none;">
                        <input type="hidden" name="address" id="form-address">
                        <input type="hidden" name="payment" id="form-payment">
                    </form>
                    <p class="text-center text-muted small fs-8 mt-3 mb-0">
                        By placing this order you consent to our terms & rapid delivery policies.
                    </p>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Interactive script placeholders -->
    <script>
        let selectedAddressStr = "";

        window.addEventListener('DOMContentLoaded', () => {
            const activeCart = JSON.parse(localStorage.getItem('quickbite_cart') || '[]');
            renderCheckoutReceipt(activeCart);

            // Fetch default address
            selectedAddressStr = document.getElementById('home-full-address').innerText.trim();
        });

        function renderCheckoutReceipt(items) {
            const container = document.getElementById('checkout-item-list');
            const subtotalValEl = document.getElementById('sum-subtotal');
            const grandTotalValEl = document.getElementById('sum-grand-total');

            if (items.length === 0) {
                container.innerHTML = `<span class="text-muted text-center fs-7">No items selected</span>`;
                return;
            }

            container.innerHTML = "";
            let subtotal = 0;

            items.forEach(item => {
                subtotal += parseFloat(item.price) * parseInt(item.qty);
                container.innerHTML += `
                    <div class="d-flex justify-content-between align-items-center fs-7">
                        <div class="text-truncate me-2" style="max-width: 180px;">
                            <span class="fw-bold text-dark">${item.qty}x</span> <span>${item.name}</span>
                        </div>
                        <span class="font-mono fw-semibold text-dark">₹${(parseFloat(item.price) * item.qty).toFixed(2)}</span>
                    </div>
                `;
            });

            subtotalValEl.innerText = `₹${subtotal.toFixed(2)}`;
            const discountVal = 0.00; // default empty
            const total = subtotal - discountVal + 160.00;
            grandTotalValEl.innerText = `₹${total.toFixed(2)}`;
        }

        // Address selection togglers
        function selectAddress(type, elementId) {
            selectedAddressStr = document.getElementById(elementId).innerText.trim();
            const homeCard = document.querySelector('.address-box');
            const workCard = document.getElementById('addr-card-work');
            
            const homeIcon = document.getElementById('adr-icon-home');
            const workIcon = document.getElementById('adr-icon-work');

            if (type === 'home') {
                homeCard.classList.add('border-orange', 'bg-orange-subtle');
                workCard.classList.remove('border-orange', 'bg-orange-subtle');
                homeIcon.className = "bi bi-check-circle-fill text-orange fs-5";
                workIcon.className = "bi bi-circle text-muted fs-5";
            } else {
                workCard.classList.add('border-orange', 'bg-orange-subtle');
                homeCard.classList.remove('border-orange', 'bg-orange-subtle');
                workIcon.className = "bi bi-check-circle-fill text-orange fs-5";
                homeIcon.className = "bi bi-circle text-muted fs-5";
            }
        }

        function selectPayment(id) {
            document.getElementById(id).checked = true;
        }

        function placeOrder() {
            const activeCart = JSON.parse(localStorage.getItem('quickbite_cart') || '[]');
            if (activeCart.length === 0) {
                alert("Your cart is empty! Please add items before placing order.");
                return;
            }

            // Retrieve selected payment method
            const paymentOptions = document.getElementsByName('payment_method');
            let paymentVal = "UPI";
            for(let i=0; i < paymentOptions.length; i++) {
                if(paymentOptions[i].checked) {
                    paymentVal = paymentOptions[i].value;
                }
            }

            // Set form values and submit to server
            document.getElementById('form-address').value = selectedAddressStr;
            document.getElementById('form-payment').value = paymentVal;
            document.getElementById('real-checkout-form').submit();
        }
    </script>
</body>
</html>
