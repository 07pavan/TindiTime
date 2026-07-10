package com.hungrygo.model.dao;

import com.hungrygo.model.Review;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object interface for Review moderation and analytics.
 */
public interface ReviewDAO {

    // ── Customer-facing ───────────────────────────────────────────────────────

    /** Insert a new review. Returns true on success. */
    boolean addReview(Review review);

    /** Fetch all APPROVED reviews for a given restaurant (customer-facing). */
    List<Review> getApprovedReviewsByRestaurant(int restaurantId);

    // ── Admin-facing ──────────────────────────────────────────────────────────

    /**
     * Paginated, filterable review list joined with user + restaurant data.
     * @param status       "PENDING" | "APPROVED" | "FLAGGED" | "REJECTED" | null (all)
     * @param restaurantId filter by restaurant — null = all
     * @param minRating    minimum rating (1-5) — 0 = no lower bound
     * @param query        search on customer name or comment — null = no filter
     * @param page         1-based page number
     * @param pageSize     rows per page
     */
    List<Review> getReviewsAdmin(String status, Integer restaurantId,
                                  int minRating, String query, int page, int pageSize);

    /** Total row count matching the same filters. */
    int countReviewsAdmin(String status, Integer restaurantId, int minRating, String query);

    /**
     * Aggregate stats for the admin stat strip.
     * Keys: total, pending, approved, flagged, avgRating
     * @param restaurantId null = platform-wide; non-null = owner scope
     */
    Map<String, Object> getReviewStats(Integer restaurantId);

    /**
     * Update only the status of a review (approve / reject / flag).
     * Valid values: "APPROVED", "REJECTED", "FLAGGED", "PENDING"
     */
    boolean updateReviewStatus(int reviewId, String newStatus);

    /** Hard-delete a review by id. */
    boolean deleteReview(int reviewId);
}
