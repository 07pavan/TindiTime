package com.hungrygo.controller;

import com.hungrygo.model.User;
import com.hungrygo.model.dao.UserDAO;
import com.hungrygo.model.dao.impl.UserDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * AdminUserServlet — user directory and management for SUPER_ADMIN.
 *
 * URL mappings (web.xml):
 *   GET  /manage/users           → searchable, filterable, paginated user table
 *   POST /manage/users/ban       → set is_banned = 1
 *   POST /manage/users/unban     → set is_banned = 0
 *   POST /manage/users/promote   → change user role
 *
 * RESTAURANT_OWNER access:
 *   Owners can view user list but cannot ban/promote — the filter enforces this
 *   by checking role before executing any write operation.
 *
 * requestScope attributes (manage-users.jsp):
 *   users        List<User>          — current page with totalOrders + registeredDate
 *   roleCounts   Map<String,Long>    — CUSTOMER / RESTAURANT_OWNER / SUPER_ADMIN / BANNED
 *   filterRole   String
 *   filterStatus String              — "BANNED" | "ACTIVE" | null
 *   searchQuery  String
 *   currentPage  int
 *   totalPages   int
 *   totalUsers   int
 *   validRoles   List<String>        — allowed role values for promote dropdown
 */
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int  PAGE_SIZE        = 15;

    private static final List<String> VALID_ROLES = Arrays.asList(
        "CUSTOMER", "RESTAURANT_OWNER", "SUPER_ADMIN");

    private final UserDAO userDAO = new UserDAOImpl();

    // ── GET /manage/users ─────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Parse filter params ───────────────────────────────────────────────
        String filterRole   = trim(request.getParameter("role"));
        String filterStatus = trim(request.getParameter("status"));  // "BANNED" | "ACTIVE"
        String searchQuery  = trim(request.getParameter("q"));
        int    page         = parsePageParam(request.getParameter("page"));

        // ── Stat strip — shape to JSP key names ───────────────────────────────
        Map<String, Long> roleCounts = userDAO.getUserRoleCounts();
        // JSP uses: stats.totalCustomers, stats.totalOwners, stats.totalAdmins, stats.bannedCount
        java.util.Map<String, Object> stats = new java.util.LinkedHashMap<>();
        stats.put("totalCustomers", roleCounts.getOrDefault("CUSTOMER",         0L));
        stats.put("totalOwners",    roleCounts.getOrDefault("RESTAURANT_OWNER", 0L));
        stats.put("totalAdmins",    roleCounts.getOrDefault("SUPER_ADMIN",      0L));
        stats.put("bannedCount",    roleCounts.getOrDefault("BANNED",           0L));

        // ── Paginated user list ───────────────────────────────────────────────
        List<User> users = userDAO.getAllUsersAdmin(filterRole, filterStatus, searchQuery, page, PAGE_SIZE);

        int total      = userDAO.countUsersAdmin(filterRole, filterStatus, searchQuery);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;

        // ── Set requestScope ──────────────────────────────────────────────────
        request.setAttribute("users",        users);
        request.setAttribute("stats",        stats);
        request.setAttribute("filterRole",   filterRole);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("searchQuery",  searchQuery);
        request.setAttribute("currentPage",  page);
        request.setAttribute("totalPages",   totalPages);
        request.setAttribute("totalUsers",   total);
        request.setAttribute("validRoles",   VALID_ROLES);

        request.getRequestDispatcher("/jsp/manage/manage-users.jsp")
               .forward(request, response);
    }

    // ── POST /manage/users/* ──────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute("role");

        // Only SUPER_ADMIN may write
        if (!"SUPER_ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/manage/users?err=access_denied");
            return;
        }

        String pathInfo = request.getRequestURI()
                                 .substring(request.getContextPath().length());
        String action = pathInfo.replaceFirst("/manage/users/?", "").trim();

        int    targetUserId  = parseId(request.getParameter("userId"));
        String msg           = "failed";

        if (targetUserId <= 0) {
            response.sendRedirect(request.getContextPath() + "/manage/users?err=invalid_id");
            return;
        }

        // Prevent self-modification
        Integer selfId = (Integer) session.getAttribute("user_id");
        if (selfId != null && selfId == targetUserId && !"promote".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/manage/users?err=self_modify");
            return;
        }

        boolean ok;
        switch (action) {
            case "ban":
                ok  = userDAO.banUser(targetUserId);
                msg = ok ? "ban_success" : "ban_failed";
                break;

            case "unban":
                ok  = userDAO.unbanUser(targetUserId);
                msg = ok ? "unban_success" : "unban_failed";
                break;

            case "promote":
                String newRole = trim(request.getParameter("newRole"));
                if (newRole == null || !VALID_ROLES.contains(newRole)) {
                    response.sendRedirect(request.getContextPath() + "/manage/users?err=invalid_role");
                    return;
                }
                ok  = userDAO.updateUserRole(targetUserId, newRole);
                msg = ok ? "promote_success" : "promote_failed";
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/manage/users?err=unknown_action");
                return;
        }

        response.sendRedirect(request.getContextPath() + "/manage/users?msg=" + msg);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private String trim(String s) {
        return (s != null && !s.trim().isEmpty()) ? s.trim() : null;
    }

    private int parsePageParam(String raw) {
        try { int p = Integer.parseInt(raw); return p > 0 ? p : 1; }
        catch (Exception e) { return 1; }
    }

    private int parseId(String raw) {
        try { return Integer.parseInt(raw); }
        catch (Exception e) { return -1; }
    }
}
