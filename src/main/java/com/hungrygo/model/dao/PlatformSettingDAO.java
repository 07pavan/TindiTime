package com.hungrygo.model.dao;

import java.util.Map;

/**
 * Data Access Object interface for platform-wide settings stored in platform_settings table.
 */
public interface PlatformSettingDAO {

    /**
     * Retrieve all platform configurations in a single flat map with camelCase keys.
     * Guaranteed keys: commissionRate, baseDeliveryFee, perKmRate, freeDeliveryThreshold,
     *                  taxRate, maxDeliveryRadius, bannerEnabled, bannerText, bannerType
     */
    Map<String, Object> getPlatformSettings();

    /** Update platform core configurations. */
    boolean updatePlatformConfig(double commissionRate, double taxRate, int maxDeliveryRadius);

    /** Update platform maintenance banner settings. */
    boolean updateBanner(boolean enabled, String type, String text);

    /** Update delivery fee structure settings. */
    boolean updateFees(double base, double perKm, double freeThreshold);
}
