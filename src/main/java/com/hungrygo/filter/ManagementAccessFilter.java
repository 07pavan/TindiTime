package com.hungrygo.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * ManagementAccessFilter — second layer of security on top of AuthenticationFilter.
 *
 * Guards every /manage/* route. Requires the user to be:
 *   1. Logged in (session.user_id != null) — AuthenticationFilter already ensured this,
 *      but we double-check for safety.
 *   2. Hold an elevated role: SUPER_ADMIN or RESTAURANT_OWNER.
 *
 * Regular CUSTOMER accounts are blocked and redirected to /index.
 *
 * Also sets request-scoped helpers that the shared manage-sidebar.jsp reads:
 *   - "managePath"   — the current path segment (e.g. "orders", "users")
 *   - "userRole"     — convenience alias of session role for JSP EL
 *   - "userName"     — display name from session
 */
public class ManagementAccessFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("HungryGO Security: ManagementAccessFilter initialized — /manage/* protected.");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);

        // ── 1. Must be logged in ────────────────────────────────────────────
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login?msg=auth_required");
            return;
        }

        // ── 2. Must hold an admin/owner role ───────────────────────────────
        String role = (String) session.getAttribute("role");
        boolean isAdminOrOwner = "SUPER_ADMIN".equals(role) || "RESTAURANT_OWNER".equals(role);

        if (!isAdminOrOwner) {
            // Logged-in customer accidentally hitting /manage — send home
            System.out.println("HungryGO Security: Access denied to /manage/* for role="
                    + role + " (user_id=" + session.getAttribute("user_id") + ")");
            response.sendRedirect(request.getContextPath() + "/index?msg=access_denied");
            return;
        }

        // ── 3. Set convenience request attributes for JSP EL ──────────────
        // userRole & userName — used by manage-sidebar.jsp
        if (request.getAttribute("userRole") == null) {
            request.setAttribute("userRole", role);
        }
        if (request.getAttribute("userName") == null) {
            request.setAttribute("userName", session.getAttribute("username"));
        }
        if ("SUPER_ADMIN".equals(role)) {
            try {
                com.hungrygo.model.dao.AdminDAO adminDAO = new com.hungrygo.model.dao.impl.AdminDAOImpl();
                request.setAttribute("pendingApprovals", adminDAO.getPendingApprovalCount());
            } catch (Exception e) {
                System.err.println("ManagementAccessFilter: error loading pendingApprovals — " + e.getMessage());
            }
        }

        // managePath — strips /manage/ prefix, e.g. "/manage/orders" → "orders"
        String uri         = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path        = uri.substring(contextPath.length()); // e.g. /manage/orders
        String managePath  = "";
        if (path.startsWith("/manage/")) {
            managePath = path.substring("/manage/".length()); // e.g. "orders"
            int slash = managePath.indexOf('/');
            if (slash > 0) managePath = managePath.substring(0, slash); // strip sub-paths
        } else if (path.equals("/manage")) {
            managePath = "dashboard";
        }
        request.setAttribute("managePath", managePath);

        // ── 4. Pass through ───────────────────────────────────────────────
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        System.out.println("HungryGO Security: ManagementAccessFilter destroyed.");
    }
}
