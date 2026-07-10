package com.hungrygo.model.dao.impl;

import com.hungrygo.model.PromoCode;
import com.hungrygo.model.dao.PromoCodeDAO;
import com.hungrygo.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * JDBC implementation of PromoCodeDAO.
 * All queries use PreparedStatement + DBConnection.closeResources() pattern.
 */
public class PromoCodeDAOImpl implements PromoCodeDAO {

    // ── SQL constants ─────────────────────────────────────────────────────────

    private static final String INSERT_SQL =
        "INSERT INTO promo_codes (code, discount_type, discount_value, min_order_value, " +
        "max_uses, expiry_date, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ID =
        "SELECT *, DATE_FORMAT(created_at,'%d %b %Y') AS created_fmt " +
        "FROM promo_codes WHERE id = ?";

    private static final String SELECT_BY_CODE =
        "SELECT *, DATE_FORMAT(created_at,'%d %b %Y') AS created_fmt " +
        "FROM promo_codes WHERE UPPER(code) = UPPER(?) AND is_active = 1";

    private static final String UPDATE_SQL =
        "UPDATE promo_codes SET code=?, discount_type=?, discount_value=?, " +
        "min_order_value=?, max_uses=?, expiry_date=?, is_active=? WHERE id=?";

    private static final String DELETE_SQL =
        "DELETE FROM promo_codes WHERE id = ?";

    private static final String TOGGLE_SQL =
        "UPDATE promo_codes SET is_active = NOT is_active WHERE id = ?";

    private static final String STATS_SQL =
        "SELECT " +
        "  COUNT(*) AS total, " +
        "  SUM(CASE WHEN is_active=1 AND expiry_date >= CURDATE() THEN 1 ELSE 0 END) AS active_count, " +
        "  SUM(CASE WHEN expiry_date < CURDATE() THEN 1 ELSE 0 END) AS expired_count, " +
        "  COALESCE(SUM(used_count),0) AS total_used " +
        "FROM promo_codes";

    // ── CRUD ─────────────────────────────────────────────────────────────────

