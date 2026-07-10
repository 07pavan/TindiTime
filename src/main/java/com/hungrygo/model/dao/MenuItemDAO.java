package com.hungrygo.model.dao;

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

    // ── Admin-only methods ───────────────────────────────────────────────────

    /**
     * Paginated, filterable item list for the admin catalog table.
     * @param restaurantId  filter by restaurant — null means all restaurants
     * @param category      filter by category   — null means all categories
     * @param query         search term on item name — null means no filter
     * @param page          1-based page number
     * @param pageSize      rows per page
     */
    List<MenuItem> searchMenuItemsAdmin(Integer restaurantId, String category,
                                        String query, int page, int pageSize);

    /** Total row count matching the same filters (used for pagination). */
    int countMenuItemsAdmin(Integer restaurantId, String category, String query);

    /** All distinct category values currently in the menu_items table. */
    List<String> getDistinctCategories();

    /** Flip is_available for the given item id. Returns true on success. */
    boolean toggleAvailability(int itemId);
}
