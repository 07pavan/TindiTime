package com.hungrygo.controller;

import com.hungrygo.model.Restaurant;
import com.hungrygo.model.dao.RestaurantDAO;
import com.hungrygo.model.dao.impl.RestaurantDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * AdminRestaurantServlet — manages the restaurant listing, approval queue,
 * and status toggling in the admin panel.
 *
 * URL mappings (web.xml):
 *   GET  /manage/restaurants            → list with search/filter/pagination
 *   POST /manage/restaurants/approve    → status = ACTIVE
 *   POST /manage/restaurants/reject     → status = REJECTED
 *   POST /manage/restaurants/suspend    → status = SUSPENDED
 *   POST /manage/restaurants/activate   → status = ACTIVE
 *
 * requestScope attributes (manage-restaurants.jsp):
 *   pendingRestaurants  List<Restaurant>
 *   allRestaurants      List<Restaurant>
 *   filterStatus        String
 *   searchQuery         String
 *   currentPage         int
 *   totalPages          int
 */
public class AdminRestaurantServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int  PAGE_SIZE        = 10;

    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    // ── GET /manage/restaurants ───────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchQuery  = trim(request.getParameter("q"));
        String filterStatus = trim(request.getParameter("filter"));
        int    page         = parsePageParam(request.getParameter("page"));

        // ── Pending approval queue (admin-only banner at top) ────────────────
        List<Restaurant> pendingRestaurants = restaurantDAO.getPendingRestaurants();

        // ── Paginated all-restaurant table ───────────────────────────────────
        List<Restaurant> allRestaurants =
            restaurantDAO.getRestaurantsAdmin(searchQuery, filterStatus, page, PAGE_SIZE);

        int totalRows  = restaurantDAO.countRestaurantsAdmin(searchQuery, filterStatus);
        int totalPages = (int) Math.ceil((double) totalRows / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;

        // ── Set requestScope ──────────────────────────────────────────────────
        request.setAttribute("pendingRestaurants", pendingRestaurants);
        request.setAttribute("allRestaurants",     allRestaurants);
        request.setAttribute("filterStatus",       filterStatus);
        request.setAttribute("searchQuery",        searchQuery);
        request.setAttribute("currentPage",        page);
        request.setAttribute("totalPages",         totalPages);

        request.getRequestDispatcher("/jsp/manage/manage-restaurants.jsp")
               .forward(request, response);
    }

    // ── POST /manage/restaurants/* ────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getRequestURI()
                                 .substring(request.getContextPath().length());
        // e.g. /manage/restaurants/approve → action = "approve"
        String action = pathInfo.replaceFirst("/manage/restaurants/?", "").trim();

        int restaurantId = parseId(request.getParameter("restaurantId"));
        if (restaurantId <= 0) {
            response.sendRedirect(request.getContextPath() + "/manage/restaurants?err=invalid_id");
            return;
        }

        String newStatus;
        switch (action) {
            case "approve":
            case "activate":
                newStatus = "ACTIVE";
                break;
            case "reject":
                newStatus = "REJECTED";
                break;
            case "suspend":
                newStatus = "SUSPENDED";
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/manage/restaurants?err=unknown_action");
                return;
        }

        boolean ok = restaurantDAO.updateStatus(restaurantId, newStatus);
        String  msg = ok ? "status_updated" : "update_failed";

        response.sendRedirect(request.getContextPath() + "/manage/restaurants?msg=" + msg);
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
