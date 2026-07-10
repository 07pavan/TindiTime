package com.hungrygo.controller;

import com.hungrygo.model.Restaurant;
import com.hungrygo.model.dao.PlatformSettingDAO;
import com.hungrygo.model.dao.RestaurantDAO;
import com.hungrygo.model.dao.UserDAO;
import com.hungrygo.model.dao.impl.PlatformSettingDAOImpl;
import com.hungrygo.model.dao.impl.RestaurantDAOImpl;
import com.hungrygo.model.dao.impl.UserDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

/**
 * AdminSettingsServlet — platform configuration & merchant operational settings.
 *
 * URL mappings (web.xml):
 *   GET  /manage/settings             → loads platform config or merchant profile
 *   POST /manage/settings/platform    → update platform core settings (SUPER_ADMIN)
 *   POST /manage/settings/banner      → update maintenance banner (SUPER_ADMIN)
 *   POST /manage/settings/fees        → update delivery fee structure (SUPER_ADMIN)
 *   POST /manage/settings/profile     → update merchant restaurant details (OWNER)
 *   POST /manage/settings/status      → toggle open/closed operational status (OWNER)
 *   POST /manage/settings/hours       → update restaurant business hours (OWNER)
 *   POST /manage/settings/password    → change account password (both roles)
 */
