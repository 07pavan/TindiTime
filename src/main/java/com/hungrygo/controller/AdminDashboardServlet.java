package com.hungrygo.controller;

import com.hungrygo.model.dao.AdminDAO;
import com.hungrygo.model.dao.impl.AdminDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AdminDashboardServlet — serves the Super Admin / Restaurant Owner dashboard.
 *
 * URL mappings (declared in web.xml):
 *   GET  /manage          → redirect to /manage/dashboard
 *   GET  /manage/dashboard → render manage-dashboard.jsp with KPI data
 *
 * requestScope attributes set (consumed by manage-dashboard.jsp):
 *   stats         Map<String,Object>  — KPI tile values
 *   recentOrders  List<Map>           — last 10 orders feed
 *   userRole      String              — "SUPER_ADMIN" or "RESTAURANT_OWNER"
 *   userName      String              — display name
 *
 * Role scoping:
 *   SUPER_ADMIN      → global data (restaurantId filter = null)
 *   RESTAURANT_OWNER → own restaurant data (restaurantId from session)
 */
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAOImpl();

    // ── GET /manage  ──────────────────────────────────────────────────────────
    // ── GET /manage/dashboard  ────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Redirect bare /manage to /manage/dashboard for clean URL
        String path = request.getServletPath();
        if ("/manage".equals(path)) {
            response.sendRedirect(request.getContextPath() + "/manage/dashboard");
            return;
        }

        HttpSession session = request.getSession(false);

        // ── Determine role scope ─────────────────────────────────────────────
        String  role         = (String)  session.getAttribute("role");
        Integer restaurantId = null;   // null = SUPER_ADMIN (all data)

        if ("RESTAURANT_OWNER".equals(role)) {
            Object rid = session.getAttribute("restaurantId");
            if (rid instanceof Integer) restaurantId = (Integer) rid;
        }

        // ── Fetch KPI stats ──────────────────────────────────────────────────
        Map<String, Object> stats = new HashMap<>();

        // Order counts
        stats.put("totalOrders",    adminDAO.getTotalOrders(restaurantId));
        stats.put("todayOrders",    adminDAO.getTodayOrderCount(restaurantId));
        stats.put("activeOrders",   adminDAO.getActiveOrderCount(restaurantId));

        // Revenue figures
        BigDecimal totalRev = adminDAO.getTotalRevenue(restaurantId);
        BigDecimal todayRev = adminDAO.getTodayRevenue(restaurantId);
        stats.put("totalRevenue",   totalRev);
        stats.put("todayRevenue",   todayRev);
        // Formatted rupee strings for JSP display (no fmt tag needed in cards)
        stats.put("totalRevenueStr", formatRupee(totalRev));
        stats.put("todayRevenueStr", formatRupee(todayRev));

        // Platform-level stats (SUPER_ADMIN only, safe to show 0 for owners)
        if ("SUPER_ADMIN".equals(role)) {
            stats.put("activeRestaurants", adminDAO.getActiveRestaurantCount());
            stats.put("pendingApprovals",  adminDAO.getPendingApprovalCount());
            stats.put("totalCustomers",    adminDAO.getTotalCustomerCount());
        } else {
            // Owner sees their restaurant's open/closed status instead
            stats.put("activeRestaurants", 0L);
            stats.put("pendingApprovals",  0L);
            stats.put("totalCustomers",    0L);

            // Populate RESTAURANT_OWNER KPIs
            stats.put("myRevenue", totalRev);
            if (restaurantId != null) {
                try {
                    com.hungrygo.model.Restaurant rest = new com.hungrygo.model.dao.impl.RestaurantDAOImpl().getRestaurantById(restaurantId);
                    stats.put("avgRating", rest != null ? rest.getRating() : java.math.BigDecimal.ZERO);
                } catch (Exception e) {
                    System.err.println("AdminDashboardServlet: error loading average rating — " + e.getMessage());
                    stats.put("avgRating", java.math.BigDecimal.ZERO);
                }
            } else {
                stats.put("avgRating", java.math.BigDecimal.ZERO);
            }
        }

        // ── Fetch recent orders feed (last 10) ───────────────────────────────
        List<Map<String, Object>> recentOrders = adminDAO.getRecentOrders(restaurantId, 10);

        // ── Set request attributes ───────────────────────────────────────────
        request.setAttribute("stats",        stats);
        request.setAttribute("recentOrders", recentOrders);

        // Role/name convenience attributes (filter also sets these, but set
        // here as a safe fallback in case the filter chain order changes)
        if (request.getAttribute("userRole") == null) {
            request.setAttribute("userRole", role);
        }
        if (request.getAttribute("userName") == null) {
            request.setAttribute("userName", session.getAttribute("username"));
        }

        // ── Forward to JSP ───────────────────────────────────────────────────
        request.getRequestDispatcher("/jsp/manage/manage-dashboard.jsp")
               .forward(request, response);
    }

    // ── POST (not used — dashboard is read-only) ──────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    /**
     * Formats a BigDecimal as an Indian rupee string.
     * e.g. 123456.78 → "₹1,23,456"
     */
    private String formatRupee(BigDecimal amount) {
        if (amount == null) return "₹0";
        long val = amount.longValue();
        if (val < 1000) return "₹" + val;

        // Indian number format: last 3 digits, then groups of 2
        String s   = String.valueOf(val);
        int    len  = s.length();
        StringBuilder sb = new StringBuilder();
        // First group (rightmost 3)
        sb.insert(0, s.substring(len - 3));
        sb.insert(0, ",");
        int remaining = len - 3;
        int pos = remaining;
        while (pos > 2) {
            sb.insert(0, s, pos - 2, pos);
            sb.insert(0, ",");
            pos -= 2;
        }
        sb.insert(0, s.substring(0, pos));
        return "₹" + sb;
    }
}
