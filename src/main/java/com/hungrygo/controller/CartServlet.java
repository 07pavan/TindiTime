package com.hungrygo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

import com.hungrygo.model.dao.MenuItemDAO;
import com.hungrygo.model.dao.impl.MenuItemDAOImpl;
import com.hungrygo.model.Cart;
import com.hungrygo.model.MenuItem;

import java.io.IOException;

/**
 * Servlet controller for presenting or routing operations concerning the interactive Session cart.
 */
@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MenuItemDAO menuItemDAO;

    @Override
    public void init() throws ServletException {
        this.menuItemDAO = new MenuItemDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("HTTP GET: CartServlet inspecting user container bag state.");
        
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }
        
        // Update cart count cookie for frontend
        int cartCount = cart.getCartSize();
        Cookie countCookie = new Cookie("cartCount", String.valueOf(cartCount));
        countCookie.setPath("/");
        response.addCookie(countCookie);

        // Forward to the cart JSP page
        request.getRequestDispatcher("/jsp/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        
        System.out.println("HTTP POST: Executing cart API operation action - " + action + ", item id: " + idParam);
        
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }

        if (action != null) {
            try {
                if (action.equalsIgnoreCase("add")) {
                    // Enforce login for cart additions
                    if (session.getAttribute("username") == null) {
                        response.sendRedirect("login?msg=auth_required");
                        return;
                    }
                    if (idParam != null && !idParam.trim().isEmpty()) {
                        int itemId = Integer.parseInt(idParam);
                        MenuItem item = menuItemDAO.getMenuItemById(itemId);
                        if (item != null) {
                            String qtyStr = request.getParameter("quantity");
                            int qty = 1;
                            if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                                qty = Integer.parseInt(qtyStr);
                            }
                            cart.addItem(item, qty);
                            System.out.println("Cart: Added " + qty + " of " + item.getName());
                        }
                    }
                } else if (action.equalsIgnoreCase("update")) {
                    if (idParam != null && !idParam.trim().isEmpty()) {
                        int itemId = Integer.parseInt(idParam);
                        String qtyStr = request.getParameter("quantity");
                        if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                            int qty = Integer.parseInt(qtyStr);
                            cart.updateQuantity(itemId, qty);
                            System.out.println("Cart: Updated item " + itemId + " quantity to " + qty);
                        }
                    }
                } else if (action.equalsIgnoreCase("remove")) {
                    if (idParam != null && !idParam.trim().isEmpty()) {
                        int itemId = Integer.parseInt(idParam);
                        cart.removeItem(itemId);
                        System.out.println("Cart: Removed item " + itemId);
                    }
                } else if (action.equalsIgnoreCase("clear")) {
                    cart.clear();
                    System.out.println("Cart: Cleared all items.");
                }
            } catch (NumberFormatException e) {
                System.err.println("CartServlet processing error: ID/Qty parsing failed: " + e.getMessage());
            }
        }

        // Sync cart count cookie
        int cartCount = cart.getCartSize();
        Cookie countCookie = new Cookie("cartCount", String.valueOf(cartCount));
        countCookie.setPath("/");
        response.addCookie(countCookie);

        // Redirect to the return URL or default back to cart
        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl != null && !returnUrl.trim().isEmpty()) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect("cart");
        }
    }
}
