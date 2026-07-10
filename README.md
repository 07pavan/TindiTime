<div align="center">

<img src="logo.png" alt="TindiTime Logo" width="160"/>

# TindiTime

### A Full-Stack Food Delivery Web Application — Built for Bengaluru 🍽️

[![Java](https://img.shields.io/badge/Java-17-orange?style=flat-square&logo=openjdk)](https://openjdk.org/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-6.0-blue?style=flat-square&logo=eclipse)](https://jakarta.ee/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=flat-square&logo=mysql)](https://www.mysql.com/)
[![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-11.0-yellow?style=flat-square&logo=apache-tomcat)](https://tomcat.apache.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## 📖 Overview

**TindiTime** is a production-grade, full-stack food delivery web application built with Java EE (Jakarta Servlet + JSP), deployed on Apache Tomcat 11, and backed by a MySQL database. It is inspired by Bengaluru's vibrant food culture — featuring 50 iconic local restaurants, 400 authentic menu items, and a complete end-to-end ordering experience.

The platform covers everything from customer-facing browsing and checkout to a comprehensive admin management panel — all served through a clean MVC architecture with asynchronous cart operations, session-based authentication, and a polished, responsive UI.

---

## ✨ Features

### 👤 Customer Experience
| Feature | Details |
|---|---|
| **Restaurant Discovery** | Browse 50 Bengaluru restaurants with cuisine filters, ratings, cost, and delivery time |
| **Smart Search & Filter** | Category substring matching with synonym support (e.g., "Thali" maps to Indian / Meal outlets) |
| **Menu Browsing** | View restaurant-specific menus with veg/non-veg tags and authentic INR pricing |
| **AJAX Shopping Cart** | Add/remove items without page reloads; floating cart bar shows live count and CTA |
| **Promo Codes** | Apply discount codes at checkout (e.g., `QKBITE20` for ₹100 off) |
| **Checkout & Orders** | Full checkout flow with delivery address management and order placement |
| **Order History** | Track all past orders with status badges |
| **User Profile** | Manage personal details, delivery address, and account settings |

### 🛡️ Security & Access
| Feature | Details |
|---|---|
| **Authentication Filter** | Central `AuthenticationFilter` guards all private routes; AJAX-aware (returns `401 JSON` for guest requests) |
| **Role-Based Access** | `ManagementAccessFilter` restricts the `/manage/*` admin panel to admin-role users only |
| **Session Management** | Secure session creation on login with consistent attribute keying across all servlets |

### 🔧 Admin Management Panel
A full-featured back-office accessible at `/manage/dashboard`:

| Module | Capabilities |
|---|---|
| **Dashboard** | KPIs — total revenue, active orders, user count, restaurant count |
| **Orders** | View all orders, update delivery status |
| **Restaurants** | Add, edit, activate/deactivate restaurant listings |
| **Catalog** | Manage menu items per restaurant — add, edit, remove dishes |
| **Users** | View and manage all registered customer accounts |
| **Reviews** | Moderate user-submitted restaurant reviews |
| **Promo Codes** | Create, edit, and toggle promo code availability |
| **Platform Settings** | Configure app-wide settings (delivery fee, tax, platform name) |

---

## 🏗️ Architecture

This application follows a classic **MVC (Model-View-Controller)** pattern:

```
TindiTime/
│
├── src/main/java/com/hungrygo/
│   ├── controller/          # 18 Jakarta Servlets (user flows + 8 admin panel controllers)
│   ├── filter/              # AuthenticationFilter + ManagementAccessFilter
│   ├── model/               # 10 domain entities (User, Restaurant, MenuItem, Order, …)
│   │   └── dao/             # 8 DAO interfaces + JDBC implementations
│   └── util/                # DBConnection, PricingConfig, DbReseeder
│
├── src/main/webapp/
│   ├── WEB-INF/
│   │   ├── web.xml          # Explicit servlet + filter URL mappings
│   │   └── lib/             # Runtime JARs (JSTL, MySQL Connector)
│   └── jsp/
│       ├── manage/          # 10 Admin panel JSP views
│       ├── index.jsp        # Homepage
│       ├── restaurants.jsp  # Restaurant listing
│       ├── menu.jsp         # Menu page
│       ├── cart.jsp         # Shopping cart
│       ├── checkout.jsp     # Checkout & payment
│       ├── orders.jsp       # Order history
│       ├── profile.jsp      # User profile
│       ├── navbar.jsp       # Global navigation + floating cart bar
│       ├── footer.jsp       # Global footer
│       └── style.css        # Global CSS (35 KB — custom design system)
│
├── schema.sql               # Full DB schema + 50 restaurants + 400 menu items
├── admin_migration.sql      # Admin panel DB migration
└── database/
    └── generate_schema_inr.py  # Python seed generator script
```

### Request Flow

```
Browser Request
      │
      ▼
AuthenticationFilter / ManagementAccessFilter
      │
      ▼
Jakarta Servlet (Controller)
      │
      ├──► DAO Layer (JDBC) ──► MySQL Database
      │
      ▼
JSP View (Presentation)
      │
      ▼
Browser Response
```

---

## 🗄️ Database Schema

The database (`hungrygo_db`) has the following core tables:

| Table | Purpose |
|---|---|
| `users` | Customer accounts — name, email, hashed password, role (CUSTOMER / ADMIN) |
| `restaurants` | 50 Bengaluru restaurants with cuisine, rating, delivery time, cost-for-two |
| `menu_items` | 400 dishes — name, description, price (INR), veg flag, category |
| `orders` | Order header — user, restaurant, total, promo, status, timestamp |
| `order_items` | Line items per order |
| `cart` | Persistent session cart items |
| `reviews` | User-submitted restaurant reviews and ratings |
| `promo_codes` | Discount codes with type, value, and active flag |
| `platform_settings` | Key-value store for admin-configurable platform parameters |

---

## 💰 Pricing Configuration

All monetary values are centralised in `PricingConfig.java`:

| Fee | Amount |
|---|---|
| Delivery Fee | ₹40.00 (flat) |
| Convenience & Taxes | ₹20.00 (flat) |
| Promo Code (`QKBITE20`) | ₹100.00 off |
| Menu items | ₹120 – ₹480 range |

---

## 🚀 Tech Stack

| Layer | Technology |
|---|---|
| **Language** | Java 17 |
| **Backend Framework** | Jakarta Servlet 6.0 + JSTL 3.0 |
| **Frontend** | HTML5, Vanilla CSS3, Bootstrap 5.3, Bootstrap Icons |
| **Database** | MySQL 8.0+ |
| **Application Server** | Apache Tomcat 11.0 |
| **Connectivity** | MySQL Connector/J 9.7.0 |
| **Build** | Java Compiler CLI (`javac --release 17`) |

---

## ⚙️ Local Setup & Installation

### Prerequisites

- Java 17+ (JDK)
- Apache Tomcat 11.0
- MySQL 8.0+
- Python 3.x *(for the seed generator only)*

### Step 1 — Clone the Repository

```bash
git clone https://github.com/07pavan/TindiTime.git
cd TindiTime
```

### Step 2 — Configure Database Credentials

Copy the environment example and set your credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=hungrygo_db
DB_USER=root
DB_PASSWORD=your_password
```

> By default, `DBConnection.java` uses `localhost:3306`, username `root`, password `root`.

### Step 3 — Initialize the Database

```bash
# Option A — Load the pre-built schema directly (recommended)
mysql -u root -p < schema.sql

# Option B — Regenerate seed SQL via Python, then load
python database/generate_schema_inr.py
mysql -u root -p < schema.sql
```

Run the admin panel migration:
```bash
mysql -u root -p hungrygo_db < admin_migration.sql
```

### Step 4 — Compile the Application

```bash
javac --release 17 \
  -cp "src/main/webapp/WEB-INF/lib/*" \
  -d src/main/webapp/WEB-INF/classes \
  src/main/java/com/hungrygo/**/*.java
```

### Step 5 — Deploy to Tomcat

1. Copy the project root into your Tomcat `webapps/` directory (or configure a Context path in `server.xml`).
2. Start Tomcat:
   ```bash
   $CATALINA_HOME/bin/startup.sh    # Linux/macOS
   %CATALINA_HOME%\bin\startup.bat  # Windows
   ```
3. Open your browser:
   ```
   http://localhost:8080/TindiTime/
   ```

### Step 6 — Verify Database Seeding

```bash
java -cp "src/main/webapp/WEB-INF/classes;src/main/webapp/WEB-INF/lib/mysql-connector-j-9.7.0.jar" \
     com.hungrygo.util.TestDB
```

Expected output:
```
Database Connected Successfully
Restaurants count: 50
Menu items count: 400
```

---

## 👤 Default Admin Account

After seeding, an admin user is available for the management panel:

| Field | Value |
|---|---|
| Email | `admin@tinditime.com` |
| Password | `admin123` |
| Role | `ADMIN` |

> ⚠️ Change the admin password immediately after first login in a production environment.

---

## 🗺️ URL Routes Reference

| Route | Controller | Access |
|---|---|---|
| `/` | `HomeServlet` | Public |
| `/restaurants` | `RestaurantServlet` | Public |
| `/menu` | `MenuServlet` | Public |
| `/login` | `LoginServlet` | Public |
| `/register` | `RegisterServlet` | Public |
| `/cart` | `CartServlet` | Authenticated |
| `/checkout` | `CheckoutServlet` | Authenticated |
| `/orders` | `OrderServlet` | Authenticated |
| `/profile` | `ProfileServlet` | Authenticated |
| `/manage/dashboard` | `AdminDashboardServlet` | Admin only |
| `/manage/orders` | `AdminOrderServlet` | Admin only |
| `/manage/restaurants` | `AdminRestaurantServlet` | Admin only |
| `/manage/catalog` | `AdminCatalogServlet` | Admin only |
| `/manage/users` | `AdminUserServlet` | Admin only |
| `/manage/reviews` | `AdminReviewServlet` | Admin only |
| `/manage/promos` | `AdminPromoServlet` | Admin only |
| `/manage/settings` | `AdminSettingsServlet` | Admin only |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes with a meaningful message
4. Push to your fork and open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ for Bengaluru's food lovers

**[⬆ Back to Top](#tinditime)**

</div>
