package com.hungrygo.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class representing a User / Customer in the HungryGO platform.
 * Implements Serializable for HTTP Session state persistence.
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String email;
    private String password;
    private String phone;
    private String address;
    private String role;
    private boolean isBanned;           // maps to is_banned column
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient admin-display fields (computed via SQL, not persisted)
    private int    totalOrders;
    private double totalSpend;
    private String registeredDate;      // formatted created_at for JSP display

    // Constructors
    public User() {}

    public User(int id, String name, String email, String password, String phone, String address, String role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.address = address;
        this.role = role;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isBanned() { return isBanned; }
    public void setIsBanned(boolean isBanned) { this.isBanned = isBanned; }

    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }

    public double getTotalSpend() { return totalSpend; }
    public void setTotalSpend(double totalSpend) { this.totalSpend = totalSpend; }

    public String getRegisteredDate() { return registeredDate; }
    public void setRegisteredDate(String registeredDate) { this.registeredDate = registeredDate; }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", role='" + role + '\'' +
                '}';
    }
}
