<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 2 : RESTAURANT MANAGEMENT  (SUPER_ADMIN only)
    MVC: populated by AdminRestaurantServlet which sets:
      requestScope.pendingRestaurants  — List<Restaurant>  status = PENDING_APPROVAL
      requestScope.allRestaurants      — List<Restaurant>  status = ACTIVE | SUSPENDED
      requestScope.filterStatus        — String            current filter value (from ?filter= param)
      requestScope.searchQuery         — String            current search value (from ?q= param)
    Each Restaurant object has:
      id, name, ownerName, ownerEmail, city, cuisineType,
      status (PENDING_APPROVAL | ACTIVE | SUSPENDED),
      registeredDate, totalOrders, totalRevenue, rating
--%>
<c:set var="pageTitle" value="Restaurant Management" scope="request"/>
<c:set var="activeNav"  value="restaurants"           scope="request"/>

<jsp:include page="manage-sidebar.jsp"/>

<%-- ══════════════════════ PAGE-SCOPED STYLES ══════════════════════ --%>
<style>
    /* ── Page header ─────────────────────────────────── */
    .page-section-title {
        font-size: 1rem; font-weight: 700; color: #111827; margin: 0;
    }
    .page-section-sub {
        font-size: .78rem; color: #9ca3af; margin-top: .15rem;
    }

    /* ── Approval banner ──────────────────────────────── */
    .approval-banner {
        background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
        border: 1px solid #fed7aa;
        border-radius: 14px;
        padding: 1.25rem 1.5rem;
    }
    .approval-banner-icon {
        width: 44px; height: 44px;
        background: #f97316;
        border-radius: 11px;
        display: flex; align-items: center; justify-content: center;
        color: #fff; font-size: 1.2rem;
        flex-shrink: 0;
    }

    /* ── Section card (re-use from dashboard) ─────────── */
    .section-card {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        overflow: hidden;
    }
    .section-card-header {
        padding: 1rem 1.25rem;
        border-bottom: 1px solid #f3f4f6;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1rem;
        flex-wrap: wrap;
    }
    .section-card-title { font-size: .92rem; font-weight: 700; color: #111827; margin: 0; }

    /* ── Manage table ─────────────────────────────────── */
    .manage-table { font-size: .84rem; margin: 0; }
    .manage-table thead th {
        background: #f9fafb;
        font-size: .68rem; font-weight: 700;
        letter-spacing: .6px; text-transform: uppercase;
        color: #9ca3af;
        border-bottom: 1px solid #f3f4f6;
        padding: .7rem 1.1rem;
        white-space: nowrap;
    }
    .manage-table tbody td {
        padding: .9rem 1.1rem;
        color: #374151;
        vertical-align: middle;
        border-bottom: 1px solid #f9fafb;
    }
    .manage-table tbody tr:last-child td { border-bottom: none; }
    .manage-table tbody tr:hover td { background: #fafafa; }

    /* ── Restaurant avatar ────────────────────────────── */
    .rest-chip { display: flex; align-items: center; gap: .65rem; }
    .rest-avatar {
        width: 38px; height: 38px;
        border-radius: 10px;
        background: linear-gradient(135deg, #f97316, #ea580c);
        color: #fff;
        font-size: .82rem; font-weight: 800;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .rest-name  { font-weight: 700; color: #111827; font-size: .85rem; }
    .rest-city  { font-size: .72rem; color: #9ca3af; }

    /* ── Status badges ────────────────────────────────── */
    .status-badge {
        display: inline-flex; align-items: center; gap: 5px;
        font-size: .7rem; font-weight: 700;
        padding: 3px 10px; border-radius: 99px; white-space: nowrap;
    }
    .status-badge::before {
        content:''; width: 6px; height: 6px;
        border-radius: 50%; display: inline-block;
    }
    .status-badge.active   { background:#f0fdf4; color:#15803d; }
    .status-badge.active::before   { background:#22c55e; }
    .status-badge.pending  { background:#fff7ed; color:#c2410c; }
    .status-badge.pending::before  { background:#f97316; }
    .status-badge.suspended{ background:#fef2f2; color:#dc2626; }
    .status-badge.suspended::before{ background:#ef4444; }

    /* ── Star rating ──────────────────────────────────── */
    .star-rating { color: #fbbf24; font-size: .8rem; }
    .star-rating span { color: #374151; font-size: .78rem; font-weight: 600; margin-left: 3px; }

    /* ── Action buttons ───────────────────────────────── */
    .btn-approve {
        font-size: .75rem; font-weight: 700;
        padding: 5px 12px; border-radius: 8px; border: none;
        background: #22c55e; color: #fff;
        cursor: pointer; transition: background .15s;
        text-decoration: none; display: inline-flex; align-items: center; gap: 4px;
    }
    .btn-approve:hover { background: #16a34a; color: #fff; }

    .btn-reject {
        font-size: .75rem; font-weight: 700;
        padding: 5px 12px; border-radius: 8px;
        border: 1px solid #fca5a5;
        background: #fef2f2; color: #dc2626;
        cursor: pointer; transition: background .15s, border-color .15s;
        text-decoration: none; display: inline-flex; align-items: center; gap: 4px;
    }
    .btn-reject:hover { background: #fee2e2; border-color: #ef4444; }

    .btn-action {
        font-size: .75rem; font-weight: 600;
        padding: 4px 10px; border-radius: 7px;
        border: 1px solid #e5e7eb;
        background: #fff; color: #374151;
        text-decoration: none; transition: border-color .15s, color .15s;
        display: inline-flex; align-items: center; gap: 4px;
        white-space: nowrap;
    }
    .btn-action:hover { border-color: #f97316; color: #f97316; }

    .btn-suspend {
        font-size: .75rem; font-weight: 600;
        padding: 4px 10px; border-radius: 7px;
        border: 1px solid #fca5a5;
        background: #fef2f2; color: #dc2626;
        text-decoration: none; transition: background .15s;
        display: inline-flex; align-items: center; gap: 4px;
        white-space: nowrap;
    }
    .btn-suspend:hover { background: #fee2e2; }

    .btn-activate {
        font-size: .75rem; font-weight: 600;
        padding: 4px 10px; border-radius: 7px;
        border: 1px solid #86efac;
        background: #f0fdf4; color: #16a34a;
        text-decoration: none; transition: background .15s;
        display: inline-flex; align-items: center; gap: 4px;
        white-space: nowrap;
    }
    .btn-activate:hover { background: #dcfce7; }

    /* ── Search & filter bar ──────────────────────────── */
    .filter-bar {
        display: flex; align-items: center;
        gap: .6rem; flex-wrap: wrap;
    }
    .filter-bar .form-control,
    .filter-bar .form-select {
        font-size: .82rem; border-radius: 9px;
        border: 1px solid #e5e7eb;
        padding: .42rem .85rem;
        background: #f9fafb;
    }
    .filter-bar .form-control:focus,
    .filter-bar .form-select:focus {
        border-color: #f97316;
        box-shadow: 0 0 0 3px rgba(249,115,22,.08);
    }
    .filter-bar .btn-search {
        font-size: .82rem; font-weight: 600;
        padding: .42rem 1rem; border-radius: 9px;
        background: #f97316; color: #fff; border: none;
        cursor: pointer; transition: background .15s;
    }
    .filter-bar .btn-search:hover { background: #ea580c; }

    /* ── Filter tabs ──────────────────────────────────── */
    .filter-tabs { display: flex; gap: .4rem; flex-wrap: wrap; }
    .filter-tab {
        font-size: .78rem; font-weight: 600;
        padding: 5px 14px; border-radius: 99px;
        border: 1px solid #e5e7eb;
        background: #fff; color: #6b7280;
        text-decoration: none; transition: all .15s;
        white-space: nowrap;
    }
    .filter-tab:hover { border-color: #f97316; color: #f97316; }
    .filter-tab.active {
        background: #f97316; color: #fff;
        border-color: #f97316;
    }

    /* ── Empty state ──────────────────────────────────── */
    .empty-state {
        text-align: center; padding: 3rem 1rem;
    }
    .empty-state i { font-size: 2.8rem; color: #e5e7eb; display: block; margin-bottom: 1rem; }
    .empty-state p { font-size: .85rem; font-weight: 600; color: #9ca3af; margin: 0; }

    /* ── Cuisine chip ─────────────────────────────────── */
    .cuisine-chip {
        display: inline-block;
        font-size: .68rem; font-weight: 600;
        padding: 2px 8px; border-radius: 6px;
        background: #f3f4f6; color: #374151;
    }
</style>

<%-- ══════════════════════ PAGE HEADER ══════════════════════ --%>
<div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
    <div>
        <h1 class="page-section-title">Restaurant Management</h1>
        <p class="page-section-sub">Approve new restaurant partners and manage existing merchants.</p>
    </div>
    <%-- Quick stats pill --%>
    <div class="d-flex gap-2 align-items-center flex-wrap">
        <span class="d-flex align-items-center gap-1 px-3 py-1 rounded-pill"
              style="background:#f0fdf4;border:1px solid #86efac;font-size:.75rem;font-weight:700;color:#15803d;">
            <i class="bi bi-circle-fill" style="font-size:.45rem;"></i>
            ${not empty allRestaurants ? allRestaurants.size() : '0'} Active
        </span>
        <c:if test="${not empty pendingRestaurants && pendingRestaurants.size() > 0}">
            <span class="d-flex align-items-center gap-1 px-3 py-1 rounded-pill"
                  style="background:#fff7ed;border:1px solid #fed7aa;font-size:.75rem;font-weight:700;color:#c2410c;">
                <i class="bi bi-exclamation-circle-fill" style="font-size:.75rem;"></i>
                ${pendingRestaurants.size()} Pending
            </span>
        </c:if>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════ --%>
<%-- SECTION 1 : PENDING APPROVAL QUEUE                         --%>
<%-- ══════════════════════════════════════════════════════════ --%>
<c:choose>
    <c:when test="${not empty pendingRestaurants}">

        <%-- Alert banner --%>
        <div class="approval-banner d-flex align-items-center gap-3 mb-4" id="manage-pending-banner">
            <div class="approval-banner-icon"><i class="bi bi-hourglass-split"></i></div>
            <div>
                <div style="font-size:.9rem;font-weight:700;color:#92400e;">
                    ${pendingRestaurants.size()} restaurant(s) waiting for your approval
                </div>
                <div style="font-size:.76rem;color:#b45309;">
                    Review each application below before they go live on the storefront.
                </div>
            </div>
        </div>

        <div class="section-card mb-4" id="manage-pending-card">
            <div class="section-card-header">
                <h2 class="section-card-title">
                    <i class="bi bi-hourglass-split text-warning me-2"></i>Pending Approval Queue
                </h2>
                <span style="font-size:.75rem;color:#9ca3af;font-weight:600;">
                    ${pendingRestaurants.size()} application(s)
                </span>
            </div>
            <div class="table-responsive">
                <table class="table manage-table" id="manage-pending-table">
                    <thead>
                        <tr>
                            <th>Restaurant</th>
                            <th>Owner</th>
                            <th>City</th>
                            <th>Cuisine</th>
                            <th>Applied On</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pendingRestaurants}" var="rest">
                            <tr id="pending-row-${rest.id}">
                                <td>
                                    <div class="rest-chip">
                                        <div class="rest-avatar">
                                            ${not empty rest.name ? rest.name.substring(0,1).toUpperCase() : 'R'}
                                        </div>
                                        <div>
                                            <div class="rest-name">${rest.name}</div>
                                            <div class="rest-city"><i class="bi bi-geo-alt-fill me-1"></i>${rest.city}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div style="font-weight:600;font-size:.83rem;color:#111827;">${rest.ownerName}</div>
                                    <div style="font-size:.72rem;color:#9ca3af;">${rest.ownerEmail}</div>
                                </td>
                                <td>${rest.city}</td>
                                <td><span class="cuisine-chip">${rest.cuisineType}</span></td>
                                <td style="font-size:.77rem;color:#9ca3af;white-space:nowrap;">${rest.registeredDate}</td>
                                <td>
                                    <div class="d-flex gap-2 align-items-center">
                                        <%-- Approve — POST to AdminRestaurantServlet --%>
                                        <form action="${pageContext.request.contextPath}/manage/restaurants/approve"
                                              method="POST" style="margin:0;" id="form-approve-${rest.id}">
                                            <input type="hidden" name="restaurantId" value="${rest.id}">
                                            <button type="submit" class="btn-approve" id="btn-approve-${rest.id}">
                                                <i class="bi bi-check-circle-fill"></i> Approve
                                            </button>
                                        </form>
                                        <%-- Reject — POST to AdminRestaurantServlet --%>
                                        <form action="${pageContext.request.contextPath}/manage/restaurants/reject"
                                              method="POST" style="margin:0;" id="form-reject-${rest.id}">
                                            <input type="hidden" name="restaurantId" value="${rest.id}">
                                            <button type="submit" class="btn-reject" id="btn-reject-${rest.id}"
                                                    onclick="return confirm('Reject this restaurant application?')">
                                                <i class="bi bi-x-circle-fill"></i> Reject
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

    </c:when>
    <c:otherwise>
        <div class="d-flex align-items-center gap-2 p-3 rounded-3 mb-4"
             style="background:#f0fdf4;border:1px solid #86efac;" id="manage-no-pending-msg">
            <i class="bi bi-check-circle-fill text-success"></i>
            <span style="font-size:.83rem;font-weight:600;color:#15803d;">
                No pending applications. All caught up!
            </span>
        </div>
    </c:otherwise>
</c:choose>

<%-- ══════════════════════════════════════════════════════════ --%>
<%-- SECTION 2 : ALL RESTAURANTS DIRECTORY                      --%>
<%-- ══════════════════════════════════════════════════════════ --%>
<div class="section-card" id="manage-all-restaurants-card">
    <div class="section-card-header flex-column flex-md-row align-items-start align-items-md-center">
        <h2 class="section-card-title">
            <i class="bi bi-shop-window text-primary me-2"></i>All Restaurants
        </h2>

        <%-- Search + Filter bar --%>
        <form action="${pageContext.request.contextPath}/manage/restaurants"
              method="GET" class="filter-bar ms-md-auto" id="manage-rest-filter-form">

            <input type="text" name="q" placeholder="Search by name or city…"
                   value="${not empty searchQuery ? searchQuery : ''}"
                   class="form-control" style="min-width:200px;max-width:260px;"
                   id="manage-rest-search-input">

            <select name="filter" class="form-select" style="width:auto;" id="manage-rest-status-filter">
                <option value="all"      ${filterStatus == 'all'      || empty filterStatus ? 'selected' : ''}>All Status</option>
                <option value="active"   ${filterStatus == 'active'   ? 'selected' : ''}>Active</option>
                <option value="suspended"${filterStatus == 'suspended' ? 'selected' : ''}>Suspended</option>
            </select>

            <button type="submit" class="btn-search" id="manage-rest-search-btn">
                <i class="bi bi-search me-1"></i>Search
            </button>
        </form>
    </div>

    <div class="table-responsive">
        <c:choose>
            <c:when test="${empty allRestaurants}">
                <div class="empty-state" id="manage-rest-empty">
                    <i class="bi bi-shop-window"></i>
                    <p>No restaurants found matching your search.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table manage-table" id="manage-all-restaurants-table">
                    <thead>
                        <tr>
                            <th>Restaurant</th>
                            <th>Owner</th>
                            <th>Cuisine</th>
                            <th>Rating</th>
                            <th>Total Orders</th>
                            <th>Revenue</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${allRestaurants}" var="rest">
                            <tr id="rest-row-${rest.id}">

                                <%-- Restaurant name + city --%>
                                <td>
                                    <div class="rest-chip">
                                        <div class="rest-avatar">
                                            ${not empty rest.name ? rest.name.substring(0,1).toUpperCase() : 'R'}
                                        </div>
                                        <div>
                                            <div class="rest-name">${rest.name}</div>
                                            <div class="rest-city">
                                                <i class="bi bi-geo-alt-fill me-1"></i>${rest.city}
                                            </div>
                                        </div>
                                    </div>
                                </td>

                                <%-- Owner --%>
                                <td>
                                    <div style="font-weight:600;font-size:.83rem;">${rest.ownerName}</div>
                                    <div style="font-size:.72rem;color:#9ca3af;">${rest.ownerEmail}</div>
                                </td>

                                <%-- Cuisine --%>
                                <td><span class="cuisine-chip">${rest.cuisineType}</span></td>

                                <%-- Rating --%>
                                <td>
                                    <div class="star-rating">
                                        <i class="bi bi-star-fill"></i>
                                        <span>${not empty rest.rating ? rest.rating : '—'}</span>
                                    </div>
                                </td>

                                <%-- Total orders --%>
                                <td style="font-weight:600;">${not empty rest.totalOrders ? rest.totalOrders : '0'}</td>

                                <%-- Revenue --%>
                                <td style="font-weight:700;">
                                    ₹<fmt:formatNumber value="${not empty rest.totalRevenue ? rest.totalRevenue : 0}" maxFractionDigits="0"/>
                                </td>

                                <%-- Status --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${rest.status == 'ACTIVE'}">
                                            <span class="status-badge active">Active</span>
                                        </c:when>
                                        <c:when test="${rest.status == 'SUSPENDED'}">
                                            <span class="status-badge suspended">Suspended</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge pending">Pending</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Actions --%>
                                <td>
                                    <div class="d-flex gap-2 align-items-center flex-wrap">
                                        <%-- View Menu --%>
                                        <a href="${pageContext.request.contextPath}/manage/catalog?restaurantId=${rest.id}"
                                           class="btn-action" id="btn-view-menu-${rest.id}">
                                            <i class="bi bi-journal-text"></i> Menu
                                        </a>

                                        <%-- Suspend / Activate toggle --%>
                                        <c:choose>
                                            <c:when test="${rest.status == 'ACTIVE'}">
                                                <form action="${pageContext.request.contextPath}/manage/restaurants/suspend"
                                                      method="POST" style="margin:0;" id="form-suspend-${rest.id}">
                                                    <input type="hidden" name="restaurantId" value="${rest.id}">
                                                    <button type="submit" class="btn-suspend" id="btn-suspend-${rest.id}"
                                                            onclick="return confirm('Suspend ${rest.name}? It will be hidden from the storefront.')">
                                                        <i class="bi bi-pause-circle"></i> Suspend
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form action="${pageContext.request.contextPath}/manage/restaurants/activate"
                                                      method="POST" style="margin:0;" id="form-activate-${rest.id}">
                                                    <input type="hidden" name="restaurantId" value="${rest.id}">
                                                    <button type="submit" class="btn-activate" id="btn-activate-${rest.id}">
                                                        <i class="bi bi-play-circle"></i> Activate
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>

                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- Pagination footer --%>
    <c:if test="${not empty totalPages && totalPages > 1}">
        <div class="d-flex align-items-center justify-content-between px-3 py-3 border-top"
             style="border-color:#f3f4f6!important;">
            <span style="font-size:.78rem;color:#9ca3af;">
                Page ${currentPage} of ${totalPages}
            </span>
            <div class="d-flex gap-2">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/manage/restaurants?page=${currentPage - 1}&q=${searchQuery}&filter=${filterStatus}"
                       class="btn-action" id="manage-rest-prev-btn">
                        <i class="bi bi-chevron-left"></i> Prev
                    </a>
                </c:if>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/manage/restaurants?page=${currentPage + 1}&q=${searchQuery}&filter=${filterStatus}"
                       class="btn-action" id="manage-rest-next-btn">
                        Next <i class="bi bi-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </div>
    </c:if>

</div><%-- /section-card --%>

<jsp:include page="manage-sidebar-close.jsp"/>
