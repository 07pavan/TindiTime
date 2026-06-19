package com.hungrygo.dao.impl;

import com.hungrygo.dao.RestaurantDAO;
import com.hungrygo.model.Restaurant;
import com.hungrygo.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object Implementation for Restaurant entities using JDBC.
 */
public class RestaurantDAOImpl implements RestaurantDAO {

    private static final String INSERT_RESTAURANT = "INSERT INTO restaurants (name, cuisine_type, rating, delivery_time_mins, cost_for_two, image_url, is_active) VALUES (?, ?, ?, ?, ?, ?, ?);";
    private static final String SELECT_RESTAURANT_BY_ID = "SELECT * FROM restaurants WHERE id = ?;";
    private static final String SELECT_ALL_RESTAURANTS = "SELECT * FROM restaurants WHERE is_active = 1;";
    private static final String SELECT_RESTAURANTS_BY_CUISINE = "SELECT * FROM restaurants WHERE cuisine_type LIKE ? AND is_active = 1;";
    private static final String SEARCH_RESTAURANTS = "SELECT * FROM restaurants WHERE (name LIKE ? OR cuisine_type LIKE ?) AND is_active = 1;";
    private static final String UPDATE_RESTAURANT = "UPDATE restaurants SET name = ?, cuisine_type = ?, rating = ?, delivery_time_mins = ?, cost_for_two = ?, image_url = ?, is_active = ? WHERE id = ?;";
    private static final String DELETE_RESTAURANT = "DELETE FROM restaurants WHERE id = ?;";

    @Override
    public boolean addRestaurant(Restaurant restaurant) {
        if (restaurant == null) return false;
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(INSERT_RESTAURANT);
            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setBigDecimal(3, restaurant.getRating());
            ps.setInt(4, restaurant.getDeliveryTimeMins());
            ps.setBigDecimal(5, restaurant.getCostForTwo());
            ps.setString(6, restaurant.getImageUrl());
            ps.setBoolean(7, restaurant.isActive());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC addRestaurant error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    @Override
    public Restaurant getRestaurantById(int id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_RESTAURANT_BY_ID);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return extractRestaurantFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("JDBC getRestaurantById error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return null;
    }

    @Override
    public List<Restaurant> getAllRestaurants() {
        List<Restaurant> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_ALL_RESTAURANTS);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractRestaurantFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC getAllRestaurants error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }

    @Override
    public List<Restaurant> getRestaurantsByCuisine(String cuisineType) {
        List<Restaurant> list = new ArrayList<>();
        if (cuisineType == null) return list;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_RESTAURANTS_BY_CUISINE);
            ps.setString(1, "%" + cuisineType.trim() + "%");
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractRestaurantFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC getRestaurantsByCuisine error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }

    @Override
    public List<Restaurant> searchRestaurants(String searchQuery) {
        List<Restaurant> list = new ArrayList<>();
        if (searchQuery == null) return list;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SEARCH_RESTAURANTS);
            String wildcard = "%" + searchQuery.trim() + "%";
            ps.setString(1, wildcard);
            ps.setString(2, wildcard);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractRestaurantFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC searchRestaurants error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }

    @Override
    public boolean updateRestaurant(Restaurant restaurant) {
        if (restaurant == null) return false;
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(UPDATE_RESTAURANT);
            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setBigDecimal(3, restaurant.getRating());
            ps.setInt(4, restaurant.getDeliveryTimeMins());
            ps.setBigDecimal(5, restaurant.getCostForTwo());
            ps.setString(6, restaurant.getImageUrl());
            ps.setBoolean(7, restaurant.isActive());
            ps.setInt(8, restaurant.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateRestaurant error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    @Override
    public boolean deleteRestaurant(int id) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(DELETE_RESTAURANT);
            ps.setInt(1, id);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC deleteRestaurant error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    /**
     * Helper method to map ResultSet row to Restaurant object
     */
    private Restaurant extractRestaurantFromResultSet(ResultSet rs) throws SQLException {
        Restaurant restaurant = new Restaurant();
        restaurant.setId(rs.getInt("id"));
        restaurant.setName(rs.getString("name"));
        restaurant.setCuisineType(rs.getString("cuisine_type"));
        restaurant.setRating(rs.getBigDecimal("rating"));
        restaurant.setDeliveryTimeMins(rs.getInt("delivery_time_mins"));
        restaurant.setCostForTwo(rs.getBigDecimal("cost_for_two"));
        restaurant.setImageUrl(rs.getString("image_url"));
        restaurant.setActive(rs.getBoolean("is_active"));
        return restaurant;
    }
}
