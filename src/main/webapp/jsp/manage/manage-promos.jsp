<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 6 : PROMO CODES & DISCOUNTS  (SUPER_ADMIN only)
    MVC: populated by AdminPromoServlet which sets:
      requestScope.promoCodes      — List<PromoCode>
      requestScope.filterStatus    — String  active | expired | all
      requestScope.stats           — Map: totalCodes, activeCodes, expiredCodes, totalUsed

    Each PromoCode has:
      id, code, discountType (FLAT|PERCENTAGE), discountValue,
      minOrderValue, maxUses, usedCount, expiryDate,
      isActive (boolean), isExpired (boolean), createdDate
--%>
<c:set var="pageTitle" value="Promo Codes"  scope="request"/>
<c:set var="activeNav"  value="promos"       scope="request"/>

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
    .kpi-icon.purple { background:#faf5ff; color:#a855f7; }
    .kpi-icon.green  { background:#f0fdf4; color:#22c55e; }
    .kpi-icon.red    { background:#fef2f2; color:#ef4444; }
    .kpi-icon.orange { background:#fff7ed; color:#f97316; }
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

    /* ── Table ────────────────────────────────────── */
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

    /* ── Promo code pill ──────────────────────────── */
    .code-pill {
        display:inline-flex; align-items:center; gap:.4rem;
        font-family:'Courier New',monospace; font-size:.85rem; font-weight:800;
        background: linear-gradient(135deg,#faf5ff,#f3e8ff);
        color:#7c3aed; padding:5px 14px; border-radius:8px;
        border:1.5px dashed #c4b5fd; letter-spacing:1px;
        cursor:pointer; transition:background .15s;
        user-select:all;
    }
    .code-pill:hover { background:linear-gradient(135deg,#f3e8ff,#ede9fe); }

    /* ── Discount type badge ──────────────────────── */
    .type-badge {
        display:inline-flex; align-items:center; gap:4px;
        font-size:.7rem; font-weight:700; padding:3px 9px; border-radius:99px;
    }
    .type-badge.flat       { background:#fff7ed; color:#c2410c; }
    .type-badge.percentage { background:#faf5ff; color:#7c3aed; }

    /* ── Status badge ─────────────────────────────── */
    .status-badge {
        display:inline-flex; align-items:center; gap:5px;
        font-size:.7rem; font-weight:700; padding:3px 10px;
        border-radius:99px; white-space:nowrap;
    }
    .status-badge::before { content:''; width:6px; height:6px; border-radius:50%; display:inline-block; }
    .status-badge.active  { background:#f0fdf4; color:#15803d; }
    .status-badge.active::before  { background:#22c55e; }
    .status-badge.expired { background:#fef2f2; color:#dc2626; }
    .status-badge.expired::before { background:#ef4444; }
    .status-badge.inactive{ background:#f9fafb; color:#6b7280; }
    .status-badge.inactive::before{ background:#9ca3af; }

    /* ── Usage bar ────────────────────────────────── */
    .usage-wrap { min-width:90px; }
    .usage-bar-bg {
        width:100%; height:6px; background:#f3f4f6;
        border-radius:99px; overflow:hidden; margin-top:4px;
    }
    .usage-bar-fill {
        height:100%; border-radius:99px;
        background:linear-gradient(90deg,#f97316,#ea580c);
        transition:width .3s;
    }
    .usage-label { font-size:.72rem; color:#6b7280; white-space:nowrap; }

    /* ── Expiry indicator ─────────────────────────── */
    .expiry-chip {
        font-size:.75rem; font-weight:600; white-space:nowrap;
    }
    .expiry-chip.soon { color:#ca8a04; }
    .expiry-chip.ok   { color:#374151; }
    .expiry-chip.gone { color:#dc2626; text-decoration:line-through; }

    /* ── Action buttons ───────────────────────────── */
    .btn-action {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #e5e7eb; background:#fff; color:#374151;
        text-decoration:none; transition:border-color .15s, color .15s;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
    }
    .btn-action:hover { border-color:#f97316; color:#f97316; }
    .btn-deactivate {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #fca5a5; background:#fef2f2; color:#dc2626;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
        transition:background .15s;
    }
    .btn-deactivate:hover { background:#fee2e2; }
    .btn-activate-promo {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #86efac; background:#f0fdf4; color:#16a34a;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
        transition:background .15s;
    }
    .btn-activate-promo:hover { background:#dcfce7; }
    .btn-delete-promo {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #e5e7eb; background:#fff; color:#6b7280;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
        transition:border-color .15s, color .15s;
    }
    .btn-delete-promo:hover { border-color:#ef4444; color:#ef4444; }

    /* ── Create code button ───────────────────────── */
    .btn-create-promo {
        font-size:.82rem; font-weight:700; padding:.5rem 1.1rem; border-radius:10px;
        background:#7c3aed; color:#fff; border:none; cursor:pointer;
        transition:background .15s; display:inline-flex; align-items:center; gap:.4rem;
        text-decoration:none;
    }
    .btn-create-promo:hover { background:#6d28d9; color:#fff; }

    /* ── Filter bar ───────────────────────────────── */
    .filter-bar { display:flex; align-items:center; gap:.6rem; flex-wrap:wrap; }
    .filter-bar .form-control,
    .filter-bar .form-select {
        font-size:.82rem; border-radius:9px; border:1px solid #e5e7eb;
        padding:.42rem .85rem; background:#f9fafb;
    }
    .filter-bar .form-control:focus,
    .filter-bar .form-select:focus { border-color:#7c3aed; box-shadow:0 0 0 3px rgba(124,58,237,.08); }
    .filter-bar .btn-search {
        font-size:.82rem; font-weight:600; padding:.42rem 1rem;
        border-radius:9px; background:#7c3aed; color:#fff; border:none; cursor:pointer;
    }
    .filter-bar .btn-search:hover { background:#6d28d9; }

    /* ── Status filter tabs ───────────────────────── */
    .status-tabs { display:flex; gap:.4rem; flex-wrap:wrap; margin-bottom:.5rem; }
    .status-tab {
        font-size:.78rem; font-weight:600; padding:5px 14px;
        border-radius:99px; border:1px solid #e5e7eb;
        background:#fff; color:#6b7280; text-decoration:none;
        transition:all .15s; white-space:nowrap;
    }
    .status-tab:hover { border-color:#7c3aed; color:#7c3aed; }
    .status-tab.active { background:#7c3aed; color:#fff; border-color:#7c3aed; }

    /* ── Empty state ──────────────────────────────── */
    .empty-state { text-align:center; padding:3.5rem 1rem; }
    .empty-state i { font-size:2.8rem; color:#e5e7eb; display:block; margin-bottom:1rem; }
    .empty-state p { font-size:.85rem; font-weight:600; color:#9ca3af; margin:0; }

    /* ── Modal ────────────────────────────────────── */
    .modal-content { border-radius:16px; border:none; box-shadow:0 25px 60px rgba(0,0,0,.15); }
    .modal-header  { border-bottom:1px solid #f3f4f6; padding:1.1rem 1.4rem; }
    .modal-footer  { border-top:1px solid #f3f4f6; padding:.85rem 1.4rem; }
    .modal-title   { font-size:1rem; font-weight:800; color:#111827; }
    .form-label {
        font-size:.72rem; font-weight:700; color:#6b7280;
        text-transform:uppercase; letter-spacing:.4px;
    }
    .form-control, .form-select {
        font-size:.85rem; border-radius:10px; border:1px solid #e5e7eb; padding:.55rem .9rem;
    }
    .form-control:focus, .form-select:focus {
        border-color:#7c3aed; box-shadow:0 0 0 3px rgba(124,58,237,.1);
    }
    .btn-modal-save {
        font-size:.85rem; font-weight:700; padding:.55rem 1.4rem;
        border-radius:10px; background:#7c3aed; color:#fff; border:none; cursor:pointer;
    }
    .btn-modal-save:hover { background:#6d28d9; }
    .btn-modal-cancel {
        font-size:.85rem; font-weight:600; padding:.55rem 1.2rem;
        border-radius:10px; background:#f9fafb; color:#374151;
        border:1px solid #e5e7eb; cursor:pointer;
    }

    /* Discount preview box */
    .discount-preview {
        background:linear-gradient(135deg,#faf5ff,#f3e8ff);
        border:1px solid #c4b5fd; border-radius:12px;
        padding:1rem 1.25rem; text-align:center;
        font-size:1.5rem; font-weight:900; color:#7c3aed;
        transition:all .2s;
    }
    .discount-preview small { display:block; font-size:.72rem; font-weight:600;
                              color:#a855f7; margin-top:.15rem; }

    /* Copied toast */
    #copy-toast {
        position:fixed; bottom:1.5rem; right:1.5rem;
        background:#111827; color:#fff; font-size:.8rem; font-weight:600;
        padding:.55rem 1.1rem; border-radius:10px; z-index:9999;
        opacity:0; transition:opacity .2s; pointer-events:none;
    }
    #copy-toast.show { opacity:1; }

    /* Expired row tint */
    .manage-table tbody tr.row-expired td { opacity:.6; }
</style>

<%-- ══════════════════════ PAGE HEADER ══════════════════════ --%>
<div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
    <div>
        <h1 class="fw-bold mb-1" style="font-size:1.4rem;color:#111827;">Promo Codes &amp; Discounts</h1>
        <p class="text-muted mb-0" style="font-size:.82rem;">
            Create and manage discount codes used at checkout.
        </p>
    </div>
    <button class="btn-create-promo" data-bs-toggle="modal" data-bs-target="#createPromoModal"
            id="btn-open-create-promo">
        <i class="bi bi-plus-circle-fill"></i> Create Promo Code
    </button>
</div>

<%-- ══════════════════════ KPI STRIP ══════════════════════ --%>
<div class="kpi-strip">
    <div class="kpi-tile">
        <div class="kpi-icon purple"><i class="bi bi-tags-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.totalCodes ? stats.totalCodes : '0'}</div>
            <div class="kpi-label">Total Codes</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon green"><i class="bi bi-check-circle-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.activeCodes ? stats.activeCodes : '0'}</div>
            <div class="kpi-label">Active</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon red"><i class="bi bi-calendar-x-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.expiredCodes ? stats.expiredCodes : '0'}</div>
            <div class="kpi-label">Expired</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon orange"><i class="bi bi-graph-up-arrow"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.totalUsed ? stats.totalUsed : '0'}</div>
            <div class="kpi-label">Total Uses</div>
        </div>
    </div>
</div>

<%-- ══════════════════════ PROMO TABLE CARD ══════════════════════ --%>
<div class="section-card" id="manage-promos-card">

    <div class="section-card-header flex-column flex-md-row align-items-start align-items-md-center">
        <h2 class="section-card-title">
            <i class="bi bi-tags-fill me-2" style="color:#7c3aed;"></i>All Promo Codes
        </h2>

        <form action="${pageContext.request.contextPath}/manage/promos"
              method="GET" class="filter-bar ms-md-auto mt-2 mt-md-0" id="promos-filter-form">
            <input type="text" name="q" placeholder="Search code…"
                   value="${not empty searchQuery ? searchQuery : ''}"
                   class="form-control" style="min-width:160px;max-width:200px;"
                   id="promos-search-input">
            <button type="submit" class="btn-search" id="promos-search-btn">
                <i class="bi bi-search me-1"></i>Search
            </button>
        </form>
    </div>

    <%-- Status filter tabs --%>
    <div class="px-3 pt-3 pb-1">
        <div class="status-tabs" id="promos-status-tabs">
            <a href="${pageContext.request.contextPath}/manage/promos"
               class="status-tab ${empty filterStatus || filterStatus == 'all' ? 'active' : ''}"
               id="promo-tab-all">All</a>
            <a href="${pageContext.request.contextPath}/manage/promos?status=active"
               class="status-tab ${filterStatus == 'active' ? 'active' : ''}"
               id="promo-tab-active">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#22c55e;"></i>Active</a>
            <a href="${pageContext.request.contextPath}/manage/promos?status=expired"
               class="status-tab ${filterStatus == 'expired' ? 'active' : ''}"
               id="promo-tab-expired">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#ef4444;"></i>Expired</a>
            <a href="${pageContext.request.contextPath}/manage/promos?status=inactive"
               class="status-tab ${filterStatus == 'inactive' ? 'active' : ''}"
               id="promo-tab-inactive">
               <i class="bi bi-circle-fill me-1" style="font-size:.45rem;color:#9ca3af;"></i>Deactivated</a>
        </div>
    </div>

    <%-- Table --%>
    <div class="table-responsive">
        <c:choose>
            <c:when test="${empty promoCodes}">
                <div class="empty-state" id="promos-empty-state">
                    <i class="bi bi-tags"></i>
                    <p>No promo codes yet. Create your first one above.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table manage-table" id="manage-promos-table">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Type</th>
                            <th>Discount</th>
                            <th>Min. Order</th>
                            <th>Usage</th>
                            <th>Expiry</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${promoCodes}" var="promo">
                            <tr id="promo-row-${promo.id}"
                                class="${promo.isExpired ? 'row-expired' : ''}">

                                <%-- Code pill (click to copy) --%>
                                <td>
                                    <span class="code-pill" id="promo-code-${promo.id}"
                                          onclick="copyCode('${promo.code}')"
                                          title="Click to copy">
                                        <i class="bi bi-clipboard" style="font-size:.7rem;"></i>
                                        ${promo.code}
                                    </span>
                                </td>

                                <%-- Type badge --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${promo.discountType == 'FLAT'}">
                                            <span class="type-badge flat">
                                                <i class="bi bi-currency-rupee"></i>Flat
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="type-badge percentage">
                                                <i class="bi bi-percent"></i>Percentage
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Discount value --%>
                                <td>
                                    <span style="font-size:1.1rem;font-weight:800;color:#7c3aed;">
                                        <c:choose>
                                            <c:when test="${promo.discountType == 'FLAT'}">
                                                ₹<fmt:formatNumber value="${promo.discountValue}" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>
                                                ${promo.discountValue}%
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>

                                <%-- Min order value --%>
                                <td style="font-weight:600;">
                                    <c:choose>
                                        <c:when test="${promo.minOrderValue > 0}">
                                            ₹<fmt:formatNumber value="${promo.minOrderValue}" maxFractionDigits="0"/>
                                        </c:when>
                                        <c:otherwise><span style="color:#d1d5db;">No min</span></c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Usage bar --%>
                                <td>
                                    <div class="usage-wrap">
                                        <div class="usage-label">
                                            ${promo.usedCount} / ${promo.maxUses > 0 ? promo.maxUses : '∞'}
                                        </div>
                                        <c:if test="${promo.maxUses > 0}">
                                            <div class="usage-bar-bg">
                                                <div class="usage-bar-fill"
                                                     style="width:${(promo.usedCount / promo.maxUses) * 100}%;"></div>
                                            </div>
                                        </c:if>
                                    </div>
                                </td>

                                <%-- Expiry --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${promo.isExpired}">
                                            <span class="expiry-chip gone">
                                                <i class="bi bi-calendar-x me-1"></i>${promo.expiryDate}
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="expiry-chip ok">
                                                <i class="bi bi-calendar-check me-1" style="color:#22c55e;"></i>${promo.expiryDate}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Status --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${promo.isExpired}">
                                            <span class="status-badge expired">Expired</span>
                                        </c:when>
                                        <c:when test="${promo.isActive}">
                                            <span class="status-badge active">Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge inactive">Deactivated</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Created date --%>
                                <td style="font-size:.76rem;color:#9ca3af;white-space:nowrap;">
                                    ${promo.createdDate}
                                </td>

                                <%-- Actions --%>
                                <td>
                                    <div class="d-flex gap-2 align-items-center flex-wrap">

                                        <%-- Edit --%>
                                        <c:if test="${!promo.isExpired}">
                                            <button type="button" class="btn-action"
                                                    id="btn-edit-promo-${promo.id}"
                                                    onclick="openEditPromoModal(
                                                        '${promo.id}','${promo.code}',
                                                        '${promo.discountType}','${promo.discountValue}',
                                                        '${promo.minOrderValue}','${promo.maxUses}',
                                                        '${promo.expiryDate}'
                                                    )"
                                                    data-bs-toggle="modal" data-bs-target="#editPromoModal">
                                                <i class="bi bi-pencil-fill"></i> Edit
                                            </button>
                                        </c:if>

                                        <%-- Deactivate / Activate --%>
                                        <c:if test="${!promo.isExpired}">
                                            <c:choose>
                                                <c:when test="${promo.isActive}">
                                                    <form action="${pageContext.request.contextPath}/manage/promos/deactivate"
                                                          method="POST" style="margin:0;" id="form-deact-${promo.id}">
                                                        <input type="hidden" name="promoId" value="${promo.id}">
                                                        <button type="submit" class="btn-deactivate"
                                                                id="btn-deact-${promo.id}"
                                                                onclick="return confirm('Deactivate ${promo.code}? Customers can no longer use it.')">
                                                            <i class="bi bi-pause-circle"></i> Deactivate
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="${pageContext.request.contextPath}/manage/promos/activate"
                                                          method="POST" style="margin:0;" id="form-act-${promo.id}">
                                                        <input type="hidden" name="promoId" value="${promo.id}">
                                                        <button type="submit" class="btn-activate-promo"
                                                                id="btn-act-${promo.id}">
                                                            <i class="bi bi-play-circle"></i> Activate
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>

                                        <%-- Delete --%>
                                        <form action="${pageContext.request.contextPath}/manage/promos/delete"
                                              method="POST" style="margin:0;" id="form-del-promo-${promo.id}">
                                            <input type="hidden" name="promoId" value="${promo.id}">
                                            <button type="submit" class="btn-delete-promo"
                                                    id="btn-del-promo-${promo.id}"
                                                    onclick="return confirm('Delete promo code ${promo.code}? This action cannot be undone.')">
                                                <i class="bi bi-trash3"></i>
                                            </button>
                                        </form>

                                    </div>
                                </td>

                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>


<%-- ═══════════════════════════════════════════════════════════ --%>
<%-- MODAL : CREATE PROMO CODE                                   --%>
<%-- ═══════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="createPromoModal" tabindex="-1"
     aria-labelledby="createPromoLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="createPromoLabel">
                    <i class="bi bi-plus-circle-fill me-2" style="color:#7c3aed;"></i>Create Promo Code
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/manage/promos/create"
                  method="POST" id="create-promo-form">
                <div class="modal-body p-4">
                    <div class="row g-3">

                        <%-- Live preview --%>
                        <div class="col-12">
                            <div class="discount-preview" id="create-preview">
                                — off
                                <small>Enter discount details below</small>
                            </div>
                        </div>

                        <%-- Promo Code --%>
                        <div class="col-12 col-md-6">
                            <label for="create-code" class="form-label">Promo Code *</label>
                            <input type="text" id="create-code" name="code" required
                                   placeholder="e.g. SAVE50, WELCOME20"
                                   class="form-control"
                                   style="font-family:'Courier New',monospace;font-weight:800;
                                          letter-spacing:1px;text-transform:uppercase;"
                                   oninput="this.value=this.value.toUpperCase().replace(/\s/g,'')">
                            <div class="form-text">Letters, numbers, no spaces.</div>
                        </div>

                        <%-- Discount Type --%>
                        <div class="col-12 col-md-3">
                            <label for="create-type" class="form-label">Discount Type *</label>
                            <select id="create-type" name="discountType" required
                                    class="form-select" onchange="updatePreview()">
                                <option value="FLAT">₹ Flat Amount</option>
                                <option value="PERCENTAGE">% Percentage</option>
                            </select>
                        </div>

                        <%-- Discount Value --%>
                        <div class="col-12 col-md-3">
                            <label for="create-value" class="form-label">Discount Value *</label>
                            <input type="number" id="create-value" name="discountValue"
                                   required min="0" step="0.01" placeholder="0"
                                   class="form-control" oninput="updatePreview()">
                        </div>

                        <%-- Min Order Value --%>
                        <div class="col-12 col-md-4">
                            <label for="create-min" class="form-label">Min. Order Value (₹)</label>
                            <input type="number" id="create-min" name="minOrderValue"
                                   min="0" step="0.01" placeholder="0 = no minimum"
                                   class="form-control">
                        </div>

                        <%-- Max Uses --%>
                        <div class="col-12 col-md-4">
                            <label for="create-maxuses" class="form-label">Max Uses</label>
                            <input type="number" id="create-maxuses" name="maxUses"
                                   min="0" placeholder="0 = unlimited"
                                   class="form-control">
                        </div>

                        <%-- Expiry Date --%>
                        <div class="col-12 col-md-4">
                            <label for="create-expiry" class="form-label">Expiry Date *</label>
                            <input type="date" id="create-expiry" name="expiryDate"
                                   required class="form-control">
                        </div>

                        <%-- Active immediately toggle --%>
                        <div class="col-12">
                            <div class="d-flex align-items-center gap-2">
                                <input type="checkbox" class="form-check-input"
                                       id="create-active" name="isActive" checked
                                       style="width:38px;height:20px;cursor:pointer;border-radius:99px;">
                                <label for="create-active" class="fw-semibold"
                                       style="font-size:.85rem;cursor:pointer;">
                                    Activate immediately (customers can use this code right away)
                                </label>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-modal-cancel" data-bs-dismiss="modal"
                            id="create-promo-cancel-btn">Cancel</button>
                    <button type="submit" class="btn-modal-save" id="create-promo-save-btn">
                        <i class="bi bi-tags-fill me-1"></i>Create Code
                    </button>
                </div>
            </form>

        </div>
    </div>
</div>

<%-- ═══════════════════════════════════════════════════════════ --%>
<%-- MODAL : EDIT PROMO CODE                                     --%>
<%-- ═══════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="editPromoModal" tabindex="-1"
     aria-labelledby="editPromoLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="editPromoLabel">
                    <i class="bi bi-pencil-fill me-2" style="color:#2563eb;"></i>
                    Edit Promo Code — <span id="edit-promo-code-label" style="color:#7c3aed;font-family:'Courier New',monospace;"></span>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/manage/promos/edit"
                  method="POST" id="edit-promo-form">
                <input type="hidden" id="edit-promo-id" name="promoId">
                <div class="modal-body p-4">
                    <div class="row g-3">

                        <div class="col-12">
                            <div class="discount-preview" id="edit-preview">— off</div>
                        </div>

                        <div class="col-12 col-md-6">
                            <label for="edit-code" class="form-label">Promo Code *</label>
                            <input type="text" id="edit-code" name="code" required
                                   class="form-control"
                                   style="font-family:'Courier New',monospace;font-weight:800;
                                          letter-spacing:1px;text-transform:uppercase;"
                                   oninput="this.value=this.value.toUpperCase().replace(/\s/g,'')">
                        </div>

                        <div class="col-12 col-md-3">
                            <label for="edit-type" class="form-label">Type *</label>
                            <select id="edit-type" name="discountType" required
                                    class="form-select" onchange="updateEditPreview()">
                                <option value="FLAT">₹ Flat Amount</option>
                                <option value="PERCENTAGE">% Percentage</option>
                            </select>
                        </div>

                        <div class="col-12 col-md-3">
                            <label for="edit-value" class="form-label">Value *</label>
                            <input type="number" id="edit-value" name="discountValue"
                                   required min="0" step="0.01" class="form-control"
                                   oninput="updateEditPreview()">
                        </div>

                        <div class="col-12 col-md-4">
                            <label for="edit-min" class="form-label">Min. Order (₹)</label>
                            <input type="number" id="edit-min" name="minOrderValue"
                                   min="0" step="0.01" class="form-control">
                        </div>

                        <div class="col-12 col-md-4">
                            <label for="edit-maxuses" class="form-label">Max Uses</label>
                            <input type="number" id="edit-maxuses" name="maxUses"
                                   min="0" class="form-control">
                        </div>

                        <div class="col-12 col-md-4">
                            <label for="edit-expiry" class="form-label">Expiry Date *</label>
                            <input type="date" id="edit-expiry" name="expiryDate"
                                   required class="form-control">
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-modal-cancel" data-bs-dismiss="modal"
                            id="edit-promo-cancel-btn">Cancel</button>
                    <button type="submit" class="btn-modal-save" id="edit-promo-save-btn"
                            style="background:#2563eb;">
                        <i class="bi bi-save me-1"></i>Save Changes
                    </button>
                </div>
            </form>

        </div>
    </div>
</div>

<%-- Copy toast notification --%>
<div id="copy-toast"><i class="bi bi-check-circle me-1"></i>Code copied!</div>

<%-- ══════════════════════ PAGE SCRIPTS ══════════════════════ --%>
<script>
    /* ── Discount preview updater ── */
    function updatePreview() {
        var type  = document.getElementById('create-type').value;
        var value = document.getElementById('create-value').value;
        var box   = document.getElementById('create-preview');
        if (!value) { box.innerHTML = '— off<small>Enter discount details below</small>'; return; }
        box.innerHTML = (type === 'FLAT' ? '₹' + parseFloat(value).toFixed(0) : parseFloat(value).toFixed(0) + '%')
                      + ' OFF<small>Discount applied at checkout</small>';
    }

    function updateEditPreview() {
        var type  = document.getElementById('edit-type').value;
        var value = document.getElementById('edit-value').value;
        var box   = document.getElementById('edit-preview');
        if (!value) { box.innerHTML = '— off'; return; }
        box.innerHTML = (type === 'FLAT' ? '₹' + parseFloat(value).toFixed(0) : parseFloat(value).toFixed(0) + '%')
                      + ' OFF<small>Discount applied at checkout</small>';
    }

    /* ── Pre-fill Edit modal ── */
    function openEditPromoModal(id, code, type, value, min, maxUses, expiry) {
        document.getElementById('edit-promo-id').value        = id;
        document.getElementById('edit-code').value            = code;
        document.getElementById('edit-type').value            = type;
        document.getElementById('edit-value').value           = value;
        document.getElementById('edit-min').value             = min;
        document.getElementById('edit-maxuses').value         = maxUses;
        document.getElementById('edit-expiry').value          = expiry;
        document.getElementById('edit-promo-code-label').textContent = code;
        updateEditPreview();
    }

    /* ── Copy to clipboard ── */
    function copyCode(code) {
        navigator.clipboard.writeText(code).then(function() {
            var toast = document.getElementById('copy-toast');
            toast.classList.add('show');
            setTimeout(function() { toast.classList.remove('show'); }, 2000);
        });
    }

    /* ── Set min expiry date to today ── */
    (function() {
        var today = new Date().toISOString().split('T')[0];
        var createExpiry = document.getElementById('create-expiry');
        if (createExpiry) createExpiry.min = today;
    })();
</script>

<jsp:include page="manage-sidebar-close.jsp"/>
