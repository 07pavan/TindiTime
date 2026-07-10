package com.hungrygo.model;

import java.io.Serializable;

/**
 * Model class representing a customer Review for a restaurant in HungryGO.
 * Maps to the reviews table created in the admin migration.
 */
public class Review implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    id;
    private int    userId;
    private int    restaurantId;
    private int    orderId;       // optional link to the order that triggered the review
    private int    rating;        // 1-5
    private String comment;
    private String status;        // "PENDING" | "APPROVED" | "FLAGGED" | "REJECTED"
    private String createdAt;     // formatted for JSP display
    private String updatedAt;

    // ── Transient fields — populated via JOIN in DAO queries ──────────────────
    private String customerName;
    private String customerEmail;
    private String restaurantName;
    private String orderRef;       // order_id string like "HG-12345"

    public Review() {}

    // ── Getters / Setters ─────────────────────────────────────────────────────

    public int    getId()                        { return id; }
    public void   setId(int id)                  { this.id = id; }

    public int    getUserId()                    { return userId; }
    public void   setUserId(int userId)          { this.userId = userId; }

    public int    getRestaurantId()              { return restaurantId; }
    public void   setRestaurantId(int id)        { this.restaurantId = id; }

    public int    getOrderId()                   { return orderId; }
    public void   setOrderId(int orderId)        { this.orderId = orderId; }

    public int    getRating()                    { return rating; }
    public void   setRating(int rating)          { this.rating = Math.max(1, Math.min(5, rating)); }

    public String getComment()                   { return comment; }
    public void   setComment(String comment)     { this.comment = comment; }

    public String getStatus()                    { return status; }
    public void   setStatus(String status)       { this.status = status; }

    public String getCreatedAt()                 { return createdAt; }
    public void   setCreatedAt(String s)         { this.createdAt = s; }

    public String getUpdatedAt()                 { return updatedAt; }
    public void   setUpdatedAt(String s)         { this.updatedAt = s; }

    // Transient JOIN fields
    public String getCustomerName()              { return customerName; }
    public void   setCustomerName(String n)      { this.customerName = n; }

    public String getCustomerEmail()             { return customerEmail; }
    public void   setCustomerEmail(String e)     { this.customerEmail = e; }

    public String getRestaurantName()            { return restaurantName; }
    public void   setRestaurantName(String n)    { this.restaurantName = n; }

    public String getOrderRef()                  { return orderRef; }
    public void   setOrderRef(String ref)        { this.orderRef = ref; }

    // ── Computed helpers (JSP EL friendly) ───────────────────────────────────

    /**
     * Returns a CSS-class-friendly status label.
     * e.g. "PENDING" → "warning", "APPROVED" → "success", "FLAGGED" → "danger"
     */
    public String getStatusBadgeClass() {
        if (status == null) return "secondary";
        switch (status) {
            case "APPROVED": return "success";
            case "PENDING":  return "warning";
            case "FLAGGED":  return "danger";
            case "REJECTED": return "secondary";
            default:         return "secondary";
        }
    }

    /**
     * Renders the star rating as a string of filled/empty star characters.
     * e.g. rating=4 → "★★★★☆"
     */
    public String getStarDisplay() {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) sb.append(i <= rating ? "★" : "☆");
        return sb.toString();
    }

    /**
     * Returns a safe preview of the comment (max 120 chars, trimmed to last word).
     */
    public String getCommentPreview() {
        if (comment == null || comment.length() <= 120) return comment;
        String trimmed = comment.substring(0, 120);
        int lastSpace = trimmed.lastIndexOf(' ');
        return (lastSpace > 80 ? trimmed.substring(0, lastSpace) : trimmed) + "…";
    }

    @Override
    public String toString() {
        return "Review{id=" + id + ", userId=" + userId + ", restaurantId=" + restaurantId
               + ", rating=" + rating + ", status='" + status + "'}";
    }
}
