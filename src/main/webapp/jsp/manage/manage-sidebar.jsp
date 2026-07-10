<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    MANAGE SIDEBAR COMPONENT
    Shared master layout shell for all /manage/* pages.
    Usage: include this file at the top of every manage-*.jsp page.
    It opens <html>, <head>, <body>, and the sidebar+topbar wrapper.
    The calling page provides the main content, then includes manage-sidebar-close.jsp to close tags.

    Expected request attributes from calling page:
      - pageTitle    : String  — used in <title> and topbar heading
      - activeNav    : String  — matches a nav item key to set 'active' highlight
--%>
<!DOCTYPE html>
<html lang="en" id="root-html-manage">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty pageTitle ? pageTitle : 'Control Center'} — HungryGO Admin</title>

    <%-- Bootstrap 5 CSS --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <%-- Bootstrap Icons --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <%-- Google Fonts: Outfit --%>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        /* ── Base ─────────────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: #f4f6fb;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ── Sidebar ──────────────────────────────────────────────── */
        :root {
            --sidebar-w: 256px;
            --topbar-h: 64px;
            --sidebar-bg: #111827;
            --sidebar-hover: #1f2937;
            --sidebar-active: #f97316;
            --sidebar-active-bg: rgba(249,115,22,.12);
            --sidebar-text: #9ca3af;
            --sidebar-text-bright: #f9fafb;
        }

        #manage-sidebar {
            position: fixed;
            top: 0; left: 0;
            width: var(--sidebar-w);
            height: 100vh;
            background: var(--sidebar-bg);
            display: flex;
            flex-direction: column;
            z-index: 1040;
            transition: transform .3s ease;
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: #374151 transparent;
        }
        #manage-sidebar::-webkit-scrollbar { width: 4px; }
        #manage-sidebar::-webkit-scrollbar-thumb { background: #374151; border-radius: 99px; }

        /* Brand area */
        .sidebar-brand {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid #1f2937;
            flex-shrink: 0;
        }
        .sidebar-brand a {
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: .75rem;
        }
        .brand-icon {
            width: 38px; height: 38px;
            background: linear-gradient(135deg, #f97316, #ea580c);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        .brand-text { font-size: 1.2rem; font-weight: 800; color: #fff; }
        .brand-text span { color: #f97316; }
        .brand-badge {
            display: inline-block;
            font-size: 9px;
            font-weight: 700;
            background: #f97316;
            color: #fff;
            padding: 2px 6px;
            border-radius: 4px;
            letter-spacing: .5px;
            margin-left: auto;
            text-transform: uppercase;
        }

        /* Role pill */
        .sidebar-role-pill {
            margin: 1rem 1.25rem .5rem;
            background: #1f2937;
            border-radius: 8px;
            padding: .6rem 1rem;
            display: flex;
            align-items: center;
            gap: .5rem;
        }
        .role-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            flex-shrink: 0;
        }
        .role-dot.admin  { background: #f97316; }
        .role-dot.owner  { background: #22c55e; }
        .sidebar-role-pill span { font-size: .75rem; color: var(--sidebar-text); font-weight: 600; }
        .sidebar-role-pill strong { font-size: .78rem; color: #fff; display: block; }

        /* Nav sections */
        .sidebar-nav { flex: 1; padding: .75rem 0; }
        .nav-section-label {
            padding: .75rem 1.5rem .35rem;
            font-size: .65rem;
            font-weight: 700;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            color: #4b5563;
        }
        .sidebar-nav .nav-link {
            display: flex;
            align-items: center;
            gap: .75rem;
            padding: .6rem 1.5rem;
            font-size: .875rem;
            font-weight: 500;
            color: var(--sidebar-text);
            border-radius: 0;
            transition: background .15s, color .15s;
            position: relative;
        }
        .sidebar-nav .nav-link i { font-size: 1rem; flex-shrink: 0; }
        .sidebar-nav .nav-link:hover {
            background: var(--sidebar-hover);
            color: #e5e7eb;
        }
        .sidebar-nav .nav-link.active {
            background: var(--sidebar-active-bg);
            color: var(--sidebar-active);
            font-weight: 600;
        }
        .sidebar-nav .nav-link.active::before {
            content: '';
            position: absolute;
            left: 0; top: 0; bottom: 0;
            width: 3px;
            background: var(--sidebar-active);
            border-radius: 0 2px 2px 0;
        }
        /* Badge on nav item */
        .nav-badge {
            margin-left: auto;
            font-size: .65rem;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 99px;
            background: #f97316;
            color: #fff;
        }
        .nav-badge.green { background: #22c55e; }

        /* Sidebar divider */
        .sidebar-divider {
            border-top: 1px solid #1f2937;
            margin: .5rem 1.25rem;
        }

        /* Sidebar footer */
        .sidebar-footer {
            padding: 1rem 1.25rem;
            border-top: 1px solid #1f2937;
            flex-shrink: 0;
        }
        .sidebar-footer .avatar-row {
            display: flex;
            align-items: center;
            gap: .75rem;
        }
        .avatar-circle {
            width: 36px; height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #f97316, #ea580c);
            color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700;
            font-size: .875rem;
            flex-shrink: 0;
        }
        .avatar-info .name  { font-size: .8rem; font-weight: 700; color: #f9fafb; }
        .avatar-info .email { font-size: .7rem; color: #6b7280; }
        .sidebar-footer .logout-btn {
            margin-left: auto;
            color: #6b7280;
            transition: color .15s;
        }
        .sidebar-footer .logout-btn:hover { color: #ef4444; }

        /* ── Top Bar ──────────────────────────────────────────────── */
        #manage-topbar {
            position: fixed;
            top: 0;
            left: var(--sidebar-w);
            right: 0;
            height: var(--topbar-h);
            background: #fff;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            padding: 0 1.5rem;
            z-index: 1030;
            gap: 1rem;
        }
        .topbar-title { font-size: 1.1rem; font-weight: 700; color: #111827; }
        .topbar-actions { margin-left: auto; display: flex; align-items: center; gap: .75rem; }
        .topbar-icon-btn {
            width: 38px; height: 38px;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            background: #fff;
            display: flex; align-items: center; justify-content: center;
            color: #6b7280;
            font-size: .95rem;
            transition: border-color .15s, color .15s;
            cursor: pointer;
            text-decoration: none;
        }
        .topbar-icon-btn:hover { border-color: #f97316; color: #f97316; }
        .topbar-hamburger {
            display: none;
            background: none;
            border: none;
            font-size: 1.3rem;
            color: #374151;
            cursor: pointer;
            padding: 0;
            line-height: 1;
        }

        /* ── Main content area ───────────────────────────────────── */
        #manage-content {
            margin-left: var(--sidebar-w);
            padding-top: var(--topbar-h);
            min-height: 100vh;
        }
        .manage-body { padding: 2rem 1.75rem; }

        /* ── Responsive ──────────────────────────────────────────── */
        @media (max-width: 991.98px) {
            #manage-sidebar { transform: translateX(calc(-1 * var(--sidebar-w))); }
            #manage-sidebar.open { transform: translateX(0); box-shadow: 0 0 60px rgba(0,0,0,.45); }
            #manage-topbar { left: 0; }
            #manage-content { margin-left: 0; }
            .topbar-hamburger { display: block; }
            .sidebar-overlay {
                display: none;
                position: fixed; inset: 0;
                background: rgba(0,0,0,.45);
                z-index: 1039;
            }
            .sidebar-overlay.show { display: block; }
        }
        @media (max-width: 575.98px) {
            .manage-body { padding: 1.25rem 1rem; }
        }
    </style>
</head>
<body id="body-manage">

<%-- Sidebar overlay for mobile --%>
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- SIDEBAR                                                     -->
<!-- ═══════════════════════════════════════════════════════════ -->
<aside id="manage-sidebar" aria-label="Admin Sidebar">

    <%-- Brand --%>
    <div class="sidebar-brand">
        <a href="${pageContext.request.contextPath}/index">
            <div class="brand-icon"><i class="bi bi-lightning-charge-fill"></i></div>
            <span class="brand-text">Hungry<span>GO</span></span>
            <span class="brand-badge">Admin</span>
        </a>
    </div>

    <%-- Logged-in Role Pill --%>
    <div class="sidebar-role-pill">
        <c:choose>
            <c:when test="${sessionScope.userRole == 'SUPER_ADMIN'}">
                <span class="role-dot admin"></span>
                <div>
                    <strong>${not empty sessionScope.userName ? sessionScope.userName : 'Administrator'}</strong>
                    <span>Super Admin</span>
                </div>
            </c:when>
            <c:otherwise>
                <span class="role-dot owner"></span>
                <div>
                    <strong>${not empty sessionScope.userName ? sessionScope.userName : 'Partner'}</strong>
                    <span>Restaurant Owner</span>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- Navigation --%>
    <nav class="sidebar-nav" aria-label="Manage Navigation">

        <%-- Overview --%>
        <div class="nav-section-label">Overview</div>

        <a href="${pageContext.request.contextPath}/manage/dashboard"
           class="nav-link ${activeNav == 'dashboard' ? 'active' : ''}" id="sidenav-dashboard">
            <i class="bi bi-grid-1x2-fill"></i>
            <span>Dashboard</span>
        </a>

        <a href="${pageContext.request.contextPath}/manage/orders"
           class="nav-link ${activeNav == 'orders' ? 'active' : ''}" id="sidenav-orders">
            <i class="bi bi-receipt-cutoff"></i>
            <span>Order Management</span>
            <span class="nav-badge green">Live</span>
        </a>

        <%-- Catalog --%>
        <div class="nav-section-label">Catalog</div>

        <a href="${pageContext.request.contextPath}/manage/catalog"
           class="nav-link ${activeNav == 'catalog' ? 'active' : ''}" id="sidenav-catalog">
            <i class="bi bi-journal-text"></i>
            <span>Menu / Catalog</span>
        </a>

        <a href="${pageContext.request.contextPath}/manage/reviews"
           class="nav-link ${activeNav == 'reviews' ? 'active' : ''}" id="sidenav-reviews">
            <i class="bi bi-star-half"></i>
            <span>Reviews & Ratings</span>
        </a>

        <%-- Admin-only section --%>
        <c:if test="${sessionScope.userRole == 'SUPER_ADMIN'}">
            <div class="nav-section-label">Platform Admin</div>

            <a href="${pageContext.request.contextPath}/manage/restaurants"
               class="nav-link ${activeNav == 'restaurants' ? 'active' : ''}" id="sidenav-restaurants">
                <i class="bi bi-shop-window"></i>
                <span>Restaurants</span>
                <c:if test="${not empty pendingApprovals && pendingApprovals > 0}">
                    <span class="nav-badge">${pendingApprovals}</span>
                </c:if>
            </a>

            <a href="${pageContext.request.contextPath}/manage/users"
               class="nav-link ${activeNav == 'users' ? 'active' : ''}" id="sidenav-users">
                <i class="bi bi-people-fill"></i>
                <span>User Management</span>
            </a>

            <a href="${pageContext.request.contextPath}/manage/promos"
               class="nav-link ${activeNav == 'promos' ? 'active' : ''}" id="sidenav-promos">
                <i class="bi bi-tags-fill"></i>
                <span>Promo Codes</span>
            </a>
        </c:if>

        <%-- Config --%>
        <div class="nav-section-label">Config</div>

        <a href="${pageContext.request.contextPath}/manage/settings"
           class="nav-link ${activeNav == 'settings' ? 'active' : ''}" id="sidenav-settings">
            <i class="bi bi-gear-fill"></i>
            <span>Settings</span>
        </a>

        <div class="sidebar-divider"></div>

        <%-- Back to storefront --%>
        <a href="${pageContext.request.contextPath}/index" class="nav-link" id="sidenav-storefront">
            <i class="bi bi-arrow-left-circle"></i>
            <span>Back to Storefront</span>
        </a>
    </nav>

    <%-- Sidebar Footer — Avatar & Logout --%>
    <div class="sidebar-footer">
        <div class="avatar-row">
            <div class="avatar-circle">
                ${not empty sessionScope.userName ? sessionScope.userName.substring(0,1).toUpperCase() : 'A'}
            </div>
            <div class="avatar-info">
                <div class="name">${not empty sessionScope.userName ? sessionScope.userName : 'Admin User'}</div>
                <div class="email">${not empty sessionScope.userEmail ? sessionScope.userEmail : 'admin@hungrygo.com'}</div>
            </div>
            <a href="${pageContext.request.contextPath}/login?action=logout" class="logout-btn" title="Logout" id="sidenav-logout">
                <i class="bi bi-box-arrow-right fs-5"></i>
            </a>
        </div>
    </div>

</aside>

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- TOP BAR                                                     -->
<!-- ═══════════════════════════════════════════════════════════ -->
<div id="manage-topbar">
    <button class="topbar-hamburger" id="sidebarToggleBtn" aria-label="Toggle Sidebar">
        <i class="bi bi-list"></i>
    </button>
    <span class="topbar-title">${not empty pageTitle ? pageTitle : 'Control Center'}</span>
    <div class="topbar-actions">
        <a href="${pageContext.request.contextPath}/manage/orders" class="topbar-icon-btn" title="Orders" id="topbar-orders-btn">
            <i class="bi bi-receipt-cutoff"></i>
        </a>
        <a href="${pageContext.request.contextPath}/manage/settings" class="topbar-icon-btn" title="Settings" id="topbar-settings-btn">
            <i class="bi bi-gear"></i>
        </a>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- MAIN CONTENT WRAPPER — calling JSP injects body here       -->
<!-- ═══════════════════════════════════════════════════════════ -->
<main id="manage-content">
    <div class="manage-body">
