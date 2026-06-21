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
 * Servlet controller handling new customer registration.
 *
 * Flow:
 *   GET  /register  → shows the registration form
 *   POST /register  → validates form, inserts user into DB, then redirects to
 *                     /login?registered=true with a one-time success flash message.
 *
 * Users are NOT automatically logged in after registration.
 * They must sign in with their new credentials to enter the application.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Data access layer — talks to the `users` table
    private final UserDAO userDAO = new UserDAOImpl();

    /**
     * Shows the registration form to the visitor.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // If user is already logged in, send them straight home
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user_id") != null) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
    }

    /**
     * Processes the submitted registration form.
     * On success  → stores flash message in session and redirects to /login.
     * On failure  → re-displays the form with an inline error message.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- Read form fields ---
        String name            = request.getParameter("name");
        String email           = request.getParameter("email");
        String phone           = request.getParameter("phone");
        String pincode         = request.getParameter("pincode");
        String address         = request.getParameter("address");
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // --- Field presence validation ---
        if (isBlank(name) || isBlank(email) || isBlank(phone)
                || isBlank(address) || isBlank(password)) {
            forwardWithError(request, response, "All registration fields are required!");
            return;
        }

        // --- Password length check ---
        if (password.length() < 6) {
            forwardWithError(request, response, "Password must be at least 6 characters long!");
            return;
        }

        // --- Password match check ---
        if (!password.equals(confirmPassword)) {
            forwardWithError(request, response, "Passwords do not match!");
            return;
        }

        // --- Normalise email to lowercase ---
        email = email.trim().toLowerCase();

        // --- Duplicate account check ---
        if (userDAO.getUserByEmail(email) != null) {
            forwardWithError(request, response,
                    "An account with this email address already exists! Please Sign In instead.");
            return;
        }

        // --- Build the full address (combines address + optional pincode) ---
        String fullAddress = address.trim();
        if (pincode != null && !pincode.trim().isEmpty()) {
            fullAddress += " - " + pincode.trim();
        }

        // --- Persist the new user ---
        User newUser = new User(0, name.trim(), email, password, phone.trim(), fullAddress, "CUSTOMER");
        boolean saved = userDAO.registerUser(newUser);

        if (saved) {
            // Put a one-time welcome message in the session; login.jsp will display it.
            HttpSession session = request.getSession(true);
            session.setAttribute("successMessage",
                    "Account created successfully! Welcome to HungryGO. Please sign in to start ordering.");

            System.out.println("Registration success for: " + email + " — redirecting to /login");

            // Redirect the user to the login screen (NOT auto-logged-in)
            response.sendRedirect(request.getContextPath() + "/login?registered=true");
        } else {
            forwardWithError(request, response,
                    "Registration failed due to a server error. Please try again.");
        }
    }

    // -----------------------------------------------------------------------
    // Private helpers
    // -----------------------------------------------------------------------

    /** Returns true if a string is null or contains only whitespace. */
    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    /** Attaches an error message and re-displays the registration form. */
    private void forwardWithError(HttpServletRequest req, HttpServletResponse res, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        req.getRequestDispatcher("/jsp/register.jsp").forward(req, res);
    }
}
