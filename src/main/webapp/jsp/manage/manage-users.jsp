<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 5 : USER MANAGEMENT  (SUPER_ADMIN only)
    MVC: populated by AdminUserServlet which sets:
      requestScope.users           — List<User>
      requestScope.filterRole      — String   active role filter
      requestScope.searchQuery     — String
      requestScope.currentPage     — int
      requestScope.totalPages      — int
      requestScope.stats           — Map: totalCustomers, totalOwners, totalAdmins, bannedCount

    Each User has:
      id, fullName, email, phone, role (CUSTOMER|RESTAURANT_OWNER|SUPER_ADMIN),
      registeredDate, totalOrders, totalSpend, isBanned (boolean),
      restaurantName (if RESTAURANT_OWNER)
--%>
<c:set var="pageTitle" value="User Management" scope="request"/>
<c:set var="activeNav"  value="users"           scope="request"/>

<jsp:include page="manage-sidebar.jsp"/>

<%-- ══════════════════════ PAGE-SCOPED STYLES ══════════════════════ --%>
<style>
    /* ── KPI Strip ────────────────────────────────── */
    .kpi-strip {
        display:grid;
        grid-template-columns:repeat(auto-fit,minmax(150px,1fr));
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
    .kpi-icon.blue   { background:#eff6ff; color:#3b82f6; }
    .kpi-icon.green  { background:#f0fdf4; color:#22c55e; }
    .kpi-icon.orange { background:#fff7ed; color:#f97316; }
    .kpi-icon.red    { background:#fef2f2; color:#ef4444; }
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

    /* ── User chip ────────────────────────────────── */
    .user-chip { display:flex; align-items:center; gap:.65rem; }
    .user-avatar {
        width:38px; height:38px; border-radius:50%;
        display:flex; align-items:center; justify-content:center;
        font-size:.85rem; font-weight:800; color:#fff; flex-shrink:0;
    }
    .user-avatar.customer { background:linear-gradient(135deg,#3b82f6,#2563eb); }
    .user-avatar.owner    { background:linear-gradient(135deg,#22c55e,#16a34a); }
    .user-avatar.admin    { background:linear-gradient(135deg,#f97316,#ea580c); }
    .user-avatar.banned   { background:linear-gradient(135deg,#ef4444,#dc2626); }
    .user-name  { font-weight:700; color:#111827; font-size:.85rem; }
    .user-email { font-size:.72rem; color:#9ca3af; }

    /* ── Role badges ──────────────────────────────── */
    .role-badge {
        display:inline-flex; align-items:center; gap:4px;
        font-size:.7rem; font-weight:700; padding:3px 10px;
        border-radius:99px; white-space:nowrap;
    }
    .role-badge.customer { background:#eff6ff; color:#2563eb; }
    .role-badge.owner    { background:#f0fdf4; color:#15803d; }
    .role-badge.admin    { background:#fff7ed; color:#c2410c; }

    /* ── Status badges ────────────────────────────── */
    .status-badge {
        display:inline-flex; align-items:center; gap:5px;
        font-size:.7rem; font-weight:700; padding:3px 10px;
        border-radius:99px; white-space:nowrap;
    }
    .status-badge::before { content:''; width:6px; height:6px; border-radius:50%; display:inline-block; }
    .status-badge.active  { background:#f0fdf4; color:#15803d; }
    .status-badge.active::before  { background:#22c55e; }
    .status-badge.banned  { background:#fef2f2; color:#dc2626; }
    .status-badge.banned::before  { background:#ef4444; }

    /* ── Action buttons ───────────────────────────── */
    .btn-action {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #e5e7eb; background:#fff; color:#374151;
        text-decoration:none; transition:border-color .15s, color .15s;
        display:inline-flex; align-items:center; gap:4px;
        white-space:nowrap; cursor:pointer;
    }
    .btn-action:hover { border-color:#f97316; color:#f97316; }

    .btn-ban {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #fca5a5; background:#fef2f2; color:#dc2626;
        text-decoration:none; transition:background .15s;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
    }
    .btn-ban:hover { background:#fee2e2; }

    .btn-unban {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #86efac; background:#f0fdf4; color:#16a34a;
        text-decoration:none; transition:background .15s;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
    }
    .btn-unban:hover { background:#dcfce7; }

    .btn-promote {
        font-size:.75rem; font-weight:600; padding:4px 10px; border-radius:7px;
        border:1px solid #a5b4fc; background:#eef2ff; color:#4338ca;
        text-decoration:none; transition:background .15s;
        display:inline-flex; align-items:center; gap:4px; white-space:nowrap; cursor:pointer;
    }
    .btn-promote:hover { background:#e0e7ff; }

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

    /* ── Role filter tabs ─────────────────────────── */
    .role-tabs { display:flex; gap:.4rem; flex-wrap:wrap; }
    .role-tab {
        font-size:.78rem; font-weight:600; padding:5px 14px;
        border-radius:99px; border:1px solid #e5e7eb;
        background:#fff; color:#6b7280; text-decoration:none;
        transition:all .15s; white-space:nowrap;
    }
    .role-tab:hover { border-color:#f97316; color:#f97316; }
    .role-tab.active { background:#f97316; color:#fff; border-color:#f97316; }

    /* ── Empty state ──────────────────────────────── */
    .empty-state { text-align:center; padding:3.5rem 1rem; }
    .empty-state i { font-size:2.8rem; color:#e5e7eb; display:block; margin-bottom:1rem; }
    .empty-state p { font-size:.85rem; font-weight:600; color:#9ca3af; margin:0; }

    /* ── Offcanvas user detail ─────────────────────── */
    .offcanvas { font-family:'Outfit',sans-serif; }
    .offcanvas-header { border-bottom:1px solid #f3f4f6; padding:1.1rem 1.4rem; }
    .offcanvas-title  { font-size:1rem; font-weight:800; color:#111827; }
    .offcanvas-body   { padding:1.25rem 1.4rem; }

    .detail-section-title {
        font-size:.68rem; font-weight:800; letter-spacing:.8px;
        text-transform:uppercase; color:#9ca3af; margin-bottom:.5rem;
    }
    .detail-info-row {
        display:flex; justify-content:space-between; align-items:center;
        padding:.45rem 0; border-bottom:1px solid #f9fafb; font-size:.83rem;
    }
    .detail-info-row:last-child { border-bottom:none; }
    .detail-info-row .key { color:#6b7280; font-weight:500; }
    .detail-info-row .val { font-weight:700; color:#111827; }

    /* Stat boxes inside offcanvas */
    .user-stat-grid { display:grid; grid-template-columns:1fr 1fr; gap:.6rem; margin:.75rem 0; }
    .user-stat-box {
        background:#f9fafb; border:1px solid #f3f4f6; border-radius:10px;
        padding:.75rem; text-align:center;
    }
    .user-stat-box .val { font-size:1.25rem; font-weight:800; color:#111827; }
    .user-stat-box .lbl { font-size:.68rem; color:#9ca3af; font-weight:600; text-transform:uppercase; }

    /* Promote role form inside offcanvas */
    .form-label-sm {
        font-size:.72rem; font-weight:700; color:#6b7280;
        text-transform:uppercase; letter-spacing:.4px;
    }
    .form-select-sm-custom {
        font-size:.82rem; border-radius:10px; border:1px solid #e5e7eb;
        padding:.5rem .85rem; width:100%;
    }
    .form-select-sm-custom:focus { border-color:#f97316; box-shadow:0 0 0 3px rgba(249,115,22,.1); outline:none; }

    .btn-save-role {
        font-size:.82rem; font-weight:700; padding:.5rem 1.2rem;
        border-radius:10px; background:#4338ca; color:#fff;
        border:none; cursor:pointer; transition:background .15s; width:100%; margin-top:.4rem;
    }
    .btn-save-role:hover { background:#3730a3; }

    .btn-panel-ban {
        font-size:.82rem; font-weight:700; padding:.5rem 1.2rem;
        border-radius:10px; background:#fef2f2; color:#dc2626;
        border:1px solid #fca5a5; cursor:pointer; transition:background .15s; width:100%; margin-top:.4rem;
    }
    .btn-panel-ban:hover { background:#fee2e2; }

    .btn-panel-unban {
        font-size:.82rem; font-weight:700; padding:.5rem 1.2rem;
        border-radius:10px; background:#f0fdf4; color:#16a34a;
        border:1px solid #86efac; cursor:pointer; transition:background .15s; width:100%; margin-top:.4rem;
    }
    .btn-panel-unban:hover { background:#dcfce7; }

    /* Banned row tint */
    .manage-table tbody tr.row-banned td { opacity:.65; background:#fef9f9; }
</style>

<%-- ══════════════════════ PAGE HEADER ══════════════════════ --%>
<div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
    <div>
        <h1 class="fw-bold mb-1" style="font-size:1.4rem;color:#111827;">User Management</h1>
        <p class="text-muted mb-0" style="font-size:.82rem;">
            View, ban, and manage roles for all registered users on the platform.
        </p>
    </div>
</div>

<%-- ══════════════════════ KPI STRIP ══════════════════════ --%>
<div class="kpi-strip">
    <div class="kpi-tile">
        <div class="kpi-icon blue"><i class="bi bi-people-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.totalCustomers ? stats.totalCustomers : '0'}</div>
            <div class="kpi-label">Customers</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon green"><i class="bi bi-shop-window"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.totalOwners ? stats.totalOwners : '0'}</div>
            <div class="kpi-label">Restaurant Owners</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon orange"><i class="bi bi-shield-fill-check"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.totalAdmins ? stats.totalAdmins : '0'}</div>
            <div class="kpi-label">Super Admins</div>
        </div>
    </div>
    <div class="kpi-tile">
        <div class="kpi-icon red"><i class="bi bi-slash-circle-fill"></i></div>
        <div>
            <div class="kpi-value">${not empty stats.bannedCount ? stats.bannedCount : '0'}</div>
            <div class="kpi-label">Banned</div>
        </div>
    </div>
</div>

<%-- ══════════════════════ USER TABLE CARD ══════════════════════ --%>
<div class="section-card" id="manage-users-card">

    <div class="section-card-header flex-column flex-lg-row align-items-start align-items-lg-center">
        <h2 class="section-card-title">
            <i class="bi bi-people-fill me-2" style="color:#3b82f6;"></i>All Users
        </h2>

        <%-- Search + Filter bar --%>
        <form action="${pageContext.request.contextPath}/manage/users"
              method="GET" class="filter-bar ms-lg-auto mt-2 mt-lg-0" id="users-filter-form">

            <c:if test="${not empty filterRole}">
                <input type="hidden" name="role" value="${filterRole}">
            </c:if>

            <input type="text" name="q" placeholder="Search name or email…"
                   value="${not empty searchQuery ? searchQuery : ''}"
                   class="form-control" style="min-width:200px;max-width:250px;"
                   id="users-search-input">

            <select name="status" class="form-select" style="width:auto;" id="users-status-filter">
                <option value="">All Status</option>
                <option value="active" ${param.status == 'active' ? 'selected' : ''}>Active</option>
                <option value="banned" ${param.status == 'banned' ? 'selected' : ''}>Banned</option>
            </select>

            <button type="submit" class="btn-search" id="users-search-btn">
                <i class="bi bi-search me-1"></i>Search
            </button>

            <c:if test="${not empty searchQuery}">
                <a href="${pageContext.request.contextPath}/manage/users${not empty filterRole ? '?role='.concat(filterRole) : ''}"
                   class="btn-action" id="users-clear-btn">
                    <i class="bi bi-x"></i> Clear
                </a>
            </c:if>
        </form>
    </div>

    <%-- Role filter tabs --%>
    <div class="px-3 pt-3 pb-1">
        <div class="role-tabs" id="users-role-tabs">
            <a href="${pageContext.request.contextPath}/manage/users"
               class="role-tab ${empty filterRole ? 'active' : ''}" id="role-tab-all">All Users</a>
            <a href="${pageContext.request.contextPath}/manage/users?role=CUSTOMER"
               class="role-tab ${filterRole == 'CUSTOMER' ? 'active' : ''}" id="role-tab-customer">
               <i class="bi bi-person-fill me-1"></i>Customers</a>
            <a href="${pageContext.request.contextPath}/manage/users?role=RESTAURANT_OWNER"
               class="role-tab ${filterRole == 'RESTAURANT_OWNER' ? 'active' : ''}" id="role-tab-owner">
               <i class="bi bi-shop me-1"></i>Restaurant Owners</a>
            <a href="${pageContext.request.contextPath}/manage/users?role=SUPER_ADMIN"
               class="role-tab ${filterRole == 'SUPER_ADMIN' ? 'active' : ''}" id="role-tab-admin">
               <i class="bi bi-shield-fill-check me-1"></i>Admins</a>
            <a href="${pageContext.request.contextPath}/manage/users?status=banned"
               class="role-tab ${param.status == 'banned' ? 'active' : ''}" id="role-tab-banned"
               style="${param.status == 'banned' ? '' : 'border-color:#fca5a5;color:#dc2626;'}">
               <i class="bi bi-slash-circle me-1"></i>Banned</a>
        </div>
    </div>

    <%-- Table --%>
    <div class="table-responsive">
        <c:choose>
            <c:when test="${empty users}">
                <div class="empty-state" id="users-empty-state">
                    <i class="bi bi-people"></i>
                    <p>No users found for this filter.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table manage-table" id="manage-users-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>User</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Restaurant</th>
                            <th>Joined</th>
                            <th>Orders</th>
                            <th>Spent</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${users}" var="user" varStatus="loop">
                            <tr id="user-row-${user.id}"
                                class="${user.isBanned ? 'row-banned' : ''}">

                                <%-- Row number --%>
                                <td style="color:#9ca3af;font-size:.76rem;">${loop.index + 1}</td>

                                <%-- User chip --%>
                                <td>
                                    <div class="user-chip">
                                        <div class="user-avatar ${user.isBanned ? 'banned' : (user.role == 'SUPER_ADMIN' ? 'admin' : (user.role == 'RESTAURANT_OWNER' ? 'owner' : 'customer'))}">
                                            ${not empty user.fullName ? user.fullName.substring(0,1).toUpperCase() : 'U'}
                                        </div>
                                        <div>
                                            <div class="user-name">${user.fullName}</div>
                                            <div class="user-email">${user.email}</div>
                                        </div>
                                    </div>
                                </td>

                                <%-- Phone --%>
                                <td style="font-size:.79rem;color:#6b7280;">
                                    ${not empty user.phone ? user.phone : '—'}
                                </td>

                                <%-- Role badge --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.role == 'SUPER_ADMIN'}">
                                            <span class="role-badge admin">
                                                <i class="bi bi-shield-fill-check"></i>Super Admin
                                            </span>
                                        </c:when>
                                        <c:when test="${user.role == 'RESTAURANT_OWNER'}">
                                            <span class="role-badge owner">
                                                <i class="bi bi-shop"></i>Owner
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="role-badge customer">
                                                <i class="bi bi-person-fill"></i>Customer
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Restaurant name (if owner) --%>
                                <td style="font-size:.79rem;font-weight:600;">
                                    <c:choose>
                                        <c:when test="${user.role == 'RESTAURANT_OWNER' && not empty user.restaurantName}">
                                            <span style="color:#16a34a;">${user.restaurantName}</span>
                                        </c:when>
                                        <c:otherwise><span style="color:#d1d5db;">—</span></c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Joined date --%>
                                <td style="font-size:.76rem;color:#9ca3af;white-space:nowrap;">${user.registeredDate}</td>

                                <%-- Total orders --%>
                                <td style="font-weight:700;">${not empty user.totalOrders ? user.totalOrders : '0'}</td>

                                <%-- Total spend --%>
                                <td style="font-weight:700;color:#f97316;">
                                    ₹<fmt:formatNumber value="${not empty user.totalSpend ? user.totalSpend : 0}" maxFractionDigits="0"/>
                                </td>

                                <%-- Status --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.isBanned}">
                                            <span class="status-badge banned">Banned</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge active">Active</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Actions --%>
                                <td>
                                    <div class="d-flex gap-2 align-items-center flex-wrap">

                                        <%-- View detail panel --%>
                                        <button type="button" class="btn-action"
                                                id="btn-view-user-${user.id}"
                                                onclick="openUserDetail(
                                                    '${user.id}',
                                                    '${user.fullName}',
                                                    '${user.email}',
                                                    '${user.phone}',
                                                    '${user.role}',
                                                    '${user.registeredDate}',
                                                    '${user.totalOrders}',
                                                    '${user.totalSpend}',
                                                    '${user.isBanned}',
                                                    '${user.restaurantName}'
                                                )"
                                                data-bs-toggle="offcanvas"
                                                data-bs-target="#userDetailPanel">
                                            <i class="bi bi-eye"></i> View
                                        </button>

                                        <%-- Ban / Unban — only for non-admin users --%>
                                        <c:if test="${user.role != 'SUPER_ADMIN'}">
                                            <c:choose>
                                                <c:when test="${user.isBanned}">
                                                    <form action="${pageContext.request.contextPath}/manage/users/unban"
                                                          method="POST" style="margin:0;" id="form-unban-${user.id}">
                                                        <input type="hidden" name="userId" value="${user.id}">
                                                        <button type="submit" class="btn-unban" id="btn-unban-${user.id}">
                                                            <i class="bi bi-check-circle"></i> Unban
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="${pageContext.request.contextPath}/manage/users/ban"
                                                          method="POST" style="margin:0;" id="form-ban-${user.id}">
                                                        <input type="hidden" name="userId" value="${user.id}">
                                                        <button type="submit" class="btn-ban" id="btn-ban-${user.id}"
                                                                onclick="return confirm('Ban ${user.fullName}? They will no longer be able to log in.')">
                                                            <i class="bi bi-slash-circle"></i> Ban
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>

                                        <%-- View order history link --%>
                                        <c:if test="${user.role == 'CUSTOMER' && user.totalOrders > 0}">
                                            <a href="${pageContext.request.contextPath}/manage/orders?customerId=${user.id}"
                                               class="btn-action" id="btn-orders-${user.id}" title="View Orders">
                                                <i class="bi bi-receipt-cutoff"></i>
                                            </a>
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
                    <a href="${pageContext.request.contextPath}/manage/users?page=${currentPage-1}&role=${filterRole}&q=${searchQuery}"
                       class="btn-action" id="users-prev-btn">
                        <i class="bi bi-chevron-left"></i> Prev
                    </a>
                </c:if>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/manage/users?page=${currentPage+1}&role=${filterRole}&q=${searchQuery}"
                       class="btn-action" id="users-next-btn">
                        Next <i class="bi bi-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </div>
    </c:if>

</div><%-- /section-card --%>


<%-- ═══════════════════════════════════════════════════════════ --%>
<%-- USER DETAIL — Bootstrap Offcanvas (slide-in panel)          --%>
<%-- ═══════════════════════════════════════════════════════════ --%>
<div class="offcanvas offcanvas-end" tabindex="-1"
     id="userDetailPanel" style="width:400px;max-width:96vw;"
     aria-labelledby="userDetailLabel">

    <div class="offcanvas-header">
        <h5 class="offcanvas-title" id="userDetailLabel">
            <i class="bi bi-person-circle me-2" style="color:#3b82f6;"></i>User Profile
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <div class="offcanvas-body">

        <%-- Avatar + name header --%>
        <div class="text-center mb-4">
            <div id="panel-avatar"
                 style="width:64px;height:64px;border-radius:50%;
                        background:linear-gradient(135deg,#f97316,#ea580c);
                        color:#fff;font-size:1.5rem;font-weight:800;
                        display:flex;align-items:center;justify-content:center;
                        margin:0 auto .75rem;">
                U
            </div>
            <div id="panel-name"   style="font-size:1.1rem;font-weight:800;color:#111827;"></div>
            <div id="panel-email"  style="font-size:.8rem;color:#9ca3af;margin-top:.2rem;"></div>
            <div id="panel-role-badge" class="mt-2"></div>
            <div id="panel-ban-indicator" style="display:none;" class="mt-1">
                <span style="font-size:.72rem;font-weight:700;background:#fef2f2;
                             color:#dc2626;padding:2px 10px;border-radius:99px;
                             border:1px solid #fca5a5;">
                    <i class="bi bi-slash-circle me-1"></i>Banned Account
                </span>
            </div>
        </div>

        <%-- Stat boxes --%>
        <div class="user-stat-grid mb-3">
            <div class="user-stat-box">
                <div class="val" id="panel-orders">0</div>
                <div class="lbl">Orders</div>
            </div>
            <div class="user-stat-box">
                <div class="val" id="panel-spend">₹0</div>
                <div class="lbl">Total Spent</div>
            </div>
        </div>

        <%-- Info rows --%>
        <div class="detail-section-title">Account Details</div>
        <div class="mb-3">
            <div class="detail-info-row">
                <span class="key">Phone</span>
                <span class="val" id="panel-phone"></span>
            </div>
            <div class="detail-info-row">
                <span class="key">Joined</span>
                <span class="val" id="panel-joined"></span>
            </div>
            <div class="detail-info-row" id="panel-rest-row" style="display:none;">
                <span class="key">Restaurant</span>
                <span class="val" id="panel-restaurant" style="color:#16a34a;"></span>
            </div>
        </div>

        <hr style="border-color:#f3f4f6;margin:.75rem 0;">

        <%-- Promote Role --%>
        <div id="panel-promote-section">
            <div class="detail-section-title">Change Role</div>
            <form action="${pageContext.request.contextPath}/manage/users/promote"
                  method="POST" id="panel-promote-form">
                <input type="hidden" name="userId" id="panel-promote-user-id">
                <select name="newRole" id="panel-role-select" class="form-select-sm-custom mb-1">
                    <option value="CUSTOMER">Customer</option>
                    <option value="RESTAURANT_OWNER">Restaurant Owner</option>
                    <option value="SUPER_ADMIN">Super Admin</option>
                </select>
                <button type="submit" class="btn-save-role" id="panel-save-role-btn"
                        onclick="return confirm('Change this user\'s role? This affects their access level.')">
                    <i class="bi bi-arrow-up-circle me-1"></i>Save Role
                </button>
            </form>
        </div>

        <hr style="border-color:#f3f4f6;margin:.75rem 0;">

        <%-- Ban / Unban from panel --%>
        <div class="detail-section-title">Account Control</div>
        <div id="panel-ban-section">
            <form action="${pageContext.request.contextPath}/manage/users/ban"
                  method="POST" id="panel-ban-form">
                <input type="hidden" name="userId" id="panel-ban-user-id">
                <button type="submit" class="btn-panel-ban" id="panel-ban-btn"
                        onclick="return confirm('Ban this user?')">
                    <i class="bi bi-slash-circle me-1"></i>Ban This User
                </button>
            </form>
        </div>
        <div id="panel-unban-section" style="display:none;">
            <form action="${pageContext.request.contextPath}/manage/users/unban"
                  method="POST" id="panel-unban-form">
                <input type="hidden" name="userId" id="panel-unban-user-id">
                <button type="submit" class="btn-panel-unban" id="panel-unban-btn">
                    <i class="bi bi-check-circle me-1"></i>Unban This User
                </button>
            </form>
        </div>

        <%-- Order history link --%>
        <a id="panel-orders-link"
           href="#"
           class="btn-action d-flex justify-content-center mt-3"
           style="width:100%;padding:.55rem;">
            <i class="bi bi-receipt-cutoff me-1"></i>View Order History
        </a>

    </div>
</div>

<%-- ══════════════════════ PAGE SCRIPTS ══════════════════════ --%>
<script>
    window.openUserDetail = function(id, name, email, phone, role, joined, orders, spend, isBanned, restName) {
        var banned = (isBanned === 'true');

        /* Avatar */
        var avatar = document.getElementById('panel-avatar');
        avatar.textContent = name ? name.charAt(0).toUpperCase() : 'U';
        var colors = { SUPER_ADMIN:'linear-gradient(135deg,#f97316,#ea580c)',
                       RESTAURANT_OWNER:'linear-gradient(135deg,#22c55e,#16a34a)',
                       CUSTOMER:'linear-gradient(135deg,#3b82f6,#2563eb)' };
        avatar.style.background = banned ? 'linear-gradient(135deg,#ef4444,#dc2626)'
                                         : (colors[role] || colors.CUSTOMER);

        /* Name / email */
        document.getElementById('panel-name').textContent  = name  || '—';
        document.getElementById('panel-email').textContent = email || '—';

        /* Role badge */
        var badgeMap = {
            SUPER_ADMIN:       '<span class="role-badge admin"><i class="bi bi-shield-fill-check me-1"></i>Super Admin</span>',
            RESTAURANT_OWNER:  '<span class="role-badge owner"><i class="bi bi-shop me-1"></i>Restaurant Owner</span>',
            CUSTOMER:          '<span class="role-badge customer"><i class="bi bi-person-fill me-1"></i>Customer</span>'
        };
        document.getElementById('panel-role-badge').innerHTML = badgeMap[role] || badgeMap.CUSTOMER;

        /* Ban indicator */
        document.getElementById('panel-ban-indicator').style.display = banned ? 'block' : 'none';

        /* Stats */
        document.getElementById('panel-orders').textContent = orders || '0';
        document.getElementById('panel-spend').textContent  = '₹' + (parseInt(spend) || 0).toLocaleString('en-IN');

        /* Info rows */
        document.getElementById('panel-phone').textContent  = phone  || '—';
        document.getElementById('panel-joined').textContent = joined || '—';

        /* Restaurant row */
        var restRow = document.getElementById('panel-rest-row');
        if (role === 'RESTAURANT_OWNER' && restName) {
            restRow.style.display = 'flex';
            document.getElementById('panel-restaurant').textContent = restName;
        } else {
            restRow.style.display = 'none';
        }

        /* Promote form */
        document.getElementById('panel-promote-user-id').value = id;
        document.getElementById('panel-role-select').value     = role;

        /* Hide promote section for self (super admin) */
        document.getElementById('panel-promote-section').style.display =
            (role === 'SUPER_ADMIN') ? 'none' : 'block';

        /* Ban / Unban switch */
        document.getElementById('panel-ban-user-id').value   = id;
        document.getElementById('panel-unban-user-id').value = id;
        document.getElementById('panel-ban-section').style.display   = banned ? 'none' : 'block';
        document.getElementById('panel-unban-section').style.display = banned ? 'block' : 'none';

        /* Orders link */
        document.getElementById('panel-orders-link').href =
            '${pageContext.request.contextPath}/manage/orders?customerId=' + id;
    };
</script>

<jsp:include page="manage-sidebar-close.jsp"/>
