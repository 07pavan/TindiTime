package com.hungrygo.model.dao;

import com.hungrygo.model.Order;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object (DAO) interface for executing food orders and transactional inserts.
 */
public interface OrderDAO {

    // Create (Insert Order + OrderItems in a transactional atomic operation)
    boolean placeOrder(Order order);

    // Read
    Order getOrderById(int id);
    Order getOrderByStringId(String orderId);
    List<Order> getOrdersByUser(int userId);
    List<Order> getAllOrders();

    // Update
    boolean updateOrderStatus(int id, String newStatus);
    boolean updatePaymentStatus(int id, String newPaymentStatus);

    // Delete/Cancel Order
    boolean cancelOrder(int id);

    // ── Admin-only methods ───────────────────────────────────────────────────

    /**
     * Paginated, filterable order list joined with users + restaurants.
     * @param status        filter by order_status  — null = all
     * @param restaurantId  filter by restaurant_id — null = all (SUPER_ADMIN only)
     * @param query         search on order_id or customer name — null = no filter
     * @param dateFrom      ISO date string (yyyy-MM-dd) — null = no lower bound
     * @param dateTo        ISO date string (yyyy-MM-dd) — null = no upper bound
     * @param page          1-based page number
     * @param pageSize      rows per page
     */
    List<Order> getOrdersAdmin(String status, Integer restaurantId, String query,
                               String dateFrom, String dateTo, int page, int pageSize);

    /** Total row count matching the same filters (for pagination). */
    int countOrdersAdmin(String status, Integer restaurantId, String query,
                         String dateFrom, String dateTo);

    /**
     * Count of orders grouped by order_status for the stat strip.
     * Keys: PLACED, CONFIRMED, PREPARING, OUT_FOR_DELIVERY, DELIVERED, CANCELLED
     * @param restaurantId null = platform-wide (SUPER_ADMIN); non-null = owner scope
     */
    Map<String, Long> getOrderStatusCounts(Integer restaurantId);
}
