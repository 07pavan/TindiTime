<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 3 : MENU / CATALOG MANAGER
    MVC: populated by AdminCatalogServlet which sets:
      requestScope.menuItems       — List<MenuItem>   all items (admin) or scoped (owner)
      requestScope.restaurants     — List<Restaurant> for the Add/Edit dropdown (admin sees all; owner sees own)
      requestScope.categories      — List<String>     distinct category names
      requestScope.filterRestId    — Long             active restaurant filter
      requestScope.filterCategory  — String           active category filter
      requestScope.searchQuery     — String           search term
      requestScope.totalPages      — int
      requestScope.currentPage     — int
    Each MenuItem:
      id, name, description, price, imageUrl, category,
      restaurantId, restaurantName, isAvailable (boolean)
--%>
<c:set var="pageTitle" value="Manage Restaurant Menu"  scope="request"/>
<c:set var="activeNav"  value="restaurants"           scope="request"/>

<jsp:include page="manage-sidebar.jsp"/>

<%-- ══════════════════════ PAGE-SCOPED STYLES ══════════════════════ --%>
<style>
    /* ── Section card ─────────────────────────────── */
    .section-card {
        background:#fff; border:1px solid #e5e7eb;
        border-radius:14px; overflow:hidden;
    }
    .section-card-header {
        padding:1rem 1.25rem;
        border-bottom:1px solid #f3f4f6;
        display:flex; align-items:center;
        justify-content:space-between;
        gap:1rem; flex-wrap:wrap;
    }
    .section-card-title { font-size:.92rem; font-weight:700; color:#111827; margin:0; }

    /* ── Manage table ─────────────────────────────── */
    .manage-table { font-size:.84rem; margin:0; }
    .manage-table thead th {
        background:#f9fafb;
        font-size:.68rem; font-weight:700;
        letter-spacing:.6px; text-transform:uppercase;
        color:#9ca3af;
        border-bottom:1px solid #f3f4f6;
        padding:.7rem 1.1rem; white-space:nowrap;
    }
    .manage-table tbody td {
        padding:.85rem 1.1rem; color:#374151;
        vertical-align:middle;
        border-bottom:1px solid #f9fafb;
    }
    .manage-table tbody tr:last-child td { border-bottom:none; }
    .manage-table tbody tr:hover td { background:#fafafa; }

    /* ── Item thumbnail ───────────────────────────── */
    .item-thumb {
        width:48px; height:48px;
        border-radius:10px; object-fit:cover;
        border:1px solid #f3f4f6;
        background:#f9fafb;
        flex-shrink:0;
    }
    .item-chip { display:flex; align-items:center; gap:.7rem; }
    .item-name { font-weight:700; color:#111827; font-size:.85rem; }
    .item-desc { font-size:.72rem; color:#9ca3af;
                 max-width:220px; white-space:nowrap;
                 overflow:hidden; text-overflow:ellipsis; }

    /* ── Category badge ───────────────────────────── */
    .cat-badge {
        display:inline-block; font-size:.68rem; font-weight:700;
        padding:3px 9px; border-radius:99px;
        background:#eff6ff; color:#3b82f6;
    }

    /* ── Availability toggle ──────────────────────── */
    .avail-toggle { display:flex; align-items:center; gap:.5rem; }
    .form-check-input[type=checkbox] {
        width:36px; height:20px; cursor:pointer;
        border-radius:99px;
    }
    .form-check-input:checked { background-color:#22c55e; border-color:#22c55e; }

    /* ── Status badge ─────────────────────────────── */
    .status-badge {
        display:inline-flex; align-items:center; gap:5px;
        font-size:.7rem; font-weight:700;
        padding:3px 10px; border-radius:99px; white-space:nowrap;
    }
    .status-badge::before {
        content:''; width:6px; height:6px;
        border-radius:50%; display:inline-block;
    }
    .status-badge.avail   { background:#f0fdf4; color:#15803d; }
    .status-badge.avail::before   { background:#22c55e; }
    .status-badge.unavail { background:#fef2f2; color:#dc2626; }
    .status-badge.unavail::before { background:#ef4444; }

    /* ── Action buttons ───────────────────────────── */
    .btn-action {
        font-size:.75rem; font-weight:600;
        padding:4px 10px; border-radius:7px;
        border:1px solid #e5e7eb;
        background:#fff; color:#374151;
        text-decoration:none;
        transition:border-color .15s, color .15s;
        display:inline-flex; align-items:center; gap:4px;
        white-space:nowrap; cursor:pointer;
    }
    .btn-action:hover { border-color:#f97316; color:#f97316; }
    .btn-edit {
        font-size:.75rem; font-weight:600;
        padding:4px 10px; border-radius:7px;
        border:1px solid #bfdbfe;
        background:#eff6ff; color:#2563eb;
        text-decoration:none;
        transition:background .15s;
        display:inline-flex; align-items:center; gap:4px;
        white-space:nowrap; cursor:pointer;
    }
    .btn-edit:hover { background:#dbeafe; color:#1d4ed8; }
    .btn-delete {
        font-size:.75rem; font-weight:600;
        padding:4px 10px; border-radius:7px;
        border:1px solid #fca5a5;
        background:#fef2f2; color:#dc2626;
        text-decoration:none;
        transition:background .15s;
        display:inline-flex; align-items:center; gap:4px;
        white-space:nowrap; cursor:pointer;
    }
    .btn-delete:hover { background:#fee2e2; }

    /* ── Add Item button ──────────────────────────── */
    .btn-add-item {
        font-size:.82rem; font-weight:700;
        padding:.5rem 1.1rem; border-radius:10px;
        background:#f97316; color:#fff; border:none;
        cursor:pointer; transition:background .15s;
        display:inline-flex; align-items:center; gap:.4rem;
        text-decoration:none;
    }
    .btn-add-item:hover { background:#ea580c; color:#fff; }

    /* ── Filter bar ───────────────────────────────── */
    .filter-bar {
        display:flex; align-items:center;
        gap:.6rem; flex-wrap:wrap;
    }
    .filter-bar .form-control,
    .filter-bar .form-select {
        font-size:.82rem; border-radius:9px;
        border:1px solid #e5e7eb;
        padding:.42rem .85rem;
        background:#f9fafb;
    }
    .filter-bar .form-control:focus,
    .filter-bar .form-select:focus {
        border-color:#f97316;
        box-shadow:0 0 0 3px rgba(249,115,22,.08);
    }
    .filter-bar .btn-search {
        font-size:.82rem; font-weight:600;
        padding:.42rem 1rem; border-radius:9px;
        background:#f97316; color:#fff; border:none;
        cursor:pointer; transition:background .15s;
    }
    .filter-bar .btn-search:hover { background:#ea580c; }

    /* ── Summary pills ────────────────────────────── */
    .summary-pill {
        display:inline-flex; align-items:center; gap:.4rem;
        font-size:.75rem; font-weight:700;
        padding:4px 12px; border-radius:99px;
    }

    /* ── Modal overrides ──────────────────────────── */
    .modal-content { border-radius:16px; border:none; box-shadow:0 25px 60px rgba(0,0,0,.15); }
    .modal-header  { border-bottom:1px solid #f3f4f6; padding:1.1rem 1.4rem; }
    .modal-footer  { border-top:1px solid #f3f4f6; padding:.85rem 1.4rem; }
    .modal-title   { font-size:1rem; font-weight:800; color:#111827; }
    .form-label    { font-size:.75rem; font-weight:700; color:#6b7280;
                     text-transform:uppercase; letter-spacing:.4px; }
    .form-control, .form-select {
        font-size:.85rem; border-radius:10px;
        border:1px solid #e5e7eb;
        padding:.55rem .9rem;
    }
    .form-control:focus, .form-select:focus {
        border-color:#f97316;
        box-shadow:0 0 0 3px rgba(249,115,22,.1);
    }
    .btn-modal-save {
        font-size:.85rem; font-weight:700;
        padding:.55rem 1.4rem; border-radius:10px;
        background:#f97316; color:#fff; border:none;
        cursor:pointer; transition:background .15s;
    }
    .btn-modal-save:hover { background:#ea580c; }
    .btn-modal-cancel {
        font-size:.85rem; font-weight:600;
        padding:.55rem 1.2rem; border-radius:10px;
        background:#f9fafb; color:#374151;
        border:1px solid #e5e7eb; cursor:pointer;
    }

    /* ── Image preview ────────────────────────────── */
    #img-preview-add, #img-preview-edit {
        width:100%; height:140px;
        object-fit:cover; border-radius:10px;
        border:1px solid #f3f4f6;
        display:none; margin-top:.5rem;
        background:#f9fafb;
    }

    /* ── Empty state ──────────────────────────────── */
    .empty-state { text-align:center; padding:3.5rem 1rem; }
    .empty-state i { font-size:2.8rem; color:#e5e7eb; display:block; margin-bottom:1rem; }
    .empty-state p { font-size:.85rem; font-weight:600; color:#9ca3af; margin:0; }
</style>

<%-- ══════════════════════ PAGE HEADER ══════════════════════ --%>
<a href="${pageContext.request.contextPath}/manage/restaurants"
   class="btn btn-sm mb-3" style="background:#eef2ff;color:#4338ca;border:1px solid #6366f1;border-radius:10px;
          padding:.4rem 1rem;font-size:.78rem;font-weight:700;display:inline-flex;align-items:center;gap:.4rem;cursor:pointer;text-decoration:none;">
    <i class="bi bi-arrow-left"></i> Back to Restaurants
</a>
<div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
    <div>
        <h1 class="fw-bold mb-1" style="font-size:1.4rem;color:#111827;">Restaurant Menu Manager</h1>
        <p class="text-muted mb-0" style="font-size:.82rem;">
            Add, edit, or toggle availability of food items on the storefront.
        </p>
    </div>
    <%-- Add New Item button triggers Bootstrap modal --%>
    <button class="btn-add-item" data-bs-toggle="modal" data-bs-target="#addItemModal" id="btn-open-add-modal">
        <i class="bi bi-plus-circle-fill"></i> Add New Item
    </button>
</div>

<%-- Summary pills --%>
<div class="d-flex gap-2 mb-4 flex-wrap">
    <span class="summary-pill" style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;">
        <i class="bi bi-check-circle-fill" style="font-size:.75rem;"></i>
        ${not empty availableCount ? availableCount : '0'} Available
    </span>
    <span class="summary-pill" style="background:#fef2f2;border:1px solid #fca5a5;color:#dc2626;">
        <i class="bi bi-x-circle-fill" style="font-size:.75rem;"></i>
        ${not empty unavailableCount ? unavailableCount : '0'} Out of Stock
    </span>
    <span class="summary-pill" style="background:#eff6ff;border:1px solid #bfdbfe;color:#2563eb;">
        <i class="bi bi-journal-text" style="font-size:.75rem;"></i>
        ${not empty menuItems ? menuItems.size() : '0'} Showing
    </span>
</div>

<%-- ══════════════════════ CATALOG TABLE CARD ══════════════════════ --%>
<div class="section-card" id="manage-catalog-card">

    <%-- Header with search + filters --%>
    <div class="section-card-header flex-column flex-lg-row align-items-start align-items-lg-center">
        <h2 class="section-card-title">
            <i class="bi bi-journal-text me-2" style="color:#f97316;"></i>All Menu Items
        </h2>

        <form action="${pageContext.request.contextPath}/manage/catalog"
              method="GET" class="filter-bar ms-lg-auto mt-2 mt-lg-0" id="catalog-filter-form">

            <%-- Search --%>
            <input type="text" name="q"
                   placeholder="Search items…"
                   value="${not empty searchQuery ? searchQuery : ''}"
                   class="form-control" style="min-width:180px;max-width:220px;"
                   id="catalog-search-input">

            <%-- Category filter --%>
            <select name="category" class="form-select" style="width:auto;" id="catalog-cat-filter">
                <option value="">All Categories</option>
                <c:forEach items="${categories}" var="cat">
                    <option value="${cat}" ${filterCategory == cat ? 'selected' : ''}>${cat}</option>
                </c:forEach>
            </select>

            <%-- Restaurant filter — admin only --%>
            <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                <select name="restaurantId" class="form-select" style="width:auto;" id="catalog-rest-filter">
                    <option value="">All Restaurants</option>
                    <c:forEach items="${restaurants}" var="rest">
                        <option value="${rest.id}" ${filterRestId == rest.id ? 'selected' : ''}>
                            ${rest.name}
                        </option>
                    </c:forEach>
                </select>
            </c:if>

            <button type="submit" class="btn-search" id="catalog-search-btn">
                <i class="bi bi-search me-1"></i>Search
            </button>

            <%-- Clear --%>
            <c:if test="${not empty searchQuery || not empty filterCategory || not empty filterRestId}">
                <a href="${pageContext.request.contextPath}/manage/catalog"
                   class="btn-action" id="catalog-clear-btn">
                    <i class="bi bi-x"></i> Clear
                </a>
            </c:if>
        </form>
    </div>

    <%-- Table --%>
    <div class="table-responsive">
        <c:choose>
            <c:when test="${empty menuItems}">
                <div class="empty-state" id="catalog-empty-state">
                    <i class="bi bi-journal-text"></i>
                    <p>No menu items found. Add your first item using the button above.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table manage-table" id="manage-catalog-table">
                    <thead>
                        <tr>
                            <th style="width:48px;"></th>
                            <th>Item Name</th>
                            <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                <th>Restaurant</th>
                            </c:if>
                            <th>Category</th>
                            <th>Price</th>
                            <th>Availability</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${menuItems}" var="item">
                            <tr id="catalog-row-${item.id}">

                                <%-- Thumbnail --%>
                                <td style="padding:.7rem 1rem;">
                                    <img src="${not empty item.imageUrl ? item.imageUrl : ''}"
                                         alt="${item.name}"
                                         class="item-thumb"
                                         id="thumb-${item.id}"
                                         onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&auto=format&fit=crop&q=60'">
                                </td>

                                <%-- Item name + description --%>
                                <td>
                                    <div class="item-chip">
                                        <div>
                                            <div class="item-name">${item.name}</div>
                                            <div class="item-desc">${item.description}</div>
                                        </div>
                                    </div>
                                </td>

                                <%-- Restaurant — admin only --%>
                                <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                    <td style="font-weight:600;font-size:.82rem;">${item.restaurantName}</td>
                                </c:if>

                                <%-- Category --%>
                                <td><span class="cat-badge">${item.category}</span></td>

                                <%-- Price --%>
                                <td>
                                    <span style="font-weight:800;color:#111827;">
                                        ₹<fmt:formatNumber value="${item.price}" maxFractionDigits="2"/>
                                    </span>
                                </td>

                                <%-- Availability toggle --%>
                                <td>
                                    <form action="${pageContext.request.contextPath}/manage/catalog/toggle"
                                          method="POST" style="margin:0;" id="form-toggle-${item.id}">
                                        <input type="hidden" name="itemId" value="${item.id}">
                                        <div class="avail-toggle">
                                            <input type="checkbox" class="form-check-input"
                                                   id="toggle-${item.id}"
                                                   ${item.isAvailable ? 'checked' : ''}
                                                   onchange="document.getElementById('form-toggle-${item.id}').submit()"
                                                   title="${item.isAvailable ? 'Click to mark Out of Stock' : 'Click to mark Available'}">
                                            <label for="toggle-${item.id}" style="font-size:.75rem;font-weight:600;cursor:pointer;">
                                                <c:choose>
                                                    <c:when test="${item.isAvailable}">
                                                        <span class="status-badge avail">Available</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge unavail">Out of Stock</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </label>
                                        </div>
                                    </form>
                                </td>

                                <%-- Actions: Edit + Delete --%>
                                <td>
                                    <div class="d-flex gap-2 align-items-center">

                                        <%-- Edit — opens modal pre-filled --%>
                                        <button type="button" class="btn-edit"
                                                id="btn-edit-${item.id}"
                                                onclick="openEditModal(
                                                    '${item.id}',
                                                    '${item.name}',
                                                    '${item.description}',
                                                    '${item.price}',
                                                    '${item.category}',
                                                    '${item.restaurantId}',
                                                    '${item.imageUrl}'
                                                )"
                                                data-bs-toggle="modal" data-bs-target="#editItemModal">
                                            <i class="bi bi-pencil-fill"></i> Edit
                                        </button>

                                        <%-- Delete --%>
                                        <form action="${pageContext.request.contextPath}/manage/catalog/delete"
                                              method="POST" style="margin:0;" id="form-delete-${item.id}">
                                            <input type="hidden" name="itemId" value="${item.id}">
                                            <button type="submit" class="btn-delete"
                                                    id="btn-delete-${item.id}"
                                                    onclick="return confirm('Delete &quot;${item.name}&quot;? This cannot be undone.')">
                                                <i class="bi bi-trash3-fill"></i> Delete
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

    <%-- Pagination --%>
    <c:if test="${not empty totalPages && totalPages > 1}">
        <div class="d-flex align-items-center justify-content-between px-3 py-3"
             style="border-top:1px solid #f3f4f6;">
            <span style="font-size:.78rem;color:#9ca3af;">
                Page ${currentPage} of ${totalPages}
            </span>
            <div class="d-flex gap-2">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/manage/catalog?page=${currentPage - 1}&q=${searchQuery}&category=${filterCategory}&restaurantId=${filterRestId}"
                       class="btn-action" id="catalog-prev-btn">
                        <i class="bi bi-chevron-left"></i> Prev
                    </a>
                </c:if>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/manage/catalog?page=${currentPage + 1}&q=${searchQuery}&category=${filterCategory}&restaurantId=${filterRestId}"
                       class="btn-action" id="catalog-next-btn">
                        Next <i class="bi bi-chevron-right"></i>
                    </a>
                </c:if>
            </div>
        </div>
    </c:if>

</div><%-- /section-card --%>


<%-- ═══════════════════════════════════════════════════════════ --%>
<%-- MODAL : ADD NEW ITEM                                        --%>
<%-- ═══════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="addItemModal" tabindex="-1"
     aria-labelledby="addItemModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="addItemModalLabel">
                    <i class="bi bi-plus-circle-fill me-2" style="color:#f97316;"></i>Add New Menu Item
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/manage/catalog/add"
                  method="POST" id="add-item-form">
                <div class="modal-body p-4">
                    <div class="row g-3">

                        <%-- Item Name --%>
                        <div class="col-12 col-md-8">
                            <label for="add-name" class="form-label">Item Name *</label>
                            <input type="text" id="add-name" name="name" required
                                   placeholder="e.g. Margherita Pizza"
                                   class="form-control">
                        </div>

                        <%-- Price --%>
                        <div class="col-12 col-md-4">
                            <label for="add-price" class="form-label">Price (₹) *</label>
                            <input type="number" id="add-price" name="price" required
                                   min="0" step="0.01" placeholder="0.00"
                                   class="form-control">
                        </div>

                        <%-- Category --%>
                        <div class="col-12 col-md-6">
                            <label for="add-category" class="form-label">Category *</label>
                            <input type="text" id="add-category" name="category" required
                                   placeholder="e.g. Pizza, Burgers, Desserts"
                                   class="form-control" list="category-suggestions">
                            <datalist id="category-suggestions">
                                <c:forEach items="${categories}" var="cat">
                                    <option value="${cat}">
                                </c:forEach>
                            </datalist>
                        </div>

                        <%-- Restaurant — admin sees all, owner auto-assigned --%>
                        <div class="col-12 col-md-6">
                            <label for="add-restaurant" class="form-label">Restaurant *</label>
                            <c:choose>
                                <c:when test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                    <select id="add-restaurant" name="restaurantId"
                                            required class="form-select">
                                        <option value="" disabled selected>Select restaurant…</option>
                                        <c:forEach items="${restaurants}" var="rest">
                                            <option value="${rest.id}">${rest.name}</option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <%-- Owner: auto-assign their own restaurant --%>
                                    <input type="text" class="form-control"
                                           value="${sessionScope.restaurantName}" readonly>
                                    <input type="hidden" name="restaurantId"
                                           value="${sessionScope.restaurantId}">
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Image URL + Preview --%>
                        <div class="col-12">
                            <label for="add-image" class="form-label">Image URL</label>
                            <input type="url" id="add-image" name="imageUrl"
                                   placeholder="https://example.com/image.jpg"
                                   class="form-control"
                                   oninput="previewImage('add-image','img-preview-add')">
                            <img id="img-preview-add" alt="Image preview">
                        </div>

                        <%-- Description --%>
                        <div class="col-12">
                            <label for="add-desc" class="form-label">Description</label>
                            <textarea id="add-desc" name="description" rows="3"
                                      placeholder="Short description of the item…"
                                      class="form-control" style="resize:vertical;"></textarea>
                        </div>

                        <%-- Available toggle --%>
                        <div class="col-12">
                            <div class="form-check form-switch d-flex align-items-center gap-2 ps-0">
                                <input type="checkbox" class="form-check-input ms-0"
                                       id="add-available" name="isAvailable"
                                       checked style="width:40px;height:22px;cursor:pointer;">
                                <label for="add-available" class="form-check-label fw-semibold"
                                       style="font-size:.85rem;cursor:pointer;">
                                    Mark as Available immediately
                                </label>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-modal-cancel" data-bs-dismiss="modal" id="add-cancel-btn">Cancel</button>
                    <button type="submit" class="btn-modal-save" id="add-save-btn">
                        <i class="bi bi-plus-circle me-1"></i> Add Item
                    </button>
                </div>
            </form>

        </div>
    </div>
</div>

<%-- ═══════════════════════════════════════════════════════════ --%>
<%-- MODAL : EDIT ITEM                                           --%>
<%-- ═══════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="editItemModal" tabindex="-1"
     aria-labelledby="editItemModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="editItemModalLabel">
                    <i class="bi bi-pencil-fill me-2" style="color:#2563eb;"></i>Edit Menu Item
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="${pageContext.request.contextPath}/manage/catalog/edit"
                  method="POST" id="edit-item-form">
                <input type="hidden" id="edit-item-id" name="itemId">
                <div class="modal-body p-4">
                    <div class="row g-3">

                        <div class="col-12 col-md-8">
                            <label for="edit-name" class="form-label">Item Name *</label>
                            <input type="text" id="edit-name" name="name" required
                                   class="form-control">
                        </div>

                        <div class="col-12 col-md-4">
                            <label for="edit-price" class="form-label">Price (₹) *</label>
                            <input type="number" id="edit-price" name="price" required
                                   min="0" step="0.01" class="form-control">
                        </div>

                        <div class="col-12 col-md-6">
                            <label for="edit-category" class="form-label">Category *</label>
                            <input type="text" id="edit-category" name="category" required
                                   class="form-control" list="category-suggestions">
                        </div>

                        <div class="col-12 col-md-6">
                            <label for="edit-restaurant" class="form-label">Restaurant *</label>
                            <c:choose>
                                <c:when test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                    <select id="edit-restaurant" name="restaurantId"
                                            required class="form-select">
                                        <option value="" disabled>Select restaurant…</option>
                                        <c:forEach items="${restaurants}" var="rest">
                                            <option value="${rest.id}">${rest.name}</option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <input type="text" class="form-control"
                                           value="${sessionScope.restaurantName}" readonly>
                                    <input type="hidden" name="restaurantId"
                                           value="${sessionScope.restaurantId}">
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="col-12">
                            <label for="edit-image" class="form-label">Image URL</label>
                            <input type="url" id="edit-image" name="imageUrl"
                                   class="form-control"
                                   oninput="previewImage('edit-image','img-preview-edit')">
                            <img id="img-preview-edit" alt="Image preview">
                        </div>

                        <div class="col-12">
                            <label for="edit-desc" class="form-label">Description</label>
                            <textarea id="edit-desc" name="description" rows="3"
                                      class="form-control" style="resize:vertical;"></textarea>
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-modal-cancel" data-bs-dismiss="modal" id="edit-cancel-btn">Cancel</button>
                    <button type="submit" class="btn-modal-save" id="edit-save-btn"
                            style="background:#2563eb;">
                        <i class="bi bi-save me-1"></i> Save Changes
                    </button>
                </div>
            </form>

        </div>
    </div>
</div>

<%-- ══════════════════════ PAGE SCRIPTS ══════════════════════ --%>
<script>
    /* Image URL preview helper */
    function previewImage(inputId, previewId) {
        var url = document.getElementById(inputId).value.trim();
        var img = document.getElementById(previewId);
        if (url) {
            img.src = url;
            img.style.display = 'block';
            img.onerror = function () { img.style.display = 'none'; };
        } else {
            img.style.display = 'none';
        }
    }

    /* Pre-fill Edit modal with item data */
    function openEditModal(id, name, description, price, category, restaurantId, imageUrl) {
        document.getElementById('edit-item-id').value    = id;
        document.getElementById('edit-name').value       = name;
        document.getElementById('edit-desc').value       = description;
        document.getElementById('edit-price').value      = price;
        document.getElementById('edit-category').value   = category;
        document.getElementById('edit-image').value      = imageUrl;

        /* Set restaurant select if admin */
        var restSelect = document.getElementById('edit-restaurant');
        if (restSelect) {
            restSelect.value = restaurantId;
        }

        /* Show image preview */
        if (imageUrl) {
            var img = document.getElementById('img-preview-edit');
            img.src = imageUrl;
            img.style.display = 'block';
        }
    }
</script>

<jsp:include page="manage-sidebar-close.jsp"/>
