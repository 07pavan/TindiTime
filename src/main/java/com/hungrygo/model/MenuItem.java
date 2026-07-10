package com.hungrygo.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Model class representing an Individual dish or MenuItem in a restaurant.
 */
public class MenuItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int restaurantId;
    private String name;
    private String description;
    private BigDecimal price;
    private String imageUrl;
    private String category;
    private boolean isVegetarian;
    private boolean isAvailable;

    /** Transient — populated via JOIN in admin queries, not persisted. */
    private String restaurantName;
    public String getRestaurantName()                  { return restaurantName; }
    public void   setRestaurantName(String restaurantName) { this.restaurantName = restaurantName; }


    public MenuItem() {}

    public MenuItem(int id, int restaurantId, String name, String description, BigDecimal price, String imageUrl, String category, boolean isVegetarian, boolean isAvailable) {
        this.id = id;
        this.restaurantId = restaurantId;
        this.name = name;
        this.description = description;
        this.price = price;
        this.imageUrl = imageUrl;
        this.category = category;
        this.isVegetarian = isVegetarian;
        this.isAvailable = isAvailable;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public boolean isVegetarian() {
        return isVegetarian;
    }

    public void setVegetarian(boolean vegetarian) {
        isVegetarian = vegetarian;
    }

    public boolean isAvailable() {
        return isAvailable;
    }

    public void setAvailable(boolean available) {
        isAvailable = available;
    }

    @Override
    public String toString() {
        return "MenuItem{" +
                "id=" + id +
                ", restaurantId=" + restaurantId +
                ", name='" + name + '\'' +
                ", price=" + price +
                ", category='" + category + '\'' +
                ", isVegetarian=" + isVegetarian +
                ", isAvailable=" + isAvailable +
                '}';
    }
}
