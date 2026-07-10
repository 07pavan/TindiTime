<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty requestScope.orderId}">
    <c:redirect url="/home" />
</c:if>

<!DOCTYPE html>
<html lang="en" id="root-html-success">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Placed Successfully | TindiTime</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/jsp/style.css?v=2" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-success">

    <!-- Header Navigation Include -->
    <jsp:include page="navbar.jsp" />

    <main class="container my-auto py-5" id="success-main-section">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-5 text-center">
                <!-- Checkmark visual card -->
                <div class="card border-0 shadow-lg p-5 rounded-4 bg-white" id="success-card">
                    <!-- Elegant animated green check circle -->
                    <div class="d-inline-flex align-items-center justify-content-center rounded-circle bg-success-subtle text-success mb-4 animate-scale" style="width: 80px; height: 80px;">
                        <i class="bi bi-patch-check-fill display-4"></i>
                    </div>

                    <h1 class="font-display fw-bold text-dark mb-2">Order Confirmed!</h1>
                    <p class="text-muted small px-lg-3 mb-4">
                        Hooray! Your payment is processed successfully. The kitchen has begun preparing your fresh meal order.
                    </p>

                    <!-- Order Receipt Box Details -->
                    <div class="bg-light p-3 rounded-4 border text-start mb-4 fs-7" id="success-receipt-details">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted font-medium">Order ID:</span>
                            <span class="fw-bold text-dark font-mono"><c:out value="${requestScope.orderId}" /></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted font-medium">Estimated Delivery:</span>
                            <span class="fw-bold text-success"><i class="bi bi-lightning-charge me-1"></i> 25 - 30 Mins</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted font-medium">Paid via:</span>
                            <span class="fw-bold text-dark" id="txt-paid-via">UPI / Card (₹<c:out value="${requestScope.total}" />)</span>
                        </div>
                    </div>

                    <div class="d-grid gap-2" id="success-action-ctas">
                        <a href="${pageContext.request.contextPath}/orders" class="btn btn-forest-primary py-3 fs-6 shadow-sm hover-up">
                            Track Order & Status <i class="bi bi-geo-alt ms-1"></i>
                        </a>
                        <a href="${pageContext.request.contextPath}/restaurants" class="btn btn-outline-orange py-2.5 rounded-pill fw-bold fs-7 text-decoration-none">
                            Contine Food Hunt <i class="bi bi-chevron-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <jsp:include page="footer.jsp" />

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
