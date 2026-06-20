-- Massive Seeding Script: 25 New Restaurants & 50 Menu Items
USE hungrygo_db;

-- 1. Insert 25 Restaurants (IDs 10 to 34)
INSERT INTO restaurants (id, name, cuisine_type, rating, delivery_time_mins, cost_for_two, image_url, is_active) VALUES
(10, 'Truffles Cafe', 'Gourmet Burgers & Cafe', 4.60, 25, 15.00, 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=500&q=80', 1),
(11, 'Shri Sagar CTR', 'Heritage South Indian', 4.80, 20, 8.00, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=500&q=80', 1),
(12, 'Leon Grill', 'Peri Peri Chicken & Wraps', 4.30, 20, 12.00, 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=500&q=80', 1),
(13, 'Meghana Foods', 'Spicy Andhra Biryani', 4.70, 25, 16.00, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=500&q=80', 1),
(14, 'Glen\'s Bakehouse', 'Bakery, Cakes & Desserts', 4.60, 20, 14.00, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=500&q=80', 1),
(15, 'Koramangala Social', 'Fusion & Continental Bites', 4.50, 25, 30.00, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=500&q=80', 1),
(16, 'Brahmin\'s Coffee Bar', 'South Indian Comfort Food', 4.90, 15, 6.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=500&q=80', 1),
(17, 'Anand Sweets', 'Indian Sweets & Chaat', 4.70, 15, 10.00, 'https://images.unsplash.com/photo-1589135306090-e177fc33f920?auto=format&fit=crop&w=500&q=80', 1),
(18, 'Bob\'s Bar', 'Local Karnataka Pub Bites', 4.50, 30, 18.00, 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=500&q=80', 1),
(19, 'Toscano', 'Authentic Italian Fine Dining', 4.60, 35, 45.00, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=500&q=80', 1),
(20, 'Shiro', 'Premium Pan-Asian & Sushi', 4.70, 35, 55.00, 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=500&q=80', 1),
(21, 'Karavalli', 'Coastal Seafood & Curry', 4.80, 40, 50.00, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=500&q=80', 1),
(22, 'Oye Amritsar', 'Dhaba Punjabi & Tandoori', 4.40, 30, 22.00, 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?auto=format&fit=crop&w=500&q=80', 1),
(23, 'Pecos Classic', 'Chilli Beef & Pub Grub', 4.40, 30, 20.00, 'https://images.unsplash.com/photo-1560614382-33bd4edd1b43?auto=format&fit=crop&w=500&q=80', 1),
(24, 'Chutney Chang', 'Indo-Chinese Buffet Feast', 4.20, 35, 25.00, 'https://images.unsplash.com/photo-1526318896980-cf78c088247c?auto=format&fit=crop&w=500&q=80', 1),
(25, 'Sly Granny', 'European Tapas & Cocktails', 4.50, 35, 40.00, 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=500&q=80', 1),
(26, 'Phobidden Fruit', 'Vietnamese Pho & Salads', 4.60, 30, 35.00, 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=500&q=80', 1),
(27, 'Windmills Craftworks', 'Craft Brews & American Jazz', 4.80, 40, 60.00, 'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=500&q=80', 1),
(28, 'Chetty\'s Corner', 'Bengaluru Street Bun Nippat', 4.40, 15, 8.00, 'https://images.unsplash.com/photo-1509722747041-616f39b57569?auto=format&fit=crop&w=500&q=80', 1),
(29, 'Smally\'s Resto Cafe', 'Cafe, Sandwiches & Shakes', 4.30, 20, 12.00, 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=500&q=80', 1),
(30, 'Mamagoto', 'Funky Asian Bowls & Noodles', 4.50, 30, 28.00, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=500&q=80', 1),
(31, 'Sankranthi', 'Karnataka Veg Banana Leaf Meals', 4.20, 25, 10.00, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=500&q=80', 1),
(32, 'The Biere Club', 'Mediterranean & Thin Pizzas', 4.40, 30, 30.00, 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?auto=format&fit=crop&w=500&q=80', 1),
(33, 'Imperial Restaurant', 'Late Night Biryani & Grilled Chicken', 4.10, 25, 15.00, 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=500&q=80', 1),
(34, 'MTR (Mavalli Tiffin Room)', 'Heritage Rava Idli & Dosas', 4.80, 20, 10.00, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=500&q=80', 1);


-- 2. Insert 50 Menu Items (2 items per restaurant)
-- Truffles (10)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(10, 'All American Cheese Burger', 'Juicy beef patty layered with double American cheddar, pickles, and dynamic mustard sauce.', 6.50, 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=150&q=80', 'Burger', 0, 1),
(10, 'Truffe Signature Cold Coffee', 'Creamy frothed cold brew ice coffee blended thick with vanilla bean scoop.', 3.00, 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=150&q=80', 'Beverages', 1, 1);

-- CTR (11)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(11, 'Benne Masala Dosa', 'Legendary butter-soaked thick crispy rice crepe stuffed with spiced potato mash.', 1.80, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1),
(11, 'Medu Vada Combo', 'Two crispy deep-fried black gram lentil fritters served with aromatic sambar.', 1.20, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1);

-- Leon Grill (12)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(12, 'Leon Peri Peri Chicken Salad', 'Flame-grilled shredded peri-peri chicken served over a bed of crisp greens and olives.', 5.50, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=150&q=80', 'Salads', 0, 1),
(12, 'Crispy Peri Peri Chicken Wrap', 'Toasted tortilla wrap filled with crispy fried chicken fingers, lettuce, and peri-peri mayo.', 4.50, 'https://images.unsplash.com/photo-1626700051175-6518c4793f4f?auto=format&fit=crop&w=150&q=80', 'Rolls', 0, 1);

-- Meghana Foods (13)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(13, 'Meghana Special Chicken Biryani', 'Classic spicy and rich layered basmati rice loaded with boneless chicken kabab pieces.', 7.00, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=150&q=80', 'Biryani', 0, 1),
(13, 'Meghana Spicy Paneer Biryani', 'Fiery long-grain basmati rice layered with Guntur spiced cottage cheese chunks.', 6.50, 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?auto=format&fit=crop&w=150&q=80', 'Biryani', 1, 1);

-- Glen\'s Bakehouse (14)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(14, 'Red Velvet Mini Cupcake', 'Soft and velvety red cocoa cupcake topped with premium cream cheese frosting.', 1.50, 'https://images.unsplash.com/photo-1614707267537-b85acf00c4b8?auto=format&fit=crop&w=150&q=80', 'Dessert', 1, 1),
(14, 'Baked Blueberry Cheesecake Slice', 'Classic dense New York style cheesecake slice topped with sweet blueberry compote.', 4.50, 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=150&q=80', 'Dessert', 1, 1);

-- Koramangala Social (15)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(15, 'Death Wingz (6 Pcs)', 'Super spicy chicken wings glazed in hot Naga chilli sauce.', 5.00, 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1),
(15, 'Social Spicy Keema Pav', 'Rich and spicy minced mutton gravy served with butter-toasted soft pav bread buns.', 6.50, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=150&q=80', 'Meals', 0, 1);

-- Brahmin\'s Coffee Bar (16)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(16, 'Steamed Rice Idli (2 Pcs)', 'Piping hot fluffy rice cakes served with legendary watery coconut and mint chutney.', 1.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1),
(16, 'Hot Semolina Khara Bhath', 'Savory roasted semolina pudding seasoned with mustard seeds, curry leaves, and ghee.', 1.20, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1);

-- Anand Sweets (17)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(17, 'Special Motichoor Ladoo (4 Pcs)', 'Rich ghee-roasted tiny gram flour pearls bound into sweet festive round balls.', 2.50, 'https://images.unsplash.com/photo-1589135306090-e177fc33f920?auto=format&fit=crop&w=150&q=80', 'Dessert', 1, 1),
(17, 'Spicy Raj Kachori Chaat', 'Crispy large hollow shell stuffed with sprouts, yogurt, sweet-spicy chutneys, and sev.', 3.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1);

-- Bob\'s Bar (18)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(18, 'Kori Gassi with Neer Dosa', 'Traditional Mangalorean chicken curry cooked in coconut-spice gravy, served with soft thin crepes.', 6.00, 'https://images.unsplash.com/photo-1604152135912-04a022e23696?auto=format&fit=crop&w=150&q=80', 'Meals', 0, 1),
(18, 'Pork Chilli Bafat', 'Spicy dry-roasted pork chunks seasoned with signature local Mangalorean bafat spice powder.', 5.50, 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1);

-- Toscano (19)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(19, 'Classic Margherita Pizza', 'Wood-fired thin crust topped with fresh bocconcini mozzarella, sweet marinara, and fresh basil.', 10.00, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=150&q=80', 'Pizza', 1, 1),
(19, 'Creamy Fettuccine Carbonara', 'Rich and velvety egg-parmesan sauce tossed with crispy bacon bits over fresh fettuccine pasta.', 11.50, 'https://images.unsplash.com/photo-1546549032-9571cd6b27df?auto=format&fit=crop&w=150&q=80', 'Pizza', 0, 1);

-- Shiro (20)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(20, 'Spicy Salmon Maki Roll (8 Pcs)', 'Fresh raw salmon loin, cucumber, and sriracha mayonnaise rolled in seasoned sushi rice.', 14.00, 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=150&q=80', 'Pizza', 0, 1),
(20, 'Steamed Crystal Dumplings (4 Pcs)', 'Translucent dough wraps filled with finely minced seasoned vegetables and water chestnuts.', 7.00, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=150&q=80', 'Appetizer', 1, 1);

-- Karavalli (21)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(21, 'Anjal Rava Fry (Seer Fish)', 'Premium slice of Seer fish coated in local spices and semolina, shallow-fried to crispy golden.', 9.50, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1),
(21, 'Kundapura Chicken Curry', 'Delectable chicken cooked in roasted coconut and dynamic spices, classic coastal style.', 7.50, 'https://images.unsplash.com/photo-1604152135912-04a022e23696?auto=format&fit=crop&w=150&q=80', 'Meals', 0, 1);

-- Oye Amritsar (22)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(22, 'Butter Chicken Masala', 'Charcoal-grilled chicken tikka chunks simmered in sweet and creamy tomato-cashew gravy.', 8.00, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=150&q=80', 'Meals', 0, 1),
(22, 'Amritsari Paneer Kulcha', 'Clay-oven baked leavened flatbread stuffed with spiced cottage cheese, served with chole gravy.', 4.50, 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?auto=format&fit=crop&w=150&q=80', 'Meals', 1, 1);

-- Pecos Classic (23)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(23, 'Pecos Chilli Beef Dry', 'Famous pub-style spicy beef strips tossed with onions, green chillies, and black pepper.', 5.50, 'https://images.unsplash.com/photo-1560614382-33bd4edd1b43?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1),
(23, 'Crispy French Fries Basket', 'Golden deep-fried salted potato fingers served with chili garlic dip.', 3.00, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=150&q=80', 'Appetizer', 1, 1);

-- Chutney Chang (24)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(24, 'Veg Schezwan Fried Rice', 'Stir-fried long grain rice tossed with assorted vegetables in spicy house Schezwan sauce.', 5.50, 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=150&q=80', 'Meals', 1, 1),
(24, 'Chilli Garlic Chicken', 'Deep-fried chicken batter bites tossed with chopped garlic, bell peppers, and soy sauce.', 6.50, 'https://images.unsplash.com/photo-1526318896980-cf78c088247c?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1);

-- Sly Granny (25)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(25, 'Tapas Garlic Prawns', 'Sauteed fresh prawns cooked in extra virgin olive oil, dry red chillies, and garlic cloves.', 8.50, 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1),
(25, 'Granny Special Apple Crumble', 'Classic warm spiced apple bake topped with brown sugar oat crumble and vanilla cream scoop.', 4.50, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=150&q=80', 'Dessert', 1, 1);

-- Phobidden Fruit (26)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(26, 'Spicy Chicken Pho Soup', 'Classic Vietnamese clear noodle broth loaded with shredded chicken, bean sprouts, and mint.', 6.50, 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=150&q=80', 'Meals', 0, 1),
(26, 'Fresh Rice Paper Summer Rolls', 'Translucent rice paper wraps loaded with fresh mint, basil, vermicelli, and dip sauce.', 4.00, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=150&q=80', 'Appetizer', 1, 1);

-- Windmills Craftworks (27)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(27, 'Windmills Angus Beef Burger', 'Premium wood-grilled imported Angus patty topped with caramelized onions and aged cheddar.', 9.00, 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=150&q=80', 'Burger', 0, 1),
(27, 'Spiced Lamb Sliders (3 Pcs)', 'Mini seasoned minced lamb patties layered inside brioche slider buns with mint yogurt.', 7.50, 'https://images.unsplash.com/photo-1513156844825-8324f8c7976e?auto=format&fit=crop&w=150&q=80', 'Burger', 0, 1);

-- Chetty\'s Corner (28)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(28, 'Classic Masala Bun Nippat', 'Toasted local bakery bun stuffed with crispy lentil cracker (nippat), onions, and sweet-sour chutney.', 1.50, 'https://images.unsplash.com/photo-1509722747041-616f39b57569?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1),
(28, 'Chetty special Cheese Nippat Bhel', 'Crispy crushed nippat crackers mixed with puffed rice, grated cheese, peanuts, and spices.', 2.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1);

-- Smally\'s Resto Cafe (29)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(29, 'Smally Ultimate Chicken Club Sandwich', 'Triple-layer toasted sandwich stuffed with grilled chicken, egg, lettuce, and cheese.', 4.50, 'https://images.unsplash.com/photo-1509722747041-616f39b57569?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1),
(29, 'Double Chocolate Thick Shake', 'Rich cocoa ice cream churned thick with chocolate fudge syrup and heavy cream.', 3.50, 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=150&q=80', 'Beverages', 1, 1);

-- Mamagoto (30)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(30, 'Mamagoto Signature Ramen Bowl', 'Rich egg noodle broth topped with sliced chicken, soft egg, bamboo shoots, and nori.', 8.50, 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=150&q=80', 'Meals', 0, 1),
(30, 'Stir Fried Hakka Noodles', 'Egg wheat noodles tossed with julienne vegetables and chicken strips in light soy sauce.', 6.50, 'https://images.unsplash.com/photo-1552611052-33e04de081de?auto=format&fit=crop&w=150&q=80', 'Meals', 0, 1);

-- Sankranthi (31)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(31, 'Sankranthi Veg Banana Leaf Meal', 'Steamed Sona Masoori rice served with palya, sambar, rasam, payasam, and obbattu (sweet bread).', 4.00, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=150&q=80', 'Meals', 1, 1),
(31, 'Sankranthi Hot Ghee Pongal', 'Soft rice and split yellow lentil porridge roasted heavily in pure cow ghee and pepper.', 2.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1);

-- The Biere Club (32)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(32, 'Mediterranean Grilled Veg Pizza', 'Wood-fired crust topped with sweet zucchini, bell peppers, olives, and feta cheese.', 9.50, 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?auto=format&fit=crop&w=150&q=80', 'Pizza', 1, 1),
(32, 'Biere Club Grilled Chicken Skewers', 'Coriander-lime marinated chicken tenders grilled on charcoal skewers, served with hummus.', 5.50, 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1);

-- Imperial Restaurant (33)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(33, 'Imperial Special Ghee Rice', 'Premium long grain basmati rice roasted in cow ghee and aromatic whole cardamoms.', 3.50, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=150&q=80', 'Meals', 1, 1),
(33, 'Grilled Tandoori Chicken Half', 'Flame-grilled chicken half marinated in spicy yogurt wash, served with green chutney.', 6.50, 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=150&q=80', 'Appetizer', 0, 1);

-- MTR (34)
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category, is_vegetarian, is_available) VALUES
(34, 'Heritage Rava Idli (2 Pcs)', 'Iconic steamed semolina idli loaded with cashews, curry leaves, served with potato sagu.', 1.80, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=150&q=80', 'South Indian', 1, 1),
(34, 'Special Badam Halwa Digest', 'Decadent ground almond pudding cooked dynamically with ghee, saffron, and sugar.', 2.50, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=150&q=80', 'Dessert', 1, 1);
