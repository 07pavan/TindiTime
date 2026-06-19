package com.hungrygo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.hungrygo.dao.RestaurantDAO;
import com.hungrygo.dao.impl.RestaurantDAOImpl;
import com.hungrygo.model.Restaurant;
import com.hungrygo.dao.MenuItemDAO;
import com.hungrygo.dao.impl.MenuItemDAOImpl;
import com.hungrygo.model.MenuItem;

import java.io.IOException;
import java.util.List;

/**
 * Servlet controller for fetching menus corresponding to selected restaurants.
 */
@WebServlet(name = "MenuServlet", urlPatterns = {"/menu"})
public class MenuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private RestaurantDAO restaurantDAO;
    private MenuItemDAO menuItemDAO;

    @Override
    public void init() throws ServletException {
        this.restaurantDAO = new RestaurantDAOImpl();
        this.menuItemDAO = new MenuItemDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String restaurantIdStr = request.getParameter("id");
        int restaurantId = (restaurantIdStr != null) ? Integer.parseInt(restaurantIdStr) : 1;

        System.out.println("HTTP GET: MenuServlet fetching menu details for restaurant ID: " + restaurantId);

        Restaurant restaurant = restaurantDAO.getRestaurantById(restaurantId);
        List<MenuItem> menuItems = menuItemDAO.getMenuItemsByRestaurant(restaurantId);

        request.setAttribute("restaurant", restaurant);
        request.setAttribute("menuItems", menuItems);

        request.getRequestDispatcher("/jsp/menu.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
