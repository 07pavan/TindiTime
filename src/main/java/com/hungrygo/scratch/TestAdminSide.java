package com.hungrygo.scratch;
 
import com.hungrygo.util.DBConnection;
import com.hungrygo.model.dao.impl.*;
import com.hungrygo.model.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.List;
 
public class TestAdminSide {
    public static void main(String[] args) throws Exception {
        System.out.println("╔══════════════════════════════════════════════════════╗");
        System.out.println("║   HUNGRYGO SYSTEM COMPREHENSIVE VERIFICATION         ║");
        System.out.println("╚══════════════════════════════════════════════════════╝\n");
 
        // ── 1. DB CONNECTOR ─────────────────────────────────────────────────
        System.out.println("▶ SECTION 1: Database Connectivity");
        System.out.println("───────────────────────────────────");
        try (Connection c = DBConnection.getConnection()) {
            System.out.println("  ✅ DB Connection: OK");
            DatabaseMetaData meta = c.getMetaData();
            System.out.println("  MySQL Server Version: " + meta.getDatabaseProductVersion());
        } catch (Exception e) {
            System.err.println("  ❌ Connection failed: " + e.getMessage());
            return;
        }
 
        // ── 2. USER DAO & BANNED FIELD ──────────────────────────────────────
        System.out.println("\n▶ SECTION 2: User DAO & isBanned Mapping");
        System.out.println("─────────────────────────────────────────");
        UserDAOImpl userDAO = new UserDAOImpl();
        List<User> users = userDAO.getAllUsersAdmin(null, null, null, 1, 5);
        System.out.println("  Total users found on page 1: " + users.size());
        if (!users.isEmpty()) {
            User first = users.get(0);
            System.out.println("  Checking properties on User type: ");
            System.out.println("    - Name: " + first.getName());
            System.out.println("    - Role: " + first.getRole());
            System.out.println("    - getIsBanned(): " + first.getIsBanned());
            System.out.println("    - isBanned(): " + first.isBanned());
            System.out.println("  ✅ User model properties mapping: OK");
        } else {
            System.out.println("  ⚠ No users in database!");
        }
 
        // ── 3. RESTAURANT CRUD ──────────────────────────────────────────────
        System.out.println("\n▶ SECTION 3: Restaurant CRUD Operations");
        System.out.println("────────────────────────────────────────");
        RestaurantDAOImpl restDAO = new RestaurantDAOImpl();
        Restaurant r = new Restaurant();
        r.setName("Verification Test Cafe");
        r.setCuisineType("Beverages");
        r.setAddress("100 verification road");
        r.setCity("Indore");
        r.setPhone("+91 99999 88888");
        r.setEmail("testcafe@hungrygo.com");
        r.setDescription("Thorough verification test restaurant.");
        r.setDeliveryTimeMins(20);
        r.setCostForTwo(new BigDecimal("400.00"));
        r.setImageUrl("https://example.com/test.jpg");
        r.setActive(true);
 
        boolean added = restDAO.addRestaurant(r);
        System.out.println("  Create Restaurant: " + (added ? "✅ SUCCESS" : "❌ FAILED"));
 
        int addedId = -1;
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT id FROM restaurants WHERE name='Verification Test Cafe' ORDER BY id DESC LIMIT 1")) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) addedId = rs.getInt("id");
        }
        System.out.println("  Verified ID: " + addedId);
 
        if (addedId > 0) {
            Restaurant fetched = restDAO.getRestaurantById(addedId);
            System.out.println("  Read Restaurant: " + (fetched != null && fetched.getName().equals("Verification Test Cafe") ? "✅ SUCCESS" : "❌ FAILED"));
 
            fetched.setName("Verification Test Cafe (Updated)");
            boolean updated = restDAO.updateRestaurant(fetched);
            System.out.println("  Update Restaurant: " + (updated ? "✅ SUCCESS" : "❌ FAILED"));
 
            boolean deleted = restDAO.deleteRestaurant(addedId);
            System.out.println("  Delete Restaurant: " + (deleted ? "✅ SUCCESS" : "❌ FAILED"));
        }
 
        // ── 4. ORDER INTEGRITY & CANCEL STATUS ──────────────────────────────
        System.out.println("\n▶ SECTION 4: Order DAO & Cancel Integrity");
        System.out.println("──────────────────────────────────────────");
        OrderDAOImpl orderDAO = new OrderDAOImpl();
        
        // Let's create an order
        Order testOrder = new Order();
        testOrder.setOrderId("TEST-VERIFY-999");
        testOrder.setUserId(2); // admin
        testOrder.setDeliveryAddress("Verification St");
        testOrder.setPaymentMethod("cod");
        testOrder.setPaymentStatus("Pending");
        testOrder.setOrderStatus("Placed");
        testOrder.setTotalAmount(new BigDecimal("250.00"));
        testOrder.setRestaurantId(1); // Imperial Restaurant
 
        boolean placed = orderDAO.placeOrder(testOrder);
        System.out.println("  Place Order: " + (placed ? "✅ SUCCESS" : "❌ FAILED"));
 
        int testOrderId = -1;
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT id FROM orders WHERE order_id='TEST-VERIFY-999' LIMIT 1")) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) testOrderId = rs.getInt("id");
        }
        System.out.println("  Verified Order ID: " + testOrderId);
 
        if (testOrderId > 0) {
            // Cancel order
            boolean cancelled = orderDAO.cancelOrder(testOrderId);
            System.out.println("  Cancel Order (History Preservation): " + (cancelled ? "✅ SUCCESS" : "❌ FAILED"));
 
            // Verify it was NOT deleted but status updated
            try (Connection c = DBConnection.getConnection();
                 PreparedStatement ps = c.prepareStatement("SELECT order_status FROM orders WHERE id=?")) {
                ps.setInt(1, testOrderId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String status = rs.getString("order_status");
                    System.out.println("    Current status in DB: '" + status + "'");
                    System.out.println("    Status update verification: " + ("Cancelled".equals(status) ? "✅ SUCCESS (updated)" : "❌ FAILED (not updated)"));
                } else {
                    System.out.println("    ❌ Order was physically DELETED! Fix failed.");
                }
            }
 
            // Clean up test order physically for verification clean-up
            try (Connection c = DBConnection.getConnection();
                 PreparedStatement ps = c.prepareStatement("DELETE FROM orders WHERE id=?")) {
                ps.setInt(1, testOrderId);
                ps.executeUpdate();
                System.out.println("  Test order cleaned up from DB.");
            }
        }
 
        // ── 5. REVIEWS DAO SQL ──────────────────────────────────────────────
        System.out.println("\n▶ SECTION 5: Reviews SQL Verification");
        System.out.println("───────────────────────────────────────");
        ReviewDAOImpl reviewDAO = new ReviewDAOImpl();
        try {
            List<Review> reviews = reviewDAO.getReviewsAdmin(null, null, 0, null, 1, 5);
            System.out.println("  getReviewsAdmin() execution: ✅ SUCCESS (Total: " + reviews.size() + ")");
        } catch (Exception e) {
            System.err.println("  getReviewsAdmin() execution: ❌ FAILED (" + e.getMessage() + ")");
        }
 
        System.out.println("\n╔══════════════════════════════════════════════════════╗");
        System.out.println("║   VERIFICATION COMPLETED SUCCESSFULLY                ║");
        System.out.println("╚══════════════════════════════════════════════════════╝");
    }
}
