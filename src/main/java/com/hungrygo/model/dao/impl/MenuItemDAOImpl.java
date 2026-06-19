package com.hungrygo.dao.impl;

import com.hungrygo.dao.MenuItemDAO;
import com.hungrygo.model.MenuItem;
import com.hungrygo.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object Implementation for MenuItem entities using JDBC queries.
 */
public class MenuItemDAOImpl implements MenuItemDAO {

    private static final String INSERT_MENU_ITEM = "INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
    private static final String SELECT_MENU_ITEM_BY_ID = "SELECT * FROM menu_items WHERE id = ?;";
    private static final String SELECT_MENU_BY_RESTAURANT = "SELECT * FROM menu_items WHERE restaurant_id = ? AND is_available = 1;";
    private static final String SELECT_MENU_BY_CATEGORY = "SELECT * FROM menu_items WHERE restaurant_id = ? AND category = ? AND is_available = 1;";
    private static final String UPDATE_MENU_ITEM = "UPDATE menu_items SET name = ?, description = ?, price = ?, image_url = ?, category = ?, is_vegetarian = ?, is_available = ? WHERE id = ?;";
    private static final String DELETE_MENU_ITEM = "DELETE FROM menu_items WHERE id = ?;";

    @Override
    public boolean addMenuItem(MenuItem item) {
        if (item == null) return false;
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(INSERT_MENU_ITEM);
            ps.setInt(1, item.getRestaurantId());
            ps.setString(2, item.getName());
            ps.setString(3, item.getDescription());
            ps.setBigDecimal(4, item.getPrice());
            ps.setString(5, item.getImageUrl());
            ps.setString(6, item.getCategory());
            ps.setBoolean(7, item.isVegetarian());
            ps.setBoolean(8, item.isAvailable());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC addMenuItem error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    @Override
    public MenuItem getMenuItemById(int id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_MENU_ITEM_BY_ID);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return extractMenuItemFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("JDBC getMenuItemById error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return null;
    }

    @Override
    public List<MenuItem> getMenuItemsByRestaurant(int restaurantId) {
        List<MenuItem> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_MENU_BY_RESTAURANT);
            ps.setInt(1, restaurantId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractMenuItemFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC getMenuItemsByRestaurant error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }

    @Override
    public List<MenuItem> getMenuItemsByCategory(int restaurantId, String category) {
        List<MenuItem> list = new ArrayList<>();
        if (category == null) return list;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_MENU_BY_CATEGORY);
            ps.setInt(1, restaurantId);
            ps.setString(2, category.trim());
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractMenuItemFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC getMenuItemsByCategory error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }

    @Override
    public boolean updateMenuItem(MenuItem item) {
        if (item == null) return false;
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(UPDATE_MENU_ITEM);
            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            ps.setBigDecimal(3, item.getPrice());
            ps.setString(4, item.getImageUrl());
            ps.setString(5, item.getCategory());
            ps.setBoolean(6, item.isVegetarian());
            ps.setBoolean(7, item.isAvailable());
            ps.setInt(8, item.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateMenuItem error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    @Override
    public boolean deleteMenuItem(int id) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(DELETE_MENU_ITEM);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC deleteMenuItem error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    /**
     * Helper method to map ResultSet row to MenuItem object
     */
    private MenuItem extractMenuItemFromResultSet(ResultSet rs) throws SQLException {
        MenuItem item = new MenuItem();
        item.setId(rs.getInt("id"));
        item.setRestaurantId(rs.getInt("restaurant_id"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        item.setPrice(rs.getBigDecimal("price"));
        item.setImageUrl(rs.getString("image_url"));
        item.setCategory(rs.getString("category"));
        item.setVegetarian(rs.getBoolean("is_vegetarian"));
        item.setAvailable(rs.getBoolean("is_available"));
        return item;
    }
}
