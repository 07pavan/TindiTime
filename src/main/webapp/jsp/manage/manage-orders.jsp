<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 4 : ORDER MANAGEMENT
    MVC: populated by AdminOrderServlet which sets:
      requestScope.orders          — List<Order>
      requestScope.filterStatus    — String   active status filter
      requestScope.filterRestId    — Long     active restaurant filter (admin only)
      requestScope.dateFrom        — String   filter date from
      requestScope.dateTo          — String   filter date to
      requestScope.searchQuery     — String   customer name / order id search
      requestScope.currentPage     — int
      requestScope.totalPages      — int
      requestScope.stats           — Map: placedCount, confirmedCount, preparingCount,
                                          deliveredCount, cancelledCount, todayRevenue
      requestScope.restaurants     — List<Restaurant>  for filter dropdown (admin only)

    Each Order has:
      id, customerName, customerPhone, customerEmail,
      restaurantName, totalAmount, paymentMethod, status,
      orderDate, deliveryAddress, city, postalCode,
      items → List<OrderItem> {name, quantity, price}
--%>
<c:set var="pageTitle" value="Order Management" scope="request"/>
<c:set var="activeNav"  value="orders"          scope="request"/>

<jsp:include page="manage-sidebar.jsp"/>

<%-- ══════════════════════ PAGE-SCOPED STYLES ══════════════════════ --%>
<style>
    /* ── Stat strip ───────────────────────────────── */
    .stat-strip {
        display:grid;
        grid-template-columns:repeat(auto-fit, minmax(130px, 1fr));
        gap:.75rem;
        margin-bottom:1.5rem;
    }
    .stat-tile {
        background:#fff;
        border:1px solid rgba(140,140,130,0.2);
        border-radius:20px;
        padding:1rem 1.1rem;
        display:flex; align-items:center; gap:.75rem;
        transition:box-shadow .2s, transform .2s;
        cursor:pointer;
        text-decoration:none;
    }
    .stat-tile:hover { box-shadow:rgba(14,21,14,0.08) 0 8px 20px -4px; transform:translateY(-2px); }
    .stat-tile.active-filter { border-color:var(--color-deep-forest); box-shadow:0 0 0 3px rgba(0,71,60,0.1); }
    .stat-icon {
        width:40px; height:40px; border-radius:12px;
        display:flex; align-items:center; justify-content:center;
        font-size:1.1rem; flex-shrink:0;
    }
    .stat-icon.blue   { background:#d8e5d6; color:#00473c; }
    .stat-icon.orange { background:rgba(230,255,85,0.25); color:#5c6a00; }
    .stat-icon.yellow { background:rgba(230,255,85,0.2); color:#5c6a00; }
    .stat-icon.green  { background:rgba(0,71,60,0.1); color:#00473c; }
    .stat-icon.red    { background:rgba(192,57,43,0.1); color:#c0392b; }
    .stat-icon.purple { background:rgba(0,71,60,0.07); color:#00473c; }
    .stat-value { font-size:1.35rem; font-weight:800; color:#0e150e; line-height:1.1; }
    .stat-label { font-size:.68rem; font-weight:700; color:#8c8c82;
                  text-transform:uppercase; letter-spacing:.4px; }

    /* ── Section card ─────────────────────────────── */
    .section-card { background:#fff; border:1px solid rgba(140,140,130,0.2); border-radius:20px; overflow:hidden; }
    .section-card-header {
        padding:1rem 1.25rem; border-bottom:1px solid rgba(140,140,130,0.15);
        display:flex; align-items:center; justify-content:space-between;
        gap:1rem; flex-wrap:wrap;
    }
    .section-card-title { font-size:.92rem; font-weight:700; color:#0e150e; margin:0; }

    /* ── Manage table ─────────────────────────────── */
    .manage-table { font-size:.84rem; margin:0; }
    .manage-table thead th {
        background:rgba(0,71,60,0.04); font-size:.68rem; font-weight:700;
        letter-spacing:.6px; text-transform:uppercase; color:#8c8c82;
        border-bottom:1px solid rgba(140,140,130,0.18); padding:.7rem 1.1rem; white-space:nowrap;
    }
    .manage-table tbody td {
        padding:.85rem 1.1rem; color:#0e150e; vertical-align:middle;
        border-bottom:1px solid rgba(140,140,130,0.12);
    }
    .manage-table tbody tr:last-child td { border-bottom:none; }
    .manage-table tbody tr:hover td { background:rgba(0,71,60,0.03); cursor:pointer; }

    /* ── User chip ────────────────────────────────── */
    .user-chip { display:flex; align-items:center; gap:.55rem; }
    .chip-avatar {
        width:32px; height:32px; border-radius:50%;
        background:#00473c;
        color:#e6ff55; font-size:.72rem; font-weight:800;
        display:flex; align-items:center; justify-content:center; flex-shrink:0;
    }
    .chip-name  { font-weight:700; color:#0e150e; font-size:.83rem; }
    .chip-sub   { font-size:.7rem; color:#8c8c82; }

    /* ── Status badges ────────────────────────────── */
    .status-badge {
        display:inline-flex; align-items:center; gap:5px;
        font-size:.7rem; font-weight:700; padding:3px 10px;
        border-radius:99px; white-space:nowrap;
    }
    .status-badge::before { content:''; width:6px; height:6px; border-radius:50%; display:inline-block; }
    .status-badge.placed       { background:rgba(0,71,60,0.08);    color:#00473c; }
    .status-badge.placed::before       { background:#00473c; }
    .status-badge.confirmed    { background:rgba(230,255,85,0.25); color:#5c6a00; }
    .status-badge.confirmed::before    { background:#a8b400; }
    .status-badge.preparing    { background:rgba(230,255,85,0.2);  color:#5c6a00; }
    .status-badge.preparing::before    { background:#c2b800; }
    .status-badge.out-delivery { background:rgba(0,71,60,0.1);     color:#00473c; }
    .status-badge.out-delivery::before { background:#00473c; }
    .status-badge.delivered    { background:rgba(0,71,60,0.12);    color:#00473c; }
    .status-badge.delivered::before    { background:#00473c; }
    .status-badge.cancelled    { background:rgba(192,57,43,0.1);   color:#c0392b; }
    .status-badge.cancelled::before    { background:#c0392b; }

    /* ── Status select inline ─────────────────────── */
    .status-select {
        font-size:.75rem; font-weight:700; border-radius:99px;
        border:1.5px solid rgba(140,140,130,0.4); padding:3px 10px;
        background:#fff; color:#0e150e; cursor:pointer;
        appearance:auto;
    }
    .status-select:focus { outline:none; border-color:#00473c; }

    /* ── Payment chip ─────────────────────────────── */
    .pay-chip {
        font-size:.68rem; font-weight:700; padding:2px 8px;
        border-radius:6px; display:inline-block;
    }
    .pay-chip.cod  { background:rgba(0,71,60,0.1); color:#00473c; }
    .pay-chip.card { background:#d8e5d6; color:#00473c; }

    /* ── Action buttons ───────────────────────────── */
    .btn-view-order {
        font-size:.75rem; font-weight:600; padding:4px 12px;
        border-radius:99px; border:1.5px solid rgba(140,140,130,0.4);
        background:transparent; color:#555; text-decoration:none;
        transition:border-color .15s, color .15s; white-space:nowrap;
        display:inline-flex; align-items:center; gap:4px; cursor:pointer;
    }
    .btn-view-order:hover { border-color:#00473c; color:#00473c; }

    /* ── Filter bar ───────────────────────────────── */
    .filter-bar { display:flex; align-items:center; gap:.6rem; flex-wrap:wrap; }
    .filter-bar .form-control,
    .filter-bar .form-select {
        font-size:.82rem; border-radius:99px; border:1.5px solid rgba(140,140,130,0.4);
        padding:.42rem 1rem; background:#fff; color:#0e150e;
    }
    .filter-bar .form-control:focus,
    .filter-bar .form-select:focus { border-color:#00473c; box-shadow:0 0 0 3px rgba(0,71,60,0.1); }
    .filter-bar .btn-search {
        font-size:.82rem; font-weight:700; padding:.42rem 1.25rem;
        border-radius:99px; background:#00473c; color:#fff; border:none; cursor:pointer;
        transition: background .15s;
    }
    .filter-bar .btn-search:hover { background:#0e150e; }
    .btn-outline-clear {
        font-size:.75rem; font-weight:600; padding:4px 12px;
        border-radius:99px; border:1.5px solid rgba(140,140,130,0.4);
        background:transparent; color:#555; text-decoration:none;
        display:inline-flex; align-items:center; gap:4px;
    }
    .btn-outline-clear:hover { border-color:#00473c; color:#00473c; }

    /* ── Status filter tabs ───────────────────────── */
    .status-tabs { display:flex; gap:.4rem; flex-wrap:wrap; margin-bottom:1rem; }
    .status-tab {
        font-size:.78rem; font-weight:700; padding:6px 16px;
        border-radius:99px; border:1.5px solid rgba(140,140,130,0.4);
        background:transparent; color:#555; text-decoration:none;
        transition:all .15s; white-space:nowrap;
    }
    .status-tab:hover { border-color:#00473c; color:#00473c; }
    .status-tab.active { background:#00473c; color:#fff; border-color:#00473c; }

    /* ── Empty state ──────────────────────────────── */
    .empty-state { text-align:center; padding:3.5rem 1rem; }
    .empty-state i { font-size:2.8rem; color:#8c8c82; display:block; margin-bottom:1rem; }
    .empty-state p { font-size:.85rem; font-weight:600; color:#8c8c82; margin:0; }

    /* ── Offcanvas detail panel ───────────────────── */
    .offcanvas { font-family:var(--font-body, 'Outfit', sans-serif); }
    .offcanvas-header { border-bottom:1px solid rgba(140,140,130,0.15); padding:1.1rem 1.4rem; }
    .offcanvas-title { font-size:1rem; font-weight:800; color:#0e150e; }
    .offcanvas-body  { padding:1.25rem 1.4rem; }

    .detail-section-title {
        font-size:.68rem; font-weight:800; letter-spacing:.8px;
        text-transform:uppercase; color:#8c8c82; margin-bottom:.6rem;
    }
    .detail-row {
        display:flex; justify-content:space-between;
        align-items:flex-start; gap:.5rem;
        padding:.45rem 0; border-bottom:1px solid rgba(140,140,130,0.12);
        font-size:.83rem;
    }
    .detail-row:last-child { border-bottom:none; }
    .detail-row .key   { color:#555; font-weight:500; }
    .detail-row .val   { font-weight:700; color:#0e150e; text-align:right; }
    .detail-row .val.orange { color:#00473c; }

    .order-item-row {
        display:flex; align-items:center; justify-content:space-between;
        gap:.75rem; padding:.6rem 0; border-bottom:1px solid rgba(140,140,130,0.12);
        font-size:.83rem;
    }
    .order-item-row:last-child { border-bottom:none; }
    .order-item-name  { font-weight:600; color:#0e150e; }
    .order-item-qty   { font-size:.75rem; color:#8c8c82; }
    .order-item-price { font-weight:700; color:#0e150e; white-space:nowrap; }

    .total-row {
        display:flex; justify-content:space-between; align-items:center;
        padding:.65rem .9rem; background:#d8e5d6;
        border-radius:10px; margin-top:.5rem;
    }
    .total-row .label { font-size:.82rem; font-weight:700; color:#00473c; }
    .total-row .amount { font-size:1.05rem; font-weight:900; color:#00473c; }

    /* Pipeline steps */
    .pipeline { display:flex; align-items:center; gap:0; margin:.75rem 0 1.25rem; overflow-x:auto; }
    .pipe-step {
        display:flex; flex-direction:column; align-items:center;
        min-width:60px; flex:1;
        position:relative;
    }
    .pipe-step:not(:last-child)::after {
        content:''; position:absolute;
        top:14px; left:50%; width:100%; height:2px;
        background:rgba(140,140,130,0.2); z-index:0;
    }
    .pipe-step.done::after { background:#00473c; }
    .pipe-dot {
        width:28px; height:28px; border-radius:50%;
        background:#fff; border:2px solid rgba(140,140,130,0.4);
        display:flex; align-items:center; justify-content:center;
        font-size:.65rem; color:#8c8c82; z-index:1;
        position:relative; transition:all .25s;
    }
    .pipe-step.done .pipe-dot  { background:#00473c; border-color:#00473c; color:#fff; }
    .pipe-step.current .pipe-dot { background:#e6ff55; border-color:#00473c; color:#00473c; box-shadow:0 0 0 4px rgba(0,71,60,0.12); }
    .pipe-label { font-size:.62rem; font-weight:600; color:#8c8c82; margin-top:.3rem; text-align:center; white-space:nowrap; }
    .pipe-step.done .pipe-label    { color:#00473c; }
    .pipe-step.current .pipe-label { color:#00473c; font-weight:700; }

    /* Update status form inside offcanvas */
    .status-update-form .form-select {
        font-size:.82rem; border-radius:99px; border:1.5px solid rgba(140,140,130,0.4);
        padding:.5rem 1rem;
    }
    .status-update-form .form-select:focus { border-color:#00473c; box-shadow:0 0 0 3px rgba(0,71,60,0.1); }
    .btn-update-status {
        font-size:.82rem; font-weight:700; padding:.5rem 1.2rem;
        border-radius:99px; background:#00473c; color:#fff; border:none;
        cursor:pointer; transition:background .15s; width:100%; margin-top:.4rem;
    }
    .btn-update-status:hover { background:#0e150e; }
</style>

<%-- ══════════════════════ PAGE HEADER ══════════════════════ --%>
<div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
    <div>
        <h1 class="fw-bold mb-1" style="font-size:1.4rem;color:#0e150e;">Order Management</h1>
        <p class="text-muted mb-0" style="font-size:.82rem;">
            Track, update and manage every order across the platform.
        </p>
    </div>
    <div class="d-flex align-items-center gap-2">
        <span class="d-flex align-items-center gap-1 px-3 py-2 rounded-pill"
              style="background:#d8e5d6;border:1px solid rgba(0,71,60,0.2);font-size:.8rem;font-weight:700;color:#00473c;">
            <i class="bi bi-currency-rupee"></i>
            Today: ₹<fmt:formatNumber value="${not empty stats.todayRevenue ? stats.todayRevenue : 0}" maxFractionDigits="0"/>
        </span>
    </div>
</div>

<%-- ══════════════════════ STAT STRIP ══════════════════════ --%>
<div class="stat-strip">
    <a href="${pageContext.request.contextPath}/manage/orders?status=PLACED"
       class="stat-tile ${filterStatus == 'PLACED' ? 'active-filter' : ''}" id="stat-placed">
        <div class="stat-icon blue"><i class="bi bi-bag-check"></i></div>
        <div>
            <div class="stat-value">${not empty stats.placedCount ? stats.placedCount : '0'}</div>
            <div class="stat-label">Placed</div>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/manage/orders?status=CONFIRMED"
       class="stat-tile ${filterStatus == 'CONFIRMED' ? 'active-filter' : ''}" id="stat-confirmed">
        <div class="stat-icon orange"><i class="bi bi-check2-circle"></i></div>
        <div>
            <div class="stat-value">${not empty stats.confirmedCount ? stats.confirmedCount : '0'}</div>
            <div class="stat-label">Confirmed</div>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/manage/orders?status=PREPARING"
       class="stat-tile ${filterStatus == 'PREPARING' ? 'active-filter' : ''}" id="stat-preparing">
        <div class="stat-icon yellow"><i class="bi bi-fire"></i></div>
        <div>
            <div class="stat-value">${not empty stats.preparingCount ? stats.preparingCount : '0'}</div>
            <div class="stat-label">Preparing</div>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/manage/orders?status=OUT_FOR_DELIVERY"
       class="stat-tile ${filterStatus == 'OUT_FOR_DELIVERY' ? 'active-filter' : ''}" id="stat-out">
        <div class="stat-icon purple"><i class="bi bi-bicycle"></i></div>
        <div>
            <div class="stat-value">${not empty stats.outForDeliveryCount ? stats.outForDeliveryCount : '0'}</div>
            <div class="stat-label">Out for Delivery</div>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/manage/orders?status=DELIVERED"
       class="stat-tile ${filterStatus == 'DELIVERED' ? 'active-filter' : ''}" id="stat-delivered">
        <div class="stat-icon green"><i class="bi bi-bag-heart-fill"></i></div>
        <div>
            <div class="stat-value">${not empty stats.deliveredCount ? stats.deliveredCount : '0'}</div>
            <div class="stat-label">Delivered</div>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/manage/orders?status=CANCELLED"
       class="stat-tile ${filterStatus == 'CANCELLED' ? 'active-filter' : ''}" id="stat-cancelled">
        <div class="stat-icon red"><i class="bi bi-x-circle"></i></div>
        <div>
            <div class="stat-value">${not empty stats.cancelledCount ? stats.cancelledCount : '0'}</div>
            <div class="stat-label">Cancelled</div>
        </div>
    </a>
</div>

<%-- ══════════════════════ ORDERS TABLE CARD ══════════════════════ --%>
<div class="section-card" id="manage-orders-card">

    <div class="section-card-header flex-column flex-lg-row align-items-start align-items-lg-center">
        <h2 class="section-card-title">
            <i class="bi bi-receipt-cutoff me-2" style="color:#f97316;"></i>
            <c:choose>
                <c:when test="${not empty filterStatus}">${filterStatus} Orders</c:when>
                <c:otherwise>All Orders</c:otherwise>
            </c:choose>
        </h2>

        <%-- Filter form --%>
        <form action="${pageContext.request.contextPath}/manage/orders"
              method="GET" class="filter-bar ms-lg-auto mt-2 mt-lg-0" id="orders-filter-form">

            <%-- Preserve status filter if set --%>
            <c:if test="${not empty filterStatus}">
                <input type="hidden" name="status" value="${filterStatus}">
            </c:if>

            <input type="text" name="q" placeholder="Order ID or customer…"
                   value="${not empty searchQuery ? searchQuery : ''}"
                   class="form-control" style="min-width:180px;max-width:220px;"
                   id="orders-search-input">

            <%-- Date range --%>
            <input type="date" name="from" value="${not empty dateFrom ? dateFrom : ''}"
                   class="form-control" style="width:auto;" id="orders-date-from">
            <input type="date" name="to"   value="${not empty dateTo   ? dateTo   : ''}"
                   class="form-control" style="width:auto;" id="orders-date-to">

            <%-- Restaurant filter (admin only) --%>
            <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                <select name="restaurantId" class="form-select" style="width:auto;" id="orders-rest-filter">
                    <option value="">All Restaurants</option>
                    <c:forEach items="${restaurants}" var="rest">
                        <option value="${rest.id}" ${filterRestId == rest.id ? 'selected' : ''}>${rest.name}</option>
                    </c:forEach>
                </select>
            </c:if>

            <button type="submit" class="btn-search" id="orders-search-btn">
                <i class="bi bi-search me-1"></i>Filter
            </button>

            <c:if test="${not empty searchQuery || not empty dateFrom || not empty dateTo || not empty filterRestId}">
                <a href="${pageContext.request.contextPath}/manage/orders${not empty filterStatus ? '?status='.concat(filterStatus) : ''}"
                   class="btn-outline-clear" id="orders-clear-btn">
                    <i class="bi bi-x"></i> Clear
                </a>
            </c:if>
        </form>
    </div>

    <%-- Status tab strip --%>
    <div class="px-3 pt-3">
        <div class="status-tabs" id="orders-status-tabs">
            <a href="${pageContext.request.contextPath}/manage/orders"
               class="status-tab ${empty filterStatus ? 'active' : ''}" id="tab-all">All</a>
            <a href="${pageContext.request.contextPath}/manage/orders?status=PLACED"
               class="status-tab ${filterStatus == 'PLACED' ? 'active' : ''}" id="tab-placed">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#3b82f6;"></i>Placed</a>
            <a href="${pageContext.request.contextPath}/manage/orders?status=CONFIRMED"
               class="status-tab ${filterStatus == 'CONFIRMED' ? 'active' : ''}" id="tab-confirmed">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#f97316;"></i>Confirmed</a>
            <a href="${pageContext.request.contextPath}/manage/orders?status=PREPARING"
               class="status-tab ${filterStatus == 'PREPARING' ? 'active' : ''}" id="tab-preparing">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#ca8a04;"></i>Preparing</a>
            <a href="${pageContext.request.contextPath}/manage/orders?status=OUT_FOR_DELIVERY"
               class="status-tab ${filterStatus == 'OUT_FOR_DELIVERY' ? 'active' : ''}" id="tab-out">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#16a34a;"></i>Out for Delivery</a>
            <a href="${pageContext.request.contextPath}/manage/orders?status=DELIVERED"
               class="status-tab ${filterStatus == 'DELIVERED' ? 'active' : ''}" id="tab-delivered">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#15803d;"></i>Delivered</a>
            <a href="${pageContext.request.contextPath}/manage/orders?status=CANCELLED"
               class="status-tab ${filterStatus == 'CANCELLED' ? 'active' : ''}" id="tab-cancelled">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#dc2626;"></i>Cancelled</a>
        </div>
    </div>

    <%-- Table --%>
    <div class="table-responsive">
        <c:choose>
            <c:when test="${empty orders}">
                <div class="empty-state" id="orders-empty-state">
                    <i class="bi bi-receipt-cutoff"></i>
                    <p>No orders found for this filter.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table manage-table" id="manage-orders-table">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Customer</th>
                            <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                <th>Restaurant</th>
                            </c:if>
                            <th>Amount</th>
                            <th>Payment</th>
                            <th>Status</th>
                            <th>Update Status</th>
                            <th>Date</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${orders}" var="order">
                            <tr id="order-row-${order.id}"
                                onclick="openOrderDetail('${order.id}')"
                                style="cursor:pointer;">

                                <%-- Order ID --%>
                                <td>
                                    <span class="fw-bold" style="color:#f97316;">#${order.id}</span>
                                </td>

                                <%-- Customer --%>
                                <td>
                                    <div class="user-chip">
                                        <div class="chip-avatar">
                                            ${not empty order.customerName ? order.customerName.substring(0,1).toUpperCase() : 'U'}
                                        </div>
                                        <div>
                                            <div class="chip-name">${order.customerName}</div>
                                            <div class="chip-sub">${order.customerPhone}</div>
                                        </div>
                                    </div>
                                </td>

                                <%-- Restaurant (admin) --%>
                                <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                    <td style="font-weight:600;">${order.restaurantName}</td>
                                </c:if>

                                <%-- Amount --%>
                                <td><span class="fw-bold">₹${order.totalAmount}</span></td>

                                <%-- Payment --%>
                                <td>
                                    <span class="pay-chip ${order.paymentMethod == 'cod' ? 'cod' : 'card'}">
                                        ${order.paymentMethod == 'cod' ? 'COD' : 'Card'}
                                    </span>
                                </td>

                                <%-- Status badge --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${order.status == 'PLACED'}">
                                            <span class="status-badge placed">Placed</span>
                                        </c:when>
                                        <c:when test="${order.status == 'CONFIRMED'}">
                                            <span class="status-badge confirmed">Confirmed</span>
                                        </c:when>
                                        <c:when test="${order.status == 'PREPARING'}">
                                            <span class="status-badge preparing">Preparing</span>
                                        </c:when>
                                        <c:when test="${order.status == 'OUT_FOR_DELIVERY'}">
                                            <span class="status-badge out-delivery">Out for Delivery</span>
                                        </c:when>
                                        <c:when test="${order.status == 'DELIVERED'}">
                                            <span class="status-badge delivered">Delivered</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge cancelled">Cancelled</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Inline status update — stops row click propagation --%>
                                <td onclick="event.stopPropagation()">
                                    <form action="${pageContext.request.contextPath}/manage/orders/updateStatus"
                                          method="POST" style="margin:0;" id="form-status-${order.id}">
                                        <input type="hidden" name="orderId" value="${order.id}">
                                        <select name="status" class="status-select"
                                                id="select-status-${order.id}"
                                                onchange="document.getElementById('form-status-${order.id}').submit()">
                                            <option value="PLACED"           ${order.status == 'PLACED'           ? 'selected' : ''}>Placed</option>
                                            <option value="CONFIRMED"        ${order.status == 'CONFIRMED'        ? 'selected' : ''}>Confirmed</option>
                                            <option value="PREPARING"        ${order.status == 'PREPARING'        ? 'selected' : ''}>Preparing</option>
                                            <option value="OUT_FOR_DELIVERY" ${order.status == 'OUT_FOR_DELIVERY' ? 'selected' : ''}>Out for Delivery</option>
                                            <option value="DELIVERED"        ${order.status == 'DELIVERED'        ? 'selected' : ''}>Delivered</option>
                                            <option value="CANCELLED"        ${order.status == 'CANCELLED'        ? 'selected' : ''}>Cancelled</option>
                                        </select>
                                    </form>
                                </td>

                                <%-- Date --%>
                                <td style="font-size:.76rem;color:#9ca3af;white-space:nowrap;">${order.orderDate}</td>

                                <%-- View detail button --%>
                                <td onclick="event.stopPropagation()">
                                    <button type="button" class="btn-view-order"
                                            id="btn-detail-${order.id}"
                                            onclick="openOrderDetail('${order.id}')">
                                        <i class="bi bi-eye"></i> View
                                    </button>
                                </td>

                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- Pagination --%>
    <c:if test="${not empty totalPages && totalPages > 1}">
        <div class="d-flex align-items-center justify-content-between px-3 py-3"
             style="border-top:1px solid #f3f4f6;">
            <span style="font-size:.78rem;color:#9ca3af;">Page ${currentPage} of ${totalPages}</span>
            <div class="d-flex gap-2">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/manage/orders?page=${currentPage-1}&status=${filterStatus}&q=${searchQuery}"
                       class="btn-outline-clear" id="orders-prev-btn">
                        <i class="bi bi-chevron-left"></i> Prev
                    </a>
                </c:if>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/manage/orders?page=${currentPage+1}&status=${filterStatus}&q=${searchQuery}"
                       class="btn-outline-clear" id="orders-next-btn">
                        Next <i class="bi bi-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </div>
    </c:if>

</div><%-- /section-card --%>


<%-- ═══════════════════════════════════════════════════════════ --%>
<%-- ORDER DETAIL — Bootstrap Offcanvas (slide-in panel)         --%>
<%-- Populated dynamically via JSTL data attributes on rows      --%>
<%-- ═══════════════════════════════════════════════════════════ --%>
<div class="offcanvas offcanvas-end" tabindex="-1"
     id="orderDetailPanel" style="width:420px;max-width:96vw;"
     aria-labelledby="orderDetailLabel">

    <div class="offcanvas-header">
        <h5 class="offcanvas-title" id="orderDetailLabel">
            <i class="bi bi-receipt-cutoff me-2" style="color:#f97316;"></i>
            Order Detail — <span id="detail-order-id" style="color:#f97316;"></span>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <div class="offcanvas-body" id="orderDetailBody">
        <div class="text-center py-5 text-muted" id="detail-loading">
            <div class="spinner-border spinner-border-sm text-warning mb-2"></div>
            <div style="font-size:.82rem;">Loading order details…</div>
        </div>

        <%-- Populated by JS using embedded JSTL data --%>
        <div id="detail-content" style="display:none;">

            <%-- Status pipeline visual --%>
            <div class="detail-section-title">Order Progress</div>
            <div class="pipeline" id="detail-pipeline">
                <div class="pipe-step" id="pipe-PLACED">
                    <div class="pipe-dot"><i class="bi bi-bag-check"></i></div>
                    <div class="pipe-label">Placed</div>
                </div>
                <div class="pipe-step" id="pipe-CONFIRMED">
                    <div class="pipe-dot"><i class="bi bi-check2-circle"></i></div>
                    <div class="pipe-label">Confirmed</div>
                </div>
                <div class="pipe-step" id="pipe-PREPARING">
                    <div class="pipe-dot"><i class="bi bi-fire"></i></div>
                    <div class="pipe-label">Preparing</div>
                </div>
                <div class="pipe-step" id="pipe-OUT_FOR_DELIVERY">
                    <div class="pipe-dot"><i class="bi bi-bicycle"></i></div>
                    <div class="pipe-label">On the Way</div>
                </div>
                <div class="pipe-step" id="pipe-DELIVERED">
                    <div class="pipe-dot"><i class="bi bi-house-check"></i></div>
                    <div class="pipe-label">Delivered</div>
                </div>
            </div>

            <hr style="border-color:#f3f4f6;margin:1rem 0;">

            <%-- Customer info --%>
            <div class="detail-section-title">Customer</div>
            <div class="mb-3">
                <div class="detail-row">
                    <span class="key">Name</span>
                    <span class="val" id="detail-cust-name"></span>
                </div>
                <div class="detail-row">
                    <span class="key">Phone</span>
                    <span class="val" id="detail-cust-phone"></span>
                </div>
                <div class="detail-row">
                    <span class="key">Payment</span>
                    <span class="val" id="detail-payment"></span>
                </div>
                <div class="detail-row">
                    <span class="key">Date</span>
                    <span class="val" id="detail-date"></span>
                </div>
            </div>

            <%-- Delivery address --%>
            <div class="detail-section-title">Delivery Address</div>
            <div class="mb-3 p-3 rounded-3" style="background:#f9fafb;border:1px solid #f3f4f6;font-size:.83rem;">
                <div class="fw-semibold text-dark" id="detail-address"></div>
                <div class="text-muted mt-1" id="detail-city-postal"></div>
            </div>

            <%-- Items ordered --%>
            <div class="detail-section-title">Items Ordered</div>
            <div id="detail-items-list" class="mb-2"></div>

            <%-- Total --%>
            <div class="total-row">
                <span class="label"><i class="bi bi-receipt me-1"></i>Order Total</span>
                <span class="amount" id="detail-total"></span>
            </div>

            <hr style="border-color:#f3f4f6;margin:1rem 0;">

            <%-- Update status from detail panel --%>
            <div class="detail-section-title">Update Order Status</div>
            <form action="${pageContext.request.contextPath}/manage/orders/updateStatus"
                  method="POST" class="status-update-form" id="detail-status-form">
                <input type="hidden" name="orderId" id="detail-status-order-id">
                <select name="status" class="form-select mb-2" id="detail-status-select">
                    <option value="PLACED">Placed</option>
                    <option value="CONFIRMED">Confirmed</option>
                    <option value="PREPARING">Preparing</option>
                    <option value="OUT_FOR_DELIVERY">Out for Delivery</option>
                    <option value="DELIVERED">Delivered</option>
                    <option value="CANCELLED">Cancelled</option>
                </select>
                <button type="submit" class="btn-update-status" id="detail-update-btn">
                    <i class="bi bi-arrow-repeat me-1"></i>Update Status
                </button>
            </form>

        </div>
    </div>
</div>

<%-- Embedded JSON-like data for all orders (read by JS) --%>
<script id="orders-data" type="application/json">
[
  <c:forEach items="${orders}" var="order" varStatus="loop">
  {
    "id":           "${order.id}",
    "customerName": "${order.customerName}",
    "customerPhone":"${order.customerPhone}",
    "paymentMethod":"${order.paymentMethod}",
    "status":       "${order.status}",
    "orderDate":    "${order.orderDate}",
    "totalAmount":  "${order.totalAmount}",
    "address":      "${order.deliveryAddress}",
    "city":         "${order.city}",
    "postalCode":   "${order.postalCode}",
    "items": [
      <c:forEach items="${order.items}" var="item" varStatus="iLoop">
      { "name":"${item.name}", "quantity":${item.quantity}, "price":"${item.price}" }${!iLoop.last ? ',' : ''}
      </c:forEach>
    ]
  }${!loop.last ? ',' : ''}
  </c:forEach>
]
</script>

<%-- ══════════════════════ PAGE SCRIPTS ══════════════════════ --%>
<script>
(function () {
    /* Parse embedded order data */
    var ordersData = [];
    try {
        ordersData = JSON.parse(document.getElementById('orders-data').textContent);
    } catch(e) {}

    var statusOrder = ['PLACED','CONFIRMED','PREPARING','OUT_FOR_DELIVERY','DELIVERED'];

    window.openOrderDetail = function (orderId) {
        var order = ordersData.find(function(o) { return o.id === String(orderId); });
        if (!order) return;

        /* Show offcanvas */
        var panel = new bootstrap.Offcanvas(document.getElementById('orderDetailPanel'));
        panel.show();

        /* Hide loading, show content */
        document.getElementById('detail-loading').style.display  = 'none';
        document.getElementById('detail-content').style.display  = 'block';

        /* Populate header */
        document.getElementById('detail-order-id').textContent  = '#' + order.id;

        /* Pipeline */
        statusOrder.forEach(function(step) {
            var el = document.getElementById('pipe-' + step);
            if (!el) return;
            el.classList.remove('done','current');
            var stepIdx    = statusOrder.indexOf(step);
            var currentIdx = statusOrder.indexOf(order.status);
            if (order.status === 'CANCELLED') {
                /* Grey out all */
            } else if (stepIdx < currentIdx) {
                el.classList.add('done');
            } else if (stepIdx === currentIdx) {
                el.classList.add('current');
            }
        });

        /* Customer info */
        document.getElementById('detail-cust-name').textContent  = order.customerName  || '—';
        document.getElementById('detail-cust-phone').textContent = order.customerPhone || '—';
        document.getElementById('detail-payment').textContent    = order.paymentMethod === 'cod' ? 'Cash on Delivery' : 'Card';
        document.getElementById('detail-date').textContent       = order.orderDate || '—';

        /* Address */
        document.getElementById('detail-address').textContent     = order.address  || '—';
        document.getElementById('detail-city-postal').textContent = (order.city || '') + (order.postalCode ? ' — ' + order.postalCode : '');

        /* Items */
        var itemsHtml = '';
        (order.items || []).forEach(function(item) {
            itemsHtml +=
                '<div class="order-item-row">' +
                '<div><div class="order-item-name">' + item.name + '</div>' +
                '<div class="order-item-qty">Qty: ' + item.quantity + '</div></div>' +
                '<div class="order-item-price">₹' + item.price + '</div>' +
                '</div>';
        });
        document.getElementById('detail-items-list').innerHTML = itemsHtml || '<p style="font-size:.8rem;color:#9ca3af;">No items.</p>';

        /* Total */
        document.getElementById('detail-total').textContent = '₹' + order.totalAmount;

        /* Status update form */
        document.getElementById('detail-status-order-id').value  = order.id;
        document.getElementById('detail-status-select').value    = order.status;
    };
})();
</script>

<jsp:include page="manage-sidebar-close.jsp"/>
