package com.hungrygo.controller;

import com.hungrygo.model.Order;
import com.hungrygo.model.Restaurant;
import com.hungrygo.model.dao.OrderDAO;
import com.hungrygo.model.dao.RestaurantDAO;
import com.hungrygo.model.dao.impl.OrderDAOImpl;
import com.hungrygo.model.dao.impl.RestaurantDAOImpl;
import com.hungrygo.model.dao.AdminDAO;
import com.hungrygo.model.dao.impl.AdminDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * AdminOrderServlet — manages the order pipeline in the admin panel.
 *
 * URL mappings (web.xml):
 *   GET  /manage/orders                → paginated, filterable order table + stat strip
 *   POST /manage/orders/updateStatus   → change order_status for one order
 *
 * requestScope attributes (manage-orders.jsp):
 *   orders           List<Order>          — current page, joined with customer + restaurant names
 *   statusCounts     Map<String,Long>     — pipeline counts (Placed, Confirmed … Cancelled)
 *   restaurants      List<Restaurant>     — dropdown for SUPER_ADMIN filter (null for owners)
 *   filterStatus     String
 *   filterRestId     Integer
 *   searchQuery      String
 *   dateFrom, dateTo String
 *   currentPage      int
 *   totalPages       int
 *   totalOrders      int
 */
public class AdminOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int  PAGE_SIZE        = 15;

    private final OrderDAO      orderDAO      = new OrderDAOImpl();
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();
    private final AdminDAO      adminDAO      = new AdminDAOImpl();

    // ── GET /manage/orders ────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session     = request.getSession(false);
        String      role        = (String) session.getAttribute("role");
        Integer     ownerRestId = ownerRestaurantId(session);

        // ── Parse filter params ───────────────────────────────────────────────
        String  filterStatus  = trim(request.getParameter("status"));
        Integer filterRestId  = parseIdParam(request.getParameter("restaurantId"));
        String  searchQuery   = trim(request.getParameter("q"));
        String  dateFrom      = trim(request.getParameter("dateFrom"));
        String  dateTo        = trim(request.getParameter("dateTo"));
        int     page          = parsePageParam(request.getParameter("page"));

        // RESTAURANT_OWNER: lock to their restaurant
        if ("RESTAURANT_OWNER".equals(role) && ownerRestId != null) {
            filterRestId = ownerRestId;
        }

        // ── Pipeline stat strip — shapes Map to match JSP key names ─────────
        Map<String, Long> rawCounts = orderDAO.getOrderStatusCounts(
            "RESTAURANT_OWNER".equals(role) ? ownerRestId : null);

        // JSP expects: stats.placedCount, confirmedCount, preparingCount,
        //              outForDeliveryCount, deliveredCount, cancelledCount
        java.util.Map<String, Object> stats = new java.util.LinkedHashMap<>();
        stats.put("placedCount",          rawCounts.getOrDefault("Placed",           0L));
        stats.put("confirmedCount",        rawCounts.getOrDefault("Confirmed",        0L));
        stats.put("preparingCount",        rawCounts.getOrDefault("Preparing",        0L));
        stats.put("outForDeliveryCount",   rawCounts.getOrDefault("Out for Delivery", 0L));
        stats.put("deliveredCount",        rawCounts.getOrDefault("Delivered Successfully", 0L) + rawCounts.getOrDefault("Delivered", 0L));
        stats.put("cancelledCount",        rawCounts.getOrDefault("CANCELLED", 0L) + rawCounts.getOrDefault("Cancelled", 0L));
        // today revenue for the sub-header strip
        java.math.BigDecimal todayRev = adminDAO.getTodayRevenue("RESTAURANT_OWNER".equals(role) ? ownerRestId : filterRestId);
        stats.put("todayRevenue", todayRev != null ? todayRev : java.math.BigDecimal.ZERO);

        // ── Paginated order list ──────────────────────────────────────────────
        List<Order> orders = orderDAO.getOrdersAdmin(
            filterStatus, filterRestId, searchQuery, dateFrom, dateTo, page, PAGE_SIZE);

        int total      = orderDAO.countOrdersAdmin(filterStatus, filterRestId, searchQuery, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;

        // ── Restaurant filter dropdown (SUPER_ADMIN only) ─────────────────────
        List<Restaurant> restaurants = null;
        if ("SUPER_ADMIN".equals(role)) {
            restaurants = restaurantDAO.getAllRestaurants();
        }

        // ── Set requestScope ──────────────────────────────────────────────────
        request.setAttribute("orders",        orders);
        request.setAttribute("stats",         stats);
        request.setAttribute("restaurants",   restaurants);
        request.setAttribute("filterStatus",  filterStatus);
        request.setAttribute("filterRestId",  filterRestId);
        request.setAttribute("searchQuery",   searchQuery);
        request.setAttribute("dateFrom",      dateFrom);
        request.setAttribute("dateTo",        dateTo);
        request.setAttribute("currentPage",   page);
        request.setAttribute("totalPages",    totalPages);
        request.setAttribute("totalOrders",   total);

        request.getRequestDispatcher("/jsp/manage/manage-orders.jsp")
               .forward(request, response);
    }

    // ── POST /manage/orders/* ─────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getRequestURI()
                                 .substring(request.getContextPath().length());
        String action = pathInfo.replaceFirst("/manage/orders/?", "").trim();

        if ("updateStatus".equals(action)) {
            int    orderId  = parseId(request.getParameter("orderId"));
            String newStatus = trim(request.getParameter("status"));

            if (orderId > 0 && newStatus != null) {
                orderDAO.updateOrderStatus(orderId, newStatus);
            }
        }

        // Always redirect back to the order list (preserving filters via referrer)
        String referer = request.getHeader("Referer");
        if (referer != null && referer.contains("/manage/orders")) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/manage/orders?msg=status_updated");
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private Integer ownerRestaurantId(HttpSession session) {
        Object rid = session.getAttribute("restaurantId");
        return (rid instanceof Integer) ? (Integer) rid : null;
    }

    private String trim(String s) {
        return (s != null && !s.trim().isEmpty()) ? s.trim() : null;
    }

    private int parsePageParam(String raw) {
        try { int p = Integer.parseInt(raw); return p > 0 ? p : 1; }
        catch (Exception e) { return 1; }
    }

    private Integer parseIdParam(String raw) {
        try { int v = Integer.parseInt(raw); return v > 0 ? v : null; }
        catch (Exception e) { return null; }
    }

    private int parseId(String raw) {
        try { return Integer.parseInt(raw); }
        catch (Exception e) { return -1; }
    }
}
