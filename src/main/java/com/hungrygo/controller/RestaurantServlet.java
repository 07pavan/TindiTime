package com.hungrygo.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.hungrygo.dao.RestaurantDAO;
import com.hungrygo.dao.impl.RestaurantDAOImpl;
import com.hungrygo.model.Restaurant;

import java.io.IOException;
import java.util.List;

/**
 * Servlet controller for querying and assembling available restaurants list.
 */
@WebServlet(name = "RestaurantServlet", urlPatterns = {"/restaurants"})
public class RestaurantServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private RestaurantDAO restaurantDAO;

    @Override
    public void init() throws ServletException {
        this.restaurantDAO = new RestaurantDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String cuisine = request.getParameter("cuisine");
        String category = request.getParameter("category");
        String search = request.getParameter("search");

        System.out.println("HTTP GET: Restaurant query parameters - cuisine: " + cuisine + ", category: " + category + ", search: " + search);

        List<Restaurant> restaurantList;
        if (search != null && !search.trim().isEmpty()) {
            restaurantList = restaurantDAO.searchRestaurants(search);
        } else if (cuisine != null && !cuisine.trim().isEmpty()) {
            restaurantList = restaurantDAO.getRestaurantsByCuisine(cuisine);
        } else if (category != null && !category.trim().isEmpty()) {
            restaurantList = restaurantDAO.getRestaurantsByCuisine(category);
        } else {
            restaurantList = restaurantDAO.getAllRestaurants();
        }

        request.setAttribute("restaurants", restaurantList);
        request.getRequestDispatcher("/jsp/restaurants.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