public class AdminSettingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final PlatformSettingDAO platformDAO = new PlatformSettingDAOImpl();
    private final RestaurantDAO      restaurantDAO  = new RestaurantDAOImpl();
    private final UserDAO            userDAO        = new UserDAOImpl();

    // ── GET /manage/settings ──────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("user_id");

        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/login?msg=auth_required");
            return;
        }

        // ── Load Platform Settings (SUPER_ADMIN only) ─────────────────────────
        if ("SUPER_ADMIN".equals(role)) {
            Map<String, Object> platformConfig = platformDAO.getPlatformSettings();
            request.setAttribute("platformConfig", platformConfig);
        }

        // ── Load Restaurant Settings (RESTAURANT_OWNER only) ──────────────────
        if ("RESTAURANT_OWNER".equals(role) && userId != null) {
            Restaurant restaurant = restaurantDAO.getRestaurantByOwnerId(userId);
            if (restaurant != null) {
                request.setAttribute("restaurantProfile", restaurant);
                // Sync session attribute restaurantId just in case
                session.setAttribute("restaurantId", restaurant.getId());
            }
        }

        // ── Success / error message handling ──────────────────────────────
        String msg = trim(request.getParameter("msg"));
        String err = trim(request.getParameter("err"));
        if (msg != null) request.setAttribute("successMessage", msg.replace('_', ' '));
        if (err != null) request.setAttribute("errorMessage",   err.replace('_', ' '));

        request.getRequestDispatcher("/jsp/manage/manage-settings.jsp")
               .forward(request, response);
    }

    // ── POST /manage/settings/* ────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("user_id");

        if (role == null || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?msg=auth_required");
            return;
        }

        String pathInfo = request.getRequestURI()
                                 .substring(request.getContextPath().length());
        String action = pathInfo.replaceFirst("/manage/settings/?", "").trim();

        boolean ok = false;
        String successMsg = "settings_saved";
        String errMsg = "save_failed";

        try {
            switch (action) {
                // ── Platform settings (SUPER_ADMIN only) ──────────────────────
                case "platform":
                    if (!"SUPER_ADMIN".equals(role)) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=access_denied");
                        return;
                    }
                    double commRate = parseDouble(request.getParameter("commissionRate"), 15.0);
                    double taxRate  = parseDouble(request.getParameter("taxRate"), 5.0);
                    int maxRadius   = parseInt(request.getParameter("maxDeliveryRadius"), 10);
                    ok = platformDAO.updatePlatformConfig(commRate, taxRate, maxRadius);
                    break;

                case "banner":
                    if (!"SUPER_ADMIN".equals(role)) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=access_denied");
                        return;
                    }
                    boolean bannerEnabled = "true".equalsIgnoreCase(request.getParameter("bannerEnabled")) 
                                            || "on".equalsIgnoreCase(request.getParameter("bannerEnabled"));
                    String bannerType     = trim(request.getParameter("bannerType"));
                    String bannerText     = trim(request.getParameter("bannerText"));
                    ok = platformDAO.updateBanner(bannerEnabled, bannerType != null ? bannerType : "info", bannerText != null ? bannerText : "");
                    break;

                case "fees":
                    if (!"SUPER_ADMIN".equals(role)) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=access_denied");
                        return;
                    }
                    double baseFee       = parseDouble(request.getParameter("baseDeliveryFee"), 30.0);
                    double perKmRate      = parseDouble(request.getParameter("perKmRate"), 5.0);
                    double freeThreshold = parseDouble(request.getParameter("freeDeliveryThreshold"), 0.0);
                    ok = platformDAO.updateFees(baseFee, perKmRate, freeThreshold);
                    break;

                // ── Merchant settings (RESTAURANT_OWNER only) ─────────────────
                case "profile":
                    if (!"RESTAURANT_OWNER".equals(role)) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=access_denied");
                        return;
                    }
                    Restaurant rest = restaurantDAO.getRestaurantByOwnerId(userId);
                    if (rest == null) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=restaurant_not_found");
                        return;
                    }
                    rest.setName(request.getParameter("name"));
                    rest.setCuisineType(request.getParameter("cuisineType"));
                    rest.setDescription(request.getParameter("description"));
                    rest.setPhone(request.getParameter("phone"));
                    rest.setEmail(request.getParameter("email"));
                    rest.setAddress(request.getParameter("address"));
                    rest.setCity(request.getParameter("city"));
                    rest.setPostalCode(request.getParameter("postalCode"));
                    rest.setLogoUrl(request.getParameter("logoUrl"));
                    ok = restaurantDAO.updateRestaurantProfile(rest);
                    break;

                case "status":
                    if (!"RESTAURANT_OWNER".equals(role)) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=access_denied");
                        return;
                    }
                    Restaurant restStatus = restaurantDAO.getRestaurantByOwnerId(userId);
                    if (restStatus == null) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=restaurant_not_found");
                        return;
                    }
                    boolean isOpen = "true".equalsIgnoreCase(request.getParameter("isOpen")) 
                                     || "on".equalsIgnoreCase(request.getParameter("isOpen"));
                    ok = restaurantDAO.updateRestaurantOperationalStatus(restStatus.getId(), isOpen);
                    successMsg = isOpen ? "Restaurant_Opened" : "Restaurant_Closed";
                    break;

                case "hours":
                    if (!"RESTAURANT_OWNER".equals(role)) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=access_denied");
                        return;
                    }
                    Restaurant restHours = restaurantDAO.getRestaurantByOwnerId(userId);
                    if (restHours == null) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=restaurant_not_found");
                        return;
                    }
                    String openTime  = trim(request.getParameter("openTime"));
                    String closeTime = trim(request.getParameter("closeTime"));
                    ok = restaurantDAO.updateRestaurantHours(restHours.getId(), openTime, closeTime);
                    break;

                // ── Account Settings (Both Roles) ─────────────────────────────
                case "password":
                    String curPass = request.getParameter("currentPassword");
                    String newPass = request.getParameter("newPassword");
                    if (curPass == null || newPass == null || curPass.trim().isEmpty() || newPass.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/manage/settings?err=passwords_cannot_be_empty");
                        return;
                    }
                    ok = userDAO.updatePassword(userId, curPass.trim(), newPass.trim());
                    successMsg = "Password_Updated";
                    errMsg = "Invalid_Current_Password";
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/manage/settings?err=unknown_action");
                    return;
            }
        } catch (Exception e) {
            System.err.println("AdminSettingsServlet error during POST actions: " + e.getMessage());
            e.printStackTrace();
            ok = false;
        }

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/manage/settings?msg=" + successMsg);
        } else {
            response.sendRedirect(request.getContextPath() + "/manage/settings?err=" + errMsg);
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private String trim(String s) {
        return (s != null && !s.trim().isEmpty()) ? s.trim() : null;
    }

    private double parseDouble(String val, double fallback) {
        try { return Double.parseDouble(val); } 
        catch (Exception e) { return fallback; }
    }

    private int parseInt(String val, int fallback) {
        try { return Integer.parseInt(val); } 
        catch (Exception e) { return fallback; }
    }
}
