package com.hungrygo.controller;

import com.hungrygo.model.PromoCode;
import com.hungrygo.model.dao.PromoCodeDAO;
import com.hungrygo.model.dao.impl.PromoCodeDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * AdminPromoServlet — promo code engine management (SUPER_ADMIN only).
 *
 * URL mappings (web.xml):
 *   GET  /manage/promos             → paginated, filterable promo table + stat strip
 *   POST /manage/promos/create      → add new promo code
 *   POST /manage/promos/edit        → update existing promo
 *   POST /manage/promos/delete      → hard-delete promo
 *   POST /manage/promos/toggle      → flip is_active
 *
 * requestScope attributes (manage-promos.jsp):
 *   promoCodes    List<PromoCode>
 *   promoStats    Map<String,Long>   — total / active / expired / totalUsed
 *   filterStatus  String
 *   searchQuery   String
 *   currentPage   int
 *   totalPages    int
 *   totalPromos   int
 */
public class AdminPromoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int  PAGE_SIZE        = 12;

    private final PromoCodeDAO promoDAO = new PromoCodeDAOImpl();

    // ── GET /manage/promos ────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String filterStatus = trim(request.getParameter("status"));  // ACTIVE | EXPIRED | INACTIVE
        String searchQuery  = trim(request.getParameter("q"));
        int    page         = parsePageParam(request.getParameter("page"));

        // ── Stat strip — shape to JSP key names ───────────────────────────────
        Map<String, Long> rawStats = promoDAO.getPromoStats();
        // JSP uses: stats.totalCodes, stats.activeCodes, stats.expiredCodes, stats.totalUsed
        java.util.Map<String, Object> stats = new java.util.LinkedHashMap<>();
        stats.put("totalCodes",   rawStats.getOrDefault("total",     0L));
        stats.put("activeCodes",  rawStats.getOrDefault("active",    0L));
        stats.put("expiredCodes", rawStats.getOrDefault("expired",   0L));
        stats.put("totalUsed",    rawStats.getOrDefault("totalUsed", 0L));

        // ── Paginated list ────────────────────────────────────────────────────
        List<PromoCode> promoCodes = promoDAO.getAllPromos(filterStatus, searchQuery, page, PAGE_SIZE);

        int total      = promoDAO.countPromos(filterStatus, searchQuery);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;

        // ── Success / error flash message from redirect ───────────────────────
        String msg = trim(request.getParameter("msg"));
        String err = trim(request.getParameter("err"));
        if (msg != null) request.setAttribute("successMsg", humanise(msg));
        if (err != null) request.setAttribute("errorMsg",   humanise(err));

        // ── Set requestScope ──────────────────────────────────────────────────
        request.setAttribute("promoCodes",   promoCodes);
        request.setAttribute("stats",         stats);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("searchQuery",  searchQuery);
        request.setAttribute("currentPage",  page);
        request.setAttribute("totalPages",   totalPages);
        request.setAttribute("totalPromos",  total);

        request.getRequestDispatcher("/jsp/manage/manage-promos.jsp")
               .forward(request, response);
    }

    // ── POST /manage/promos/* ─────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!"SUPER_ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/manage/promos?err=access_denied");
            return;
        }

        String pathInfo = request.getRequestURI()
                                 .substring(request.getContextPath().length());
        String action = pathInfo.replaceFirst("/manage/promos/?", "").trim();

        boolean ok;
        switch (action) {
            case "create": ok = handleCreate(request); break;
            case "edit":   ok = handleEdit(request);   break;
            case "delete": ok = handleDelete(request); break;
            case "toggle": ok = handleToggle(request); break;
            default:
                response.sendRedirect(request.getContextPath() + "/manage/promos?err=unknown_action");
                return;
        }

        String result = ok ? "success" : "failed";
        response.sendRedirect(request.getContextPath() + "/manage/promos?msg=" + action + "_" + result);
    }

    // ── Action handlers ───────────────────────────────────────────────────────

    private boolean handleCreate(HttpServletRequest req) {
        PromoCode p = buildFromRequest(req, -1);
        return p != null && promoDAO.createPromo(p);
    }

    private boolean handleEdit(HttpServletRequest req) {
        int id = parseId(req.getParameter("promoId"));
        if (id <= 0) return false;
        PromoCode p = buildFromRequest(req, id);
        return p != null && promoDAO.updatePromo(p);
    }

    private boolean handleDelete(HttpServletRequest req) {
        int id = parseId(req.getParameter("promoId"));
        return id > 0 && promoDAO.deletePromo(id);
    }

    private boolean handleToggle(HttpServletRequest req) {
        int id = parseId(req.getParameter("promoId"));
        return id > 0 && promoDAO.toggleActive(id);
    }

    // ── Build PromoCode from form fields ──────────────────────────────────────

    private PromoCode buildFromRequest(HttpServletRequest req, int id) {
        try {
            PromoCode p = new PromoCode();
            if (id > 0) p.setId(id);

            String code = trim(req.getParameter("code"));
            if (code == null) return null;
            p.setCode(code);

            String dtype = trim(req.getParameter("discountType"));
            p.setDiscountType("PERCENTAGE".equals(dtype) ? "PERCENTAGE" : "FLAT");

            String dval = trim(req.getParameter("discountValue"));
            p.setDiscountValue(dval != null ? new BigDecimal(dval) : BigDecimal.ZERO);

            String moval = trim(req.getParameter("minOrderValue"));
            p.setMinOrderValue(moval != null ? new BigDecimal(moval) : BigDecimal.ZERO);

            String maxUses = trim(req.getParameter("maxUses"));
            p.setMaxUses(maxUses != null ? Integer.parseInt(maxUses) : 0);

            String expiry = trim(req.getParameter("expiryDate"));
            if (expiry == null) return null;                 // expiry is required
            p.setExpiryDate(LocalDate.parse(expiry));        // ISO format from <input type="date">

            p.setActive(!"false".equals(req.getParameter("isActive"))
                        && !"0".equals(req.getParameter("isActive")));

            return p;
        } catch (Exception e) {
            System.err.println("AdminPromoServlet: buildFromRequest error — " + e.getMessage());
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

    /** Converts snake_case msg keys into readable text for flash messages. */
    private String humanise(String key) {
        if (key == null) return "";
        return key.replace('_', ' ');
    }
}
