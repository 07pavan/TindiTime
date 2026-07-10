package com.hungrygo.model.dao.impl;

import com.hungrygo.model.dao.AdminDAO;
import com.hungrygo.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AdminDAOImpl — implements cross-table aggregate queries using raw JDBC.
 * All queries follow the project's standard pattern:
 *   conn = DBConnection.getConnection()  →  PreparedStatement  →  finally closeResources()
 */
public class AdminDAOImpl implements AdminDAO {

    // ── SQL constants ────────────────────────────────────────────────────────

    private static final String COUNT_ORDERS_ALL =
        "SELECT COUNT(*) FROM orders";

    private static final String COUNT_ORDERS_ALL_REST =
        "SELECT COUNT(*) FROM orders WHERE restaurant_id = ?";

    private static final String COUNT_ORDERS_TODAY =
        "SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURDATE()";

    private static final String COUNT_ORDERS_TODAY_REST =
        "SELECT COUNT(*) FROM orders WHERE restaurant_id = ? AND DATE(created_at) = CURDATE()";

    private static final String SUM_REVENUE_ALL =
        "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status != 'CANCELLED'";

    private static final String SUM_REVENUE_ALL_REST =
        "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE restaurant_id = ? AND order_status != 'CANCELLED'";

    private static final String SUM_REVENUE_TODAY =
        "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE DATE(created_at) = CURDATE()";

    private static final String SUM_REVENUE_TODAY_REST =
        "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE restaurant_id = ? AND DATE(created_at) = CURDATE()";

    private static final String COUNT_ACTIVE_RESTAURANTS =
        "SELECT COUNT(*) FROM restaurants WHERE is_active = 1";

    private static final String COUNT_PENDING_RESTAURANTS =
        "SELECT COUNT(*) FROM restaurants WHERE status = 'PENDING_APPROVAL'";

    private static final String COUNT_CUSTOMERS =
        "SELECT COUNT(*) FROM users WHERE role = 'CUSTOMER'";

    private static final String RECENT_ORDERS_ALL =
        "SELECT o.order_id, o.total_amount, o.order_status, o.payment_method, " +
        "       DATE_FORMAT(o.created_at, '%d %b %Y, %h:%i %p') AS created_fmt, " +
        "       u.name AS customer_name, " +
        "       COALESCE(r.name, 'N/A') AS restaurant_name " +
        "FROM orders o " +
        "LEFT JOIN users u       ON o.user_id       = u.id " +
        "LEFT JOIN restaurants r ON o.restaurant_id = r.id " +
        "ORDER BY o.created_at DESC LIMIT ?";

    private static final String RECENT_ORDERS_REST =
        "SELECT o.order_id, o.total_amount, o.order_status, o.payment_method, " +
        "       DATE_FORMAT(o.created_at, '%d %b %Y, %h:%i %p') AS created_fmt, " +
        "       u.name AS customer_name, " +
        "       COALESCE(r.name, 'N/A') AS restaurant_name " +
        "FROM orders o " +
        "LEFT JOIN users u       ON o.user_id       = u.id " +
        "LEFT JOIN restaurants r ON o.restaurant_id = r.id " +
        "WHERE o.restaurant_id = ? " +
        "ORDER BY o.created_at DESC LIMIT ?";

    // ── Helpers ──────────────────────────────────────────────────────────────

    /** Runs a scalar COUNT/SUM query with no parameters. Returns 0 on error. */
    private long scalar(String sql) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql);
            rs   = ps.executeQuery();
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) {
            System.err.println("AdminDAO scalar error [" + sql + "]: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return 0L;
    }

    /** Runs a scalar COUNT/SUM query with one int parameter. Returns 0 on error. */
    private long scalarInt(String sql, int param) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql);
            ps.setInt(1, param);
            rs   = ps.executeQuery();
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) {
            System.err.println("AdminDAO scalarInt error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return 0L;
    }

    /** Runs a BigDecimal SUM query with no parameters. Returns ZERO on error. */
    private BigDecimal scalarDecimal(String sql) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql);
            rs   = ps.executeQuery();
            if (rs.next()) {
                BigDecimal v = rs.getBigDecimal(1);
                return v != null ? v : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            System.err.println("AdminDAO scalarDecimal error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return BigDecimal.ZERO;
    }

    /** Runs a BigDecimal SUM query with one int parameter. Returns ZERO on error. */
    private BigDecimal scalarDecimalInt(String sql, int param) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql);
            ps.setInt(1, param);
            rs   = ps.executeQuery();
            if (rs.next()) {
                BigDecimal v = rs.getBigDecimal(1);
                return v != null ? v : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            System.err.println("AdminDAO scalarDecimalInt error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return BigDecimal.ZERO;
    }

    // ── Interface implementations ─────────────────────────────────────────────

    @Override
    public long getTotalOrders(Integer restaurantId) {
        return (restaurantId == null)
               ? scalar(COUNT_ORDERS_ALL)
               : scalarInt(COUNT_ORDERS_ALL_REST, restaurantId);
    }

    @Override
    public long getTodayOrderCount(Integer restaurantId) {
        return (restaurantId == null)
               ? scalar(COUNT_ORDERS_TODAY)
               : scalarInt(COUNT_ORDERS_TODAY_REST, restaurantId);
    }

    @Override
    public BigDecimal getTotalRevenue(Integer restaurantId) {
        return (restaurantId == null)
               ? scalarDecimal(SUM_REVENUE_ALL)
               : scalarDecimalInt(SUM_REVENUE_ALL_REST, restaurantId);
    }

    @Override
    public BigDecimal getTodayRevenue(Integer restaurantId) {
        return (restaurantId == null)
               ? scalarDecimal(SUM_REVENUE_TODAY)
               : scalarDecimalInt(SUM_REVENUE_TODAY_REST, restaurantId);
    }

    @Override
    public long getActiveRestaurantCount() {
        return scalar(COUNT_ACTIVE_RESTAURANTS);
    }

    @Override
    public long getPendingApprovalCount() {
        return scalar(COUNT_PENDING_RESTAURANTS);
    }

    @Override
    public long getTotalCustomerCount() {
        return scalar(COUNT_CUSTOMERS);
    }

    @Override
    public List<Map<String, Object>> getRecentOrders(Integer restaurantId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            if (restaurantId == null) {
                ps = conn.prepareStatement(RECENT_ORDERS_ALL);
                ps.setInt(1, limit);
            } else {
                ps = conn.prepareStatement(RECENT_ORDERS_REST);
                ps.setInt(1, restaurantId);
                ps.setInt(2, limit);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("orderId",        rs.getString("order_id"));
                row.put("customerName",   rs.getString("customer_name"));
                row.put("restaurantName", rs.getString("restaurant_name"));
                row.put("totalAmount",    rs.getBigDecimal("total_amount"));
                row.put("orderStatus",    rs.getString("order_status"));
                row.put("paymentMethod",  rs.getString("payment_method"));
                row.put("createdAt",      rs.getString("created_fmt"));
                list.add(row);
            }
        } catch (SQLException e) {
            System.err.println("AdminDAO.getRecentOrders error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }
}
