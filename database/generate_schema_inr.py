# Programmatic schema.sql generator with 50 Bengaluru Restaurants and INR-priced menu items
import random

output_file = 'f:\\HungryGO\\schema.sql'

# 50 Restaurants details: (name, cuisine_type, rating, delivery_time_mins, cost_for_two, primary_category)
restaurants_data = [
    ('The Burger Lab', 'Gourmet Burgers', 4.80, 25, 500.00, 'BURGER'),
    ('Mamma Mia Pizza', 'Italian Pizza', 4.50, 30, 800.00, 'PIZZA'),
    ('Sushi Zen Garden', 'Japanese', 4.90, 35, 1200.00, 'ASIAN'),
    ('Green Bowl Co.', 'Healthy Salads', 4.20, 20, 600.00, 'SALAD'),
    ('Vidyarthi Bhavan', 'South Indian Breakfast', 4.80, 20, 250.00, 'SOUTH_INDIAN'),
    ('Nagarjuna Restaurant', 'Andhra Spice & Biryani', 4.60, 30, 700.00, 'BIRYANI'),
    ('Toit Microbrewery', 'Woodfired Pizzas & Pub Grub', 4.70, 35, 1100.00, 'PIZZA'),
    ('Corner House Ice Cream', 'Iconic Desserts', 4.90, 15, 300.00, 'DESSERT'),
    ('Empire Restaurant', 'Late Night Mughlai & Kebabs', 4.30, 25, 600.00, 'BIRYANI'),
    ('Truffles Cafe', 'Gourmet Burgers & Cafe', 4.60, 25, 500.00, 'BURGER'),
    ('Shri Sagar CTR', 'Heritage South Indian', 4.80, 20, 250.00, 'SOUTH_INDIAN'),
    ('Leon Grill', 'Peri Peri Chicken & Wraps', 4.30, 20, 450.00, 'BURGER'),
    ('Meghana Foods', 'Spicy Andhra Biryani', 4.70, 25, 650.00, 'BIRYANI'),
    ('Glen\'s Bakehouse', 'Bakery, Cakes & Desserts', 4.60, 20, 500.00, 'DESSERT'),
    ('Koramangala Social', 'Fusion & Continental Bites', 4.50, 25, 1000.00, 'MIXED'),
    ('Brahmin\'s Coffee Bar', 'South Indian Comfort Food', 4.90, 15, 150.00, 'SOUTH_INDIAN'),
    ('Anand Sweets', 'Indian Sweets & Chaat', 4.70, 15, 300.00, 'DESSERT'),
    ('Bob\'s Bar', 'Local Karnataka Pub Bites', 4.50, 30, 700.00, 'MIXED'),
    ('Toscano', 'Authentic Italian Fine Dining', 4.60, 35, 1500.00, 'PIZZA'),
    ('Shiro', 'Premium Pan-Asian & Sushi', 4.70, 35, 2000.00, 'ASIAN'),
    ('Karavalli', 'Coastal Seafood & Curry', 4.80, 40, 1800.00, 'SEAFOOD'),
    ('Oye Amritsar', 'Dhaba Punjabi & Tandoori', 4.40, 30, 650.00, 'NORTH_INDIAN'),
    ('Pecos Classic', 'Chilli Beef & Pub Grub', 4.40, 30, 600.00, 'MIXED'),
    ('Chutney Chang', 'Indo-Chinese Buffet Feast', 4.20, 35, 800.00, 'CHINESE'),
    ('Sly Granny', 'European Tapas & Cocktails', 4.50, 35, 1400.00, 'MIXED'),
    ('Phobidden Fruit', 'Vietnamese Pho & Salads', 4.60, 30, 1200.00, 'ASIAN'),
    ('Windmills Craftworks', 'Craft Brews & American Jazz', 4.80, 40, 1800.00, 'BURGER'),
    ('Chetty\'s Corner', 'Bengaluru Street Bun Nippat', 4.40, 15, 200.00, 'SOUTH_INDIAN'),
    ('Smally\'s Resto Cafe', 'Cafe, Sandwiches & Shakes', 4.30, 20, 500.00, 'MIXED'),
    ('Mamagoto', 'Funky Asian Bowls & Noodles', 4.50, 30, 1000.00, 'CHINESE'),
    ('Sankranthi', 'Karnataka Veg Banana Leaf Meals', 4.20, 25, 350.00, 'SOUTH_INDIAN'),
    ('The Biere Club', 'Mediterranean & Thin Pizzas', 4.40, 30, 1200.00, 'PIZZA'),
    ('Imperial Restaurant', 'Late Night Biryani & Grilled Chicken', 4.10, 25, 550.00, 'BIRYANI'),
    ('MTR (Mavalli Tiffin Room)', 'Heritage Rava Idli & Dosas', 4.80, 20, 300.00, 'SOUTH_INDIAN'),
    ('Bhartiya Jalpan', 'North Indian Sweets & Chaat', 4.40, 20, 350.00, 'DESSERT'),
    ('Onesta', 'Unlimited Pizzas & Pasta', 4.30, 30, 600.00, 'PIZZA'),
    ('Mani\'s Dum Biryani', 'Classic Dum Biryani Hub', 4.50, 25, 500.00, 'BIRYANI'),
    ('Shanghai Times', 'Authentic Chinese & Dim Sums', 4.20, 25, 700.00, 'CHINESE'),
    ('Kota Kachori', 'Rajasthani Sweets & Chaat', 4.50, 15, 200.00, 'SOUTH_INDIAN'),
    ('Hallimane', 'Traditional Karnataka Rural Cuisine', 4.60, 25, 300.00, 'SOUTH_INDIAN'),
    ('Pind Balluchi', 'Punjabi Dhaba & Rich Gravies', 4.30, 30, 650.00, 'NORTH_INDIAN'),
    ('Chili\'s Grill & Bar', 'Tex-Mex, Ribs & Burgers', 4.50, 35, 1200.00, 'BURGER'),
    ('Keventers', 'Legendary Milkshakes & Desserts', 4.40, 15, 300.00, 'DESSERT'),
    ('Asha Sweet CenterCenter', 'Traditional Indian Sweets & Snacks', 4.70, 15, 350.00, 'DESSERT'),
    ('Beijing Bites', 'Indo-Chinese Noodles & Appetizers', 4.10, 25, 500.00, 'CHINESE'),
    ('Rajdhani Thali', 'Unlimited Rajasthani & Gujarati Thali', 4.60, 30, 900.00, 'NORTH_INDIAN'),
    ('Sante Spa Cuisine', 'Healthy, Vegan & Organic Salads', 4.70, 30, 800.00, 'SALAD'),
    ('Smoke House Deli', 'European Panini & Pancakes', 4.60, 30, 1000.00, 'MIXED'),
    ('Biryani by Kilo', 'Slow-cooked Handi Biryani', 4.40, 35, 700.00, 'BIRYANI'),
    ('Imperial Restaurant KBR', 'Kerala Style Parotta & Beef Fry', 4.20, 25, 550.00, 'SOUTH_INDIAN')
]

