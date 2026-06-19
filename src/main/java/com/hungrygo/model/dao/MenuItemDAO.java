package com.hungrygo.dao;

import com.hungrygo.model.MenuItem;
import java.util.List;

/**
 * Data Access Object (DAO) interface for MenuItem queries.
 */
public interface MenuItemDAO {
    
    // Create
    boolean addMenuItem(MenuItem item);
    
    // Read
    MenuItem getMenuItemById(int id);
    List<MenuItem> getMenuItemsByRestaurant(int restaurantId);
    List<MenuItem> getMenuItemsByCategory(int restaurantId, String category);
    
    // Update
    boolean updateMenuItem(MenuItem item);
    
    // Delete
    boolean deleteMenuItem(int id);
}
