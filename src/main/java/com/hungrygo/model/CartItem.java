package com.hungrygo.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Model representing an item inside a user's shopping cart.
 */
public class CartItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private MenuItem menuItem;
    private int quantity;

    public CartItem() {}

    public CartItem(MenuItem menuItem, int quantity) {
        this.menuItem = menuItem;
        this.quantity = quantity;
    }

    public MenuItem getMenuItem() {
        return menuItem;
    }

    public void setMenuItem(MenuItem menuItem) {
        this.menuItem = menuItem;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getSubtotal() {
        if (menuItem == null || menuItem.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        return menuItem.getPrice().multiply(new BigDecimal(quantity));
    }
}
