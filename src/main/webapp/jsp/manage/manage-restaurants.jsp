<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
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
        font-size: 1rem; font-weight: 700; color: #0e150e; margin: 0;
    }
    .page-section-sub {
        font-size: .78rem; color: #8c8c82; margin-top: .15rem;
    }

    /* ── Approval banner ──────────────────────────────── */
    .approval-banner {
        background: var(--color-warm-sand, #e8dcc6);
        border: 1px solid rgba(0,71,60,0.15);
        border-radius: 20px;
        padding: 1.25rem 1.5rem;
    }
    .approval-banner-icon {
        width: 44px; height: 44px;
        background: var(--color-deep-forest, #00473c);
        border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        color: #fff; font-size: 1.2rem;
        flex-shrink: 0;
    }

    /* ── Section card (re-use from dashboard) ─────────── */
    .section-card {
        background: #fff;
        border: 1px solid rgba(140,140,130,0.2);
        border-radius: 20px;
        overflow: hidden;
    }
    .section-card-header {
        padding: 1rem 1.25rem;
        border-bottom: 1px solid rgba(140,140,130,0.15);
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1rem;
        flex-wrap: wrap;
    }
    .section-card-title { font-size: .92rem; font-weight: 700; color: #0e150e; margin: 0; }

    /* ── Manage table ─────────────────────────────────── */
    .manage-table { font-size: .84rem; margin: 0; }
    .manage-table thead th {
        background: rgba(0,71,60,0.04);
        font-size: .68rem; font-weight: 700;
        letter-spacing: .6px; text-transform: uppercase;
        color: #8c8c82;
        border-bottom: 1px solid rgba(140,140,130,0.18);
        padding: .7rem 1.1rem;
        white-space: nowrap;
    }
    .manage-table tbody td {
        padding: .9rem 1.1rem;
        color: #0e150e;
        vertical-align: middle;
        border-bottom: 1px solid rgba(140,140,130,0.12);
    }
    .manage-table tbody tr:last-child td { border-bottom: none; }
    .manage-table tbody tr:hover td { background: rgba(0,71,60,0.03); }

    /* ── Restaurant avatar ────────────────────────────── */
    .rest-chip { display: flex; align-items: center; gap: .65rem; }
    .rest-avatar {
        width: 38px; height: 38px;
        border-radius: 12px;
        background: var(--color-deep-forest, #00473c);
        color: var(--color-lime-glow, #e6ff55);
        font-size: .82rem; font-weight: 800;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .rest-name  { font-weight: 700; color: #0e150e; font-size: .85rem; }
    .rest-city  { font-size: .72rem; color: #8c8c82; }

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
    .status-badge.active   { background:rgba(0,71,60,0.1); color:#00473c; }
    .status-badge.active::before   { background:#00473c; }
    .status-badge.pending  { background:rgba(230,255,85,0.25); color:#5c6a00; }
    .status-badge.pending::before  { background:#a8b400; }
    .status-badge.suspended{ background:rgba(192,57,43,0.1); color:#c0392b; }
    .status-badge.suspended::before{ background:#c0392b; }

    /* ── Star rating ──────────────────────────────────── */
    .star-rating { color: #fbbf24; font-size: .8rem; }
    .star-rating span { color: #0e150e; font-size: .78rem; font-weight: 600; margin-left: 3px; }

    /* ── Action buttons ───────────────────────────────── */
    .btn-approve {
        font-size: .75rem; font-weight: 700;
        padding: 6px 14px; border-radius: 99px; border: none;
        background: var(--color-deep-forest, #00473c); color: #fff;
        cursor: pointer; transition: background .15s;
        text-decoration: none; display: inline-flex; align-items: center; gap: 4px;
    }
    .btn-approve:hover { background: #0e150e; color: #fff; }

    .btn-reject {
        font-size: .75rem; font-weight: 700;
        padding: 5px 12px; border-radius: 99px;
        border: 1.5px solid rgba(192,57,43,0.4);
        background: transparent; color: #c0392b;
        cursor: pointer; transition: background .15s, border-color .15s;
        text-decoration: none; display: inline-flex; align-items: center; gap: 4px;
    }
    .btn-reject:hover { background: rgba(192,57,43,0.1); border-color: #c0392b; }

    .btn-action {
        font-size: .75rem; font-weight: 600;
        padding: 5px 12px; border-radius: 99px;
        border: 1.5px solid rgba(140,140,130,0.4);
        background: transparent; color: #555;
        text-decoration: none; transition: border-color .15s, color .15s;
        display: inline-flex; align-items: center; gap: 4px;
        white-space: nowrap;
    }
    .btn-action:hover { border-color: #00473c; color: #00473c; }

    .btn-suspend {
        font-size: .75rem; font-weight: 600;
        padding: 5px 12px; border-radius: 99px;
        border: 1.5px solid rgba(192,57,43,0.4);
        background: transparent; color: #c0392b;
        text-decoration: none; transition: background .15s;
        display: inline-flex; align-items: center; gap: 4px;
        white-space: nowrap;
    }
    .btn-suspend:hover { background: rgba(192,57,43,0.1); }

    .btn-activate {
        font-size: .75rem; font-weight: 600;
        padding: 5px 12px; border-radius: 99px;
        border: 1.5px solid rgba(0,71,60,0.3);
        background: transparent; color: #00473c;
        text-decoration: none; transition: background .15s;
        display: inline-flex; align-items: center; gap: 4px;
        white-space: nowrap;
    }
    .btn-activate:hover { background: rgba(0,71,60,0.1); }

    /* ── Search & filter bar ──────────────────────────── */
    .filter-bar {
        display: flex; align-items: center;
        gap: .6rem; flex-wrap: wrap;
    }
    .filter-bar .form-control,
    .filter-bar .form-select {
        font-size: .82rem; border-radius: 99px;
        border: 1.5px solid rgba(140,140,130,0.4);
        padding: .42rem 1rem;
        background: #fff;
        color: #0e150e;
    }
    .filter-bar .form-control:focus,
    .filter-bar .form-select:focus {
        border-color: #00473c;
        box-shadow: 0 0 0 3px rgba(0,71,60,0.1);
    }
    .filter-bar .btn-search {
        font-size: .82rem; font-weight: 700;
        padding: .42rem 1.25rem; border-radius: 99px;
        background: #00473c; color: #fff; border: none;
        cursor: pointer; transition: background .15s;
    }
    .filter-bar .btn-search:hover { background: #0e150e; }

    /* ── Filter tabs ──────────────────────────────────── */
    .filter-tabs { display: flex; gap: .4rem; flex-wrap: wrap; }
    .filter-tab {
        font-size: .78rem; font-weight: 700;
        padding: 6px 16px; border-radius: 99px;
        border: 1.5px solid rgba(140,140,130,0.4);
        background: transparent; color: #555;
        text-decoration: none; transition: all .15s;
        white-space: nowrap;
    }
    .filter-tab:hover { border-color: #00473c; color: #00473c; }
    .filter-tab.active {
        background: #00473c; color: #fff;
        border-color: #00473c;
    }

    /* ── Empty state ──────────────────────────────────── */
    .empty-state {
        text-align: center; padding: 3rem 1rem;
    }
    .empty-state i { font-size: 2.8rem; color: #8c8c82; display: block; margin-bottom: 1rem; }
    .empty-state p { font-size: .85rem; font-weight: 600; color: #8c8c82; margin: 0; }

    /* ── Cuisine chip ─────────────────────────────────── */
    .cuisine-chip {
        display: inline-block;
        font-size: .68rem; font-weight: 700;
        padding: 2px 10px; border-radius: 99px;
        background: var(--color-warm-sand, #e8dcc6); color: var(--color-deep-forest, #00473c);
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
        <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
            <button class="btn btn-sm" id="btn-add-restaurant"
                    onclick="document.getElementById('addRestaurantModal').style.display='flex'"
                    style="background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;border:none;
                           border-radius:10px;padding:.45rem 1rem;font-size:.8rem;font-weight:700;
                           display:flex;align-items:center;gap:.4rem;cursor:pointer;">
                <i class="bi bi-plus-lg"></i> Add Restaurant
            </button>
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

                                        <%-- Edit button --%>
                                        <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                            <button type="button"
                                                    id="btn-edit-${rest.id}"
                                                    onclick="openEditModal(
                                                        '${rest.id}',
                                                        '${fn:escapeXml(rest.name)}',
                                                        '${fn:escapeXml(rest.cuisineType)}',
                                                        '${fn:escapeXml(rest.city)}',
                                                        '${fn:escapeXml(rest.address)}',
                                                        '${fn:escapeXml(rest.phone)}',
                                                        '${fn:escapeXml(rest.email)}',
                                                        '${rest.deliveryTimeMins}',
                                                        '${rest.costForTwo}',
                                                        '${fn:escapeXml(rest.imageUrl)}',
                                                        '${fn:escapeXml(rest.description)}'
                                                    )"
                                                    style="display:inline-flex;align-items:center;gap:.3rem;
                                                           padding:.3rem .7rem;border:1px solid #6366f1;
                                                           border-radius:7px;background:#eef2ff;color:#4338ca;
                                                           font-size:.75rem;font-weight:600;cursor:pointer;">
                                                <i class="bi bi-pencil"></i> Edit
                                            </button>
                                            <button type="button"
                                                    id="btn-delete-${rest.id}"
                                                    onclick="deleteRestaurant('${rest.id}', '${fn:escapeXml(rest.name)}')"
                                                    style="display:inline-flex;align-items:center;gap:.3rem;
                                                           padding:.3rem .7rem;border:1px solid #ef4444;
                                                           border-radius:7px;background:#fef2f2;color:#dc2626;
                                                           font-size:.75rem;font-weight:600;cursor:pointer;">
                                                <i class="bi bi-trash3"></i> Delete
                                            </button>
                                        </c:if>
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

<%-- ═══════════════════════════════════ MODALS ══════════════════════════════════ --%>

<%-- ── ADD RESTAURANT MODAL ──────────────────────────────────────────────────── --%>
<div id="addRestaurantModal" style="display:none;position:fixed;inset:0;z-index:1060;
     background:rgba(0,0,0,.55);align-items:center;justify-content:center;padding:1rem;">
    <div style="background:#fff;border-radius:18px;width:100%;max-width:620px;
                max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,.25);">
        <div style="padding:1.4rem 1.6rem;border-bottom:1px solid #f3f4f6;
                    display:flex;align-items:center;justify-content:space-between;">
            <h5 style="margin:0;font-weight:700;font-size:1rem;">Add New Restaurant</h5>
            <button onclick="document.getElementById('addRestaurantModal').style.display='none'"
                    style="background:none;border:none;font-size:1.3rem;cursor:pointer;color:#6b7280;">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/manage/restaurants/add"
              id="form-add-restaurant" style="padding:1.6rem;">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Restaurant Name *</label>
                    <input type="text" name="name" required placeholder="e.g. The Burger Lab"
                           id="add-rest-name"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Cuisine Type *</label>
                    <input type="text" name="cuisineType" required placeholder="e.g. North Indian"
                           id="add-rest-cuisine"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">City</label>
                    <input type="text" name="city" placeholder="e.g. Bengaluru" id="add-rest-city"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Address</label>
                    <input type="text" name="address" placeholder="Full street address" id="add-rest-address"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Phone</label>
                    <input type="text" name="phone" placeholder="+91 98765 43210" id="add-rest-phone"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Email</label>
                    <input type="email" name="email" placeholder="restaurant@example.com" id="add-rest-email"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Delivery Time (mins)</label>
                    <input type="number" name="deliveryTimeMins" placeholder="30" min="5" max="120" id="add-rest-delivery"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Cost for Two (₹)</label>
                    <input type="number" name="costForTwo" placeholder="500" min="0" id="add-rest-cost"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Image URL</label>
                    <input type="url" name="imageUrl" placeholder="https://..." id="add-rest-image"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Description</label>
                    <textarea name="description" rows="2" placeholder="Short description of the restaurant..."
                              id="add-rest-desc"
                              style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                     border-radius:8px;font-size:.85rem;margin-top:.3rem;
                                     resize:vertical;box-sizing:border-box;"></textarea>
                </div>
            </div>
            <div style="display:flex;gap:.75rem;justify-content:flex-end;margin-top:1.4rem;">
                <button type="button"
                        onclick="document.getElementById('addRestaurantModal').style.display='none'"
                        style="padding:.55rem 1.2rem;border:1px solid #d1d5db;border-radius:9px;
                               background:#fff;font-size:.85rem;cursor:pointer;color:#374151;">
                    Cancel
                </button>
                <button type="submit" id="btn-add-rest-submit"
                        style="padding:.55rem 1.4rem;border:none;border-radius:9px;
                               background:linear-gradient(135deg,#6366f1,#8b5cf6);
                               color:#fff;font-size:.85rem;font-weight:700;cursor:pointer;">
                    <i class="bi bi-plus-lg me-1"></i>Add Restaurant
                </button>
            </div>
        </form>
    </div>
</div>

<%-- ── EDIT RESTAURANT MODAL ──────────────────────────────────────────────────── --%>
<div id="editRestaurantModal" style="display:none;position:fixed;inset:0;z-index:1060;
     background:rgba(0,0,0,.55);align-items:center;justify-content:center;padding:1rem;">
    <div style="background:#fff;border-radius:18px;width:100%;max-width:620px;
                max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,.25);">
        <div style="padding:1.4rem 1.6rem;border-bottom:1px solid #f3f4f6;
                    display:flex;align-items:center;justify-content:space-between;">
            <h5 style="margin:0;font-weight:700;font-size:1rem;">Edit Restaurant</h5>
            <button onclick="document.getElementById('editRestaurantModal').style.display='none'"
                    style="background:none;border:none;font-size:1.3rem;cursor:pointer;color:#6b7280;">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/manage/restaurants/edit"
              id="form-edit-restaurant" style="padding:1.6rem;">
            <input type="hidden" name="restaurantId" id="edit-rest-id">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Restaurant Name *</label>
                    <input type="text" name="name" required id="edit-rest-name"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Cuisine Type *</label>
                    <input type="text" name="cuisineType" required id="edit-rest-cuisine"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">City</label>
                    <input type="text" name="city" id="edit-rest-city"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Address</label>
                    <input type="text" name="address" id="edit-rest-address"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Phone</label>
                    <input type="text" name="phone" id="edit-rest-phone"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Email</label>
                    <input type="email" name="email" id="edit-rest-email"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Delivery Time (mins)</label>
                    <input type="number" name="deliveryTimeMins" min="5" max="120" id="edit-rest-delivery"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Cost for Two (₹)</label>
                    <input type="number" name="costForTwo" min="0" id="edit-rest-cost"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Image URL</label>
                    <input type="url" name="imageUrl" id="edit-rest-image"
                           style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                  border-radius:8px;font-size:.85rem;margin-top:.3rem;box-sizing:border-box;">
                </div>
                <div style="grid-column:1/-1;">
                    <label style="font-size:.8rem;font-weight:600;color:#374151;">Description</label>
                    <textarea name="description" rows="2" id="edit-rest-desc"
                              style="width:100%;padding:.55rem .8rem;border:1px solid #d1d5db;
                                     border-radius:8px;font-size:.85rem;margin-top:.3rem;
                                     resize:vertical;box-sizing:border-box;"></textarea>
                </div>
            </div>
            <div style="display:flex;gap:.75rem;justify-content:flex-end;margin-top:1.4rem;">
                <button type="button"
                        onclick="document.getElementById('editRestaurantModal').style.display='none'"
                        style="padding:.55rem 1.2rem;border:1px solid #d1d5db;border-radius:9px;
                               background:#fff;font-size:.85rem;cursor:pointer;color:#374151;">
                    Cancel
                </button>
                <button type="submit" id="btn-edit-rest-submit"
                        style="padding:.55rem 1.4rem;border:none;border-radius:9px;
                               background:linear-gradient(135deg,#0ea5e9,#6366f1);
                               color:#fff;font-size:.85rem;font-weight:700;cursor:pointer;">
                    <i class="bi bi-check-lg me-1"></i>Save Changes
                </button>
            </div>
        </form>
    </div>
</div>

<%-- ── EDIT + DELETE trigger buttons wired via JS ─────────────────────────────── --%>
<script>
function openEditModal(id, name, cuisine, city, address, phone, email, delivery, cost, imageUrl, desc) {
    document.getElementById('edit-rest-id').value      = id;
    document.getElementById('edit-rest-name').value    = name;
    document.getElementById('edit-rest-cuisine').value = cuisine;
    document.getElementById('edit-rest-city').value    = city;
    document.getElementById('edit-rest-address').value = address;
    document.getElementById('edit-rest-phone').value   = phone;
    document.getElementById('edit-rest-email').value   = email;
    document.getElementById('edit-rest-delivery').value= delivery;
    document.getElementById('edit-rest-cost').value    = cost;
    document.getElementById('edit-rest-image').value   = imageUrl;
    document.getElementById('edit-rest-desc').value    = desc;
    document.getElementById('editRestaurantModal').style.display = 'flex';
}
function deleteRestaurant(id, name) {
    if (!confirm('Delete "' + name + '"?\nThis will permanently remove the restaurant and cannot be undone.')) return;
    var f = document.createElement('form');
    f.method = 'POST';
    f.action = '${pageContext.request.contextPath}/manage/restaurants/delete';
    var inp = document.createElement('input');
    inp.type = 'hidden'; inp.name = 'restaurantId'; inp.value = id;
    f.appendChild(inp); document.body.appendChild(f); f.submit();
}
// Close modals on outside-click
['addRestaurantModal','editRestaurantModal'].forEach(function(id) {
    document.getElementById(id).addEventListener('click', function(e) {
        if (e.target === this) this.style.display = 'none';
    });
});
</script>

<jsp:include page="manage-sidebar-close.jsp"/>

