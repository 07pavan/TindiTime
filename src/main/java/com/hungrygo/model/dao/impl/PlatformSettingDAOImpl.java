package com.hungrygo.model.dao.impl;

import com.hungrygo.model.dao.PlatformSettingDAO;
import com.hungrygo.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * JDBC implementation of PlatformSettingDAO targeting the single-row platform_settings table.
 */
public class PlatformSettingDAOImpl implements PlatformSettingDAO {

    @Override
    public Map<String, Object> getPlatformSettings() {
        Map<String, Object> map = new LinkedHashMap<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement("SELECT * FROM platform_settings WHERE id = 1");
            rs   = ps.executeQuery();
            if (rs.next()) {
                map.put("commissionRate",          rs.getDouble("commission_rate"));
                map.put("baseDeliveryFee",         rs.getDouble("base_delivery_fee"));
                map.put("perKmRate",              rs.getDouble("per_km_rate"));
                map.put("freeDeliveryThreshold",   rs.getDouble("free_delivery_threshold"));
                map.put("taxRate",                 rs.getDouble("tax_rate"));
                map.put("maxDeliveryRadius",       rs.getInt("max_delivery_radius"));
                map.put("bannerEnabled",           rs.getBoolean("banner_enabled"));
                map.put("bannerText",              rs.getString("banner_text"));
                map.put("bannerType",              rs.getString("banner_type"));
            } else {
                // Return defaults if row doesn't exist
                map.put("commissionRate", 15.0);
                map.put("baseDeliveryFee", 30.0);
                map.put("perKmRate", 5.0);
                map.put("freeDeliveryThreshold", 0.0);
                map.put("taxRate", 5.0);
                map.put("maxDeliveryRadius", 10);
                map.put("bannerEnabled", false);
                map.put("bannerText", "");
                map.put("bannerType", "info");
            }
        } catch (SQLException e) {
            System.err.println("JDBC getPlatformSettings error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return map;
    }

    @Override
    public boolean updatePlatformConfig(double commissionRate, double taxRate, int maxDeliveryRadius) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(
                "UPDATE platform_settings SET commission_rate = ?, tax_rate = ?, max_delivery_radius = ? WHERE id = 1");
            ps.setDouble(1, commissionRate);
            ps.setDouble(2, taxRate);
            ps.setInt(3,    maxDeliveryRadius);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updatePlatformConfig error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(ps, conn);
        }
        return false;
    }

    @Override
    public boolean updateBanner(boolean enabled, String type, String text) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(
                "UPDATE platform_settings SET banner_enabled = ?, banner_type = ?, banner_text = ? WHERE id = 1");
            ps.setBoolean(1, enabled);
            ps.setString(2,  type);
            ps.setString(3,  text);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateBanner error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(ps, conn);
        }
        return false;
    }

    @Override
    public boolean updateFees(double base, double perKm, double freeThreshold) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(
                "UPDATE platform_settings SET base_delivery_fee = ?, per_km_rate = ?, free_delivery_threshold = ? WHERE id = 1");
            ps.setDouble(1, base);
            ps.setDouble(2, perKm);
            ps.setDouble(3, freeThreshold);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateFees error: " + e.getMessage());
        } finally {
            DBConnection.closeResources(ps, conn);
        }
        return false;
    }
}