# Image pools for high-quality visuals
images = {
    'BURGER': [
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1513156844825-8324f8c7976e?auto=format&fit=crop&w=500&q=80'
    ],
    'PIZZA': [
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1571066811602-716837d681de?auto=format&fit=crop&w=500&q=80'
    ],
    'ASIAN': [
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1552611052-33e04de081de?auto=format&fit=crop&w=500&q=80'
    ],
    'SOUTH_INDIAN': [
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1626132647523-66f5bf380027?auto=format&fit=crop&w=500&q=80'
    ],
    'BIRYANI': [
        'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?auto=format&fit=crop&w=500&q=80'
    ],
    'DESSERT': [
        'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=500&q=80'
    ],
    'SALAD': [
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=500&q=80'
    ]
}

# Fill category links
images['MIXED'] = images['BURGER'] + images['PIZZA'] + images['ASIAN'] + images['SOUTH_INDIAN']
images['NORTH_INDIAN'] = images['BIRYANI'] + images['SOUTH_INDIAN']
images['SEAFOOD'] = images['ASIAN']
images['CHINESE'] = images['ASIAN']

# Vocabulary lists to generate dynamic names
adj = ['Gourmet', 'Spicy', 'Crispy', 'Classic', 'Delicious', 'Signature', 'House Special', 'Toasted', 'Smoked', 'Hot', 'Fresh', 'Premium', 'Traditional', 'Authentic']
fillings_veg = ['Cottage Cheese', 'Mushroom', 'Paneer', 'Avocado', 'Potato', 'Vegetable', 'Sweet Corn', 'Cheese', 'Garlic', 'Tofu']
fillings_nonveg = ['Chicken', 'Egg', 'Mutton', 'Pepperoni', 'Seafood', 'Fish', 'Beef', 'Prawn', 'Sausage', 'Bacon']
types = {
    'BURGER': ['Burger', 'Slider', 'Wrap', 'Sandwich', 'Panini', 'Sub', 'Melt'],
    'PIZZA': ['Pizza', 'Flatbread', 'Calzone', 'Garlic Bread', 'Pasta', 'Fettuccine', 'Lasagna'],
    'SOUTH_INDIAN': ['Dosa', 'Idli', 'Vada', 'Uttapam', 'Pongal', 'Akki Roti', 'Parotta', 'Meals'],
    'BIRYANI': ['Dum Biryani', 'Kabab', 'Tikka', 'Ghee Rice', 'Pulao', 'Curry', 'Gravy'],
    'NORTH_INDIAN': ['Curry', 'Tandoori Tikka', 'Masala', 'Korma', 'Roti', 'Naan', 'Kachori', 'Thali'],
    'DESSERT': ['Sundae', 'Ice Cream Scoop', 'Brownie Slice', 'Cheesecakes', 'Milkshake', 'Lassi', 'Halwa', 'Mysore Pak'],
    'SALAD': ['Salad Bowl', 'Veggie Platter', 'Quinoa Bowl', 'Healthy Mix', 'Greens'],
    'CHINESE': ['Hakka Noodles', 'Fried Rice', 'Dim Sums', 'Manchurian', 'Spring Rolls'],
    'SEAFOOD': ['Fish Fry', 'Prawn Curry', 'Crab Cakes', 'Seafood Platter'],
    'ASIAN': ['Ramen Bowl', 'Maki Sushi Roll', 'Dumplings', 'Noodle Soup', 'Stir Fry'],
    'MIXED': ['Burger', 'Pizza', 'Noodles', 'Biryani', 'Dessert', 'Wrap', 'Salad']
}

