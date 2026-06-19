package com.hungrygo.controller;

import com.hungrygo.dao.OrderDAO;
import com.hungrygo.dao.impl.OrderDAOImpl;
import com.hungrygo.model.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet controller for retrieving complete active/past order history models.
 */
@WebServlet(name = "OrderServlet", urlPatterns = {"/orders"})
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("HTTP GET: OrderServlet loading historic tracking datasets.");
        
        HttpSession session = request.getSession();
        // Auth gate
        if (session.getAttribute("username") == null) {
            response.sendRedirect("login");
            return;
        }

        Integer userIdObj = (Integer) session.getAttribute("user_id");
        int userId = (userIdObj != null) ? userIdObj : 1;

        // Fetch past orders from the database
        List<Order> pastOrders = orderDAO.getOrdersByUser(userId);
        request.setAttribute("orders", pastOrders);

        request.getRequestDispatcher("/jsp/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
