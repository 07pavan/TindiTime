package com.hungrygo.model;

import java.io.Serializable;

/**
 * Model class representing a single platform configuration key-value pair.
 * Maps to the platform_config table created in the admin migration.
 *
 * Example rows:
 *   site_name       → "HungryGO"
 *   delivery_fee    → "40"
 *   gst_percent     → "5"
 *   support_email   → "support@hungrygo.com"
 *   maintenance_mode → "false"
 */
public class PlatformSetting implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    id;
    private String settingKey;
    private String settingValue;
    private String description;    // human-readable label for admin UI
    private String settingType;    // "TEXT" | "NUMBER" | "BOOLEAN" | "EMAIL"
    private String updatedAt;

    public PlatformSetting() {}

    public PlatformSetting(String settingKey, String settingValue) {
        this.settingKey   = settingKey;
        this.settingValue = settingValue;
    }

    // ── Getters / Setters ─────────────────────────────────────────────────────

    public int    getId()                          { return id; }
    public void   setId(int id)                    { this.id = id; }

    public String getSettingKey()                  { return settingKey; }
    public void   setSettingKey(String k)          { this.settingKey = k; }

    public String getSettingValue()                { return settingValue; }
    public void   setSettingValue(String v)        { this.settingValue = v; }

    public String getDescription()                 { return description; }
    public void   setDescription(String d)         { this.description = d; }

    public String getSettingType()                 { return settingType; }
    public void   setSettingType(String t)         { this.settingType = t; }

    public String getUpdatedAt()                   { return updatedAt; }
    public void   setUpdatedAt(String s)           { this.updatedAt = s; }

    // ── Computed helpers (JSP EL friendly) ───────────────────────────────────

    /** True when settingValue equals "true" (case-insensitive). */
    public boolean isBooleanTrue() {
        return "true".equalsIgnoreCase(settingValue);
    }

    /** Safe numeric value — returns 0 when not parseable. */
    public double numericValue() {
        try { return Double.parseDouble(settingValue); }
        catch (Exception e) { return 0; }
    }

    /** HTML input type hint based on settingType. */
    public String getInputType() {
        if (settingType == null) return "text";
        switch (settingType) {
            case "NUMBER":  return "number";
            case "EMAIL":   return "email";
            case "BOOLEAN": return "checkbox";
            default:        return "text";
        }
    }

    @Override
    public String toString() {
        return "PlatformSetting{key='" + settingKey + "', value='" + settingValue + "'}";
    }
}
