package com.hungrygo.model.dao.impl;

import com.hungrygo.model.dao.RestaurantDAO;
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
     * Helper method to map ResultSet row to Restaurant object.
     * New admin columns are read with graceful fallback if absent.
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
        // Admin columns added by migration — silently ignored if absent
        try { restaurant.setStatus(rs.getString("status")); }         catch (SQLException ignored) {}
        try { restaurant.setOpen(rs.getBoolean("is_open")); }         catch (SQLException ignored) {}
        try { restaurant.setTotalOrders(rs.getInt("total_orders")); } catch (SQLException ignored) {}
        try { restaurant.setTotalRevenue(rs.getBigDecimal("total_revenue")); } catch (SQLException ignored) {}
        try { restaurant.setOwnerUserId(rs.getInt("owner_user_id")); } catch (SQLException ignored) {}
        try { restaurant.setAddress(rs.getString("address")); }        catch (SQLException ignored) {}
        try { restaurant.setCity(rs.getString("city")); }              catch (SQLException ignored) {}
        try { restaurant.setPhone(rs.getString("phone")); }            catch (SQLException ignored) {}
        try { restaurant.setEmail(rs.getString("email")); }            catch (SQLException ignored) {}
        try { restaurant.setPostalCode(rs.getString("postal_code")); } catch (SQLException ignored) {}
        try { restaurant.setLogoUrl(rs.getString("logo_url")); }       catch (SQLException ignored) {}
        try { restaurant.setDescription(rs.getString("description")); } catch (SQLException ignored) {}
        try { restaurant.setOpenTime(rs.getString("open_time")); }     catch (SQLException ignored) {}
        try { restaurant.setCloseTime(rs.getString("close_time")); }   catch (SQLException ignored) {}
        return restaurant;
    }

    // ──────────────────────────────────────────────────────────────
    // Admin-only implementations
    // ──────────────────────────────────────────────────────────────

    @Override
    public boolean updateStatus(int restaurantId, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(
                "UPDATE restaurants SET status = ? WHERE id = ?");
            ps.setString(1, status);
            ps.setInt(2, restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateStatus error: " + e.getMessage());
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    @Override
    public List<Restaurant> getRestaurantsAdmin(String query, String status, int page, int pageSize) {
        List<Restaurant> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            // Build dynamic WHERE clause
            StringBuilder sql = new StringBuilder(
                "SELECT * FROM restaurants WHERE 1=1");
            if (query != null && !query.trim().isEmpty()) {
                sql.append(" AND (name LIKE ? OR cuisine_type LIKE ?)");
            }
            if (status != null && !status.trim().isEmpty()) {
                sql.append(" AND status = ?");
            }
            sql.append(" ORDER BY id DESC LIMIT ? OFFSET ?");

            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql.toString());

            int idx = 1;
            if (query != null && !query.trim().isEmpty()) {
                String w = "%" + query.trim() + "%";
                ps.setString(idx++, w);
                ps.setString(idx++, w);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status.trim());
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx,   (page - 1) * pageSize);

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractRestaurantFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC getRestaurantsAdmin error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }

    @Override
    public int countRestaurantsAdmin(String query, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM restaurants WHERE 1=1");
            if (query != null && !query.trim().isEmpty()) {
                sql.append(" AND (name LIKE ? OR cuisine_type LIKE ?)");
            }
            if (status != null && !status.trim().isEmpty()) {
                sql.append(" AND status = ?");
            }
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql.toString());

            int idx = 1;
            if (query != null && !query.trim().isEmpty()) {
                String w = "%" + query.trim() + "%";
                ps.setString(idx++, w);
                ps.setString(idx++, w);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx, status.trim());
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("JDBC countRestaurantsAdmin error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return 0;
    }

    @Override
    public List<Restaurant> getPendingRestaurants() {
        List<Restaurant> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(
                "SELECT * FROM restaurants WHERE status = 'PENDING_APPROVAL' ORDER BY id ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractRestaurantFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC getPendingRestaurants error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
     }

    @Override
    public Restaurant getRestaurantByOwnerId(int ownerUserId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement("SELECT * FROM restaurants WHERE owner_user_id = ?");
            ps.setInt(1, ownerUserId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return extractRestaurantFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("JDBC getRestaurantByOwnerId error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return null;
    }

    @Override
    public boolean updateRestaurantProfile(Restaurant restaurant) {
        if (restaurant == null) return false;
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(
                "UPDATE restaurants SET name = ?, cuisine_type = ?, description = ?, " +
                "phone = ?, email = ?, address = ?, city = ?, postal_code = ?, logo_url = ? " +
                "WHERE id = ?");
            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setString(3, restaurant.getDescription());
            ps.setString(4, restaurant.getPhone());
            ps.setString(5, restaurant.getEmail());
            ps.setString(6, restaurant.getAddress());
            ps.setString(7, restaurant.getCity());
            ps.setString(8, restaurant.getPostalCode());
            ps.setString(9, restaurant.getLogoUrl());
            ps.setInt(10,   restaurant.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateRestaurantProfile error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(ps, conn);
        }
        return false;
    }

    @Override
    public boolean updateRestaurantHours(int restaurantId, String openTime, String closeTime) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(
                "UPDATE restaurants SET open_time = ?, close_time = ? WHERE id = ?");
            ps.setString(1, openTime);
            ps.setString(2, closeTime);
            ps.setInt(3,    restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateRestaurantHours error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(ps, conn);
        }
        return false;
    }

    @Override
    public boolean updateRestaurantOperationalStatus(int restaurantId, boolean isOpen) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement("UPDATE restaurants SET is_open = ? WHERE id = ?");
            ps.setBoolean(1, isOpen);
            ps.setInt(2,     restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateRestaurantOperationalStatus error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(ps, conn);
        }
        return false;
    }
}
