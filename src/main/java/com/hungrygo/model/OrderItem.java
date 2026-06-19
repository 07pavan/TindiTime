package com.hungrygo.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Model class representing items listed in a specific order details snapshot.
 */
public class OrderItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int orderId;
    private int menuItemId;
    private int quantity;
    private BigDecimal priceAtPurchase;
    
    // Referenced menu item details
    private MenuItem menuItem;

    public OrderItem() {}

    public OrderItem(int id, int orderId, int menuItemId, int quantity, BigDecimal priceAtPurchase) {
        this.id = id;
        this.orderId = orderId;
        this.menuItemId = menuItemId;
        this.quantity = quantity;
        this.priceAtPurchase = priceAtPurchase;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getMenuItemId() {
        return menuItemId;
    }

    public void setMenuItemId(int menuItemId) {
        this.menuItemId = menuItemId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getPriceAtPurchase() {
        return priceAtPurchase;
    }

    public void setPriceAtPurchase(BigDecimal priceAtPurchase) {
        this.priceAtPurchase = priceAtPurchase;
    }

    public MenuItem getMenuItem() {
        return menuItem;
    }

    public void setMenuItem(MenuItem menuItem) {
        this.menuItem = menuItem;
    }

    @Override
    public String toString() {
        return "OrderItem{" +
                "id=" + id +
                ", orderId=" + orderId +
                ", menuItemId=" + menuItemId +
                ", quantity=" + quantity +
                ", priceAtPurchase=" + priceAtPurchase +
                '}';
    }
}
