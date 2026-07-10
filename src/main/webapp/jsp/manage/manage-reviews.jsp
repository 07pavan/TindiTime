<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 7 : REVIEWS & RATINGS
    MVC: populated by AdminReviewServlet which sets:
      requestScope.reviews            — List<Review>
      requestScope.restaurantSummary  — List<Map> { restaurantId, restaurantName,
                                          avgRating, totalReviews, flaggedCount }
      requestScope.filterStatus       — String  published | flagged | all
      requestScope.filterRestId       — Long    restaurant filter (admin only)
      requestScope.searchQuery        — String
      requestScope.stats              — Map: totalReviews, avgPlatformRating,
                                          flaggedCount, publishedCount
      requestScope.restaurants        — List<Restaurant>  for filter dropdown

    Each Review has:
      id, customerName, customerEmail, restaurantName, restaurantId,
      productName, rating (1–5), comment, reviewDate,
      status (PUBLISHED | FLAGGED | REMOVED)
--%>
<c:set var="pageTitle" value="Reviews &amp; Ratings" scope="request"/>
<c:set var="activeNav"  value="reviews"              scope="request"/>

<jsp:include page="manage-sidebar.jsp"/>

<%-- ══════════════════════ PAGE-SCOPED STYLES ══════════════════════ --%>
<style>
    /* ── KPI strip ────────────────────────────────── */
    .kpi-strip {
        display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr));
        gap:.75rem; margin-bottom:1.5rem;
    }
    .kpi-tile {
        background:#fff; border:1px solid #e5e7eb; border-radius:12px;
        padding:1rem 1.1rem; display:flex; align-items:center; gap:.75rem;
    }
    .kpi-icon {
        width:42px; height:42px; border-radius:10px;
        display:flex; align-items:center; justify-content:center;
        font-size:1.1rem; flex-shrink:0;
    }
    .kpi-icon.yellow { background:#fefce8; color:#ca8a04; }
    .kpi-icon.green  { background:#f0fdf4; color:#22c55e; }
    .kpi-icon.red    { background:#fef2f2; color:#ef4444; }
    .kpi-icon.blue   { background:#eff6ff; color:#3b82f6; }
    .kpi-value { font-size:1.4rem; font-weight:800; color:#111827; line-height:1.1; }
    .kpi-label { font-size:.68rem; font-weight:700; color:#9ca3af;
                 text-transform:uppercase; letter-spacing:.4px; }

    /* ── Section card ─────────────────────────────── */
    .section-card { background:#fff; border:1px solid #e5e7eb; border-radius:14px; overflow:hidden; }
    .section-card-header {
        padding:1rem 1.25rem; border-bottom:1px solid #f3f4f6;
        display:flex; align-items:center; justify-content:space-between;
        gap:1rem; flex-wrap:wrap;
    }
    .section-card-title { font-size:.92rem; font-weight:700; color:#111827; margin:0; }

    /* ── Restaurant rating summary cards ──────────── */
    .rest-rating-grid {
        display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr));
        gap:.75rem; padding:1.25rem;
    }
    .rest-rating-card {
        background:#f9fafb; border:1px solid #f3f4f6; border-radius:12px;
        padding:1rem; transition:box-shadow .2s, transform .2s;
        cursor:pointer; text-decoration:none;
    }
    .rest-rating-card:hover { box-shadow:0 4px 16px rgba(0,0,0,.07); transform:translateY(-2px); }
    .rest-rating-card.active-filter { border-color:#f97316; box-shadow:0 0 0 3px rgba(249,115,22,.1); }
    .rest-card-name { font-weight:700; color:#111827; font-size:.85rem; margin-bottom:.5rem;
                      white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .rest-card-stars { display:flex; align-items:center; gap:.3rem; }
    .star-full    { color:#fbbf24; font-size:.9rem; }
    .star-empty   { color:#e5e7eb; font-size:.9rem; }
    .rest-card-score { font-size:1.2rem; font-weight:900; color:#111827; margin-left:.25rem; }
    .rest-card-meta  { font-size:.72rem; color:#9ca3af; margin-top:.35rem; }
    .flagged-chip {
        font-size:.68rem; font-weight:700; padding:1px 7px; border-radius:99px;
        background:#fef2f2; color:#dc2626; margin-left:.35rem;
    }

    /* ── Manage table ─────────────────────────────── */
    .manage-table { font-size:.84rem; margin:0; }
    .manage-table thead th {
        background:#f9fafb; font-size:.68rem; font-weight:700;
        letter-spacing:.6px; text-transform:uppercase; color:#9ca3af;
        border-bottom:1px solid #f3f4f6; padding:.7rem 1.1rem; white-space:nowrap;
    }
    .manage-table tbody td {
        padding:.85rem 1.1rem; color:#374151; vertical-align:middle;
        border-bottom:1px solid #f9fafb;
    }
    .manage-table tbody tr:last-child td { border-bottom:none; }
    .manage-table tbody tr:hover td { background:#fafafa; }
    .manage-table tbody tr.row-flagged td { background:#fff9f9; }
    .manage-table tbody tr.row-removed td { opacity:.5; background:#f9fafb; }

    /* ── User chip ────────────────────────────────── */
    .user-chip { display:flex; align-items:center; gap:.55rem; }
    .chip-avatar {
        width:32px; height:32px; border-radius:50%;
        background:linear-gradient(135deg,#f97316,#ea580c);
        color:#fff; font-size:.72rem; font-weight:700;
        display:flex; align-items:center; justify-content:center; flex-shrink:0;
    }
    .chip-name  { font-weight:700; color:#111827; font-size:.83rem; }
    .chip-sub   { font-size:.7rem; color:#9ca3af; }

    /* ── Star display ─────────────────────────────── */
    .stars-display { display:flex; align-items:center; gap:2px; white-space:nowrap; }
    .stars-display .s { font-size:.85rem; }
    .stars-display .s.on  { color:#fbbf24; }
    .stars-display .s.off { color:#e5e7eb; }
    .stars-display .rating-num {
        font-size:.8rem; font-weight:800; color:#111827; margin-left:.35rem;
    }

    /* ── Review comment preview ───────────────────── */
    .comment-preview {
        font-size:.8rem; color:#374151; line-height:1.45;
        max-width:300px;
        display:-webkit-box; -webkit-line-clamp:2;
        -webkit-box-orient:vertical; overflow:hidden;
    }
    .comment-full { display:none; }

    /* ── Status badges ────────────────────────────── */
    .status-badge {
        display:inline-flex; align-items:center; gap:5px;
        font-size:.7rem; font-weight:700; padding:3px 10px;
        border-radius:99px; white-space:nowrap;
    }
    .status-badge::before { content:''; width:6px; height:6px; border-radius:50%; display:inline-block; }
    .status-badge.published { background:#f0fdf4; color:#15803d; }
    .status-badge.published::before { background:#22c55e; }
    .status-badge.flagged   { background:#fef2f2; color:#dc2626; }
    .status-badge.flagged::before   { background:#ef4444; }
    .status-badge.removed   { background:#f9fafb; color:#6b7280; }
    .status-badge.removed::before   { background:#9ca3af; }

    /* ── Action buttons ───────────────────────────── */
    .btn-action {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #e5e7eb; background:#fff; color:#374151;
        text-decoration:none; transition:border-color .15s, color .15s;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
    }
    .btn-action:hover { border-color:#f97316; color:#f97316; }
    .btn-flag {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #fca5a5; background:#fef2f2; color:#dc2626;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
        transition:background .15s;
    }
    .btn-flag:hover { background:#fee2e2; }
    .btn-unflag {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #86efac; background:#f0fdf4; color:#16a34a;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
        transition:background .15s;
    }
    .btn-unflag:hover { background:#dcfce7; }
    .btn-remove-review {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #e5e7eb; background:#fff; color:#6b7280;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
        transition:border-color .15s, color .15s;
    }
    .btn-remove-review:hover { border-color:#ef4444; color:#ef4444; }

    /* ── Filter bar ───────────────────────────────── */
    .filter-bar { display:flex; align-items:center; gap:.6rem; flex-wrap:wrap; }
    .filter-bar .form-control,
    .filter-bar .form-select {
        font-size:.82rem; border-radius:9px; border:1px solid #e5e7eb;
        padding:.42rem .85rem; background:#f9fafb;
    }
    .filter-bar .form-control:focus,
    .filter-bar .form-select:focus { border-color:#f97316; box-shadow:0 0 0 3px rgba(249,115,22,.08); }
    .filter-bar .btn-search {
        font-size:.82rem; font-weight:600; padding:.42rem 1rem;
        border-radius:9px; background:#f97316; color:#fff; border:none; cursor:pointer;
    }
    .filter-bar .btn-search:hover { background:#ea580c; }

    /* ── Status filter tabs ───────────────────────── */
    .status-tabs { display:flex; gap:.4rem; flex-wrap:wrap; }
    .status-tab {
        font-size:.78rem; font-weight:600; padding:5px 14px;
        border-radius:99px; border:1px solid #e5e7eb;
        background:#fff; color:#6b7280; text-decoration:none;
        transition:all .15s; white-space:nowrap;
    }
    .status-tab:hover { border-color:#f97316; color:#f97316; }
    .status-tab.active { background:#f97316; color:#fff; border-color:#f97316; }

    /* ── Read more link ───────────────────────────── */
    .read-more-btn {
        font-size:.72rem; font-weight:600; color:#f97316;
        cursor:pointer; background:none; border:none; padding:0;
        display:inline; text-decoration:underline;
    }

    /* ── Empty state ──────────────────────────────── */
    .empty-state { text-align:center; padding:3.5rem 1rem; }
    .empty-state i { font-size:2.8rem; color:#e5e7eb; display:block; margin-bottom:1rem; }
    .empty-state p { font-size:.85rem; font-weight:600; color:#9ca3af; margin:0; }

    /* ── Review detail offcanvas ──────────────────── */
    .offcanvas { font-family:'Outfit',sans-serif; }
    .offcanvas-header { border-bottom:1px solid #f3f4f6; padding:1.1rem 1.4rem; }
    .offcanvas-title  { font-size:1rem; font-weight:800; color:#111827; }
    .offcanvas-body   { padding:1.25rem 1.4rem; }

    .detail-section-title {
        font-size:.68rem; font-weight:800; letter-spacing:.8px;
        text-transform:uppercase; color:#9ca3af; margin-bottom:.5rem;
    }
    .review-full-comment {
        background:#f9fafb; border:1px solid #f3f4f6;
        border-radius:10px; padding:1rem; font-size:.85rem;
        color:#374151; line-height:1.6; font-style:italic;
    }

    /* ── Platform avg rating hero ─────────────────── */
    .rating-hero {
        background:linear-gradient(135deg,#fefce8,#fef9c3);
        border:1px solid #fde68a; border-radius:14px;
        padding:1.25rem 1.5rem;
        display:flex; align-items:center; gap:1.5rem;
        margin-bottom:1.5rem; flex-wrap:wrap;
    }
    .rating-hero-score {
        font-size:3.5rem; font-weight:900; color:#111827; line-height:1;
    }
    .rating-hero-stars { display:flex; gap:3px; margin:.3rem 0; }
    .rating-hero-stars i { font-size:1.4rem; color:#fbbf24; }
    .rating-hero-stars i.empty { color:#e5e7eb; }
    .rating-hero-meta { font-size:.82rem; color:#92400e; font-weight:600; }
</style>

<%-- ══════════════════════ PAGE HEADER ══════════════════════ --%>
<div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
    <div>
        <h1 class="fw-bold mb-1" style="font-size:1.4rem;color:#111827;">Reviews &amp; Ratings</h1>
        <p class="text-muted mb-0" style="font-size:.82rem;">
            Monitor customer feedback, flag abuse, and track restaurant ratings.
        </p>
    </div>
</div>

<%-- ══════════════════════ PLATFORM RATING HERO ══════════════════════ --%>
<div class="rating-hero" id="reviews-rating-hero">
    <div class="rating-hero-score">
        ${not empty stats.avgPlatformRating ? stats.avgPlatformRating : '—'}
    </div>
    <div>
        <div class="rating-hero-stars">
            <%-- Render 5 stars based on avgPlatformRating — simplified full stars display --%>
            <c:forEach begin="1" end="5" var="s">
                <c:choose>
                    <c:when test="${s <= stats.avgPlatformRating}">
                        <i class="bi bi-star-fill"></i>
                    </c:when>
                    <c:otherwise>
                        <i class="bi bi-star empty"></i>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </div>
        <div class="rating-hero-meta">
            Platform Average · ${not empty stats.totalReviews ? stats.totalReviews : '0'} total reviews
        </div>
    </div>
    <div class="ms-auto d-flex gap-3 flex-wrap">
        <div class="text-center">
            <div style="font-size:1.5rem;font-weight:900;color:#16a34a;">${not empty stats.publishedCount ? stats.publishedCount : '0'}</div>
            <div style="font-size:.7rem;font-weight:700;color:#9ca3af;text-transform:uppercase;">Published</div>
        </div>
        <div class="text-center">
            <div style="font-size:1.5rem;font-weight:900;color:#dc2626;">${not empty stats.flaggedCount ? stats.flaggedCount : '0'}</div>
            <div style="font-size:.7rem;font-weight:700;color:#9ca3af;text-transform:uppercase;">Flagged</div>
        </div>
    </div>
</div>

<%-- ══════════════════════ KPI STRIP ══════════════════════ --%>
<div class="kpi-strip">
    <div class="kpi-tile">
        <div class="kpi-icon yellow"><i class="bi bi-star-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.avgPlatformRating ? stats.avgPlatformRating : '—'}</div>
            <div class="kpi-label">Avg Rating</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon blue"><i class="bi bi-chat-left-text-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.totalReviews ? stats.totalReviews : '0'}</div>
            <div class="kpi-label">Total Reviews</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon green"><i class="bi bi-check-circle-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.publishedCount ? stats.publishedCount : '0'}</div>
            <div class="kpi-label">Published</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon red"><i class="bi bi-flag-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.flaggedCount ? stats.flaggedCount : '0'}</div>
            <div class="kpi-label">Flagged</div>
        </div>
    </div>
</div>

<%-- ══════════════════════ RESTAURANT RATING SUMMARY ══════════════════════ --%>
<c:if test="${not empty restaurantSummary}">
    <div class="section-card mb-4" id="reviews-rest-summary-card">
        <div class="section-card-header">
            <h2 class="section-card-title">
                <i class="bi bi-shop-window me-2" style="color:#f97316;"></i>
                Restaurant Rating Overview
            </h2>
            <span style="font-size:.75rem;color:#9ca3af;">Click to filter reviews</span>
        </div>
        <div class="rest-rating-grid" id="reviews-rest-grid">
            <c:forEach items="${restaurantSummary}" var="rs">
                <a href="${pageContext.request.contextPath}/manage/reviews?restaurantId=${rs.restaurantId}"
                   class="rest-rating-card ${filterRestId == rs.restaurantId ? 'active-filter' : ''}"
                   id="rest-card-${rs.restaurantId}">
                    <div class="rest-card-name">${rs.restaurantName}</div>
                    <div class="rest-card-stars">
                        <%-- Stars --%>
                        <c:forEach begin="1" end="5" var="s">
                            <c:choose>
                                <c:when test="${s <= rs.avgRating}">
                                    <i class="bi bi-star-fill star-full"></i>
                                </c:when>
                                <c:otherwise>
                                    <i class="bi bi-star star-empty"></i>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <span class="rest-card-score">${rs.avgRating}</span>
                    </div>
                    <div class="rest-card-meta">
                        ${rs.totalReviews} review${rs.totalReviews != 1 ? 's' : ''}
                        <c:if test="${rs.flaggedCount > 0}">
                            <span class="flagged-chip"><i class="bi bi-flag-fill me-1"></i>${rs.flaggedCount} flagged</span>
                        </c:if>
                    </div>
                </a>
            </c:forEach>
        </div>
    </div>
</c:if>

<%-- ══════════════════════ REVIEWS TABLE CARD ══════════════════════ --%>
<div class="section-card" id="manage-reviews-card">

    <div class="section-card-header flex-column flex-lg-row align-items-start align-items-lg-center">
        <h2 class="section-card-title">
            <i class="bi bi-chat-left-text-fill me-2" style="color:#fbbf24;"></i>
            <c:choose>
                <c:when test="${filterStatus == 'flagged'}">Flagged Reviews</c:when>
                <c:when test="${filterStatus == 'published'}">Published Reviews</c:when>
                <c:otherwise>All Reviews</c:otherwise>
            </c:choose>
        </h2>

        <form action="${pageContext.request.contextPath}/manage/reviews"
              method="GET" class="filter-bar ms-lg-auto mt-2 mt-lg-0" id="reviews-filter-form">

            <c:if test="${not empty filterStatus}">
                <input type="hidden" name="status" value="${filterStatus}">
            </c:if>

            <input type="text" name="q" placeholder="Customer or restaurant…"
                   value="${not empty searchQuery ? searchQuery : ''}"
                   class="form-control" style="min-width:180px;max-width:220px;"
                   id="reviews-search-input">

            <%-- Star rating filter --%>
            <select name="rating" class="form-select" style="width:auto;" id="reviews-rating-filter">
                <option value="">All Stars</option>
                <option value="5" ${param.rating == '5' ? 'selected' : ''}>⭐⭐⭐⭐⭐ 5 Stars</option>
                <option value="4" ${param.rating == '4' ? 'selected' : ''}>⭐⭐⭐⭐ 4 Stars</option>
                <option value="3" ${param.rating == '3' ? 'selected' : ''}>⭐⭐⭐ 3 Stars</option>
                <option value="2" ${param.rating == '2' ? 'selected' : ''}>⭐⭐ 2 Stars</option>
                <option value="1" ${param.rating == '1' ? 'selected' : ''}>⭐ 1 Star</option>
            </select>

            <%-- Restaurant filter (admin only) --%>
            <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                <select name="restaurantId" class="form-select" style="width:auto;" id="reviews-rest-filter">
                    <option value="">All Restaurants</option>
                    <c:forEach items="${restaurants}" var="rest">
                        <option value="${rest.id}" ${filterRestId == rest.id ? 'selected' : ''}>${rest.name}</option>
                    </c:forEach>
                </select>
            </c:if>

            <button type="submit" class="btn-search" id="reviews-search-btn">
                <i class="bi bi-search me-1"></i>Filter
            </button>

            <c:if test="${not empty searchQuery || not empty filterRestId || not empty param.rating}">
                <a href="${pageContext.request.contextPath}/manage/reviews${not empty filterStatus ? '?status='.concat(filterStatus) : ''}"
                   class="btn-action" id="reviews-clear-btn">
                    <i class="bi bi-x"></i> Clear
                </a>
            </c:if>
        </form>
    </div>

    <%-- Status tabs --%>
    <div class="px-3 pt-3 pb-1">
        <div class="status-tabs" id="reviews-status-tabs">
            <a href="${pageContext.request.contextPath}/manage/reviews"
               class="status-tab ${empty filterStatus ? 'active' : ''}" id="rtab-all">All</a>
            <a href="${pageContext.request.contextPath}/manage/reviews?status=published"
               class="status-tab ${filterStatus == 'published' ? 'active' : ''}" id="rtab-published">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#22c55e;"></i>Published</a>
            <a href="${pageContext.request.contextPath}/manage/reviews?status=flagged"
               class="status-tab ${filterStatus == 'flagged' ? 'active' : ''}" id="rtab-flagged"
               style="${filterStatus != 'flagged' ? 'border-color:#fca5a5;color:#dc2626;' : ''}">
               <i class="bi bi-flag-fill me-1" style="font-size:.65rem;"></i>Flagged
               <c:if test="${not empty stats.flaggedCount && stats.flaggedCount > 0}">
                   <span style="background:#ef4444;color:#fff;font-size:.6rem;font-weight:800;
                                padding:1px 5px;border-radius:99px;margin-left:3px;">${stats.flaggedCount}</span>
               </c:if>
            </a>
            <a href="${pageContext.request.contextPath}/manage/reviews?status=removed"
               class="status-tab ${filterStatus == 'removed' ? 'active' : ''}" id="rtab-removed">
               <i class="bi bi-eye-slash me-1"></i>Removed</a>
        </div>
    </div>

    <%-- Table --%>
    <div class="table-responsive">
        <c:choose>
            <c:when test="${empty reviews}">
                <div class="empty-state" id="reviews-empty-state">
                    <i class="bi bi-chat-left-text"></i>
                    <p>No reviews found for this filter.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table manage-table" id="manage-reviews-table">
                    <thead>
                        <tr>
                            <th>Customer</th>
                            <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                <th>Restaurant</th>
                            </c:if>
                            <th>Rating</th>
                            <th>Comment</th>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${reviews}" var="review">
                            <tr id="review-row-${review.id}"
                                class="${review.status == 'FLAGGED' ? 'row-flagged' : (review.status == 'REMOVED' ? 'row-removed' : '')}">

                                <%-- Customer --%>
                                <td>
                                    <div class="user-chip">
                                        <div class="chip-avatar">
                                            ${not empty review.customerName ? review.customerName.substring(0,1).toUpperCase() : 'U'}
                                        </div>
                                        <div>
                                            <div class="chip-name">${review.customerName}</div>
                                            <div class="chip-sub">${review.customerEmail}</div>
                                        </div>
                                    </div>
                                </td>

                                <%-- Restaurant (admin) --%>
                                <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                    <td style="font-weight:600;font-size:.82rem;">${review.restaurantName}</td>
                                </c:if>

                                <%-- Star rating --%>
                                <td>
                                    <div class="stars-display">
                                        <c:forEach begin="1" end="5" var="s">
                                            <span class="s ${s <= review.rating ? 'on' : 'off'}">
                                                <i class="bi bi-star-fill"></i>
                                            </span>
                                        </c:forEach>
                                        <span class="rating-num">${review.rating}.0</span>
                                    </div>
                                </td>

                                <%-- Comment preview + read more --%>
                                <td>
                                    <div class="comment-preview" id="comment-preview-${review.id}">
                                        "<c:out value="${review.comment}"/>"
                                    </div>
                                    <c:if test="${not empty review.comment && review.comment.length() > 80}">
                                        <button type="button" class="read-more-btn mt-1"
                                                id="readmore-${review.id}"
                                                onclick="openReviewDetail(
                                                    '${review.id}',
                                                    '${review.customerName}',
                                                    '${review.restaurantName}',
                                                    '${review.rating}',
                                                    '${review.reviewDate}',
                                                    '${review.status}'
                                                )"
                                                data-comment="${review.comment}"
                                                data-bs-toggle="offcanvas"
                                                data-bs-target="#reviewDetailPanel">
                                            Read full review
                                        </button>
                                    </c:if>
                                </td>

                                <%-- Date --%>
                                <td style="font-size:.76rem;color:#9ca3af;white-space:nowrap;">${review.reviewDate}</td>

                                <%-- Status --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${review.status == 'PUBLISHED'}">
                                            <span class="status-badge published">Published</span>
                                        </c:when>
                                        <c:when test="${review.status == 'FLAGGED'}">
                                            <span class="status-badge flagged">
                                                <i class="bi bi-flag-fill" style="font-size:.6rem;margin-right:2px;"></i>Flagged
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge removed">Removed</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Actions --%>
                                <td>
                                    <div class="d-flex gap-2 align-items-center flex-wrap">

                                        <%-- Full detail --%>
                                        <button type="button" class="btn-action"
                                                id="btn-detail-review-${review.id}"
                                                onclick="openReviewDetail(
                                                    '${review.id}',
                                                    '${review.customerName}',
                                                    '${review.restaurantName}',
                                                    '${review.rating}',
                                                    '${review.reviewDate}',
                                                    '${review.status}'
                                                )"
                                                data-comment="${review.comment}"
                                                data-bs-toggle="offcanvas"
                                                data-bs-target="#reviewDetailPanel">
                                            <i class="bi bi-eye"></i>
                                        </button>

                                        <%-- Flag / Unflag --%>
                                        <c:choose>
                                            <c:when test="${review.status == 'FLAGGED'}">
                                                <form action="${pageContext.request.contextPath}/manage/reviews/unflag"
                                                      method="POST" style="margin:0;" id="form-unflag-${review.id}">
                                                    <input type="hidden" name="reviewId" value="${review.id}">
                                                    <button type="submit" class="btn-unflag" id="btn-unflag-${review.id}">
                                                        <i class="bi bi-check-circle"></i> Unflag
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:when test="${review.status == 'PUBLISHED'}">
                                                <form action="${pageContext.request.contextPath}/manage/reviews/flag"
                                                      method="POST" style="margin:0;" id="form-flag-${review.id}">
                                                    <input type="hidden" name="reviewId" value="${review.id}">
                                                    <button type="submit" class="btn-flag" id="btn-flag-${review.id}">
                                                        <i class="bi bi-flag-fill"></i> Flag
                                                    </button>
                                                </form>
                                            </c:when>
                                        </c:choose>

                                        <%-- Remove (soft delete — hides from storefront) --%>
                                        <c:if test="${review.status != 'REMOVED'}">
                                            <form action="${pageContext.request.contextPath}/manage/reviews/remove"
                                                  method="POST" style="margin:0;" id="form-remove-${review.id}">
                                                <input type="hidden" name="reviewId" value="${review.id}">
                                                <button type="submit" class="btn-remove-review"
                                                        id="btn-remove-${review.id}"
                                                        onclick="return confirm('Remove this review from the storefront?')">
                                                    <i class="bi bi-eye-slash"></i> Remove
                                                </button>
                                            </form>
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

    <%-- Pagination --%>
    <c:if test="${not empty totalPages && totalPages > 1}">
        <div class="d-flex align-items-center justify-content-between px-3 py-3"
             style="border-top:1px solid #f3f4f6;">
            <span style="font-size:.78rem;color:#9ca3af;">Page ${currentPage} of ${totalPages}</span>
            <div class="d-flex gap-2">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/manage/reviews?page=${currentPage-1}&status=${filterStatus}&q=${searchQuery}"
                       class="btn-action" id="reviews-prev-btn">
                        <i class="bi bi-chevron-left"></i> Prev
                    </a>
                </c:if>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/manage/reviews?page=${currentPage+1}&status=${filterStatus}&q=${searchQuery}"
                       class="btn-action" id="reviews-next-btn">
                        Next <i class="bi bi-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </div>
    </c:if>

</div><%-- /section-card --%>


<%-- ═══════════════════════════════════════════════════════════ --%>
<%-- REVIEW DETAIL — Bootstrap Offcanvas                         --%>
<%-- ═══════════════════════════════════════════════════════════ --%>
<div class="offcanvas offcanvas-end" tabindex="-1"
     id="reviewDetailPanel" style="width:400px;max-width:96vw;"
     aria-labelledby="reviewDetailLabel">

    <div class="offcanvas-header">
        <h5 class="offcanvas-title" id="reviewDetailLabel">
            <i class="bi bi-chat-left-quote-fill me-2" style="color:#fbbf24;"></i>Full Review
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <div class="offcanvas-body">

        <%-- Reviewer info --%>
        <div class="d-flex align-items-center gap-3 mb-4">
            <div style="width:48px;height:48px;border-radius:50%;
                        background:linear-gradient(135deg,#f97316,#ea580c);
                        color:#fff;font-size:1.1rem;font-weight:800;
                        display:flex;align-items:center;justify-content:center;flex-shrink:0;"
                 id="panel-rev-avatar">U</div>
            <div>
                <div style="font-size:.95rem;font-weight:800;color:#111827;" id="panel-rev-name"></div>
                <div style="font-size:.75rem;color:#9ca3af;" id="panel-rev-restaurant"></div>
            </div>
        </div>

        <%-- Stars --%>
        <div class="detail-section-title">Rating</div>
        <div class="d-flex align-items-center gap-2 mb-3">
            <div id="panel-rev-stars" class="d-flex gap-1" style="font-size:1.4rem;"></div>
            <span id="panel-rev-score" style="font-size:1.2rem;font-weight:900;color:#111827;"></span>
            <span style="font-size:.8rem;color:#9ca3af;">/ 5</span>
        </div>

        <%-- Full comment --%>
        <div class="detail-section-title">Review Comment</div>
        <div class="review-full-comment mb-3" id="panel-rev-comment">
            No comment provided.
        </div>

        <%-- Meta --%>
        <div class="detail-section-title">Details</div>
        <div style="font-size:.82rem;color:#6b7280;margin-bottom:.3rem;">
            <i class="bi bi-calendar3 me-1"></i>Submitted: <strong id="panel-rev-date"></strong>
        </div>
        <div style="font-size:.82rem;margin-bottom:1.5rem;">
            Status: <span id="panel-rev-status-badge"></span>
        </div>

        <%-- Actions from panel --%>
        <div id="panel-rev-actions"></div>

    </div>
</div>

<%-- ══════════════════════ PAGE SCRIPTS ══════════════════════ --%>
<script>
    window.openReviewDetail = function(id, customer, restaurant, rating, date, status) {
        /* Get full comment from data attribute of the button that triggered this */
        var btn = document.getElementById('btn-detail-review-' + id);
        var comment = btn ? btn.getAttribute('data-comment') : '';

        /* Avatar */
        var av = document.getElementById('panel-rev-avatar');
        av.textContent = customer ? customer.charAt(0).toUpperCase() : 'U';

        /* Header */
        document.getElementById('panel-rev-name').textContent       = customer   || '—';
        document.getElementById('panel-rev-restaurant').textContent = restaurant || '—';

        /* Stars */
        var starsEl = document.getElementById('panel-rev-stars');
        starsEl.innerHTML = '';
        var r = parseInt(rating) || 0;
        for (var i = 1; i <= 5; i++) {
            starsEl.innerHTML += '<i class="bi bi-star-fill" style="color:' + (i <= r ? '#fbbf24' : '#e5e7eb') + ';"></i>';
        }
        document.getElementById('panel-rev-score').textContent = rating;

        /* Comment */
        document.getElementById('panel-rev-comment').textContent =
            comment ? '"' + comment + '"' : 'No comment provided.';

        /* Date */
        document.getElementById('panel-rev-date').textContent = date || '—';

        /* Status badge */
        var badgeMap = {
            PUBLISHED: '<span style="background:#f0fdf4;color:#15803d;font-size:.72rem;font-weight:700;padding:3px 10px;border-radius:99px;">Published</span>',
            FLAGGED:   '<span style="background:#fef2f2;color:#dc2626;font-size:.72rem;font-weight:700;padding:3px 10px;border-radius:99px;"><i class=\'bi bi-flag-fill me-1\'></i>Flagged</span>',
            REMOVED:   '<span style="background:#f9fafb;color:#6b7280;font-size:.72rem;font-weight:700;padding:3px 10px;border-radius:99px;">Removed</span>'
        };
        document.getElementById('panel-rev-status-badge').innerHTML = badgeMap[status] || badgeMap.PUBLISHED;

        /* Action buttons */
        var ctx = '${pageContext.request.contextPath}';
        var actionsHtml = '';
        if (status === 'PUBLISHED') {
            actionsHtml +=
                '<form action="' + ctx + '/manage/reviews/flag" method="POST" style="margin-bottom:.5rem;">' +
                '<input type="hidden" name="reviewId" value="' + id + '">' +
                '<button type="submit" style="width:100%;font-size:.82rem;font-weight:700;padding:.5rem;border-radius:10px;border:1px solid #fca5a5;background:#fef2f2;color:#dc2626;cursor:pointer;">' +
                '<i class="bi bi-flag-fill me-1"></i>Flag This Review</button></form>';
        }
        if (status === 'FLAGGED') {
            actionsHtml +=
                '<form action="' + ctx + '/manage/reviews/unflag" method="POST" style="margin-bottom:.5rem;">' +
                '<input type="hidden" name="reviewId" value="' + id + '">' +
                '<button type="submit" style="width:100%;font-size:.82rem;font-weight:700;padding:.5rem;border-radius:10px;border:1px solid #86efac;background:#f0fdf4;color:#16a34a;cursor:pointer;">' +
                '<i class="bi bi-check-circle me-1"></i>Unflag Review</button></form>';
        }
        if (status !== 'REMOVED') {
            actionsHtml +=
                '<form action="' + ctx + '/manage/reviews/remove" method="POST">' +
                '<input type="hidden" name="reviewId" value="' + id + '">' +
                '<button type="submit" style="width:100%;font-size:.82rem;font-weight:700;padding:.5rem;border-radius:10px;border:1px solid #e5e7eb;background:#fff;color:#6b7280;cursor:pointer;"' +
                ' onclick="return confirm(\'Remove this review from the storefront?\')">' +
                '<i class="bi bi-eye-slash me-1"></i>Remove from Storefront</button></form>';
        }
        document.getElementById('panel-rev-actions').innerHTML = actionsHtml;
    };
</script>

<jsp:include page="manage-sidebar-close.jsp"/>
