package com.hungrygo.dao;

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
}
