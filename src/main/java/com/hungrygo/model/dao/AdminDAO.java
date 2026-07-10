package com.hungrygo.model.dao;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * AdminDAO — cross-table aggregate queries used across all admin modules.
 * Each method accepts an optional restaurantId filter:
 *   - null  → SUPER_ADMIN scope (all data)
 *   - non-null → RESTAURANT_OWNER scope (own data only)
 */
public interface AdminDAO {

    // ── Dashboard KPI stats ──────────────────────────────────────────────────

    /** Total order count (all time). */
    long getTotalOrders(Integer restaurantId);

    /** Orders placed today (server date). */
    long getTodayOrderCount(Integer restaurantId);

    /** Sum of total_amount for non-cancelled orders (all time). */
    BigDecimal getTotalRevenue(Integer restaurantId);

    /** Sum of total_amount for today's orders. */
    BigDecimal getTodayRevenue(Integer restaurantId);

    /** Count of active restaurants (status = 'ACTIVE'). Admin only. */
    long getActiveRestaurantCount();

    /** Count of restaurants awaiting approval (status = 'PENDING_APPROVAL'). Admin only. */
    long getPendingApprovalCount();

    /** Count of users with role = 'CUSTOMER'. Admin only. */
    long getTotalCustomerCount();

    /**
     * Recent orders — joined with users and restaurants tables.
     * Each map contains: orderId, customerName, restaurantName,
     *   totalAmount, orderStatus, paymentMethod, createdAt (String formatted).
     */
    List<Map<String, Object>> getRecentOrders(Integer restaurantId, int limit);
}
