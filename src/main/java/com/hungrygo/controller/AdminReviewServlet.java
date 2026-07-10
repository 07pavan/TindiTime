package com.hungrygo.controller;

import com.hungrygo.model.Restaurant;
import com.hungrygo.model.Review;
import com.hungrygo.model.dao.RestaurantDAO;
import com.hungrygo.model.dao.ReviewDAO;
import com.hungrygo.model.dao.impl.RestaurantDAOImpl;
import com.hungrygo.model.dao.impl.ReviewDAOImpl;

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
 * AdminReviewServlet — review moderation panel for SUPER_ADMIN and RESTAURANT_OWNER.
 *
 * URL mappings (web.xml):
 *   GET  /manage/reviews                   → paginated, filterable review table + stat strip
 *   POST /manage/reviews/approve           → status = APPROVED
 *   POST /manage/reviews/reject            → status = REJECTED
 *   POST /manage/reviews/flag              → status = FLAGGED
 *   POST /manage/reviews/delete            → hard-delete review
 *
 * Role scoping:
 *   SUPER_ADMIN      → all reviews platform-wide; restaurant filter dropdown shown
 *   RESTAURANT_OWNER → only reviews for their restaurant; no restaurant dropdown
 *
 * requestScope attributes (manage-reviews.jsp):
 *   reviews        List<Review>        — current page with customer + restaurant names
 *   reviewStats    Map<String,Object>  — total / pending / approved / flagged / avgRating
 *   restaurants    List<Restaurant>    — dropdown for SUPER_ADMIN (null for owners)
 *   filterStatus   String
 *   filterRestId   Integer
 *   filterRating   int
 *   searchQuery    String
 *   currentPage    int
 *   totalPages     int
 *   totalReviews   int
 */
public class AdminReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int  PAGE_SIZE        = 12;

    private static final List<String> VALID_STATUSES =
        Arrays.asList("PENDING", "APPROVED", "FLAGGED", "REJECTED");

    private final ReviewDAO     reviewDAO     = new ReviewDAOImpl();
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    // ── GET /manage/reviews ───────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session     = request.getSession(false);
        String      role        = (String) session.getAttribute("role");
        Integer     ownerRestId = ownerRestaurantId(session);

        // ── Parse filter params ───────────────────────────────────────────────
        String  filterStatus  = trim(request.getParameter("status"));
        Integer filterRestId  = parseIdParam(request.getParameter("restaurantId"));
        int     filterRating  = parseRating(request.getParameter("rating"));
        String  searchQuery   = trim(request.getParameter("q"));
        int     page          = parsePageParam(request.getParameter("page"));

        // RESTAURANT_OWNER: lock to their restaurant
        if ("RESTAURANT_OWNER".equals(role) && ownerRestId != null) {
            filterRestId = ownerRestId;
        }

        // ── Stat strip — shape to JSP key names ───────────────────────────────
        Integer statsScope = "RESTAURANT_OWNER".equals(role) ? ownerRestId : null;
        Map<String, Object> rawStats = reviewDAO.getReviewStats(statsScope);
        // JSP uses: stats.totalReviews, stats.avgPlatformRating, stats.publishedCount, stats.flaggedCount
        java.util.Map<String, Object> stats = new java.util.LinkedHashMap<>();
        stats.put("totalReviews",      rawStats.getOrDefault("total",    0L));
        stats.put("avgPlatformRating", rawStats.getOrDefault("avgRating", 0.0));
        stats.put("publishedCount",    rawStats.getOrDefault("approved",  0L));
        stats.put("flaggedCount",      rawStats.getOrDefault("flagged",   0L));
        stats.put("pendingCount",      rawStats.getOrDefault("pending",   0L));

        // ── Paginated review list ─────────────────────────────────────────────
        List<Review> reviews = reviewDAO.getReviewsAdmin(
            filterStatus, filterRestId, filterRating, searchQuery, page, PAGE_SIZE);

        int total      = reviewDAO.countReviewsAdmin(filterStatus, filterRestId, filterRating, searchQuery);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;

        // ── Restaurant filter dropdown (SUPER_ADMIN only) ─────────────────────
        List<Restaurant> restaurants = null;
        if ("SUPER_ADMIN".equals(role)) {
            restaurants = restaurantDAO.getAllRestaurants();
        }

        // ── Flash messages ────────────────────────────────────────────────────
        String msg = trim(request.getParameter("msg"));
        String err = trim(request.getParameter("err"));
        if (msg != null) request.setAttribute("successMsg", msg.replace('_', ' '));
        if (err != null) request.setAttribute("errorMsg",   err.replace('_', ' '));

        // ── Set requestScope ──────────────────────────────────────────────────
        request.setAttribute("reviews",      reviews);
        request.setAttribute("stats",        stats);
        request.setAttribute("restaurants",  restaurants);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("filterRestId", filterRestId);
        request.setAttribute("filterRating", filterRating);
        request.setAttribute("searchQuery",  searchQuery);
        request.setAttribute("currentPage",  page);
        request.setAttribute("totalPages",   totalPages);
        request.setAttribute("totalReviews", total);

        request.getRequestDispatcher("/jsp/manage/manage-reviews.jsp")
               .forward(request, response);
    }

    // ── POST /manage/reviews/* ────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session  = request.getSession(false);
        String      role     = (String) session.getAttribute("role");

        String pathInfo = request.getRequestURI()
                                 .substring(request.getContextPath().length());
        String action = pathInfo.replaceFirst("/manage/reviews/?", "").trim();

        int reviewId = parseId(request.getParameter("reviewId"));
        if (reviewId <= 0) {
            response.sendRedirect(request.getContextPath() + "/manage/reviews?err=invalid_id");
            return;
        }

        boolean ok;
        String  resultKey;

        switch (action) {
            case "approve":
                ok = reviewDAO.updateReviewStatus(reviewId, "APPROVED");
                resultKey = "approve";
                break;

            case "reject":
                ok = reviewDAO.updateReviewStatus(reviewId, "REJECTED");
                resultKey = "reject";
                break;

            case "flag":
                ok = reviewDAO.updateReviewStatus(reviewId, "FLAGGED");
                resultKey = "flag";
                break;

            case "delete":
                // RESTAURANT_OWNER cannot delete reviews — only SUPER_ADMIN can
                if (!"SUPER_ADMIN".equals(role)) {
                    response.sendRedirect(request.getContextPath() + "/manage/reviews?err=access_denied");
                    return;
                }
                ok = reviewDAO.deleteReview(reviewId);
                resultKey = "delete";
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/manage/reviews?err=unknown_action");
                return;
        }

        String result = ok ? "success" : "failed";
        response.sendRedirect(request.getContextPath() + "/manage/reviews?msg=" + resultKey + "_" + result);
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

    private int parseRating(String raw) {
        try {
            int r = Integer.parseInt(raw);
            return (r >= 1 && r <= 5) ? r : 0;
        } catch (Exception e) { return 0; }
    }
}
