package com.hungrygo.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Centralized security filter that intercepts all application requests.
 * Restricts access to authenticated users only, excluding public resources like Login and Register views.
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("HungryGO Security: AuthenticationFilter initialized.");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());
        
        // Define public pages and resources that bypass authentication checks
        boolean isPublicResource = path.equals("/") ||
                                   path.equals("/login") || 
                                   path.equals("/register") || 
                                   path.equals("/jsp/login.jsp") || 
                                   path.equals("/jsp/register.jsp") ||
                                   path.endsWith("/style.css") ||
                                   path.startsWith("/css/") ||
                                   path.startsWith("/js/") ||
                                   path.startsWith("/images/");
        
        HttpSession session = request.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user_id") != null);
        
        if (isLoggedIn || isPublicResource) {
            // User is authenticated or accessing a public resource, proceed normally
            chain.doFilter(request, response);
        } else {
            // User is anonymous and trying to access a protected page, redirect to Login
            System.out.println("HungryGO Security: Anonymous access denied for " + path + ". Redirecting to /login...");
            
            // Check if the request is an AJAX call
            boolean isAjax = false;
            String requestedWith = request.getHeader("X-Requested-With");
            String acceptHeader = request.getHeader("Accept");
            if ("XMLHttpRequest".equals(requestedWith) || (acceptHeader != null && acceptHeader.contains("application/json"))) {
                isAjax = true;
            }
            
            if (isAjax) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\":false,\"redirect\":\"" + contextPath + "/login?msg=auth_required\"}");
                return;
            }
            
            response.sendRedirect(contextPath + "/login?msg=auth_required");
        }
    }

    @Override
    public void destroy() {
        System.out.println("HungryGO Security: AuthenticationFilter destroyed.");
    }
}
