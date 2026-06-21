package com.hungrygo.util;

import java.math.BigDecimal;

/**
 * Single source of truth for all pricing and fee constants across the HungryGO application.
 */
public class PricingConfig {
    public static final BigDecimal DELIVERY_FEE = new BigDecimal("1.50");
    public static final BigDecimal TAX_FEE = new BigDecimal("0.50");
    public static final BigDecimal PROMO_DISCOUNT = new BigDecimal("2.00");
}
