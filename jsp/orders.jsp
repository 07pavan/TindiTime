<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (request.getAttribute("orders") == null) {
        response.sendRedirect("orders");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en" id="root-html-orders">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders | HungryGO Delivery Tracking</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-orders">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <main class="container py-5" id="orders-main-section">
        <div class="row" id="orders-dashboard-layout">
            <!-- Left Navigation Sidebar -->
            <div class="col-lg-3 d-none d-lg-block" id="orders-dashboard-sidebar">
                <div class="card border-0 shadow-sm p-3 rounded-4" id="profile-links-card">
                    <div class="text-center p-3 border-bottom mb-3" id="profile-tiny-summary">
                        <i class="bi bi-person-circle display-4 text-orange mb-2"></i>
                        <h6 class="fw-bold mb-0">Pavan Hegade</h6>
                        <span class="fs-8 text-muted">pavanhegade1232@gmail.com</span>
                    </div>
                    <div class="d-flex flex-column gap-2">
                        <a href="profile.jsp" class="profile-sidebar-item"><i class="bi bi-person"></i> My Profile</a>
                        <a href="orders" class="profile-sidebar-item active"><i class="bi bi-journal-text"></i> My Orders</a>
                        <a href="login.jsp?action=logout" class="profile-sidebar-item text-danger"><i class="bi bi-box-arrow-right"></i> Log Out</a>
                    </div>
                </div>
            </div>

            <!-- Right Orders History Panel -->
            <div class="col-lg-9" id="orders-history-panel">
                <div class="card border-0 shadow-sm rounded-4 p-4" id="orders-wrapper-card">
                    <h4 class="fw-bold text-dark border-bottom pb-3 mb-4 font-display"><i class="bi bi-clock-history text-orange me-2"></i> My Order Journeys</h4>
                    
                    <div class="d-flex flex-column gap-4" id="placed-orders-list">
                        <!-- Simulated items will be loaded dynamically or fall back to default -->
                        <div class="text-center py-5" id="orders-spinner">
                            <div class="spinner-border text-orange" role="status">
                                <span class="visually-hidden">Loading Orders...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Orders Loading and Reorder mechanism -->
    <script>
        // Default past orders mock data
        const defaultOrdersHistory = [
            {
                orderId: 'QKB-452109',
                date: 'June 18, 2026',
                items: [
                    { name: 'Double Pepperoni Supreme Pizza', price: 10.50, qty: 1, img: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=150&q=80' },
                    { name: 'Thick Oreo Vanilla Cream Shake', price: 3.50, qty: 1, img: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=150&q=80' }
                ],
                address: 'Flat 402, Sunset Heights, Bandra West, Mumbai',
                payment: 'Card Payment',
                status: 'Delivered Successfully',
                total: 16.00
            },
            {
                orderId: 'QKB-219504',
                date: 'May 30, 2026',
                items: [
                    { name: 'Crispy Southern fried Chicken Slider', price: 4.00, qty: 2, img: 'https://images.unsplash.com/photo-1513156844825-8324f8c7976e?auto=format&fit=crop&w=150&q=80' }
                ],
                address: 'Flat 402, Sunset Heights, Bandra West, Mumbai',
                payment: 'Cash on Delivery',
                status: 'Delivered Successfully',
                total: 10.00
            }
        ];

        window.addEventListener('DOMContentLoaded', () => {
            let activeOrders = null;
            <%
                java.util.List<com.hungrygo.model.Order> javaOrders = (java.util.List<com.hungrygo.model.Order>) request.getAttribute("orders");
                if (javaOrders != null && !javaOrders.isEmpty()) {
            %>
                activeOrders = [
                    <% 
                        for (int i = 0; i < javaOrders.size(); i++) {
                            com.hungrygo.model.Order o = javaOrders.get(i);
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMMM dd, yyyy");
                            String formattedDate = sdf.format(o.getCreatedAt());
                    %>
                    {
                        orderId: '<%= o.getOrderId() %>',
                        date: '<%= formattedDate %>',
                        items: [
                            <%
                                for (int j = 0; j < o.getOrderItems().size(); j++) {
                                    com.hungrygo.model.OrderItem oi = o.getOrderItems().get(j);
                                    com.hungrygo.model.MenuItem mi = oi.getMenuItem();
                                    String iconUrl = (mi != null && mi.getImageUrl() != null) ? mi.getImageUrl() : "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=150&q=80";
                                    String name = (mi != null) ? mi.getName().replace("'", "\\'") : "Food Dish";
                                    java.math.BigDecimal price = (mi != null) ? mi.getPrice() : oi.getPriceAtPurchase();
                            %>
                            {
                                id: '<%= oi.getMenuItemId() %>',
                                name: '<%= name %>',
                                price: <%= price %>,
                                qty: <%= oi.getQuantity() %>,
                                img: '<%= iconUrl %>'
                            }<%= (j < o.getOrderItems().size() - 1) ? "," : "" %>
                            <% } %>
                        ],
                        address: '<%= o.getDeliveryAddress().replace("'", "\\'") %>',
                        payment: '<%= o.getPaymentMethod() %>',
                        status: '<%= o.getOrderStatus().equals("Preparing") ? "Food is Preparing" : o.getOrderStatus() %>',
                        total: <%= o.getTotalAmount() %>
                    }<%= (i < javaOrders.size() - 1) ? "," : "" %>
                    <% } %>
                ];
            <% } else { %>
                activeOrders = [];
            <% } %>

            renderOrders(activeOrders);
        });

        function renderOrders(orders) {
            const container = document.getElementById('placed-orders-list');
            if (!orders || orders.length === 0) {
                container.innerHTML = `
                    <div class="text-center py-5">
                        <i class="bi bi-clock-history text-muted display-3 mb-3"></i>
                        <h5>No Orders Tracked Yet</h5>
                        <p class="text-muted text-truncate">We haven't recorded any order activity from you yet.</p>
                        <a href="restaurants.jsp" class="btn btn-orange px-4 py-2 mt-2 rounded-3 text-white fw-bold text-decoration-none">Order Dinner Now</a>
                    </div>
                `;
                return;
            }

            container.innerHTML = "";

            orders.forEach((order, index) => {
                const totalItemsQty = order.items.reduce((accum, x) => accum + x.qty, 0);

                let badgeColor = "bg-success";
                let badgeIcon = "bi-check-circle-fill";
                
                if (order.status === "Food is Preparing") {
                    badgeColor = "bg-warning text-dark";
                    badgeIcon = "bi-hourglass-split";
                } else if (order.status === "Out For Delivery") {
                    badgeColor = "bg-info text-white";
                    badgeIcon = "bi-truck";
                }

                // Compile items listing txt
                const itemsNameText = order.items.map(i => `${i.qty} x ${i.name}`).join(', ');

                container.innerHTML += `
                    <div class="card border rounded-4 p-3 mb-2" id="order-box-${index}">
                        <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
                            <div>
                                <span class="badge bg-light text-dark font-mono border py-2 px-3 fw-bold">${order.orderId}</span>
                                <span class="text-muted small ms-2">${order.date}</span>
                            </div>
                            <span class="badge ${badgeColor} py-2 px-3 fw-bold rounded-pill d-flex align-items-center gap-1.5 fs-8">
                                <i class="bi ${badgeIcon}"></i> ${order.status.toUpperCase()}
                            </span>
                        </div>

                        <div class="row align-items-center fs-7 g-3 border-bottom pb-3 mb-3">
                            <div class="col-sm-8 text-start">
                                <h6 class="fw-bold mb-1 text-dark text-truncate">${itemsNameText}</h6>
                                <p class="text-muted mb-2 text-truncate" style="max-width: 500px;"><i class="bi bi-geo-alt me-1"></i> Deliver to: ${order.address}</p>
                                <span class="fs-8 text-muted uppercase font-medium">Payment: ${order.payment}</span>
                            </div>
                            <div class="col-sm-4 text-sm-end text-start">
                                <span class="text-muted small d-block">Grand Total:</span>
                                <span class="fw-bold fs-4 text-orange font-mono">$${parseFloat(order.total).toFixed(2)}</span>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pt-1">
                            <!-- Visual Tracking mini bar if active order -->
                            ${order.status === 'Food is Preparing' ? `
                                <div class="d-flex align-items-center gap-2 text-warning fs-8 fw-semibold animate-pulse">
                                    <span class="spinner-grow spinner-grow-sm text-warning" role="status"></span>
                                    <span>Rider assigning coordinates...</span>
                                </div>
                            ` : `
                                <span class="text-muted small"><i class="bi bi-shield-fill-check text-success me-1"></i> Contactless delivery completed</span>
                            `}
                            
                            <!-- Reorder button passes item list directly -->
                            <button class="btn btn-outline-orange btn-sm px-4 py-2 rounded-3 fw-bold text-uppercase" onclick="reorderItems(${JSON.stringify(order.items).replace(/"/g, '&quot;')})">
                                <i class="bi bi-arrow-repeat me-1"></i> Reorder Items
                            </button>
                        </div>
                    </div>
                `;
            });
        }

        // Reorder action copies items back to basket
        function reorderItems(items) {
            if (!items || items.length === 0) return;

            // Load existing cart items
            let cart = JSON.parse(localStorage.getItem('quickbite_cart') || '[]');
            
            // Loop and add
            items.forEach(pastItem => {
                const existingIdx = cart.findIndex(x => x.id === pastItem.id);
                if (existingIdx > -1) {
                    cart[existingIdx].qty += pastItem.qty;
                } else {
                    cart.push({
                        id: pastItem.id,
                        name: pastItem.name,
                        price: pastItem.price,
                        qty: pastItem.qty,
                        img: pastItem.img
                    });
                }
            });

            localStorage.setItem('quickbite_cart', JSON.stringify(cart));
            
            // Calculate and broadcast total cart badge to cookie
            const totalQty = cart.reduce((accum, x) => accum + x.qty, 0);
            document.cookie = `cartCount=${totalQty}; path=/`;

            // Prompt success trigger and relocate
            alert("Items added back to your cart! Redirecting to basket checkout...");
            window.location.href = "cart.jsp";
        }
    </script>
</body>
</html>
