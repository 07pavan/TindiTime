-- ================================================================
-- HungryGO Admin Panel — DB Migration (MySQL 5.7 / 8.0 compatible)
-- Safe: uses IGNORE and IF NOT EXISTS where supported;
--       duplicate-column errors on ALTER are caught via stored proc.
-- ================================================================

USE hungrygo_db;

-- ----------------------------------------------------------------
-- Helper procedure: add column only if it does not already exist
-- ----------------------------------------------------------------
DROP PROCEDURE IF EXISTS add_column_safe;
DELIMITER //
CREATE PROCEDURE add_column_safe(
    IN tbl    VARCHAR(64),
    IN col    VARCHAR(64),
    IN def    TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
         WHERE table_schema = DATABASE()
           AND table_name   = tbl
           AND column_name  = col
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `', col, '` ', def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //
DELIMITER ;

-- ================================================================
-- 1. users table
-- ================================================================
CALL add_column_safe('users', 'role',      "VARCHAR(30) NOT NULL DEFAULT 'CUSTOMER' AFTER `address`");
CALL add_column_safe('users', 'is_banned', "TINYINT(1)  NOT NULL DEFAULT 0          AFTER `role`");

-- ================================================================
-- 2. restaurants table
-- ================================================================
CALL add_column_safe('restaurants', 'owner_user_id', "INT           NULL                          AFTER `id`");
CALL add_column_safe('restaurants', 'status',        "VARCHAR(30)   NOT NULL DEFAULT 'ACTIVE'     AFTER `is_active`");
CALL add_column_safe('restaurants', 'phone',         "VARCHAR(20)   NULL                          AFTER `status`");
CALL add_column_safe('restaurants', 'email',         "VARCHAR(100)  NULL                          AFTER `phone`");
CALL add_column_safe('restaurants', 'address',       "VARCHAR(255)  NULL                          AFTER `email`");
CALL add_column_safe('restaurants', 'city',          "VARCHAR(100)  NULL                          AFTER `address`");
CALL add_column_safe('restaurants', 'postal_code',   "VARCHAR(20)   NULL                          AFTER `city`");
CALL add_column_safe('restaurants', 'description',   "TEXT          NULL                          AFTER `postal_code`");
CALL add_column_safe('restaurants', 'is_open',       "TINYINT(1)    NOT NULL DEFAULT 1            AFTER `description`");
CALL add_column_safe('restaurants', 'open_time',     "TIME          NULL                          AFTER `is_open`");
CALL add_column_safe('restaurants', 'close_time',    "TIME          NULL                          AFTER `open_time`");
CALL add_column_safe('restaurants', 'total_orders',  "INT           NOT NULL DEFAULT 0            AFTER `close_time`");
CALL add_column_safe('restaurants', 'total_revenue', "DECIMAL(12,2) NOT NULL DEFAULT 0.00         AFTER `total_orders`");

-- ================================================================
-- 3. orders table
-- ================================================================
CALL add_column_safe('orders', 'restaurant_id',  "INT          NULL  AFTER `user_id`");
CALL add_column_safe('orders', 'customer_name',  "VARCHAR(100) NULL  AFTER `restaurant_id`");
CALL add_column_safe('orders', 'customer_phone', "VARCHAR(20)  NULL  AFTER `customer_name`");
CALL add_column_safe('orders', 'city',           "VARCHAR(100) NULL  AFTER `delivery_address`");
CALL add_column_safe('orders', 'postal_code',    "VARCHAR(20)  NULL  AFTER `city`");

-- ================================================================
-- 4. promo_codes — new table
-- ================================================================
CREATE TABLE IF NOT EXISTS promo_codes (
  id              INT            AUTO_INCREMENT PRIMARY KEY,
  code            VARCHAR(50)    NOT NULL UNIQUE,
  discount_type   ENUM('FLAT','PERCENTAGE') NOT NULL DEFAULT 'FLAT',
  discount_value  DECIMAL(10,2)  NOT NULL,
  min_order_value DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  max_uses        INT            NOT NULL DEFAULT 0,
  used_count      INT            NOT NULL DEFAULT 0,
  expiry_date     DATE           NOT NULL,
  is_active       TINYINT(1)     NOT NULL DEFAULT 1,
  created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- 5. reviews — new table
-- ================================================================
CREATE TABLE IF NOT EXISTS reviews (
  id             INT        AUTO_INCREMENT PRIMARY KEY,
  user_id        INT        NOT NULL,
  restaurant_id  INT        NOT NULL,
  rating         TINYINT    NOT NULL,
  comment        TEXT       NULL,
  status         ENUM('PUBLISHED','FLAGGED','REMOVED') NOT NULL DEFAULT 'PUBLISHED',
  created_at     TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)       REFERENCES users(id)       ON DELETE CASCADE,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- 6. platform_settings — single-row config table
-- ================================================================
CREATE TABLE IF NOT EXISTS platform_settings (
  id                       INT           AUTO_INCREMENT PRIMARY KEY,
  commission_rate          DECIMAL(5,2)  NOT NULL DEFAULT 15.00,
  base_delivery_fee        DECIMAL(8,2)  NOT NULL DEFAULT 30.00,
  per_km_rate              DECIMAL(8,2)  NOT NULL DEFAULT 5.00,
  free_delivery_threshold  DECIMAL(8,2)  NOT NULL DEFAULT 0.00,
  tax_rate                 DECIMAL(5,2)  NOT NULL DEFAULT 5.00,
  max_delivery_radius      INT           NOT NULL DEFAULT 10,
  banner_enabled           TINYINT(1)    NOT NULL DEFAULT 0,
  banner_text              TEXT          NULL,
  banner_type              VARCHAR(20)   NOT NULL DEFAULT 'info',
  updated_at               TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed single config row (safe to re-run)
INSERT INTO platform_settings
  (id, commission_rate, base_delivery_fee, per_km_rate,
   free_delivery_threshold, tax_rate, max_delivery_radius, banner_enabled, banner_type)
VALUES
  (1, 15.00, 30.00, 5.00, 0.00, 5.00, 10, 0, 'info')
ON DUPLICATE KEY UPDATE id = id;

-- ================================================================
-- 7. Seed sample promo codes
-- ================================================================
INSERT IGNORE INTO promo_codes
  (code, discount_type, discount_value, min_order_value, max_uses, expiry_date, is_active)
VALUES
  ('WELCOME50', 'FLAT',       50.00, 199.00, 1000, DATE_ADD(CURDATE(), INTERVAL 90 DAY), 1),
  ('SAVE20PCT', 'PERCENTAGE', 20.00, 299.00,  500, DATE_ADD(CURDATE(), INTERVAL 60 DAY), 1),
  ('FREEDEL',   'FLAT',       40.00,   0.00,  200, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 1),
  ('OLDCODE',   'FLAT',       30.00,   0.00,   50, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 0);

-- ================================================================
-- 8. Clean up helper procedure
-- ================================================================
DROP PROCEDURE IF EXISTS add_column_safe;

-- ================================================================
-- Verification
-- ================================================================
SELECT tbl, cols FROM (
  SELECT 'users'           AS tbl, COUNT(*) AS cols FROM information_schema.columns WHERE table_schema='hungrygo_db' AND table_name='users'
  UNION ALL
  SELECT 'restaurants',            COUNT(*) FROM information_schema.columns WHERE table_schema='hungrygo_db' AND table_name='restaurants'
  UNION ALL
  SELECT 'orders',                 COUNT(*) FROM information_schema.columns WHERE table_schema='hungrygo_db' AND table_name='orders'
  UNION ALL
  SELECT 'promo_codes',            COUNT(*) FROM information_schema.columns WHERE table_schema='hungrygo_db' AND table_name='promo_codes'
  UNION ALL
  SELECT 'reviews',                COUNT(*) FROM information_schema.columns WHERE table_schema='hungrygo_db' AND table_name='reviews'
  UNION ALL
  SELECT 'platform_settings',      COUNT(*) FROM information_schema.columns WHERE table_schema='hungrygo_db' AND table_name='platform_settings'
) AS summary;

SELECT CONCAT('Promo codes seeded: ', COUNT(*)) AS promo_check FROM promo_codes;
SELECT 'Migration complete' AS result;