schema_header = """-- HungryGO Complete Database Schema Design
-- Target RDBMS: MySQL 8.0+
-- Prepared by Senior Java Full Stack Developer

CREATE DATABASE IF NOT EXISTS hungrygo_db;
USE hungrygo_db;

-- Drop tables if they exist in reverse order of dependencies
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS users;

-- 1. Users Table (Handles user credentials, roles & addresses)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Stored hashed password
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    role VARCHAR(20) DEFAULT 'CUSTOMER', -- Options: CUSTOMER, RIDER, ADMIN
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Restaurants Table (Holds restaurant master records)
CREATE TABLE restaurants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    cuisine_type VARCHAR(100) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.00,
    delivery_time_mins INT NOT NULL,
    cost_for_two DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(255) DEFAULT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Menu Items Table (Dishes belonging to a specific restaurant)
CREATE TABLE menu_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(255) DEFAULT NULL,
    category VARCHAR(50) NOT NULL, -- Pizza, Burger, Shakes, Appetizer, etc.
    is_vegetarian TINYINT(1) DEFAULT 0,
    is_available TINYINT(1) DEFAULT 1,
    CONSTRAINT fk_menu_restaurant FOREIGN KEY (restaurant_id) 
        REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Cart Table (Persists active shopping baskets across sessions)
CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_item FOREIGN KEY (menu_item_id) 
        REFERENCES menu_items(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_item UNIQUE (user_id, menu_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Orders Table (Summary details of completed transactions)
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL UNIQUE, -- Human-readable unique order identifier (e.g., 'HG-452109')
    user_id INT NOT NULL,
    delivery_address TEXT NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- Card Payment, Cash on Delivery
    payment_status VARCHAR(50) DEFAULT 'PENDING', -- PENDING, COMPLETED, FAILED
    order_status VARCHAR(50) DEFAULT 'Food is Preparing', -- Food is Preparing, Out For Delivery, Delivered Successfully
    total_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Order Items Table (Granular items purchased inside an order - relational junction)
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_purchase DECIMAL(10,2) NOT NULL, -- Freeze price snapshot historically
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) 
        REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_item_menu FOREIGN KEY (menu_item_id) 
        REFERENCES menu_items(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optimized indexes for fast read lookups
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_restaurant_cuisine ON restaurants(cuisine_type);
CREATE INDEX idx_menu_restaurant ON menu_items(restaurant_id);
CREATE INDEX idx_cart_user ON cart(user_id);
CREATE INDEX idx_order_user ON orders(user_id);


-- =========================================================================
-- SAMPLE TEST DATA SEEDING
-- =========================================================================

-- 1. Insert Users (Default Password is 'pavan123')
INSERT INTO users (id, name, email, password, phone, address, role) VALUES
(1, 'Pavan Hegade', 'pavanhegade1232@gmail.com', 'pavan123', '+91 98765 43210', 'Flat 402, Sunset Heights, Bandra West, Mumbai', 'CUSTOMER'),
(2, 'Admin Manager', 'admin@hungrygo.com', 'admin123', '+91 99999 88888', 'Admin Office, BKC, Mumbai', 'ADMIN');
"""

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(schema_header)
    f.write("\n-- 2. Insert 50 Bengaluru Restaurants\n")
    f.write("INSERT INTO restaurants (id, name, cuisine_type, rating, delivery_time_mins, cost_for_two, image_url, is_active) VALUES\n")
    
    for idx, r in enumerate(restaurants_data):
        r_id = idx + 1
        name, cuisine_type, rating, delivery_time_mins, cost_for_two, primary_cat = r
        img_pool = images.get(primary_cat, images['MIXED'])
        img_url = random.choice(img_pool)
        
        name_esc = name.replace("'", "''")
        cuisine_esc = cuisine_type.replace("'", "''")
        comma = "," if idx < len(restaurants_data) - 1 else ";"
        f.write(f"({r_id}, '{name_esc}', '{cuisine_esc}', {rating:.2f}, {delivery_time_mins}, {cost_for_two:.2f}, '{img_url}', 1){comma}\n")
        
    f.write("\n-- 3. Insert 8 Menu Items per Restaurant (Total 400 Items)\n")
    f.write("INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES\n")
    
    items_to_write = []
    for idx, r in enumerate(restaurants_data):
        r_id = idx + 1
        name, cuisine_type, rating, delivery_time_mins, cost_for_two, primary_cat = r
        used_names = set()
        
        for i in range(8):
            is_veg = 1
            if primary_cat in ['BIRYANI', 'SEAFOOD']:
                is_veg = random.choice([0, 0, 1])
            elif primary_cat in ['SOUTH_INDIAN', 'SALAD', 'DESSERT']:
                is_veg = 1
            else:
                is_veg = random.choice([0, 1])
                
            item_name = ""
            while True:
                a = random.choice(adj)
                f_list = fillings_veg if is_veg == 1 else fillings_nonveg
                fil = random.choice(f_list)
                t = random.choice(types.get(primary_cat, types['MIXED']))
                
                if primary_cat == 'DESSERT':
                    item_name = f"{a} {fil} {t}" if random.choice([True, False]) else f"{fil} {t}"
                else:
                    item_name = f"{a} {fil} {t}"
                
                if item_name not in used_names:
                    used_names.add(item_name)
                    break
                    
            category = t
            # Realistic INR prices between 120 and 480 rupees
            price = float(random.randint(12, 48) * 10)
            img_pool = images.get(primary_cat, images['MIXED'])
            img = random.choice(img_pool)
            desc = f"Freshly prepared {item_name.lower()} cooked using premium ingredients, signature herbs, and spices."
            
            items_to_write.append((r_id, item_name, desc, price, img, category, is_veg))

    for idx, item in enumerate(items_to_write):
        r_id, item_name, desc, price, img, category, is_veg = item
        name_esc = item_name.replace("'", "''")
        desc_esc = desc.replace("'", "''")
        category_esc = category.replace("'", "''")
        
        comma = "," if idx < len(items_to_write) - 1 else ";"
        f.write(f"({r_id}, '{name_esc}', '{desc_esc}', {price:.2f}, '{img}', '{category_esc}', {is_veg}, 1){comma}\n")

    f.write("""
-- 4. Insert Cart Items (Pre-populating Pavan's active checkout basket)
INSERT INTO cart (user_id, menu_item_id, quantity) VALUES
(1, 1, 1), -- 1 x Classic Cheddar Beef Burger
(1, 4, 1); -- 1 x Thick Oreo Vanilla Cream Shake


-- 5. Insert Orders (Past History for Pavan Hegade)
INSERT INTO orders (id, order_id, user_id, delivery_address, payment_method, payment_status, order_status, total_amount, created_at) VALUES
(1, 'QKB-452109', 1, 'Flat 402, Sunset Heights, Bandra West, Mumbai', 'Card Payment', 'COMPLETED', 'Delivered Successfully', 570.00, '2026-06-18 14:30:00'),
(2, 'QKB-219504', 1, 'Flat 402, Sunset Heights, Bandra West, Mumbai', 'Cash on Delivery', 'PENDING', 'Delivered Successfully', 300.00, '2026-05-30 20:00:00');

-- 6. Insert Order Items History
INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_purchase) VALUES
(1, 5, 1, 450.00), -- Pizza
(1, 4, 1, 120.00),  -- Shake
(2, 3, 2, 150.00);  -- Sliders (Qty 2)
""")

print("schema.sql generated successfully with 50 Bengaluru restaurants and 400 menu items.")
