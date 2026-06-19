package com.hungrygo.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Model class representing a Restaurant in the HungryGO food delivery platform.
 */
public class Restaurant implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String cuisineType;
    private BigDecimal rating;
    private int deliveryTimeMins;
    private BigDecimal costForTwo;
    private String imageUrl;
    private boolean isActive;

    public Restaurant() {}

    public Restaurant(int id, String name, String cuisineType, BigDecimal rating, int deliveryTimeMins, BigDecimal costForTwo, String imageUrl, boolean isActive) {
        this.id = id;
        this.name = name;
        this.cuisineType = cuisineType;
        this.rating = rating;
        this.deliveryTimeMins = deliveryTimeMins;
        this.costForTwo = costForTwo;
        this.imageUrl = imageUrl;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCuisineType() {
        return cuisineType;
    }

    public void setCuisineType(String cuisineType) {
        this.cuisineType = cuisineType;
    }

    public BigDecimal getRating() {
        return rating;
    }

    public void setRating(BigDecimal rating) {
        this.rating = rating;
    }

    public int getDeliveryTimeMins() {
        return deliveryTimeMins;
    }

    public void setDeliveryTimeMins(int deliveryTimeMins) {
        this.deliveryTimeMins = deliveryTimeMins;
    }

    public BigDecimal getCostForTwo() {
        return costForTwo;
    }

    public void setCostForTwo(BigDecimal costForTwo) {
        this.costForTwo = costForTwo;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    @Override
    public String toString() {
        return "Restaurant{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", cuisineType='" + cuisineType + '\'' +
                ", rating=" + rating +
                ", deliveryTimeMins=" + deliveryTimeMins +
                ", costForTwo=" + costForTwo +
                ", isActive=" + isActive +
                '}';
    }
}
