package com.hungrygo.model.dao;

import com.hungrygo.model.Restaurant;
import java.util.List;

/**
 * Data Access Object (DAO) interface for Restaurant entity queries.
 */
public interface RestaurantDAO {

    // Create
    boolean addRestaurant(Restaurant restaurant);

    // Read
    Restaurant getRestaurantById(int id);
    List<Restaurant> getAllRestaurants();
    List<Restaurant> getRestaurantsByCuisine(String cuisineType);
    List<Restaurant> searchRestaurants(String searchQuery);

    // Update
    boolean updateRestaurant(Restaurant restaurant);

    // Delete
    boolean deleteRestaurant(int id);

    // ── Admin-only methods ───────────────────────────────────────────────────

    /**
     * Update only the status column (ACTIVE, SUSPENDED, PENDING_APPROVAL, REJECTED).
     * Used by the approve / reject / suspend / activate actions.
     */
    boolean updateStatus(int restaurantId, String status);

    /**
     * Paginated, filterable list for the admin restaurant table.
     * @param query      search string (matches name or cuisine) — null means no filter
     * @param status     status filter string — null means all statuses
     * @param page       1-based page number
     * @param pageSize   rows per page
     */
    List<Restaurant> getRestaurantsAdmin(String query, String status, int page, int pageSize);

    /** Total row count matching the same query + status filter (used for pagination). */
    int countRestaurantsAdmin(String query, String status);

    /** All restaurants with status = 'PENDING_APPROVAL', ordered oldest first. */
    List<Restaurant> getPendingRestaurants();

    /** Get restaurant details by owner user ID. */
    Restaurant getRestaurantByOwnerId(int ownerUserId);

    /** Update restaurant profile info: name, cuisine, description, phone, email, address, city, postal_code, logo_url. */
    boolean updateRestaurantProfile(Restaurant restaurant);

    /** Update restaurant business hours: open_time, close_time. */
    boolean updateRestaurantHours(int restaurantId, String openTime, String closeTime);

    /** Update restaurant operational status: is_open. */
    boolean updateRestaurantOperationalStatus(int restaurantId, boolean isOpen);
}
