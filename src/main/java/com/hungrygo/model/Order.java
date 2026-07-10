package com.hungrygo.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Model class representing a Food Delivery Order in HungryGO.
 */
public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String orderId; // Unique string identifier like 'HG-294819'
    private int userId;
    private String deliveryAddress;
    private String paymentMethod;
    private String paymentStatus;
    private String orderStatus;
    private BigDecimal totalAmount;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // List of items in this order
    private List<OrderItem> orderItems = new ArrayList<>();

    // ── Admin fields (added by migration + transient JOINs) ──────────────────
    private int    restaurantId;
    private String customerName;    // snapshot or JOIN from users.name
    private String customerPhone;   // snapshot field
    private String restaurantName;  // transient — from JOIN

    public int    getRestaurantId()                  { return restaurantId; }
    public void   setRestaurantId(int restaurantId)  { this.restaurantId = restaurantId; }

    public String getCustomerName()                  { return customerName; }
    public void   setCustomerName(String name)       { this.customerName = name; }

    public String getCustomerPhone()                 { return customerPhone; }
    public void   setCustomerPhone(String phone)     { this.customerPhone = phone; }

    public String getRestaurantName()                { return restaurantName; }
    public void   setRestaurantName(String name)     { this.restaurantName = name; }

    /** Alias for ${order.status} in JSP EL (same as orderStatus). */
    public String getStatus()                        { return orderStatus; }


    public Order() {}

    public Order(int id, String orderId, int userId, String deliveryAddress, String paymentMethod, String paymentStatus, String orderStatus, BigDecimal totalAmount) {
        this.id = id;
        this.orderId = orderId;
        this.userId = userId;
        this.deliveryAddress = deliveryAddress;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.orderStatus = orderStatus;
        this.totalAmount = totalAmount;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

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

    public List<OrderItem> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<OrderItem> orderItems) {
        this.orderItems = orderItems;
    }

    public void addOrderItem(OrderItem item) {
        this.orderItems.add(item);
    }

    @Override
    public String toString() {
        return "Order{" +
                "id=" + id +
                ", orderId='" + orderId + '\'' +
                ", userId=" + userId +
                ", orderStatus='" + orderStatus + '\'' +
                ", totalAmount=" + totalAmount +
                ", itemsCount=" + orderItems.size() +
                '}';
    }
}
