package com.hungrygo.controller;

import com.hungrygo.model.dao.UserDAO;
import com.hungrygo.model.dao.impl.UserDAOImpl;
import com.hungrygo.model.dao.RestaurantDAO;
import com.hungrygo.model.dao.impl.RestaurantDAOImpl;
import com.hungrygo.model.Restaurant;
import com.hungrygo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Handles all user authentication for HungryGO.
 *
 * Supported flows:
 *   GET  /login                    → Show the login form
 *   GET  /login?registered=true    → Show login form with a "registration success" banner
 *   GET  /login?msg=auth_required  → Show login form with a "please sign in" warning
 *   GET  /login?action=logout      → Destroy the current session and redirect home
 *   POST /login                    → Validate credentials; on success redirect to /index
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Data access layer — talks to the `users` table
    private final UserDAO userDAO = new UserDAOImpl();
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    // -----------------------------------------------------------------------
    // GET  /login
    // -----------------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // --- Handle Sign Out ---
        if ("logout".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();   // wipe the whole session cleanly
                System.out.println("HungryGO: session invalidated — user signed out.");
            }

            // Expire all state cookies so the browser forgets the user
            expireCookie(response, "username");
            expireCookie(response, "email");
            expireCookie(response, "phone");
            expireCookie(response, "address");
            expireCookie(response, "cartCount");

            // Send back to home with a goodbye query param (login.jsp reads it)
            response.sendRedirect(request.getContextPath() + "/login?msg=logged_out");
            return;
        }

        // --- Guard: already logged in? Send straight to home ---
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user_id") != null) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        // --- Pass "just registered" flag so login.jsp shows the success banner ---
        if ("true".equals(request.getParameter("registered"))) {
            request.setAttribute("registered", true);
        }

        // Show the login form
        request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
    }

    // -----------------------------------------------------------------------
    // POST /login  (form submission)
    // -----------------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        System.out.println("HungryGO: login attempt for → " + email);

        // --- Basic field presence check ---
        if (isBlank(email) || isBlank(password)) {
            request.setAttribute("error", "Please enter both your email address and password.");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            return;
        }

        // --- Check credentials against the database ---
        User authenticatedUser = userDAO.validateUser(email.trim().toLowerCase(), password);

        if (authenticatedUser != null) {
            // Create a brand-new session to prevent session-fixation attacks
            HttpSession session = request.getSession(true);
            session.setAttribute("user_id",  authenticatedUser.getId());
            session.setAttribute("username", authenticatedUser.getName());
            session.setAttribute("email",    authenticatedUser.getEmail());
            session.setAttribute("userEmail", authenticatedUser.getEmail()); // Fix 2: Sidebar email consistency
            session.setAttribute("phone",    authenticatedUser.getPhone());
            session.setAttribute("address",  authenticatedUser.getAddress());
            session.setAttribute("cartSize", 0);   // fresh cart count on every login

            // Role — read by ManagementAccessFilter and manage-sidebar.jsp
            String userRole = (authenticatedUser.getRole() != null)
                              ? authenticatedUser.getRole() : "CUSTOMER";
            session.setAttribute("role",     userRole);
            session.setAttribute("userRole", userRole);
            session.setAttribute("userName", authenticatedUser.getName());

            // Fix 1: Associate restaurantId for restaurant owners
            if ("RESTAURANT_OWNER".equals(userRole)) {
                Restaurant rest = restaurantDAO.getRestaurantByOwnerId(authenticatedUser.getId());
                if (rest != null) {
                    session.setAttribute("restaurantId", rest.getId());
                    session.setAttribute("restaurantName", rest.getName());
                }
            }

            // Sync lightweight cookies for any client-side reads
            addStateCookie(response, "username", authenticatedUser.getName());
            addStateCookie(response, "email",    authenticatedUser.getEmail());
            addStateCookie(response, "phone",    authenticatedUser.getPhone());
            addStateCookie(response, "address",  authenticatedUser.getAddress());

            System.out.println("HungryGO: login success for " + email + " — redirecting to /index");

            // Drop the user onto the home page
            response.sendRedirect(request.getContextPath() + "/index");

        } else {
            System.out.println("HungryGO: login failed for " + email);
            request.setAttribute("error", "Incorrect email or password. Please try again.");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }

    // -----------------------------------------------------------------------
    // Private helpers
    // -----------------------------------------------------------------------

    /** Adds a browser cookie that stays alive for 1 day (used for client-side state). */
    private void addStateCookie(HttpServletResponse response, String name, String value) {
        if (value == null) return;
        try {
            String encoded = URLEncoder.encode(value, StandardCharsets.UTF_8.toString());
            Cookie cookie  = new Cookie(name, encoded);
            cookie.setPath("/");
            cookie.setMaxAge(60 * 60 * 24); // 24 hours
            response.addCookie(cookie);
        } catch (Exception e) {
            System.err.println("HungryGO: cookie error — " + e.getMessage());
        }
    }

    /** Sets a cookie's max-age to 0 so the browser deletes it immediately. */
    private void expireCookie(HttpServletResponse response, String name) {
        Cookie cookie = new Cookie(name, "");
        cookie.setPath("/");
        cookie.setMaxAge(0);
        response.addCookie(cookie);
    }

    /** Returns true if a string is null or blank. */
    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
