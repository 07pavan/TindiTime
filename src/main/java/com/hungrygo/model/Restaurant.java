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

    // ── Admin fields (added by migration) ─────────────────────────────────────
    private String     status        = "ACTIVE"; // ACTIVE | SUSPENDED | PENDING_APPROVAL | REJECTED
    private boolean    isOpen        = true;
    private int        ownerUserId;
    private int        totalOrders;
    private BigDecimal totalRevenue  = BigDecimal.ZERO;
    private String     address;
    private String     city;
    private String     phone;
    private String     email;
    private String     postalCode;
    private String     logoUrl;
    private String     description;
    private String     openTime;
    private String     closeTime;

    public Restaurant() {}

    public Restaurant(int id, String name, String cuisineType, BigDecimal rating,
                      int deliveryTimeMins, BigDecimal costForTwo,
                      String imageUrl, boolean isActive) {
        this.id = id; this.name = name; this.cuisineType = cuisineType;
        this.rating = rating; this.deliveryTimeMins = deliveryTimeMins;
        this.costForTwo = costForTwo; this.imageUrl = imageUrl; this.isActive = isActive;
    }

    // ── Original getters/setters ──────────────────────────────────────────────
    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }

    public String getName()              { return name; }
    public void   setName(String name)   { this.name = name; }

    public String getCuisineType()                   { return cuisineType; }
    public void   setCuisineType(String cuisineType) { this.cuisineType = cuisineType; }

    public BigDecimal getRating()                  { return rating; }
    public void       setRating(BigDecimal rating) { this.rating = rating; }

    public int  getDeliveryTimeMins()                    { return deliveryTimeMins; }
    public void setDeliveryTimeMins(int deliveryTimeMins){ this.deliveryTimeMins = deliveryTimeMins; }

    public BigDecimal getCostForTwo()                    { return costForTwo; }
    public void       setCostForTwo(BigDecimal costForTwo){ this.costForTwo = costForTwo; }

    public String getImageUrl()              { return imageUrl; }
    public void   setImageUrl(String url)    { this.imageUrl = url; }

    public boolean isActive()               { return isActive; }
    public void    setActive(boolean active){ this.isActive = active; }

    // ── Admin getters/setters ─────────────────────────────────────────────────
    public String  getStatus()                { return status; }
    public void    setStatus(String status)   { this.status = status; }

    public boolean isOpen()                   { return isOpen; }
    public void    setOpen(boolean open)      { this.isOpen = open; }

    public int  getOwnerUserId()              { return ownerUserId; }
    public void setOwnerUserId(int ownerId)   { this.ownerUserId = ownerId; }

    public int  getTotalOrders()              { return totalOrders; }
    public void setTotalOrders(int n)         { this.totalOrders = n; }

    public BigDecimal getTotalRevenue()             { return totalRevenue; }
    public void       setTotalRevenue(BigDecimal r) { this.totalRevenue = r != null ? r : BigDecimal.ZERO; }

    public String getAddress()               { return address; }
    public void   setAddress(String address) { this.address = address; }

    public String getCity()            { return city; }
    public void   setCity(String city) { this.city = city; }

    public String getPhone()             { return phone; }
    public void   setPhone(String phone) { this.phone = phone; }

    public String getEmail()             { return email; }
    public void   setEmail(String email) { this.email = email; }

    public String getPostalCode()                  { return postalCode; }
    public void   setPostalCode(String postalCode)  { this.postalCode = postalCode; }

    public String getLogoUrl()                     { return logoUrl; }
    public void   setLogoUrl(String logoUrl)       { this.logoUrl = logoUrl; }

    public String getDescription()                 { return description; }
    public void   setDescription(String desc)      { this.description = desc; }

    public String getOpenTime()                    { return openTime; }
    public void   setOpenTime(String openTime)     { this.openTime = openTime; }

    public String getCloseTime()                   { return closeTime; }
    public void   setCloseTime(String closeTime)   { this.closeTime = closeTime; }

    @Override
    public String toString() {
        return "Restaurant{id=" + id + ", name='" + name + "', status='" + status + "', isActive=" + isActive + '}';
    }
}