    @Override
    public boolean createPromo(PromoCode promo) {
        if (promo == null || promo.getCode() == null) return false;
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(INSERT_SQL);
            ps.setString(1, promo.getCode().toUpperCase().trim());
            ps.setString(2, promo.getDiscountType());
            ps.setBigDecimal(3, promo.getDiscountValue());
            ps.setBigDecimal(4, promo.getMinOrderValue() != null ? promo.getMinOrderValue() : BigDecimal.ZERO);
            ps.setInt(5,    promo.getMaxUses());
            ps.setDate(6,   promo.getExpiryDate() != null ? Date.valueOf(promo.getExpiryDate()) : null);
            ps.setBoolean(7, promo.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC createPromo error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    @Override
    public PromoCode getPromoById(int id) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(SELECT_BY_ID);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return extract(rs);
        } catch (SQLException e) {
            System.err.println("JDBC getPromoById error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return null;
    }

    @Override
    public PromoCode getPromoByCode(String code) {
        if (code == null) return null;
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(SELECT_BY_CODE);
            ps.setString(1, code.trim());
            rs = ps.executeQuery();
            if (rs.next()) return extract(rs);
        } catch (SQLException e) {
            System.err.println("JDBC getPromoByCode error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return null;
    }

    @Override
    public boolean updatePromo(PromoCode promo) {
        if (promo == null || promo.getId() <= 0) return false;
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(UPDATE_SQL);
            ps.setString(1, promo.getCode().toUpperCase().trim());
            ps.setString(2, promo.getDiscountType());
            ps.setBigDecimal(3, promo.getDiscountValue());
            ps.setBigDecimal(4, promo.getMinOrderValue() != null ? promo.getMinOrderValue() : BigDecimal.ZERO);
            ps.setInt(5,    promo.getMaxUses());
            ps.setDate(6,   promo.getExpiryDate() != null ? Date.valueOf(promo.getExpiryDate()) : null);
            ps.setBoolean(7, promo.isActive());
            ps.setInt(8,    promo.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updatePromo error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    @Override
    public boolean deletePromo(int id) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(DELETE_SQL);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC deletePromo error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    // ── Admin list + stats ────────────────────────────────────────────────────

    @Override
    public List<PromoCode> getAllPromos(String statusFilter, String query, int page, int pageSize) {
        List<PromoCode> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            StringBuilder sql = new StringBuilder(
                "SELECT *, DATE_FORMAT(created_at,'%d %b %Y') AS created_fmt " +
                "FROM promo_codes WHERE 1=1");

            // Status filter applied in SQL for efficiency
            if ("ACTIVE".equals(statusFilter))   sql.append(" AND is_active=1 AND expiry_date >= CURDATE()");
            else if ("EXPIRED".equals(statusFilter)) sql.append(" AND expiry_date < CURDATE()");
            else if ("INACTIVE".equals(statusFilter)) sql.append(" AND is_active=0");

            if (query != null && !query.trim().isEmpty()) sql.append(" AND UPPER(code) LIKE UPPER(?)");
            sql.append(" ORDER BY created_at DESC LIMIT ? OFFSET ?");

            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (query != null && !query.trim().isEmpty()) ps.setString(idx++, "%" + query.trim() + "%");
            ps.setInt(idx++, pageSize);
            ps.setInt(idx,   (page - 1) * pageSize);

            rs = ps.executeQuery();
            while (rs.next()) list.add(extract(rs));
        } catch (SQLException e) {
            System.err.println("JDBC getAllPromos error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return list;
    }

    @Override
    public int countPromos(String statusFilter, String query) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM promo_codes WHERE 1=1");
            if ("ACTIVE".equals(statusFilter))    sql.append(" AND is_active=1 AND expiry_date >= CURDATE()");
            else if ("EXPIRED".equals(statusFilter))  sql.append(" AND expiry_date < CURDATE()");
            else if ("INACTIVE".equals(statusFilter)) sql.append(" AND is_active=0");
            if (query != null && !query.trim().isEmpty()) sql.append(" AND UPPER(code) LIKE UPPER(?)");

            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql.toString());
            if (query != null && !query.trim().isEmpty()) ps.setString(1, "%" + query.trim() + "%");
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("JDBC countPromos error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return 0;
    }

    @Override
    public Map<String, Long> getPromoStats() {
        Map<String, Long> stats = new LinkedHashMap<>();
        stats.put("total",      0L);
        stats.put("active",     0L);
        stats.put("expired",    0L);
        stats.put("totalUsed",  0L);

        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(STATS_SQL);
            rs   = ps.executeQuery();
            if (rs.next()) {
                stats.put("total",     rs.getLong("total"));
                stats.put("active",    rs.getLong("active_count"));
                stats.put("expired",   rs.getLong("expired_count"));
                stats.put("totalUsed", rs.getLong("total_used"));
            }
        } catch (SQLException e) {
            System.err.println("JDBC getPromoStats error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return stats;
    }

    @Override
    public boolean toggleActive(int promoId) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(TOGGLE_SQL);
            ps.setInt(1, promoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC toggleActive error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    // ── ResultSet extractor ───────────────────────────────────────────────────

    private PromoCode extract(ResultSet rs) throws SQLException {
        PromoCode p = new PromoCode();
        p.setId(rs.getInt("id"));
        p.setCode(rs.getString("code"));
        p.setDiscountType(rs.getString("discount_type"));
        p.setDiscountValue(rs.getBigDecimal("discount_value"));
        p.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        p.setMaxUses(rs.getInt("max_uses"));
        p.setUsedCount(rs.getInt("used_count"));
        // LocalDate from java.sql.Date
        Date expiry = rs.getDate("expiry_date");
        if (expiry != null) p.setExpiryDate(expiry.toLocalDate());
        p.setActive(rs.getBoolean("is_active"));
        try { p.setCreatedAt(rs.getString("created_fmt")); } catch (SQLException ignored) {}
        return p;
    }
}
