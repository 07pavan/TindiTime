<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    MODULE 8 : SYSTEM SETTINGS
    MVC: populated by AdminSettingsServlet which sets:

    SUPER_ADMIN sees all sections:
      requestScope.platformConfig  — Map:
          commissionRate, baseDeliveryFee, perKmRate, taxRate,
          maxDeliveryRadius, bannerEnabled (boolean), bannerText, bannerType

    RESTAURANT_OWNER sees profile + operational sections only:
      requestScope.restaurantProfile — Map:
          name, description, address, city, postalCode, phone, email,
          logoUrl, cuisineType, isOpen (boolean), openTime, closeTime

    Both roles see:
      requestScope.successMessage  — String  (after a successful form POST)
      requestScope.errorMessage    — String  (after a failed form POST)
--%>
<c:set var="pageTitle" value="Settings"   scope="request"/>
<c:set var="activeNav"  value="settings"  scope="request"/>

<jsp:include page="manage-sidebar.jsp"/>

<%-- ═════════════════════<style>
    /* ── Settings page layout ─────────────────────── */
    .settings-layout {
        display:grid;
        grid-template-columns:220px 1fr;
        gap:1.5rem;
        align-items:start;
    }
    @media (max-width:767px) {
        .settings-layout { grid-template-columns:1fr; }
        .settings-sidenav { display:flex; flex-wrap:wrap; gap:.4rem; }
        .settings-sidenav .snav-link { border-radius:99px !important; padding:5px 14px !important; }
    }

    /* ── Settings side nav ────────────────────────── */
    .settings-sidenav {
        background:#fff; border:1px solid rgba(140,140,130,0.2); border-radius:20px;
        padding:.5rem; position:sticky; top:80px;
    }
    .snav-link {
        display:flex; align-items:center; gap:.65rem;
        padding:.55rem 1rem; border-radius:10px;
        font-size:.84rem; font-weight:700; color:#555;
        text-decoration:none; transition:background .15s, color .15s;
        cursor:pointer; border:none; background:none; width:100%; text-align:left;
    }
    .snav-link i { font-size:.95rem; flex-shrink:0; }
    .snav-link:hover { background:rgba(0,71,60,0.05); color:var(--color-deep-forest); }
    .snav-link.active { background:rgba(0,71,60,0.1); color:var(--color-deep-forest); font-weight:700; }
    .snav-link.active i { color:var(--color-deep-forest); }
    .snav-divider { border-top:1px solid rgba(140,140,130,0.2); margin:.4rem 0; }

    /* ── Settings panel cards ─────────────────────── */
    .settings-panel { display:none; }
    .settings-panel.active { display:block; }

    .settings-card {
        background:#fff; border:1px solid rgba(140,140,130,0.2); border-radius:20px;
        overflow:hidden; margin-bottom:1.25rem;
    }
    .settings-card:last-child { margin-bottom:0; }

    .settings-card-header {
        padding:1.1rem 1.4rem; border-bottom:1px solid rgba(140,140,130,0.15);
        display:flex; align-items:center; gap:.75rem;
    }
    .settings-card-icon {
        width:38px; height:38px; border-radius:12px;
        display:flex; align-items:center; justify-content:center;
        font-size:1rem; flex-shrink:0;
    }
    .settings-card-icon.orange { background:rgba(230,255,85,0.25); color:#5c6a00; }
    .settings-card-icon.blue   { background:#d8e5d6; color:#00473c; }
    .settings-card-icon.green  { background:rgba(0,71,60,0.1); color:#00473c; }
    .settings-card-icon.red    { background:rgba(192,57,43,0.1); color:#c0392b; }
    .settings-card-icon.purple { background:rgba(0,71,60,0.07); color:#00473c; }
    .settings-card-icon.yellow { background:rgba(230,255,85,0.2); color:#5c6a00; }
    .settings-card-icon.teal   { background:rgba(0,71,60,0.12); color:#00473c; }

    .settings-card-title { font-size:.95rem; font-weight:800; color:#0e150e; margin:0; }
    .settings-card-sub   { font-size:.75rem; color:#8c8c82; margin-top:.1rem; }

    .settings-card-body { padding:1.4rem; }

    /* ── Form elements ────────────────────────────── */
    .form-group { margin-bottom:1.1rem; }
    .form-group:last-child { margin-bottom:0; }
    .form-label {
        font-size:.72rem; font-weight:700; color:#8c8c82;
        text-transform:uppercase; letter-spacing:.4px;
        display:block; margin-bottom:.4rem;
    }
    .form-control, .form-select {
        font-size:.85rem; border-radius:10px; border:1.5px solid rgba(140,140,130,0.4);
        padding:.6rem .9rem; width:100%; transition:border-color .15s, box-shadow .15s;
        background:#fff; color:#0e150e;
    }
    .form-control:focus, .form-select:focus {
        border-color:#00473c; box-shadow:0 0 0 3px rgba(0,71,60,0.1); outline:none;
    }
    .form-control[readonly] { background:rgba(140,140,130,0.1); color:#8c8c82; cursor:not-allowed; }
    .form-hint { font-size:.72rem; color:#8c8c82; margin-top:.3rem; }

    /* Input with prefix/suffix ─ */
    .input-group-custom {
        display:flex; align-items:center;
        border:1.5px solid rgba(140,140,130,0.4); border-radius:10px; overflow:hidden;
        transition:border-color .15s, box-shadow .15s;
    }
    .input-group-custom:focus-within {
        border-color:#00473c; box-shadow:0 0 0 3px rgba(0,71,60,0.1);
    }
    .input-prefix, .input-suffix {
        padding:.6rem .85rem; background:rgba(140,140,130,0.08);
        font-size:.82rem; font-weight:700; color:#555;
        white-space:nowrap; flex-shrink:0;
    }
    .input-prefix { border-right:1.5px solid rgba(140,140,130,0.4); }
    .input-suffix { border-left:1.5px solid rgba(140,140,130,0.4); }
    .input-group-custom .form-control {
        border:none; border-radius:0; box-shadow:none; flex:1;
    }
    .input-group-custom .form-control:focus { box-shadow:none; }

    /* ── Toggle switch ────────────────────────────── */
    .toggle-row {
        display:flex; align-items:center; justify-content:space-between;
        gap:1rem; padding:.85rem 0;
        border-bottom:1px solid rgba(140,140,130,0.12);
    }
    .toggle-row:last-child { border-bottom:none; padding-bottom:0; }
    .toggle-row:first-child { padding-top:0; }
    .toggle-label  { font-size:.85rem; font-weight:600; color:#0e150e; }
    .toggle-hint   { font-size:.73rem; color:#8c8c82; margin-top:.15rem; }
    .toggle-switch {
        position:relative; display:inline-block;
        width:46px; height:26px; flex-shrink:0;
    }
    .toggle-switch input { opacity:0; width:0; height:0; }
    .toggle-slider {
        position:absolute; inset:0;
        background:rgba(140,140,130,0.3); border-radius:99px; cursor:pointer;
        transition:background .2s;
    }
    .toggle-slider::before {
        content:''; position:absolute;
        width:20px; height:20px; left:3px; bottom:3px;
        background:#fff; border-radius:50%;
        transition:transform .2s; box-shadow:0 1px 3px rgba(0,0,0,.2);
    }
    .toggle-switch input:checked + .toggle-slider { background:#00473c; }
    .toggle-switch input:checked + .toggle-slider::before { transform:translateX(20px); }
    .toggle-switch input:disabled + .toggle-slider { opacity:.5; cursor:not-allowed; }

    /* ── Banner preview ───────────────────────────── */
    .banner-preview {
        border-radius:10px; padding:.75rem 1rem;
        font-size:.83rem; font-weight:600; margin-top:.75rem;
        display:none; align-items:center; gap:.6rem;
        transition:all .2s;
    }
    .banner-preview.info    { background:rgba(0,71,60,0.06); color:#00473c; border:1px solid rgba(0,71,60,0.2); }
    .banner-preview.warning { background:rgba(230,255,85,0.2); color:#5c6a00; border:1px solid rgba(0,71,60,0.2); }
    .banner-preview.success { background:rgba(0,71,60,0.1); color:#00473c; border:1px solid rgba(0,71,60,0.25); }
    .banner-preview.error   { background:rgba(192,57,43,0.1); color:#c0392b; border:1px solid rgba(192,57,43,0.25); }

    /* ── Save button ──────────────────────────────── */
    .btn-save {
        font-size:.85rem; font-weight:700; padding:.6rem 1.4rem; border-radius:99px;
        background:#00473c; color:#fff; border:none; cursor:pointer;
        transition:background .15s; display:inline-flex; align-items:center; gap:.4rem;
    }
    .btn-save:hover { background:#0e150e; }
    .btn-save:disabled { background:rgba(140,140,130,0.15); color:#8c8c82; cursor:not-allowed; }
    .btn-save.blue   { background:#00473c; }
    .btn-save.blue:hover { background:#0e150e; }
    .btn-save.green  { background:#00473c; }
    .btn-save.green:hover { background:#0e150e; }
    .btn-save.red    { background:#c0392b; }
    .btn-save.red:hover { background:#962d20; }

    /* ── Open/Closed toggle hero ──────────────────── */
    .open-closed-hero {
        border-radius:20px; padding:1.5rem;
        display:flex; align-items:center; justify-content:space-between;
        gap:1.5rem; flex-wrap:wrap; margin-bottom:1.25rem;
        transition:background .3s, border-color .3s;
    }
    .open-closed-hero.open-state {
        background:var(--color-sage-mist, #d8e5d6);
        border:1.5px solid rgba(0,71,60,0.25);
    }
    .open-closed-hero.closed-state {
        background:rgba(192,57,43,0.1);
        border:1.5px solid rgba(192,57,43,0.25);
    }
    .open-status-label {
        font-size:1.5rem; font-weight:900;
    }
    .open-status-label.open   { color:#00473c; }
    .open-status-label.closed { color:#c0392b; }
    .open-status-sub { font-size:.8rem; font-weight:600; color:#555; margin-top:.2rem; }

    /* ── Alert messages ───────────────────────────── */
    .alert-success, .alert-error {
        border-radius:12px; padding:.75rem 1rem;
        font-size:.83rem; font-weight:600; margin-bottom:1rem;
        display:flex; align-items:center; gap:.6rem;
    }
    .alert-success { background:rgba(0,71,60,0.08); color:#00473c; border:1px solid rgba(0,71,60,0.2); }
    .alert-error   { background:rgba(192,57,43,0.08); color:#c0392b; border:1px solid rgba(192,57,43,0.2); }

    /* ── Logo preview ─────────────────────────────── */
    #logo-preview {
        width:80px; height:80px; border-radius:16px;
        object-fit:cover; border:1.5px solid rgba(140,140,130,0.4);
        background:var(--color-cream-canvas, #f4f3e7); display:none; margin-top:.5rem;
    }

    /* ── Password strength bar ────────────────────── */
    .strength-bar {
        height:4px; border-radius:99px; background:rgba(140,140,130,0.15);
        margin-top:.5rem; overflow:hidden;
    }
    .strength-fill {
        height:100%; border-radius:99px; width:0%;
        transition:width .3s, background .3s;
    }
    .strength-label {
        font-size:.7rem; font-weight:700; margin-top:.3rem;
    }

    /* ── Danger zone ──────────────────────────────── */
    .danger-zone {
        border:1.5px solid rgba(192,57,43,0.4); border-radius:20px;
        padding:1rem 1.25rem; background:rgba(192,57,43,0.03);
    }
    .danger-zone-title {
        font-size:.8rem; font-weight:800; color:#c0392b;
        text-transform:uppercase; letter-spacing:.5px; margin-bottom:.75rem;
        display:flex; align-items:center; gap:.4rem;
    }
</style>

<%-- ══════════════════════ FLASH MESSAGES ══════════════════════ --%>
<c:if test="${not empty successMessage}">
    <div class="alert-success mb-3" id="settings-success-alert">
        <i class="bi bi-check-circle-fill"></i>${successMessage}
    </div>
</c:if>
<c:if test="${not empty errorMessage}">
    <div class="alert-error mb-3" id="settings-error-alert">
        <i class="bi bi-x-circle-fill"></i>${errorMessage}
    </div>
</c:if>

<%-- ══════════════════════ PAGE HEADER ══════════════════════ --%>
<div class="mb-4">
    <h1 class="fw-bold mb-1" style="font-size:1.4rem;color:#111827;">Settings</h1>
    <p class="text-muted mb-0" style="font-size:.82rem;">
        <c:choose>
            <c:when test="${sessionScope.userRole == 'SUPER_ADMIN'}">Configure platform-wide rules, fees, and storefront behaviour.</c:when>
            <c:otherwise>Manage your restaurant profile and operational preferences.</c:otherwise>
        </c:choose>
    </p>
</div>

<%-- ══════════════════════ SETTINGS LAYOUT ══════════════════════ --%>
<div class="settings-layout">

    <%-- ── SIDE NAV ────────────────────────────────────── --%>
    <nav class="settings-sidenav" aria-label="Settings sections" id="settings-sidenav">

        <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
            <button class="snav-link active" onclick="showPanel('platform')" id="snav-platform">
                <i class="bi bi-sliders2"></i> Platform Config
            </button>
            <button class="snav-link" onclick="showPanel('banner')" id="snav-banner">
                <i class="bi bi-megaphone-fill"></i> Storefront Banner
            </button>
            <button class="snav-link" onclick="showPanel('fees')" id="snav-fees">
                <i class="bi bi-currency-rupee"></i> Fees &amp; Commission
            </button>
            <div class="snav-divider"></div>
        </c:if>

        <button class="snav-link ${sessionScope.userRole != 'SUPER_ADMIN' ? 'active' : ''}"
                onclick="showPanel('profile')" id="snav-profile">
            <i class="bi bi-shop"></i> Restaurant Profile
        </button>
        <button class="snav-link" onclick="showPanel('hours')" id="snav-hours">
            <i class="bi bi-clock-fill"></i> Operating Hours
        </button>

        <div class="snav-divider"></div>

        <button class="snav-link" onclick="showPanel('security')" id="snav-security">
            <i class="bi bi-shield-lock-fill"></i> Security
        </button>

    </nav>

    <%-- ── PANELS CONTAINER ────────────────────────────── --%>
    <div id="settings-panels">

        <%-- ════════════════════════════════════════════════ --%>
        <%-- PANEL: PLATFORM CONFIG (admin only)             --%>
        <%-- ════════════════════════════════════════════════ --%>
        <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
            <div class="settings-panel active" id="panel-platform">

                <div class="settings-card">
                    <div class="settings-card-header">
                        <div class="settings-card-icon orange"><i class="bi bi-sliders2"></i></div>
                        <div>
                            <div class="settings-card-title">Platform Configuration</div>
                            <div class="settings-card-sub">Core settings that affect all restaurants and customers.</div>
                        </div>
                    </div>
                    <div class="settings-card-body">
                        <form action="${pageContext.request.contextPath}/manage/settings/platform"
                              method="POST" id="platform-config-form">
                            <div class="row g-3 mb-4">

                                <%-- Commission Rate --%>
                                <div class="col-12 col-md-6">
                                    <label for="commissionRate" class="form-label">Commission Rate</label>
                                    <div class="input-group-custom">
                                        <div class="input-prefix"><i class="bi bi-percent"></i></div>
                                        <input type="number" id="commissionRate" name="commissionRate"
                                               min="0" max="50" step="0.1"
                                               value="${not empty platformConfig.commissionRate ? platformConfig.commissionRate : '15'}"
                                               class="form-control">
                                    </div>
                                    <div class="form-hint">Percentage TindiTime deducts from each order payout to restaurants.</div>
                                </div>

                                <%-- Tax Rate --%>
                                <div class="col-12 col-md-6">
                                    <label for="taxRate" class="form-label">GST / Tax Rate</label>
                                    <div class="input-group-custom">
                                        <div class="input-prefix"><i class="bi bi-percent"></i></div>
                                        <input type="number" id="taxRate" name="taxRate"
                                               min="0" max="30" step="0.01"
                                               value="${not empty platformConfig.taxRate ? platformConfig.taxRate : '5'}"
                                               class="form-control">
                                    </div>
                                    <div class="form-hint">Added to the subtotal at checkout. Shown to the customer.</div>
                                </div>

                                <%-- Max Delivery Radius --%>
                                <div class="col-12 col-md-6">
                                    <label for="maxDeliveryRadius" class="form-label">Max Delivery Radius</label>
                                    <div class="input-group-custom">
                                        <input type="number" id="maxDeliveryRadius" name="maxDeliveryRadius"
                                               min="1" max="100" step="1"
                                               value="${not empty platformConfig.maxDeliveryRadius ? platformConfig.maxDeliveryRadius : '10'}"
                                               class="form-control">
                                        <div class="input-suffix">km</div>
                                    </div>
                                    <div class="form-hint">Maximum distance a restaurant will accept delivery orders from.</div>
                                </div>

                            </div>
                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn-save" id="btn-save-platform">
                                    <i class="bi bi-floppy-fill"></i> Save Platform Config
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div><%-- /panel-platform --%>

            <%-- ════════════════════════════════════════════════ --%>
            <%-- PANEL: STOREFRONT BANNER                        --%>
            <%-- ════════════════════════════════════════════════ --%>
            <div class="settings-panel" id="panel-banner">

                <div class="settings-card">
                    <div class="settings-card-header">
                        <div class="settings-card-icon yellow"><i class="bi bi-megaphone-fill"></i></div>
                        <div>
                            <div class="settings-card-title">Storefront Announcement Banner</div>
                            <div class="settings-card-sub">Display a sitewide message to all customers on the storefront.</div>
                        </div>
                    </div>
                    <div class="settings-card-body">
                        <form action="${pageContext.request.contextPath}/manage/settings/banner"
                              method="POST" id="banner-form">

                            <%-- Enable toggle --%>
                            <div class="toggle-row">
                                <div>
                                    <div class="toggle-label">Enable Banner</div>
                                    <div class="toggle-hint">When on, the message below appears on every customer page.</div>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" name="bannerEnabled"
                                           id="bannerEnabled"
                                           ${not empty platformConfig.bannerEnabled && platformConfig.bannerEnabled ? 'checked' : ''}
                                           onchange="toggleBannerPreview()">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>

                            <div class="form-group mt-3">
                                <label for="bannerType" class="form-label">Banner Type</label>
                                <select id="bannerType" name="bannerType" class="form-select"
                                        onchange="updateBannerPreview()">
                                    <option value="info"    ${platformConfig.bannerType == 'info'    ? 'selected' : ''}>ℹ️ Info (Blue)</option>
                                    <option value="warning" ${platformConfig.bannerType == 'warning' ? 'selected' : ''}>⚠️ Warning (Orange)</option>
                                    <option value="success" ${platformConfig.bannerType == 'success' ? 'selected' : ''}>✅ Success (Green)</option>
                                    <option value="error"   ${platformConfig.bannerType == 'error'   ? 'selected' : ''}>🚨 Alert (Red)</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="bannerText" class="form-label">Banner Message</label>
                                <textarea id="bannerText" name="bannerText" rows="3"
                                          placeholder="e.g. We are experiencing delays in your area due to heavy rain. Thank you for your patience."
                                          class="form-control"
                                          oninput="updateBannerPreview()"
                                          style="resize:vertical;">${not empty platformConfig.bannerText ? platformConfig.bannerText : ''}</textarea>
                                <div class="form-hint">Keep it under 150 characters for best display.</div>
                            </div>

                            <%-- Live preview --%>
                            <div class="banner-preview info" id="banner-live-preview">
                                <i class="bi bi-info-circle-fill"></i>
                                <span id="banner-preview-text">Your banner will appear here.</span>
                            </div>

                            <div class="d-flex justify-content-end mt-3">
                                <button type="submit" class="btn-save yellow" id="btn-save-banner"
                                        style="background:#ca8a04;">
                                    <i class="bi bi-megaphone-fill"></i> Save Banner
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div><%-- /panel-banner --%>

            <%-- ════════════════════════════════════════════════ --%>
            <%-- PANEL: FEES & COMMISSION                        --%>
            <%-- ════════════════════════════════════════════════ --%>
            <div class="settings-panel" id="panel-fees">

                <div class="settings-card">
                    <div class="settings-card-header">
                        <div class="settings-card-icon blue"><i class="bi bi-currency-rupee"></i></div>
                        <div>
                            <div class="settings-card-title">Delivery Fees</div>
                            <div class="settings-card-sub">Fees shown to customers at checkout.</div>
                        </div>
                    </div>
                    <div class="settings-card-body">
                        <form action="${pageContext.request.contextPath}/manage/settings/fees"
                              method="POST" id="fees-form">
                            <div class="row g-3 mb-4">

                                <div class="col-12 col-md-6">
                                    <label for="baseDeliveryFee" class="form-label">Base Delivery Fee</label>
                                    <div class="input-group-custom">
                                        <div class="input-prefix">₹</div>
                                        <input type="number" id="baseDeliveryFee" name="baseDeliveryFee"
                                               min="0" step="0.5"
                                               value="${not empty platformConfig.baseDeliveryFee ? platformConfig.baseDeliveryFee : '30'}"
                                               class="form-control">
                                    </div>
                                    <div class="form-hint">Flat fee applied to every delivery order.</div>
                                </div>

                                <div class="col-12 col-md-6">
                                    <label for="perKmRate" class="form-label">Per-Kilometre Rate</label>
                                    <div class="input-group-custom">
                                        <div class="input-prefix">₹</div>
                                        <input type="number" id="perKmRate" name="perKmRate"
                                               min="0" step="0.5"
                                               value="${not empty platformConfig.perKmRate ? platformConfig.perKmRate : '5'}"
                                               class="form-control">
                                        <div class="input-suffix">/ km</div>
                                    </div>
                                    <div class="form-hint">Added on top of the base fee for every km beyond 2km.</div>
                                </div>

                                <%-- Free delivery threshold --%>
                                <div class="col-12 col-md-6">
                                    <label for="freeDeliveryThreshold" class="form-label">Free Delivery Above</label>
                                    <div class="input-group-custom">
                                        <div class="input-prefix">₹</div>
                                        <input type="number" id="freeDeliveryThreshold" name="freeDeliveryThreshold"
                                               min="0" step="10"
                                               value="${not empty platformConfig.freeDeliveryThreshold ? platformConfig.freeDeliveryThreshold : '0'}"
                                               class="form-control">
                                    </div>
                                    <div class="form-hint">Orders above this amount get free delivery. Set 0 to disable.</div>
                                </div>

                            </div>

                            <%-- Fee preview calculator --%>
                            <div class="p-3 rounded-3 mb-4"
                                 style="background:#f9fafb;border:1px solid #f3f4f6;">
                                <div style="font-size:.72rem;font-weight:800;text-transform:uppercase;
                                            letter-spacing:.6px;color:#9ca3af;margin-bottom:.6rem;">
                                    Fee Preview (for 5km delivery)
                                </div>
                                <div class="d-flex justify-content-between"
                                     style="font-size:.83rem;font-weight:600;color:#374151;">
                                    <span>Base fee:</span>
                                    <span id="preview-base">₹30</span>
                                </div>
                                <div class="d-flex justify-content-between mt-1"
                                     style="font-size:.83rem;font-weight:600;color:#374151;">
                                    <span>Distance (3km extra × rate):</span>
                                    <span id="preview-km">₹15</span>
                                </div>
                                <div class="d-flex justify-content-between mt-1 pt-2"
                                     style="font-size:.9rem;font-weight:800;color:#f97316;border-top:1px solid #e5e7eb;">
                                    <span>Total delivery fee:</span>
                                    <span id="preview-total">₹45</span>
                                </div>
                            </div>

                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn-save blue" id="btn-save-fees">
                                    <i class="bi bi-floppy-fill"></i> Save Fee Settings
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div><%-- /panel-fees --%>
        </c:if>

        <%-- ════════════════════════════════════════════════ --%>
        <%-- PANEL: RESTAURANT PROFILE (both roles)          --%>
        <%-- ════════════════════════════════════════════════ --%>
        <div class="settings-panel ${sessionScope.userRole != 'SUPER_ADMIN' ? 'active' : ''}"
             id="panel-profile">

            <div class="settings-card">
                <div class="settings-card-header">
                    <div class="settings-card-icon green"><i class="bi bi-shop-window"></i></div>
                    <div>
                        <div class="settings-card-title">Restaurant Profile</div>
                        <div class="settings-card-sub">Public-facing details shown to customers on the storefront.</div>
                    </div>
                </div>
                <div class="settings-card-body">
                    <form action="${pageContext.request.contextPath}/manage/settings/profile"
                          method="POST" id="profile-form">
                        <div class="row g-3 mb-4">

                            <div class="col-12 col-md-8">
                                <label for="restName" class="form-label">Restaurant Name *</label>
                                <input type="text" id="restName" name="name" required
                                       value="${not empty restaurantProfile.name ? restaurantProfile.name : ''}"
                                       class="form-control" placeholder="e.g. The Spice Garden">
                            </div>

                            <div class="col-12 col-md-4">
                                <label for="restCuisine" class="form-label">Cuisine Type *</label>
                                <input type="text" id="restCuisine" name="cuisineType" required
                                       value="${not empty restaurantProfile.cuisineType ? restaurantProfile.cuisineType : ''}"
                                       class="form-control" placeholder="e.g. Indian, Chinese"
                                       list="cuisine-list">
                                <datalist id="cuisine-list">
                                    <option value="Indian"><option value="Chinese">
                                    <option value="Italian"><option value="Mexican">
                                    <option value="Burgers"><option value="Pizza">
                                    <option value="Biryani"><option value="North Indian">
                                    <option value="South Indian"><option value="Desserts">
                                </datalist>
                            </div>

                            <div class="col-12">
                                <label for="restDesc" class="form-label">Description</label>
                                <textarea id="restDesc" name="description" rows="3"
                                          placeholder="Brief description of your restaurant and specialty dishes…"
                                          class="form-control" style="resize:vertical;">${not empty restaurantProfile.description ? restaurantProfile.description : ''}</textarea>
                            </div>

                            <div class="col-12 col-md-6">
                                <label for="restPhone" class="form-label">Contact Phone</label>
                                <input type="tel" id="restPhone" name="phone"
                                       value="${not empty restaurantProfile.phone ? restaurantProfile.phone : ''}"
                                       class="form-control" placeholder="+91 XXXXX XXXXX">
                            </div>

                            <div class="col-12 col-md-6">
                                <label for="restEmail" class="form-label">Contact Email</label>
                                <input type="email" id="restEmail" name="email"
                                       value="${not empty restaurantProfile.email ? restaurantProfile.email : ''}"
                                       class="form-control" placeholder="contact@restaurant.com">
                            </div>

                            <div class="col-12">
                                <label for="restAddress" class="form-label">Street Address</label>
                                <input type="text" id="restAddress" name="address"
                                       value="${not empty restaurantProfile.address ? restaurantProfile.address : ''}"
                                       class="form-control" placeholder="Building, Street, Area">
                            </div>

                            <div class="col-12 col-md-6">
                                <label for="restCity" class="form-label">City</label>
                                <input type="text" id="restCity" name="city"
                                       value="${not empty restaurantProfile.city ? restaurantProfile.city : ''}"
                                       class="form-control">
                            </div>

                            <div class="col-12 col-md-6">
                                <label for="restPostal" class="form-label">Postal Code</label>
                                <input type="text" id="restPostal" name="postalCode"
                                       value="${not empty restaurantProfile.postalCode ? restaurantProfile.postalCode : ''}"
                                       class="form-control">
                            </div>

                            <%-- Logo URL + preview --%>
                            <div class="col-12">
                                <label for="restLogo" class="form-label">Logo / Cover Image URL</label>
                                <input type="url" id="restLogo" name="logoUrl"
                                       value="${not empty restaurantProfile.logoUrl ? restaurantProfile.logoUrl : ''}"
                                       class="form-control" placeholder="https://example.com/logo.jpg"
                                       oninput="previewLogo()">
                                <img id="logo-preview"
                                     src="${not empty restaurantProfile.logoUrl ? restaurantProfile.logoUrl : ''}"
                                     alt="Logo preview"
                                     style="${not empty restaurantProfile.logoUrl ? 'display:block;' : 'display:none;'}">
                            </div>

                        </div>
                        <div class="d-flex justify-content-end">
                            <button type="submit" class="btn-save green" id="btn-save-profile">
                                <i class="bi bi-floppy-fill"></i> Save Profile
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div><%-- /panel-profile --%>

        <%-- ════════════════════════════════════════════════ --%>
        <%-- PANEL: OPERATING HOURS                          --%>
        <%-- ════════════════════════════════════════════════ --%>
        <div class="settings-panel" id="panel-hours">

            <%-- Open / Closed hero --%>
            <div class="open-closed-hero ${not empty restaurantProfile.isOpen && restaurantProfile.isOpen ? 'open-state' : 'closed-state'}"
                 id="open-closed-hero">
                <div>
                    <div class="open-status-label ${not empty restaurantProfile.isOpen && restaurantProfile.isOpen ? 'open' : 'closed'}"
                         id="open-status-text">
                        <i class="bi bi-circle-fill me-2" style="font-size:.65rem;"></i>
                        ${not empty restaurantProfile.isOpen && restaurantProfile.isOpen ? 'Currently Open' : 'Currently Closed'}
                    </div>
                    <div class="open-status-sub">Toggle your live status below. Customers see this in real time.</div>
                </div>
                <form action="${pageContext.request.contextPath}/manage/settings/status"
                      method="POST" id="open-status-form">
                    <label class="toggle-switch" style="width:54px;height:30px;">
                        <input type="checkbox" name="isOpen" id="isOpenToggle"
                               ${not empty restaurantProfile.isOpen && restaurantProfile.isOpen ? 'checked' : ''}
                               onchange="document.getElementById('open-status-form').submit()">
                        <span class="toggle-slider"></span>
                    </label>
                </form>
            </div>

            <div class="settings-card">
                <div class="settings-card-header">
                    <div class="settings-card-icon teal"><i class="bi bi-clock-fill"></i></div>
                    <div>
                        <div class="settings-card-title">Operating Hours</div>
                        <div class="settings-card-sub">Set your regular open and close times.</div>
                    </div>
                </div>
                <div class="settings-card-body">
                    <form action="${pageContext.request.contextPath}/manage/settings/hours"
                          method="POST" id="hours-form">
                        <div class="row g-3 mb-4">
                            <div class="col-12 col-md-6">
                                <label for="openTime" class="form-label">Opening Time</label>
                                <input type="time" id="openTime" name="openTime"
                                       value="${not empty restaurantProfile.openTime ? restaurantProfile.openTime : '09:00'}"
                                       class="form-control">
                            </div>
                            <div class="col-12 col-md-6">
                                <label for="closeTime" class="form-label">Closing Time</label>
                                <input type="time" id="closeTime" name="closeTime"
                                       value="${not empty restaurantProfile.closeTime ? restaurantProfile.closeTime : '22:00'}"
                                       class="form-control">
                            </div>
                        </div>

                        <%-- Days of week --%>
                        <div class="form-group">
                            <label class="form-label">Open Days</label>
                            <div class="d-flex gap-2 flex-wrap">
                                <c:forEach var="day"
                                           items="Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday">
                                    <label class="d-flex align-items-center gap-1"
                                           style="font-size:.8rem;font-weight:600;cursor:pointer;">
                                        <input type="checkbox" name="openDays" value="${day}"
                                               style="cursor:pointer;"
                                               checked>
                                        ${day.substring(0,3)}
                                    </label>
                                </c:forEach>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end mt-3">
                            <button type="submit" class="btn-save" id="btn-save-hours"
                                    style="background:#14b8a6;">
                                <i class="bi bi-floppy-fill"></i> Save Hours
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div><%-- /panel-hours --%>

        <%-- ════════════════════════════════════════════════ --%>
        <%-- PANEL: SECURITY                                 --%>
        <%-- ════════════════════════════════════════════════ --%>
        <div class="settings-panel" id="panel-security">

            <%-- Change Password --%>
            <div class="settings-card mb-3">
                <div class="settings-card-header">
                    <div class="settings-card-icon red"><i class="bi bi-key-fill"></i></div>
                    <div>
                        <div class="settings-card-title">Change Password</div>
                        <div class="settings-card-sub">Use a strong password of at least 8 characters.</div>
                    </div>
                </div>
                <div class="settings-card-body">
                    <form action="${pageContext.request.contextPath}/manage/settings/password"
                          method="POST" id="password-form" onsubmit="return validatePasswords()">
                        <div class="row g-3 mb-4">

                            <div class="col-12">
                                <label for="currentPassword" class="form-label">Current Password</label>
                                <input type="password" id="currentPassword" name="currentPassword"
                                       required class="form-control" placeholder="••••••••">
                            </div>

                            <div class="col-12 col-md-6">
                                <label for="newPassword" class="form-label">New Password</label>
                                <input type="password" id="newPassword" name="newPassword"
                                       required class="form-control" placeholder="••••••••"
                                       oninput="checkStrength(this.value)">
                                <div class="strength-bar">
                                    <div class="strength-fill" id="strength-fill"></div>
                                </div>
                                <div class="strength-label" id="strength-label" style="color:#9ca3af;">
                                    Enter a password
                                </div>
                            </div>

                            <div class="col-12 col-md-6">
                                <label for="confirmPassword" class="form-label">Confirm New Password</label>
                                <input type="password" id="confirmPassword" name="confirmPassword"
                                       required class="form-control" placeholder="••••••••">
                            </div>

                        </div>
                        <div class="d-flex justify-content-end">
                            <button type="submit" class="btn-save red" id="btn-save-password">
                                <i class="bi bi-shield-lock-fill"></i> Update Password
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <%-- Session info --%>
            <div class="settings-card">
                <div class="settings-card-header">
                    <div class="settings-card-icon purple"><i class="bi bi-person-badge-fill"></i></div>
                    <div>
                        <div class="settings-card-title">Account Info</div>
                        <div class="settings-card-sub">Your current session details.</div>
                    </div>
                </div>
                <div class="settings-card-body">
                    <div class="toggle-row">
                        <div><div class="toggle-label">Logged in as</div></div>
                        <div style="font-weight:700;color:#111827;">${sessionScope.userName}</div>
                    </div>
                    <div class="toggle-row">
                        <div><div class="toggle-label">Email</div></div>
                        <div style="font-weight:700;color:#111827;">${sessionScope.userEmail}</div>
                    </div>
                    <div class="toggle-row">
                        <div><div class="toggle-label">Role</div></div>
                        <div>
                            <c:choose>
                                <c:when test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                                    <span style="background:#fff7ed;color:#c2410c;font-size:.72rem;
                                                 font-weight:700;padding:3px 10px;border-radius:99px;">
                                        <i class="bi bi-shield-fill-check me-1"></i>Super Admin
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span style="background:#f0fdf4;color:#15803d;font-size:.72rem;
                                                 font-weight:700;padding:3px 10px;border-radius:99px;">
                                        <i class="bi bi-shop me-1"></i>Restaurant Owner
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="toggle-row">
                        <div>
                            <div class="toggle-label">Sign Out</div>
                            <div class="toggle-hint">Ends your current session immediately.</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/logout"
                           class="btn-save red" style="font-size:.8rem;padding:.4rem 1rem;text-decoration:none;"
                           id="settings-logout-btn">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </div>
                </div>
            </div>

        </div><%-- /panel-security --%>

    </div><%-- /settings-panels --%>
</div><%-- /settings-layout --%>

<%-- ══════════════════════ PAGE SCRIPTS ══════════════════════ --%>
<script>
/* ── Panel switching ── */
function showPanel(panelId) {
    document.querySelectorAll('.settings-panel').forEach(function(p) { p.classList.remove('active'); });
    document.querySelectorAll('.snav-link').forEach(function(l) { l.classList.remove('active'); });
    var panel = document.getElementById('panel-' + panelId);
    var link  = document.getElementById('snav-' + panelId);
    if (panel) panel.classList.add('active');
    if (link)  link.classList.add('active');
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

/* ── Banner live preview ── */
function updateBannerPreview() {
    var text  = document.getElementById('bannerText').value.trim();
    var type  = document.getElementById('bannerType').value;
    var box   = document.getElementById('banner-live-preview');
    var textEl = document.getElementById('banner-preview-text');
    var iconMap = { info:'bi-info-circle-fill', warning:'bi-exclamation-triangle-fill',
                    success:'bi-check-circle-fill', error:'bi-x-circle-fill' };
    box.className = 'banner-preview ' + type;
    box.querySelector('i').className = 'bi ' + (iconMap[type] || 'bi-info-circle-fill');
    textEl.textContent = text || 'Your banner message will appear here.';
    if (document.getElementById('bannerEnabled').checked) { box.style.display = 'flex'; }
}
function toggleBannerPreview() {
    var box = document.getElementById('banner-live-preview');
    box.style.display = document.getElementById('bannerEnabled').checked ? 'flex' : 'none';
    updateBannerPreview();
}
/* Init on load */
(function() {
    var be = document.getElementById('bannerEnabled');
    if (be && be.checked) { updateBannerPreview(); document.getElementById('banner-live-preview').style.display='flex'; }
})();

/* ── Fee preview calculator ── */
function updateFeePreview() {
    var base   = parseFloat(document.getElementById('baseDeliveryFee').value) || 0;
    var perKm  = parseFloat(document.getElementById('perKmRate').value) || 0;
    var extra  = 3 * perKm;
    document.getElementById('preview-base').textContent  = '₹' + base.toFixed(0);
    document.getElementById('preview-km').textContent    = '₹' + extra.toFixed(0);
    document.getElementById('preview-total').textContent = '₹' + (base + extra).toFixed(0);
}
(function() {
    var bf = document.getElementById('baseDeliveryFee');
    var pk = document.getElementById('perKmRate');
    if (bf) { bf.addEventListener('input', updateFeePreview); pk.addEventListener('input', updateFeePreview); }
})();

/* ── Logo preview ── */
function previewLogo() {
    var url = document.getElementById('restLogo').value.trim();
    var img = document.getElementById('logo-preview');
    if (url) { img.src = url; img.style.display = 'block'; img.onerror = function() { img.style.display = 'none'; }; }
    else { img.style.display = 'none'; }
}

/* ── Password strength ── */
function checkStrength(val) {
    var fill  = document.getElementById('strength-fill');
    var label = document.getElementById('strength-label');
    var score = 0;
    if (val.length >= 8) score++;
    if (/[A-Z]/.test(val)) score++;
    if (/[0-9]/.test(val)) score++;
    if (/[^A-Za-z0-9]/.test(val)) score++;
    var map = [
        { w:'10%',  bg:'#ef4444', lbl:'Too short',  color:'#ef4444' },
        { w:'35%',  bg:'#f97316', lbl:'Weak',        color:'#f97316' },
        { w:'60%',  bg:'#ca8a04', lbl:'Fair',        color:'#ca8a04' },
        { w:'85%',  bg:'#22c55e', lbl:'Good',        color:'#22c55e' },
        { w:'100%', bg:'#15803d', lbl:'Strong 💪',   color:'#15803d' }
    ];
    var m = map[score];
    fill.style.width      = val.length ? m.w  : '0%';
    fill.style.background = val.length ? m.bg : '#f3f4f6';
    label.textContent     = val.length ? m.lbl : 'Enter a password';
    label.style.color     = val.length ? m.color : '#9ca3af';
}

/* ── Password match validation ── */
function validatePasswords() {
    var np = document.getElementById('newPassword').value;
    var cp = document.getElementById('confirmPassword').value;
    if (np !== cp) { alert('New password and confirmation do not match.'); return false; }
    if (np.length < 8) { alert('Password must be at least 8 characters long.'); return false; }
    return true;
}
</script>

<jsp:include page="manage-sidebar-close.jsp"/>
