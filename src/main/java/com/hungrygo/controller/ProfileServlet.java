package com.hungrygo.controller;

import com.hungrygo.model.dao.UserDAO;
import com.hungrygo.model.dao.impl.UserDAOImpl;
import com.hungrygo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet controller for presenting profile details and handling password/detail updates.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("HTTP GET: ProfileServlet verifying current auth state.");
        
        HttpSession session = request.getSession();
        // Check if user is logged in
        if (session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Fetch latest user details from database to keep session updated
        Integer userIdObj = (Integer) session.getAttribute("user_id");
        int userId = (userIdObj != null) ? userIdObj : 1;
        User user = userDAO.getUserById(userId);
        if (user != null) {
            // Update session variables with latest DB values
            session.setAttribute("username", user.getName());
            session.setAttribute("userName", user.getName());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("phone", user.getPhone());
            session.setAttribute("address", user.getAddress());
        }

        request.setAttribute("profileVerified", true);
        request.getRequestDispatcher("/jsp/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("HTTP POST: ProfileServlet executing profile updates.");

        HttpSession session = request.getSession();
        // Check if user is logged in
        if (session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userIdObj = (Integer) session.getAttribute("user_id");
        int userId = (userIdObj != null) ? userIdObj : 1;

        String action = request.getParameter("action");
        if ("updateProfile".equalsIgnoreCase(action)) {
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");

            System.out.println("Processing updates: name=" + name + ", phone=" + phone + ", address=" + address);
            
            User user = userDAO.getUserById(userId);
            if (user != null) {
                user.setName(name != null ? name.trim() : "");
                user.setPhone(phone != null ? phone.trim() : "");
                user.setAddress(address != null ? address.trim() : "");
                
                boolean success = userDAO.updateUserProfile(user);
                if (success) {
                    // Update session details
                    session.setAttribute("username", user.getName());
                    session.setAttribute("userName", user.getName());
                    session.setAttribute("phone", user.getPhone());
                    session.setAttribute("address", user.getAddress());
                    
                    // Update cookies for frontend sync
                    addStateCookie(response, "username", user.getName());
                    addStateCookie(response, "phone", user.getPhone());
                    addStateCookie(response, "address", user.getAddress());
                    
                    request.setAttribute("success", "Profile updated successfully!");
                } else {
                    request.setAttribute("error", "Failed to update profile settings in database.");
                }
            } else {
                request.setAttribute("error", "Authenticated user profile not found.");
            }
        } else if ("changePassword".equalsIgnoreCase(action) || "updatePassword".equalsIgnoreCase(action)) {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            
            System.out.println("Processing update password request...");
            
            if (oldPassword != null && newPassword != null && !newPassword.trim().isEmpty()) {
                boolean success = userDAO.updatePassword(userId, oldPassword, newPassword);
                if (success) {
                    request.setAttribute("success", "Password updated successfully!");
                } else {
                    request.setAttribute("error", "Current password verification failed. Please try again.");
                }
            } else {
                request.setAttribute("error", "Password fields cannot be blank.");
            }
        }

        request.setAttribute("profileVerified", true);
        request.getRequestDispatcher("/jsp/profile.jsp").forward(request, response);
    }

    /**
     * Helper to set a state cookie for frontend sync
     */
    private void addStateCookie(HttpServletResponse response, String name, String value) {
        if (value == null) return;
        try {
            String encodedValue = java.net.URLEncoder.encode(value, java.nio.charset.StandardCharsets.UTF_8.toString());
            jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie(name, encodedValue);
            cookie.setPath("/");
            cookie.setMaxAge(60 * 60 * 24); // 1 day
            response.addCookie(cookie);
        } catch (Exception e) {
            System.err.println("Cookie setup exception: " + e.getMessage());
        }
    }
}
