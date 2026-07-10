package com.hungrygo.model.dao.impl;

import com.hungrygo.model.Review;
import com.hungrygo.model.dao.ReviewDAO;
import com.hungrygo.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * JDBC implementation of ReviewDAO.
 * All queries follow the project's standard try/finally/closeResources pattern.
 */
public class ReviewDAOImpl implements ReviewDAO {

    // ── SQL constants ─────────────────────────────────────────────────────────

    private static final String INSERT_SQL =
        "INSERT INTO reviews (user_id, restaurant_id, order_id, rating, comment, status) " +
        "VALUES (?, ?, ?, ?, ?, 'PENDING')";

    private static final String SELECT_APPROVED =
        "SELECT r.*, " +
        "  u.name AS customer_name, u.email AS customer_email, " +
        "  rest.name AS restaurant_name, " +
        "  o.order_id AS order_ref, " +
        "  DATE_FORMAT(r.created_at,'%d %b %Y') AS created_fmt, " +
        "  DATE_FORMAT(r.updated_at,'%d %b %Y') AS updated_fmt " +
        "FROM reviews r " +
        "LEFT JOIN users       u    ON r.user_id       = u.id " +
        "LEFT JOIN restaurants rest ON r.restaurant_id = rest.id " +
        "LEFT JOIN orders      o    ON r.order_id      = o.id " +
        "WHERE r.restaurant_id = ? AND r.status = 'APPROVED' " +
        "ORDER BY r.created_at DESC";

    private static final String STATS_SQL =
        "SELECT " +
        "  COUNT(*) AS total, " +
        "  SUM(CASE WHEN status='PENDING'  THEN 1 ELSE 0 END) AS pending_count, " +
        "  SUM(CASE WHEN status='APPROVED' THEN 1 ELSE 0 END) AS approved_count, " +
        "  SUM(CASE WHEN status='FLAGGED'  THEN 1 ELSE 0 END) AS flagged_count, " +
        "  ROUND(AVG(rating), 1) AS avg_rating " +
        "FROM reviews";

    private static final String STATS_SQL_OWNER =
        STATS_SQL + " WHERE restaurant_id = ?";

    private static final String UPDATE_STATUS_SQL =
        "UPDATE reviews SET status = ? WHERE id = ?";

    private static final String DELETE_SQL =
        "DELETE FROM reviews WHERE id = ?";

    // ── Base JOIN fragment for admin queries ──────────────────────────────────
    private static final String ADMIN_SELECT =
        "SELECT r.*, " +
        "  u.name AS customer_name, u.email AS customer_email, " +
        "  rest.name AS restaurant_name, " +
        "  o.order_id AS order_ref, " +
        "  DATE_FORMAT(r.created_at,'%d %b %Y') AS created_fmt, " +
        "  DATE_FORMAT(r.updated_at,'%d %b %Y') AS updated_fmt " +
        "FROM reviews r " +
        "LEFT JOIN users       u    ON r.user_id       = u.id " +
        "LEFT JOIN restaurants rest ON r.restaurant_id = rest.id " +
        "LEFT JOIN orders      o    ON r.order_id      = o.id ";

    // ── Customer-facing ───────────────────────────────────────────────────────

