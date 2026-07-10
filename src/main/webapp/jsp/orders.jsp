<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>


<!DOCTYPE html>
<html lang="en" id="root-html-orders">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders | TindiTime Delivery Tracking</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/jsp/style.css?v=2" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-orders">

    <!-- Header Navigation Include -->
    <jsp:include page="navbar.jsp" />

    <main class="container py-5" id="orders-main-section">
        <div class="row" id="orders-dashboard-layout">
            <!-- Left Navigation Sidebar -->
            <div class="col-lg-3 d-none d-lg-block" id="orders-dashboard-sidebar">
                <div class="card border-0 shadow-sm p-3 rounded-4" id="profile-links-card">
                    <div class="text-center p-3 border-bottom mb-3" id="profile-tiny-summary">
                        <i class="bi bi-person-circle display-4 mb-2" style="color: var(--color-deep-forest) !important;"></i>
                        <h6 class="fw-bold mb-0"><c:out value="${sessionScope.username}" /></h6>
                        <span class="fs-8 text-muted"><c:out value="${sessionScope.email}" /></span>
                    </div>
                    <div class="d-flex flex-column gap-2">
                        <a href="${pageContext.request.contextPath}/profile" class="profile-sidebar-item"><i class="bi bi-person"></i> My Profile</a>
                        <a href="${pageContext.request.contextPath}/orders" class="profile-sidebar-item active"><i class="bi bi-journal-text"></i> My Orders</a>
                        <a href="${pageContext.request.contextPath}/login?action=logout" class="profile-sidebar-item text-danger"><i class="bi bi-box-arrow-right"></i> Log Out</a>
                    </div>
                </div>
            </div>

            <!-- Right Orders History Panel -->
            <div class="col-lg-9" id="orders-history-panel">
                <div class="card border-0 shadow-sm rounded-4 p-4" id="orders-wrapper-card">
                    <h4 class="fw-bold text-dark border-bottom pb-3 mb-4 font-display"><i class="bi bi-clock-history me-2" style="color: var(--color-deep-forest) !important;"></i> My Order Journeys</h4>
                    
                    <div class="d-flex flex-column gap-4" id="placed-orders-list">
                        <c:forEach var="order" items="${orders}" varStatus="loop">
                            <!-- Compile item JSON string dynamically for Reorder button -->
                            <c:set var="itemJson">
                            [
                                <c:forEach var="oi" items="${order.orderItems}" varStatus="itemLoop">
                                    {
                                        "id": "${oi.menuItemId}",
                                        "name": "${oi.menuItem.name}",
                                        "price": ${not empty oi.menuItem ? oi.menuItem.price : oi.priceAtPurchase},
                                        "qty": ${oi.quantity},
                                        "img": "${not empty oi.menuItem ? oi.menuItem.imageUrl : 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=150&q=80'}"
                                    }${not itemLoop.last ? ',' : ''}
                                </c:forEach>
                            ]
                            </c:set>

                            <div class="card border rounded-4 p-3 mb-2" id="order-box-${loop.index}">
                                <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
                                    <div>
                                        <span class="badge bg-light text-dark font-mono border py-2 px-3 fw-bold"><c:out value="${order.orderId}" /></span>
                                        <span class="text-muted small ms-2"><fmt:formatDate value="${order.createdAt}" pattern="MMMM dd, yyyy" /></span>
                                    </div>
                                    <span class="badge <c:choose><c:when test='${order.orderStatus == \"Preparing\"}'>bg-warning text-dark</c:when><c:when test='${order.orderStatus == \"Out For Delivery\"}'>bg-info text-white</c:when><c:otherwise>bg-success</c:otherwise></c:choose> py-2 px-3 fw-bold rounded-pill d-flex align-items-center gap-1.5 fs-8">
                                        <i class="bi <c:choose><c:when test='${order.orderStatus == \"Preparing\"}'>bi-hourglass-split</c:when><c:when test='${order.orderStatus == \"Out For Delivery\"}'>bi-truck</c:when><c:otherwise>bi-check-circle-fill</c:otherwise></c:choose>"></i>
                                        <c:choose>
                                            <c:when test='${order.orderStatus == "Preparing"}'>FOOD IS PREPARING</c:when>
                                            <c:otherwise><c:out value="${order.orderStatus.toUpperCase()}" /></c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="row align-items-center fs-7 g-3 border-bottom pb-3 mb-3">
                                    <div class="col-sm-8 text-start">
                                        <h6 class="fw-bold mb-1 text-dark text-truncate">
                                            <c:forEach var="oi" items="${order.orderItems}" varStatus="itemLoop">
                                                <c:out value="${oi.quantity}" /> x <c:out value="${oi.menuItem.name}" />${not itemLoop.last ? ', ' : ''}
                                            </c:forEach>
                                        </h6>
                                        <p class="text-muted mb-2 text-truncate" style="max-width: 500px;"><i class="bi bi-geo-alt me-1"></i> Deliver to: <c:out value="${order.deliveryAddress}" /></p>
                                        <span class="fs-8 text-muted uppercase font-medium">Payment: <c:out value="${order.paymentMethod}" /></span>
                                    </div>
                                    <div class="col-sm-4 text-sm-end text-start">
                                        <span class="text-muted small d-block">Grand Total:</span>
                                        <span class="fw-bold fs-4 font-mono" style="color: var(--color-deep-forest) !important;">₹<fmt:formatNumber value="${order.totalAmount}" type="number" minFractionDigits="2" maxFractionDigits="2" /></span>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pt-1">
                                    <c:choose>
                                        <c:when test="${order.orderStatus == 'Preparing'}">
                                            <div class="d-flex align-items-center gap-2 text-warning fs-8 fw-semibold animate-pulse">
                                                <span class="spinner-grow spinner-grow-sm text-warning" role="status"></span>
                                                <span>Rider assigning coordinates...</span>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small"><i class="bi bi-shield-fill-check text-success me-1"></i> Contactless delivery completed</span>
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <!-- Reorder button passes item list directly -->
                                    <button class="btn btn-outline-orange btn-sm px-4 py-2 rounded-pill fw-bold text-uppercase" onclick="reorderItems('<c:out value="${itemJson}" />')">
                                        <i class="bi bi-arrow-repeat me-1"></i> Reorder Items
                                    </button>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty orders}">
                            <div class="text-center py-5">
                                <i class="bi bi-clock-history text-muted display-3 mb-3"></i>
                                <h5>No Orders Tracked Yet</h5>
                                <p class="text-muted text-truncate">We haven't recorded any order activity from you yet.</p>
                                <a href="${pageContext.request.contextPath}/restaurants" class="btn btn-orange px-4 py-2 mt-2 rounded-pill fw-bold text-decoration-none">Order Dinner Now</a>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <jsp:include page="footer.jsp" />

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Reorder mechanism -->
    <script>
        // Reorder action copies items back to basket
        function reorderItems(itemsJsonStr) {
            if (!itemsJsonStr) return;
            
            try {
                // Decode HTML entities if parsed as string attribute
                const parser = new DOMParser();
                const decodedStr = parser.parseFromString(itemsJsonStr, 'text/html').body.textContent;
                const items = JSON.parse(decodedStr);

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
                window.location.href = "${pageContext.request.contextPath}/cart";
            } catch (e) {
                console.error("Error during reorder parsing", e);
                alert("Failed to reorder items. Please try adding them manually.");
            }
        }
    </script>
</body>
</html>
