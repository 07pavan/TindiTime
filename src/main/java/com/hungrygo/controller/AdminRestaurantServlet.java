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
import java.math.BigDecimal;
import java.util.List;

/**
 * AdminRestaurantServlet — full CRUD + status management for restaurants.
 *
 * URL mappings (web.xml):
 *   GET  /manage/restaurants            → list with search/filter/pagination
 *   POST /manage/restaurants/add        → insert new restaurant
 *   POST /manage/restaurants/edit       → update restaurant details
 *   POST /manage/restaurants/delete     → hard-delete restaurant
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

        // ── All restaurants (for edit dropdown reference) ─────────────────────
        List<Restaurant> allForDropdown = restaurantDAO.getAllRestaurants();

        // ── Set requestScope ──────────────────────────────────────────────────
        request.setAttribute("pendingRestaurants", pendingRestaurants);
        request.setAttribute("allRestaurants",     allRestaurants);
        request.setAttribute("allForDropdown",     allForDropdown);
        request.setAttribute("filterStatus",       filterStatus);
        request.setAttribute("searchQuery",        searchQuery);
        request.setAttribute("currentPage",        page);
        request.setAttribute("totalPages",         totalPages);
        request.setAttribute("totalRestaurants",   totalRows);

        request.getRequestDispatcher("/jsp/manage/manage-restaurants.jsp")
               .forward(request, response);
    }

    // ── POST /manage/restaurants/* ────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getRequestURI()
                                 .substring(request.getContextPath().length());
        String action = pathInfo.replaceFirst("/manage/restaurants/?", "").trim();

        boolean ok;
        String  redirectParam;

        switch (action) {

            // ── CRUD: Add new restaurant ──────────────────────────────────────
            case "add":
                ok = handleAdd(request);
                redirectParam = ok ? "msg=add_success" : "err=add_failed";
                response.sendRedirect(request.getContextPath() + "/manage/restaurants?" + redirectParam);
                return;

            // ── CRUD: Edit restaurant details ─────────────────────────────────
            case "edit":
                ok = handleEdit(request);
                redirectParam = ok ? "msg=edit_success" : "err=edit_failed";
                response.sendRedirect(request.getContextPath() + "/manage/restaurants?" + redirectParam);
                return;

            // ── CRUD: Delete restaurant ───────────────────────────────────────
            case "delete":
                int delId = parseId(request.getParameter("restaurantId"));
                ok = (delId > 0) && restaurantDAO.deleteRestaurant(delId);
                redirectParam = ok ? "msg=delete_success" : "err=delete_failed";
                response.sendRedirect(request.getContextPath() + "/manage/restaurants?" + redirectParam);
                return;

            // ── Status management ─────────────────────────────────────────────
            case "approve":
            case "activate":
                handleStatusChange(request, response, "ACTIVE");
                return;
            case "reject":
                handleStatusChange(request, response, "REJECTED");
                return;
            case "suspend":
                handleStatusChange(request, response, "SUSPENDED");
                return;

            default:
                response.sendRedirect(request.getContextPath() + "/manage/restaurants?err=unknown_action");
        }
    }

    // ── Action handlers ───────────────────────────────────────────────────────

    private boolean handleAdd(HttpServletRequest req) {
        Restaurant r = buildRestaurantFromRequest(req, -1);
        return r != null && restaurantDAO.addRestaurant(r);
    }

    private boolean handleEdit(HttpServletRequest req) {
        int id = parseId(req.getParameter("restaurantId"));
        if (id <= 0) return false;
        Restaurant r = buildRestaurantFromRequest(req, id);
        return r != null && restaurantDAO.updateRestaurant(r);
    }

    private void handleStatusChange(HttpServletRequest req,
                                    HttpServletResponse res, String newStatus)
            throws IOException {
        int id = parseId(req.getParameter("restaurantId"));
        if (id <= 0) {
            res.sendRedirect(req.getContextPath() + "/manage/restaurants?err=invalid_id");
            return;
        }
        boolean ok = restaurantDAO.updateStatus(id, newStatus);
        res.sendRedirect(req.getContextPath() + "/manage/restaurants?msg=" + (ok ? "status_updated" : "update_failed"));
    }

    // ── Build Restaurant from form fields ─────────────────────────────────────

    private Restaurant buildRestaurantFromRequest(HttpServletRequest req, int id) {
        try {
            String name = trim(req.getParameter("name"));
            if (name == null) return null;

            Restaurant r = new Restaurant();
            if (id > 0) r.setId(id);

            r.setName(name);
            r.setCuisineType(trim(req.getParameter("cuisineType")));
            r.setAddress(trim(req.getParameter("address")));
            r.setCity(trim(req.getParameter("city")));
            r.setPhone(trim(req.getParameter("phone")));
            r.setEmail(trim(req.getParameter("email")));
            r.setDescription(trim(req.getParameter("description")));
            r.setImageUrl(trim(req.getParameter("imageUrl")));

            String ratingStr = trim(req.getParameter("rating"));
            r.setRating(ratingStr != null ? new BigDecimal(ratingStr) : BigDecimal.ZERO);

            String deliveryStr = trim(req.getParameter("deliveryTimeMins"));
            r.setDeliveryTimeMins(deliveryStr != null ? Integer.parseInt(deliveryStr) : 30);

            String costStr = trim(req.getParameter("costForTwo"));
            r.setCostForTwo(costStr != null ? new BigDecimal(costStr) : BigDecimal.ZERO);

            r.setActive(true);
            return r;
        } catch (Exception e) {
            System.err.println("AdminRestaurantServlet: error building Restaurant — " + e.getMessage());
            return null;
        }
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