    @Override
    public boolean addReview(Review review) {
        if (review == null) return false;
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(INSERT_SQL);
            ps.setInt(1, review.getUserId());
            ps.setInt(2, review.getRestaurantId());
            if (review.getOrderId() > 0) ps.setInt(3, review.getOrderId());
            else ps.setNull(3, Types.INTEGER);
            ps.setInt(4, review.getRating());
            ps.setString(5, review.getComment());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC addReview error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    @Override
    public List<Review> getApprovedReviewsByRestaurant(int restaurantId) {
        List<Review> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(SELECT_APPROVED);
            ps.setInt(1, restaurantId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(extract(rs));
        } catch (SQLException e) {
            System.err.println("JDBC getApprovedReviewsByRestaurant error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return list;
    }

    // ── Admin-facing ──────────────────────────────────────────────────────────

    @Override
    public List<Review> getReviewsAdmin(String status, Integer restaurantId,
                                         int minRating, String query, int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            StringBuilder where = buildWhere(status, restaurantId, minRating, query);
            String sql = ADMIN_SELECT + where + " ORDER BY r.created_at DESC LIMIT ? OFFSET ?";

            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql);
            int idx = bindParams(ps, 1, status, restaurantId, minRating, query);
            ps.setInt(idx++, pageSize);
            ps.setInt(idx,   (page - 1) * pageSize);

            rs = ps.executeQuery();
            while (rs.next()) list.add(extract(rs));
        } catch (SQLException e) {
            System.err.println("JDBC getReviewsAdmin error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return list;
    }

    @Override
    public int countReviewsAdmin(String status, Integer restaurantId, int minRating, String query) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            StringBuilder where = buildWhere(status, restaurantId, minRating, query);
            String sql = "SELECT COUNT(*) FROM reviews r " +
                         "LEFT JOIN users u ON r.user_id = u.id " + where;

            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql);
            bindParams(ps, 1, status, restaurantId, minRating, query);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("JDBC countReviewsAdmin error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return 0;
    }

    @Override
    public Map<String, Object> getReviewStats(Integer restaurantId) {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("total",    0L);
        stats.put("pending",  0L);
        stats.put("approved", 0L);
        stats.put("flagged",  0L);
        stats.put("avgRating", 0.0);

        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            String sql = restaurantId == null ? STATS_SQL : STATS_SQL_OWNER;
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql);
            if (restaurantId != null) ps.setInt(1, restaurantId);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("total",    rs.getLong("total"));
                stats.put("pending",  rs.getLong("pending_count"));
                stats.put("approved", rs.getLong("approved_count"));
                stats.put("flagged",  rs.getLong("flagged_count"));
                double avg = rs.getDouble("avg_rating");
                stats.put("avgRating", rs.wasNull() ? 0.0 : avg);
            }
        } catch (SQLException e) {
            System.err.println("JDBC getReviewStats error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return stats;
    }

    @Override
    public boolean updateReviewStatus(int reviewId, String newStatus) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(UPDATE_STATUS_SQL);
            ps.setString(1, newStatus);
            ps.setInt(2, reviewId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateReviewStatus error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    @Override
    public boolean deleteReview(int reviewId) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(DELETE_SQL);
            ps.setInt(1, reviewId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC deleteReview error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private StringBuilder buildWhere(String status, Integer restaurantId,
                                      int minRating, String query) {
        StringBuilder w = new StringBuilder("WHERE 1=1");
        if (status       != null && !status.trim().isEmpty())  w.append(" AND r.status = ?");
        if (restaurantId != null)                              w.append(" AND r.restaurant_id = ?");
        if (minRating    >  0)                                 w.append(" AND r.rating >= ?");
        if (query        != null && !query.trim().isEmpty())
            w.append(" AND (u.name LIKE ? OR r.comment LIKE ?)");
        return w;
    }

    private int bindParams(PreparedStatement ps, int startIdx,
                            String status, Integer restaurantId,
                            int minRating, String query) throws SQLException {
        int idx = startIdx;
        if (status       != null && !status.trim().isEmpty())  ps.setString(idx++, status.trim());
        if (restaurantId != null)                              ps.setInt(idx++, restaurantId);
        if (minRating    >  0)                                 ps.setInt(idx++, minRating);
        if (query        != null && !query.trim().isEmpty()) {
            String w = "%" + query.trim() + "%";
            ps.setString(idx++, w);
            ps.setString(idx++, w);
        }
        return idx;
    }

    private Review extract(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setId(rs.getInt("id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRestaurantId(rs.getInt("restaurant_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setStatus(rs.getString("status"));
        try { r.setOrderId(rs.getInt("order_id")); }          catch (SQLException ignored) {}
        try { r.setCreatedAt(rs.getString("created_fmt")); }   catch (SQLException ignored) {}
        try { r.setUpdatedAt(rs.getString("updated_fmt")); }   catch (SQLException ignored) {}
        // Transient JOIN fields
        try { r.setCustomerName(rs.getString("customer_name"));     } catch (SQLException ignored) {}
        try { r.setCustomerEmail(rs.getString("customer_email"));   } catch (SQLException ignored) {}
        try { r.setRestaurantName(rs.getString("restaurant_name")); } catch (SQLException ignored) {}
        try { r.setOrderRef(rs.getString("order_ref"));             } catch (SQLException ignored) {}
        return r;
    }
}
