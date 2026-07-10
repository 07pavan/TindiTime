package com.hungrygo.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Model class representing a Promo Code in the HungryGO platform.
 * Maps to the promo_codes table created in the admin migration.
 */
public class PromoCode implements Serializable {
    private static final long serialVersionUID = 1L;

    private int        id;
    private String     code;
    private String     discountType;   // "FLAT" or "PERCENTAGE"
    private BigDecimal discountValue;
    private BigDecimal minOrderValue;
    private int        maxUses;
    private int        usedCount;
    private LocalDate  expiryDate;
    private boolean    isActive;
    private String     createdAt;      // formatted string for JSP display

    public PromoCode() {}

    // ── Getters / Setters ─────────────────────────────────────────────────────

    public int        getId()                        { return id; }
    public void       setId(int id)                  { this.id = id; }

    public String     getCode()                      { return code; }
    public void       setCode(String code)           { this.code = code != null ? code.toUpperCase().trim() : null; }

    public String     getDiscountType()              { return discountType; }
    public void       setDiscountType(String t)      { this.discountType = t; }

    public BigDecimal getDiscountValue()             { return discountValue; }
    public void       setDiscountValue(BigDecimal v) { this.discountValue = v; }

    public BigDecimal getMinOrderValue()             { return minOrderValue; }
    public void       setMinOrderValue(BigDecimal v) { this.minOrderValue = v; }

    public int        getMaxUses()                   { return maxUses; }
    public void       setMaxUses(int n)              { this.maxUses = n; }

    public int        getUsedCount()                 { return usedCount; }
    public void       setUsedCount(int n)            { this.usedCount = n; }

    public LocalDate  getExpiryDate()                { return expiryDate; }
    public void       setExpiryDate(LocalDate d)     { this.expiryDate = d; }

    public boolean    isActive()                     { return isActive; }
    public void       setActive(boolean active)      { this.isActive = active; }

    public String     getCreatedAt()                 { return createdAt; }
    public void       setCreatedAt(String s)         { this.createdAt = s; }

    // ── Computed helpers (used in JSP EL) ────────────────────────────────────

    /** True when today is past the expiry date. */
    public boolean isExpired() {
        return expiryDate != null && LocalDate.now().isAfter(expiryDate);
    }

    /** "ACTIVE" | "EXPIRED" | "INACTIVE" — used by JSP badge logic. */
    public String getStatusLabel() {
        if (isExpired())  return "EXPIRED";
        if (!isActive)    return "INACTIVE";
        return "ACTIVE";
    }

    /**
     * Remaining uses before the code is exhausted.
     * Returns Integer.MAX_VALUE when maxUses = 0 (unlimited).
     */
    public int getRemainingUses() {
        if (maxUses == 0) return Integer.MAX_VALUE;
        return Math.max(0, maxUses - usedCount);
    }

    /** Usage percentage (0-100) for progress bar. Returns 0 when unlimited. */
    public int getUsagePct() {
        if (maxUses == 0) return 0;
        return (int) Math.min(100, Math.round((double) usedCount / maxUses * 100));
    }

    /** Formatted expiry date for display e.g. "25 Jan 2025". */
    public String getExpiryFormatted() {
        if (expiryDate == null) return "—";
        return expiryDate.format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
    }

    /** ISO date string "yyyy-MM-dd" for HTML date inputs. */
    public String getExpiryIso() {
        if (expiryDate == null) return "";
        return expiryDate.toString();
    }

    /** Human-readable discount label e.g. "₹50 OFF" or "20% OFF". */
    public String getDiscountLabel() {
        if ("PERCENTAGE".equals(discountType)) {
            return discountValue != null ? discountValue.stripTrailingZeros().toPlainString() + "% OFF" : "—";
        }
        return discountValue != null ? "₹" + discountValue.stripTrailingZeros().toPlainString() + " OFF" : "—";
    }

    @Override
    public String toString() {
        return "PromoCode{id=" + id + ", code='" + code + "', type=" + discountType
               + ", value=" + discountValue + ", active=" + isActive + '}';
    }
}
