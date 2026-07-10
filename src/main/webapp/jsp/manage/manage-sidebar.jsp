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
    <title>${not empty pageTitle ? pageTitle : 'Control Center'} — TindiTime Admin</title>

    <%-- Bootstrap 5 CSS --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <%-- Custom Theme CSS --%>
    <link href="${pageContext.request.contextPath}/jsp/style.css?v=2" rel="stylesheet">
    <%-- Bootstrap Icons --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        /* ═══════════════════════════════════════════════════════════
           ADMIN PANEL — Sweetgreen Design System
           ═══════════════════════════════════════════════════════════ */

        /* ── Layout variables ─────────────────────────────────────── */
        :root {
            --sidebar-w:          256px;
            --topbar-h:           64px;
            /* Sidebar palette — Deep Forest */
            --sidebar-bg:         #00473c;
            --sidebar-hover:      rgba(14,21,14,0.5);
            --sidebar-active:     #e6ff55;
            --sidebar-active-bg:  rgba(230,255,85,0.12);
            --sidebar-text:       #b8d4bf;
            --sidebar-text-dim:   rgba(216,229,214,0.55);
            --sidebar-border:     rgba(255,255,255,0.08);
        }

        /* ── Reset ────────────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; }
        body {
            font-family: var(--font-body, 'Outfit', sans-serif);
            background: var(--color-cream-canvas, #f4f3e7);
            color: var(--color-forest-shadow, #0e150e);
            min-height: 100vh;
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
        }

        /* ── Sidebar ──────────────────────────────────────────────── */
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
            scrollbar-color: rgba(255,255,255,0.15) transparent;
        }
        #manage-sidebar::-webkit-scrollbar { width: 4px; }
        #manage-sidebar::-webkit-scrollbar-thumb {
            background: rgba(255,255,255,0.15);
            border-radius: 99px;
        }

        /* Brand */
        .sidebar-brand {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--sidebar-border);
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
            background: var(--sidebar-active);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #0e150e;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        .brand-text { font-size: 1.2rem; font-weight: 800; color: #fff; letter-spacing: -0.3px; }
        .brand-text span { color: var(--sidebar-active); }
        .brand-badge {
            font-size: 9px;
            font-weight: 700;
            background: var(--sidebar-active);
            color: #0e150e;
            padding: 2px 8px;
            border-radius: 4px;
            letter-spacing: .5px;
            margin-left: auto;
            text-transform: uppercase;
        }

        /* Role pill */
        .sidebar-role-pill {
            margin: 1rem 1.25rem .5rem;
            background: rgba(255,255,255,0.07);
            border: 1px solid var(--sidebar-border);
            border-radius: 10px;
            padding: .65rem 1rem;
            display: flex;
            align-items: center;
            gap: .6rem;
        }
        .role-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            flex-shrink: 0;
        }
        .role-dot.admin  { background: var(--sidebar-active); }
        .role-dot.owner  { background: #4ade80; }
        .sidebar-role-pill span   { font-size: .72rem; color: var(--sidebar-text); font-weight: 600; letter-spacing: .02em; }
        .sidebar-role-pill strong { font-size: .8rem; color: #fff; display: block; font-weight: 700; }

        /* Nav sections */
        .sidebar-nav { flex: 1; padding: .75rem 0; }
        .nav-section-label {
            padding: .85rem 1.5rem .3rem;
            font-size: .6rem;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--sidebar-text-dim);
        }
        .sidebar-nav .nav-link {
            display: flex;
            align-items: center;
            gap: .75rem;
            padding: .62rem 1.25rem .62rem 1.5rem;
            margin: 1px .75rem;
            font-size: .875rem;
            font-weight: 500;
            color: var(--sidebar-text);
            border-radius: 10px;
            transition: background .15s, color .15s;
            position: relative;
            text-decoration: none;
        }
        .sidebar-nav .nav-link i { font-size: 1rem; flex-shrink: 0; opacity: 0.8; }
        .sidebar-nav .nav-link:hover {
            background: rgba(255,255,255,0.08);
            color: #fff;
        }
        .sidebar-nav .nav-link.active {
            background: var(--sidebar-active-bg);
            color: var(--sidebar-active);
            font-weight: 700;
        }
        .sidebar-nav .nav-link.active i { opacity: 1; }
        .sidebar-nav .nav-link.active::before {
            content: '';
            position: absolute;
            left: -12px; top: 20%; bottom: 20%;
            width: 3px;
            background: var(--sidebar-active);
            border-radius: 99px;
        }

        /* Nav badge */
        .nav-badge {
            margin-left: auto;
            font-size: .62rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 99px;
            background: var(--sidebar-active);
            color: #0e150e;
        }
        .nav-badge.green { background: #4ade80; color: #052e16; }

        /* Divider */
        .sidebar-divider {
            border-top: 1px solid var(--sidebar-border);
            margin: .6rem 1.25rem;
        }

        /* Sidebar footer */
        .sidebar-footer {
            padding: 1rem 1.25rem;
            border-top: 1px solid var(--sidebar-border);
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
            background: var(--sidebar-active);
            color: #0e150e;
            display: flex; align-items: center; justify-content: center;
            font-weight: 800;
            font-size: .875rem;
            flex-shrink: 0;
        }
        .avatar-info .name  { font-size: .82rem; font-weight: 700; color: #fff; }
        .avatar-info .email { font-size: .68rem; color: var(--sidebar-text); margin-top: 1px; }
        .sidebar-footer .logout-btn {
            margin-left: auto;
            color: var(--sidebar-text);
            transition: color .15s;
            text-decoration: none;
            font-size: 1.1rem;
        }
        .sidebar-footer .logout-btn:hover { color: #f87171; }

        /* ── Top Bar ──────────────────────────────────────────────── */
        #manage-topbar {
            position: fixed;
            top: 0;
            left: var(--sidebar-w);
            right: 0;
            height: var(--topbar-h);
            background: var(--color-cream-canvas, #f4f3e7);
            border-bottom: 1px solid rgba(140,140,130,0.25);
            display: flex;
            align-items: center;
            padding: 0 1.75rem;
            z-index: 1030;
            gap: 1rem;
        }
        .topbar-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--color-forest-shadow, #0e150e);
            letter-spacing: -0.2px;
        }
        .topbar-breadcrumb {
            font-size: .75rem;
            color: var(--color-warm-gray, #8c8c82);
            margin-top: 1px;
        }
        .topbar-actions { margin-left: auto; display: flex; align-items: center; gap: .6rem; }
        .topbar-icon-btn {
            width: 36px; height: 36px;
            border: 1.5px solid rgba(140,140,130,0.3);
            border-radius: 9px;
            background: #fff;
            display: flex; align-items: center; justify-content: center;
            color: var(--color-warm-gray, #8c8c82);
            font-size: .9rem;
            transition: border-color .15s, color .15s, background .15s;
            cursor: pointer;
            text-decoration: none;
        }
        .topbar-icon-btn:hover {
            border-color: var(--color-deep-forest, #00473c);
            color: var(--color-deep-forest, #00473c);
            background: rgba(0,71,60,0.05);
        }
        .topbar-hamburger {
            display: none;
            background: none;
            border: 1.5px solid rgba(140,140,130,0.35);
            border-radius: 8px;
            font-size: 1.2rem;
            color: var(--color-forest-shadow, #0e150e);
            cursor: pointer;
            padding: 4px 8px;
            line-height: 1;
        }

        /* Topbar admin avatar chip */
        .topbar-user-chip {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 5px 12px 5px 6px;
            background: var(--color-sage-mist, #d8e5d6);
            border-radius: 99px;
            font-size: .8rem;
            font-weight: 700;
            color: var(--color-deep-forest, #00473c);
            text-decoration: none;
        }
        .topbar-user-chip .chip-avatar {
            width: 26px; height: 26px;
            background: var(--color-deep-forest, #00473c);
            color: #e6ff55;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: .7rem;
            font-weight: 800;
        }

        /* ── Main content area ───────────────────────────────────── */
        #manage-content {
            margin-left: var(--sidebar-w);
            padding-top: var(--topbar-h);
            min-height: 100vh;
        }
        .manage-body { padding: 2rem 1.75rem; }

        /* ── Admin card overrides ────────────────────────────────── */
        .admin-card {
            background: #fff;
            border: 1px solid rgba(140,140,130,0.2);
            border-radius: 20px;
            box-shadow: rgba(14,21,14,0.05) 0 2px 12px -2px;
        }

        /* Stat cards */
        .stat-card {
            background: #fff;
            border: 1px solid rgba(140,140,130,0.2);
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: rgba(14,21,14,0.05) 0 2px 12px -2px;
            transition: box-shadow .2s ease, transform .2s ease;
        }
        .stat-card:hover {
            box-shadow: rgba(14,21,14,0.1) 0 8px 24px -4px;
            transform: translateY(-2px);
        }
        .stat-icon {
            width: 48px; height: 48px;
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem;
            flex-shrink: 0;
        }
        .stat-icon.green  { background: rgba(0,71,60,0.1);  color: #00473c; }
        .stat-icon.lime   { background: rgba(230,255,85,0.3); color: #5c6a00; }
        .stat-icon.sage   { background: var(--color-sage-mist, #d8e5d6); color: #00473c; }
        .stat-icon.sand   { background: var(--color-warm-sand, #e8dcc6); color: #6b5c2e; }
        .stat-icon.red    { background: rgba(192,57,43,0.1); color: #c0392b; }
        .stat-value { font-size: 1.9rem; font-weight: 800; color: #0e150e; letter-spacing: -0.5px; line-height: 1.1; }
        .stat-label { font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: #8c8c82; margin-top: 4px; }
        .stat-change { font-size: .78rem; font-weight: 600; }
        .stat-change.positive { color: #00473c; }
        .stat-change.negative { color: #c0392b; }

        /* Admin table styling */
        .admin-table { border-radius: 16px; overflow: hidden; }
        .admin-table thead th {
            background: rgba(0,71,60,0.05) !important;
            color: #555 !important;
            font-size: .7rem !important;
            font-weight: 700 !important;
            text-transform: uppercase;
            letter-spacing: .1em;
            border-bottom: 1px solid rgba(140,140,130,0.2) !important;
            padding: 12px 16px !important;
        }
        .admin-table tbody tr { transition: background .15s; }
        .admin-table tbody tr:hover td { background: rgba(0,71,60,0.03) !important; }
        .admin-table tbody td { border-color: rgba(140,140,130,0.15) !important; vertical-align: middle !important; }

        /* Action buttons in admin tables */
        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 12px;
            border-radius: 99px;
            font-size: .78rem;
            font-weight: 700;
            border: 1.5px solid;
            transition: all .15s;
            text-decoration: none;
            cursor: pointer;
            background: transparent;
        }
        .btn-action.edit   { border-color: #00473c; color: #00473c; }
        .btn-action.edit:hover  { background: #00473c; color: #fff; }
        .btn-action.delete { border-color: #c0392b; color: #c0392b; }
        .btn-action.delete:hover { background: #c0392b; color: #fff; }
        .btn-action.view   { border-color: #8c8c82; color: #555; }
        .btn-action.view:hover  { background: #f4f3e7; border-color: #555; }

        /* Status pills */
        .pill-status {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 10px;
            border-radius: 99px;
            font-size: .72rem;
            font-weight: 700;
            letter-spacing: .04em;
            text-transform: uppercase;
        }
        .pill-status::before { content:''; width:6px; height:6px; border-radius:50%; flex-shrink:0; }
        .pill-status.active    { background: rgba(0,71,60,0.1);  color:#00473c; }
        .pill-status.active::before { background:#00473c; }
        .pill-status.inactive  { background: rgba(140,140,130,0.15); color:#555; }
        .pill-status.inactive::before { background:#8c8c82; }
        .pill-status.pending   { background: rgba(230,255,85,0.25); color:#5c6a00; }
        .pill-status.pending::before { background:#a8b400; }
        .pill-status.cancelled { background: rgba(192,57,43,0.1); color:#c0392b; }
        .pill-status.cancelled::before { background:#c0392b; }
        .pill-status.delivered { background: rgba(0,71,60,0.12); color:#00473c; }
        .pill-status.delivered::before { background:#00473c; }

        /* Search/filter bar */
        .admin-filter-bar {
            display: flex;
            align-items: center;
            gap: .75rem;
            padding: 1rem 1.25rem;
            border-bottom: 1px solid rgba(140,140,130,0.2);
            flex-wrap: wrap;
        }
        .admin-search-input {
            flex: 1;
            min-width: 200px;
            padding: .5rem .875rem;
            background: #f4f3e7;
            border: 1.5px solid rgba(140,140,130,0.3);
            border-radius: 99px;
            font-size: .875rem;
            color: #0e150e;
            transition: border-color .15s;
        }
        .admin-search-input:focus {
            outline: none;
            border-color: #00473c;
            box-shadow: 0 0 0 3px rgba(0,71,60,0.1);
        }

        /* Page header */
        .page-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        .page-header-title { font-size: 1.5rem; font-weight: 800; color: #0e150e; letter-spacing: -0.3px; }
        .page-header-sub   { font-size: .83rem; color: #8c8c82; margin-top: 2px; }

        /* ── Responsive ──────────────────────────────────────────── */
        @media (max-width: 991.98px) {
            #manage-sidebar { transform: translateX(calc(-1 * var(--sidebar-w))); }
            #manage-sidebar.open { transform: translateX(0); box-shadow: 0 0 80px rgba(0,0,0,.5); }
            #manage-topbar { left: 0; }
            #manage-content { margin-left: 0; }
            .topbar-hamburger { display: block; }
            .sidebar-overlay {
                display: none;
                position: fixed; inset: 0;
                background: rgba(14,21,14,0.5);
                z-index: 1039;
            }
            .sidebar-overlay.show { display: block; }
        }
        @media (max-width: 575.98px) {
            .manage-body { padding: 1.25rem 1rem; }
            .page-header { flex-direction: column; }
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
            border-bottom: 1px solid var(--sidebar-hover);
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
            background: var(--sidebar-active);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #0e150e;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        .brand-text { font-size: 1.2rem; font-weight: 800; color: #fff; }
        .brand-text span { color: var(--sidebar-active); }
        .brand-badge {
            display: inline-block;
            font-size: 9px;
            font-weight: 700;
            background: var(--sidebar-active);
            color: #0e150e;
            padding: 2px 6px;
            border-radius: 4px;
            letter-spacing: .5px;
            margin-left: auto;
            text-transform: uppercase;
        }

        /* Role pill */
        .sidebar-role-pill {
            margin: 1rem 1.25rem .5rem;
            background: var(--sidebar-hover);
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
        .role-dot.admin  { background: var(--sidebar-active); }
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
            background: var(--sidebar-active);
            color: #0e150e;
        }
        .nav-badge.green { background: #22c55e; }

        /* Sidebar divider */
        .sidebar-divider {
            border-top: 1px solid var(--sidebar-hover);
            margin: .5rem 1.25rem;
        }

        /* Sidebar footer */
        .sidebar-footer {
            padding: 1rem 1.25rem;
            border-top: 1px solid var(--sidebar-hover);
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
            background: var(--sidebar-active);
            color: #0e150e;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700;
            font-size: .875rem;
            flex-shrink: 0;
        }
        .avatar-info .name  { font-size: .8rem; font-weight: 700; color: #f9fafb; }
        .avatar-info .email { font-size: .7rem; color: #a3b0c2; }
        .sidebar-footer .logout-btn {
            margin-left: auto;
            color: #a3b0c2;
            transition: color .15s;
        }
        .sidebar-footer .logout-btn:hover { color: #e44d3a; }

        /* ── Top Bar ──────────────────────────────────────────────── */
        #manage-topbar {
            position: fixed;
            top: 0;
            left: var(--sidebar-w);
            right: 0;
            height: var(--topbar-h);
            background: var(--bg-color);
            border-bottom: 1px solid rgba(140,140,130,0.3);
            display: flex;
            align-items: center;
            padding: 0 1.5rem;
            z-index: 1030;
            gap: 1rem;
        }
        .topbar-title { font-size: 1.1rem; font-weight: 700; color: var(--text-color); }
        .topbar-actions { margin-left: auto; display: flex; align-items: center; gap: .75rem; }
        .topbar-icon-btn {
            width: 38px; height: 38px;
            border: 1px solid rgba(140, 140, 130, 0.3);
            border-radius: 10px;
            background: var(--surface-color);
            display: flex; align-items: center; justify-content: center;
            color: var(--text-muted);
            font-size: .95rem;
            transition: border-color .15s, color .15s;
            cursor: pointer;
            text-decoration: none;
        }
        .topbar-icon-btn:hover { border-color: var(--primary-color); color: var(--primary-color); }
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

    <div class="sidebar-brand">
        <a href="${pageContext.request.contextPath}/index">
            <div class="brand-icon" style="background: transparent;">
                <img src="${pageContext.request.contextPath}/jsp/logo.png" alt="TindiTime Logo" style="height: 38px; width: 38px; object-fit: contain; border-radius: 8px;">
            </div>
            <span class="brand-text" style="font-family: 'Outfit', sans-serif; font-weight: 800; letter-spacing: -0.5px;">Tindi<span style="color: var(--sidebar-active);">Time</span></span>
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
                <div class="email">${not empty sessionScope.userEmail ? sessionScope.userEmail : 'admin@TindiTime.com'}</div>
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
