package com.hungrygo.model.dao;

import com.hungrygo.model.PromoCode;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object interface for PromoCode CRUD and admin stats.
 */
public interface PromoCodeDAO {

    // ── CRUD ──────────────────────────────────────────────────────────────────

    /** Insert a new promo code. Returns true on success. */
    boolean createPromo(PromoCode promo);

    /** Fetch a promo by its integer PK. */
    PromoCode getPromoById(int id);

    /** Fetch a promo by its string code (case-insensitive). Used during checkout. */
    PromoCode getPromoByCode(String code);

    /** Update all editable fields of an existing promo. */
    boolean updatePromo(PromoCode promo);

    /** Hard-delete a promo code by id. */
    boolean deletePromo(int id);

    // ── Admin list + stats ────────────────────────────────────────────────────

    /**
     * Filtered, paginated list for the admin promo table.
     * @param statusFilter "ACTIVE" | "EXPIRED" | "INACTIVE" | null (all)
     * @param query        search term on code column — null = no filter
     * @param page         1-based page number
     * @param pageSize     rows per page
     */
    List<PromoCode> getAllPromos(String statusFilter, String query, int page, int pageSize);

    /** Total row count matching the same filters. */
    int countPromos(String statusFilter, String query);

    /**
     * Aggregate stats for the admin stat strip.
     * Keys: total, active, expired, totalUsed
     */
    Map<String, Long> getPromoStats();

    /** Flip is_active for the given promo id. */
    boolean toggleActive(int promoId);
}
