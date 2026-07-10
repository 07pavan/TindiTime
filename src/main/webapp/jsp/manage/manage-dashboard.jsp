<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 1: DASHBOARD
    MVC: populated by AdminDashboardServlet which sets:
      requestScope.stats          — Map with keys: totalOrders, todayOrders, totalRevenue,
                                    todayRevenue, activeRestaurants, pendingApprovals,
                                    totalCustomers, activeOrders
      requestScope.recentOrders   — List<Order> latest 10 orders (all fields)
      sessionScope.userRole       — 'SUPER_ADMIN' | 'RESTAURANT_OWNER'
      sessionScope.userName       — Display name
--%>
<c:set var="pageTitle"  value="Dashboard"  scope="request" />
<c:set var="activeNav"  value="dashboard"  scope="request" />

<jsp:include page="manage-sidebar.jsp" />

<%-- ══════════════════════════════════════════ --%>
<%-- PAGE STYLES (scoped to this module)        --%>
<%-- ══════════════════════════════════════════ --%>
<style>
    /* ── KPI Cards ──────────────────────────────── */
    .kpi-card {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        padding: 1.4rem 1.5rem;
        display: flex;
        align-items: center;
        gap: 1.1rem;
        transition: box-shadow .2s, transform .2s;
    }
    .kpi-card:hover { box-shadow: 0 6px 24px rgba(0,0,0,.08); transform: translateY(-2px); }
    .kpi-icon {
        width: 52px; height: 52px;
        border-radius: 13px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.4rem;
        flex-shrink: 0;
    }
    .kpi-icon.orange { background: #fff7ed; color: #f97316; }
    .kpi-icon.green  { background: #f0fdf4; color: #22c55e; }
    .kpi-icon.blue   { background: #eff6ff; color: #3b82f6; }
    .kpi-icon.purple { background: #faf5ff; color: #a855f7; }
    .kpi-icon.red    { background: #fef2f2; color: #ef4444; }
    .kpi-icon.teal   { background: #f0fdfa; color: #14b8a6; }

    .kpi-body {}
    .kpi-label { font-size: .75rem; font-weight: 600; color: #6b7280; letter-spacing: .3px; text-transform: uppercase; }
    .kpi-value { font-size: 1.7rem; font-weight: 800; color: #111827; line-height: 1.1; }
    .kpi-sub   { font-size: .72rem; color: #9ca3af; margin-top: .15rem; }
    .kpi-trend { font-size: .72rem; font-weight: 700; padding: 2px 7px; border-radius: 99px; }
    .kpi-trend.up   { background: #f0fdf4; color: #16a34a; }
    .kpi-trend.down { background: #fef2f2; color: #dc2626; }
    .kpi-trend.neutral { background: #f9fafb; color: #6b7280; }

    /* ── Section Card ───────────────────────────── */
    .section-card {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        overflow: hidden;
    }
    .section-card-header {
        padding: 1.1rem 1.5rem;
        border-bottom: 1px solid #f3f4f6;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1rem;
    }
    .section-card-title { font-size: .95rem; font-weight: 700; color: #111827; margin: 0; }
    .section-card-body  { padding: 0; }

    /* ── Orders Table ───────────────────────────── */
    .manage-table { font-size: .85rem; margin: 0; }
    .manage-table thead th {
        background: #f9fafb;
        font-size: .7rem;
        font-weight: 700;
        letter-spacing: .6px;
        text-transform: uppercase;
        color: #9ca3af;
        border-bottom: 1px solid #f3f4f6;
        padding: .75rem 1.25rem;
        white-space: nowrap;
    }
    .manage-table tbody td {
        padding: .85rem 1.25rem;
        color: #374151;
        vertical-align: middle;
        border-bottom: 1px solid #f9fafb;
    }
    .manage-table tbody tr:last-child td { border-bottom: none; }
    .manage-table tbody tr:hover td { background: #fafafa; }

    /* Status badges */
    .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-size: .72rem;
        font-weight: 700;
        padding: 3px 10px;
        border-radius: 99px;
        white-space: nowrap;
    }
    .status-badge::before {
        content: '';
        width: 6px; height: 6px;
        border-radius: 50%;
        display: inline-block;
    }
    .status-badge.placed     { background: #eff6ff; color: #3b82f6; }
    .status-badge.placed::before     { background: #3b82f6; }
    .status-badge.confirmed  { background: #fff7ed; color: #f97316; }
    .status-badge.confirmed::before  { background: #f97316; }
    .status-badge.preparing  { background: #fefce8; color: #ca8a04; }
    .status-badge.preparing::before  { background: #ca8a04; }
    .status-badge.out-delivery { background: #f0fdf4; color: #16a34a; }
    .status-badge.out-delivery::before { background: #16a34a; }
    .status-badge.delivered  { background: #f0fdf4; color: #15803d; }
    .status-badge.delivered::before  { background: #15803d; }
    .status-badge.cancelled  { background: #fef2f2; color: #dc2626; }
    .status-badge.cancelled::before  { background: #dc2626; }

    /* Avatar chip */
    .user-chip { display: flex; align-items: center; gap: .5rem; }
    .chip-avatar {
        width: 30px; height: 30px;
        border-radius: 50%;
        background: linear-gradient(135deg, #f97316, #ea580c);
        color: #fff;
        font-size: .7rem;
        font-weight: 700;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .chip-name  { font-weight: 600; color: #111827; font-size: .82rem; }
    .chip-email { font-size: .72rem; color: #9ca3af; }

    /* Quick action button */
    .btn-action {
        font-size: .75rem;
        font-weight: 600;
        padding: 4px 10px;
        border-radius: 7px;
        border: 1px solid #e5e7eb;
        background: #fff;
        color: #374151;
        text-decoration: none;
        transition: border-color .15s, color .15s;
        white-space: nowrap;
    }
    .btn-action:hover { border-color: #f97316; color: #f97316; }

    /* ── Activity Feed ──────────────────────────── */
    .activity-item {
        display: flex;
        align-items: flex-start;
        gap: .85rem;
        padding: .85rem 1.25rem;
        border-bottom: 1px solid #f9fafb;
    }
    .activity-item:last-child { border-bottom: none; }
    .activity-icon {
        width: 34px; height: 34px;
        border-radius: 9px;
        display: flex; align-items: center; justify-content: center;
        font-size: .9rem;
        flex-shrink: 0;
        margin-top: .1rem;
    }
    .activity-body .activity-text { font-size: .82rem; color: #374151; font-weight: 500; }
    .activity-body .activity-time { font-size: .72rem; color: #9ca3af; margin-top: .15rem; }
</style>

<%-- ══════════════════════════════════════════ --%>
<%-- PAGE HEADER                                --%>
<%-- ══════════════════════════════════════════ --%>
<div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-3">
    <div>
        <h1 class="fw-bold mb-0" style="font-size:1.5rem;color:#111827;">
            Good day, ${not empty sessionScope.userName ? sessionScope.userName : 'Admin'} 👋
        </h1>
        <p class="text-muted mb-0" style="font-size:.85rem;">
            Here is what is happening with HungryGO today.
        </p>
    </div>
    <a href="${pageContext.request.contextPath}/manage/orders"
       class="btn btn-sm fw-semibold text-white d-flex align-items-center gap-2"
       style="background:#f97316;border:none;border-radius:10px;padding:.5rem 1.1rem;font-size:.83rem;"
       id="dash-view-orders-btn">
        <i class="bi bi-receipt-cutoff"></i> View All Orders
    </a>
</div>

<%-- ══════════════════════════════════════════ --%>
<%-- KPI CARDS GRID                             --%>
<%-- ══════════════════════════════════════════ --%>
<div class="row g-3 mb-4">

    <%-- Total Orders --%>
    <div class="col-6 col-md-4 col-xl-2">
        <div class="kpi-card">
            <div class="kpi-icon orange"><i class="bi bi-bag-check-fill"></i></div>
            <div class="kpi-body">
                <div class="kpi-label">Total Orders</div>
                <div class="kpi-value">${not empty stats.totalOrders ? stats.totalOrders : '—'}</div>
                <div class="kpi-sub">All time</div>
            </div>
        </div>
    </div>

    <%-- Today Orders --%>
    <div class="col-6 col-md-4 col-xl-2">
        <div class="kpi-card">
            <div class="kpi-icon green"><i class="bi bi-lightning-charge-fill"></i></div>
            <div class="kpi-body">
                <div class="kpi-label">Today Orders</div>
                <div class="kpi-value">${not empty stats.todayOrders ? stats.todayOrders : '0'}</div>
                <div class="kpi-sub"><span class="kpi-trend up"><i class="bi bi-arrow-up-short"></i>Live</span></div>
            </div>
        </div>
    </div>

    <%-- Total Revenue — Admin only --%>
    <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
        <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card">
                <div class="kpi-icon blue"><i class="bi bi-currency-rupee"></i></div>
                <div class="kpi-body">
                    <div class="kpi-label">Total Revenue</div>
                    <div class="kpi-value">
                        ₹<fmt:formatNumber value="${not empty stats.totalRevenue ? stats.totalRevenue : 0}" maxFractionDigits="0"/>
                    </div>
                    <div class="kpi-sub">Platform GMV</div>
                </div>
            </div>
        </div>

        <%-- Active Restaurants --%>
        <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card">
                <div class="kpi-icon purple"><i class="bi bi-shop-window"></i></div>
                <div class="kpi-body">
                    <div class="kpi-label">Restaurants</div>
                    <div class="kpi-value">${not empty stats.activeRestaurants ? stats.activeRestaurants : '—'}</div>
                    <div class="kpi-sub">Active partners</div>
                </div>
            </div>
        </div>

        <%-- Pending Approvals --%>
        <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card">
                <div class="kpi-icon red"><i class="bi bi-hourglass-split"></i></div>
                <div class="kpi-body">
                    <div class="kpi-label">Pending</div>
                    <div class="kpi-value">${not empty stats.pendingApprovals ? stats.pendingApprovals : '0'}</div>
                    <div class="kpi-sub">Needs review</div>
                </div>
            </div>
        </div>

        <%-- Total Customers --%>
        <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card">
                <div class="kpi-icon teal"><i class="bi bi-people-fill"></i></div>
                <div class="kpi-body">
                    <div class="kpi-label">Customers</div>
                    <div class="kpi-value">${not empty stats.totalCustomers ? stats.totalCustomers : '—'}</div>
                    <div class="kpi-sub">Registered</div>
                </div>
            </div>
        </div>
    </c:if>

    <%-- Restaurant-owner only KPIs --%>
    <c:if test="${sessionScope.userRole == 'RESTAURANT_OWNER'}">
        <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card">
                <div class="kpi-icon blue"><i class="bi bi-currency-rupee"></i></div>
                <div class="kpi-body">
                    <div class="kpi-label">My Revenue</div>
                    <div class="kpi-value">
                        ₹<fmt:formatNumber value="${not empty stats.myRevenue ? stats.myRevenue : 0}" maxFractionDigits="0"/>
                    </div>
                    <div class="kpi-sub">Today earnings</div>
                </div>
            </div>
        </div>

        <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card">
                <div class="kpi-icon purple"><i class="bi bi-star-fill"></i></div>
                <div class="kpi-body">
                    <div class="kpi-label">Avg Rating</div>
                    <div class="kpi-value">${not empty stats.avgRating ? stats.avgRating : '—'}</div>
                    <div class="kpi-sub">Customer score</div>
                </div>
            </div>
        </div>

        <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card">
                <div class="kpi-icon red"><i class="bi bi-exclamation-circle-fill"></i></div>
                <div class="kpi-body">
                    <div class="kpi-label">Active Orders</div>
                    <div class="kpi-value">${not empty stats.activeOrders ? stats.activeOrders : '0'}</div>
                    <div class="kpi-sub">Needs prep now</div>
                </div>
            </div>
        </div>
    </c:if>

</div>

<%-- ══════════════════════════════════════════════════════════════ --%>
<%-- MAIN TWO-COLUMN SECTION: Recent Orders + Activity Feed        --%>
<%-- ══════════════════════════════════════════════════════════════ --%>
<div class="row g-3">

    <%-- RECENT ORDERS TABLE — spans 8 columns on lg+ --%>
    <div class="col-12 col-xl-8">
        <div class="section-card h-100">
            <div class="section-card-header">
                <h2 class="section-card-title"><i class="bi bi-receipt-cutoff text-warning me-2"></i>Recent Orders</h2>
                <a href="${pageContext.request.contextPath}/manage/orders" class="btn-action" id="dash-all-orders-link">
                    View all <i class="bi bi-arrow-right ms-1"></i>
                </a>
            </div>
            <div class="section-card-body">
                <c:choose>
                    <c:when test="${empty recentOrders}">
                        <%-- Empty state --%>
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-inbox fs-1 d-block mb-3" style="color:#e5e7eb;"></i>
                            <p class="mb-0 fw-semibold" style="font-size:.85rem;">No orders placed yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table manage-table" id="dash-recent-orders-table">
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
                                        <th>Date</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${recentOrders}" var="order">
                                        <tr id="order-row-${order.id}">
                                            <td>
                                                <span class="fw-bold" style="color:#f97316;">#${order.id}</span>
                                            </td>
                                            <td>
                                                <div class="user-chip">
                                                    <div class="chip-avatar">
                                                        ${not empty order.customerName ? order.customerName.substring(0,1).toUpperCase() : 'U'}
                                                    </div>
                                                    <div>
                                                        <div class="chip-name">${order.customerName}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                                <td style="font-weight:600;">${order.restaurantName}</td>
                                            </c:if>
                                            <td class="fw-bold">₹${order.totalAmount}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${order.paymentMethod == 'cod'}">
                                                        <span class="badge rounded-pill" style="background:#f0fdf4;color:#16a34a;font-size:.68rem;">COD</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge rounded-pill" style="background:#eff6ff;color:#3b82f6;font-size:.68rem;">Card</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
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
                                            <td style="font-size:.77rem;color:#9ca3af;white-space:nowrap;">${order.orderDate}</td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/manage/orders?id=${order.id}"
                                                   class="btn-action" id="dash-order-view-${order.id}">
                                                    View
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%-- ACTIVITY FEED — spans 4 columns on lg+ --%>
    <div class="col-12 col-xl-4">
        <div class="section-card h-100">
            <div class="section-card-header">
                <h2 class="section-card-title"><i class="bi bi-activity text-danger me-2"></i>Activity Feed</h2>
            </div>
            <div class="section-card-body">

                <%-- If no activity list passed, show sensible placeholders --%>
                <c:choose>
                    <c:when test="${empty activityFeed}">
                        <%-- Static placeholder items --%>
                        <div class="activity-item">
                            <div class="activity-icon orange" style="background:#fff7ed;color:#f97316;">
                                <i class="bi bi-bag-check"></i>
                            </div>
                            <div class="activity-body">
                                <div class="activity-text">New order placed by a customer</div>
                                <div class="activity-time">Just now</div>
                            </div>
                        </div>
                        <div class="activity-item">
                            <div class="activity-icon green" style="background:#f0fdf4;color:#22c55e;">
                                <i class="bi bi-shop"></i>
                            </div>
                            <div class="activity-body">
                                <div class="activity-text">Restaurant application pending review</div>
                                <div class="activity-time">2 minutes ago</div>
                            </div>
                        </div>
                        <div class="activity-item">
                            <div class="activity-icon blue" style="background:#eff6ff;color:#3b82f6;">
                                <i class="bi bi-person-plus"></i>
                            </div>
                            <div class="activity-body">
                                <div class="activity-text">New customer registered</div>
                                <div class="activity-time">15 minutes ago</div>
                            </div>
                        </div>
                        <div class="activity-item">
                            <div class="activity-icon" style="background:#faf5ff;color:#a855f7;">
                                <i class="bi bi-tag"></i>
                            </div>
                            <div class="activity-body">
                                <div class="activity-text">Promo code FREESHIP created</div>
                                <div class="activity-time">1 hour ago</div>
                            </div>
                        </div>
                        <div class="activity-item">
                            <div class="activity-icon" style="background:#fef2f2;color:#ef4444;">
                                <i class="bi bi-x-circle"></i>
                            </div>
                            <div class="activity-body">
                                <div class="activity-text">Order #2034 cancelled by customer</div>
                                <div class="activity-time">3 hours ago</div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${activityFeed}" var="activity">
                            <div class="activity-item">
                                <div class="activity-icon ${activity.iconClass}" style="background:${activity.bgColor};color:${activity.iconColor};">
                                    <i class="bi ${activity.icon}"></i>
                                </div>
                                <div class="activity-body">
                                    <div class="activity-text">${activity.message}</div>
                                    <div class="activity-time">${activity.timeAgo}</div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>

            </div>
        </div>
    </div>

</div><%-- /row --%>

<%-- Pending Approvals Quick Banner — Admin only --%>
<c:if test="${sessionScope.userRole == 'SUPER_ADMIN' && not empty stats.pendingApprovals && stats.pendingApprovals > 0}">
    <div class="mt-3 p-3 rounded-3 d-flex align-items-center justify-content-between flex-wrap gap-3"
         style="background:#fff7ed;border:1px solid #fed7aa;" id="dash-pending-alert-banner">
        <div class="d-flex align-items-center gap-2">
            <i class="bi bi-exclamation-circle-fill text-warning fs-5"></i>
            <span style="font-size:.85rem;font-weight:600;color:#92400e;">
                You have <strong>${stats.pendingApprovals}</strong> restaurant(s) waiting for approval.
            </span>
        </div>
        <a href="${pageContext.request.contextPath}/manage/restaurants?filter=pending"
           class="btn btn-sm fw-semibold text-white"
           style="background:#f97316;border:none;border-radius:8px;font-size:.8rem;"
           id="dash-review-approvals-btn">
            Review Now <i class="bi bi-arrow-right ms-1"></i>
        </a>
    </div>
</c:if>

<jsp:include page="manage-sidebar-close.jsp" />
