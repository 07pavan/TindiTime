package com.hungrygo.model.dao.impl;

import com.hungrygo.model.dao.UserDAO;
import com.hungrygo.model.User;
import com.hungrygo.util.DBConnection;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object Implementation for User profile storage and authentication using JDBC.
 */
public class UserDAOImpl implements UserDAO {

    private static final String INSERT_USER_SQL = "INSERT INTO users (name, email, password, phone, address, role) VALUES (?, ?, ?, ?, ?, ?);";
    private static final String SELECT_USER_BY_ID = "SELECT * FROM users WHERE id = ?;";
    private static final String SELECT_USER_BY_EMAIL = "SELECT * FROM users WHERE email = ?;";
    private static final String SELECT_ALL_USERS = "SELECT * FROM users;";
    private static final String UPDATE_USER_PROFILE = "UPDATE users SET name = ?, phone = ?, address = ? WHERE id = ?;";
    private static final String UPDATE_PASSWORD = "UPDATE users SET password = ? WHERE id = ?;";
    private static final String DELETE_USER = "DELETE FROM users WHERE id = ?;";

    /**
     * Hash plain-text password using SHA-256
     */
    private String hashPassword(String password) {
        if (password == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 hashing algorithm not available", e);
        }
    }

    @Override
    public boolean registerUser(User user) {
        if (user == null || user.getEmail() == null) {
            return false;
        }

        // Check if user already exists with this email
        if (getUserByEmail(user.getEmail()) != null) {
            System.out.println("Registration rejected: Email " + user.getEmail() + " already exists in system.");
            return false;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(INSERT_USER_SQL);
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            // Securely hash the password before saving
            ps.setString(3, hashPassword(user.getPassword()));
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getRole() != null ? user.getRole() : "CUSTOMER");

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("JDBC registration error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    @Override
    public User getUserById(int id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_USER_BY_ID);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("JDBC select user by ID error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return null;
    }

    @Override
    public User getUserByEmail(String email) {
        if (email == null) return null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_USER_BY_EMAIL);
            ps.setString(1, email.trim().toLowerCase());
            rs = ps.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("JDBC select user by Email error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return null;
    }

    @Override
    public User validateUser(String email, String password) {
        if (email == null || password == null) return null;
        
        User user = getUserByEmail(email);
        if (user == null) {
            return null;
        }

        String storedPassword = user.getPassword();
        String hashedCandidate = hashPassword(password);

        // Smart double-matching: supports both hashed passwords and original demo plain-text database seeds
        if (password.equals(storedPassword) || (hashedCandidate != null && hashedCandidate.equals(storedPassword))) {
            return user;
        }

        return null;
    }

    @Override
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_ALL_USERS);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractUserFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("JDBC select all users error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(rs, ps, conn);
        }
        return list;
    }

    @Override
    public boolean updateUserProfile(User user) {
        if (user == null) return false;
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(UPDATE_USER_PROFILE);
            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getAddress());
            ps.setInt(4, user.getId());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("JDBC update user profile error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    @Override
    public boolean updatePassword(int userId, String oldPassword, String newPassword) {
        User user = getUserById(userId);
        if (user == null || oldPassword == null || newPassword == null) {
            return false;
        }

        String storedPassword = user.getPassword();
        String hashedOld = hashPassword(oldPassword);

        // Verify matches old credentials
        if (oldPassword.equals(storedPassword) || (hashedOld != null && hashedOld.equals(storedPassword))) {
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = DBConnection.getConnection();
                ps = conn.prepareStatement(UPDATE_PASSWORD);
                ps.setString(1, hashPassword(newPassword));
                ps.setInt(2, userId);

                int rowsAffected = ps.executeUpdate();
                return rowsAffected > 0;
            } catch (SQLException e) {
                System.err.println("JDBC update password error: " + e.getMessage());
                e.printStackTrace();
            } finally {
                DBConnection.closeResources(ps, conn);
            }
        }
        return false;
    }

    @Override
    public boolean deleteUser(int id) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(DELETE_USER);
            ps.setInt(1, id);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("JDBC delete user error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(ps, conn);
        }
    }

    /**
     * Helper method to map ResultSet row to User object
     */
    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        user.setRole(rs.getString("role"));
        // is_banned added by admin migration — gracefully ignored if column absent
        try { user.setIsBanned(rs.getInt("is_banned") == 1); } catch (SQLException ignored) {}
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        // Transient admin fields from JOIN queries
        try { user.setTotalOrders((int) rs.getLong("order_count")); }    catch (SQLException ignored) {}
        try { user.setRegisteredDate(rs.getString("reg_date")); }         catch (SQLException ignored) {}
        return user;
    }

    // ── Admin-only implementations ────────────────────────────────────────────

    @Override
    public List<User> getAllUsersAdmin(String role, String status, String query,
                                       int page, int pageSize) {
        List<User> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            StringBuilder sql = new StringBuilder(
                "SELECT u.*, " +
                "  COUNT(o.id) AS order_count, " +
                "  DATE_FORMAT(u.created_at, '%d %b %Y') AS reg_date " +
                "FROM users u " +
                "LEFT JOIN orders o ON o.user_id = u.id " +
                "WHERE 1=1");

            if (role   != null && !role.trim().isEmpty())  sql.append(" AND u.role = ?");
            if (status != null) {
                if ("BANNED".equals(status))  sql.append(" AND u.is_banned = 1");
                else if ("ACTIVE".equals(status)) sql.append(" AND u.is_banned = 0");
            }
            if (query  != null && !query.trim().isEmpty()) sql.append(" AND (u.name LIKE ? OR u.email LIKE ?)");
            sql.append(" GROUP BY u.id ORDER BY u.created_at DESC LIMIT ? OFFSET ?");

            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (role  != null && !role.trim().isEmpty())  ps.setString(idx++, role.trim());
            if (query != null && !query.trim().isEmpty()) {
                String w = "%" + query.trim() + "%";
                ps.setString(idx++, w);
                ps.setString(idx++, w);
            }
            ps.setInt(idx++, pageSize);
            ps.setInt(idx,   (page - 1) * pageSize);

            rs = ps.executeQuery();
            while (rs.next()) list.add(extractUserFromResultSet(rs));
        } catch (SQLException e) {
            System.err.println("JDBC getAllUsersAdmin error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return list;
    }

    @Override
    public int countUsersAdmin(String role, String status, String query) {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1");
            if (role   != null && !role.trim().isEmpty())  sql.append(" AND role = ?");
            if (status != null) {
                if ("BANNED".equals(status))        sql.append(" AND is_banned = 1");
                else if ("ACTIVE".equals(status))   sql.append(" AND is_banned = 0");
            }
            if (query  != null && !query.trim().isEmpty()) sql.append(" AND (name LIKE ? OR email LIKE ?)");

            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (role  != null && !role.trim().isEmpty()) ps.setString(idx++, role.trim());
            if (query != null && !query.trim().isEmpty()) {
                String w = "%" + query.trim() + "%";
                ps.setString(idx++, w);
                ps.setString(idx++, w);
            }
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("JDBC countUsersAdmin error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return 0;
    }

    @Override
    public Map<String, Long> getUserRoleCounts() {
        Map<String, Long> counts = new LinkedHashMap<>();
        // guaranteed keys in display order
        counts.put("CUSTOMER",         0L);
        counts.put("RESTAURANT_OWNER", 0L);
        counts.put("SUPER_ADMIN",      0L);
        counts.put("BANNED",           0L);

        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            // Role counts
            ps = conn.prepareStatement("SELECT role, COUNT(*) FROM users GROUP BY role");
            rs = ps.executeQuery();
            while (rs.next()) {
                String key = rs.getString(1);
                if (key != null && counts.containsKey(key)) counts.put(key, rs.getLong(2));
            }
            DBConnection.closeResources(rs, ps);

            // Banned count (cross-role)
            ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE is_banned = 1");
            rs = ps.executeQuery();
            if (rs.next()) counts.put("BANNED", rs.getLong(1));
        } catch (SQLException e) {
            System.err.println("JDBC getUserRoleCounts error: " + e.getMessage());
        } finally { DBConnection.closeResources(rs, ps, conn); }
        return counts;
    }

    @Override
    public boolean banUser(int userId) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement("UPDATE users SET is_banned = 1 WHERE id = ?");
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC banUser error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    @Override
    public boolean unbanUser(int userId) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement("UPDATE users SET is_banned = 0 WHERE id = ?");
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC unbanUser error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }

    @Override
    public boolean updateUserRole(int userId, String newRole) {
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps   = conn.prepareStatement("UPDATE users SET role = ? WHERE id = ?");
            ps.setString(1, newRole);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("JDBC updateUserRole error: " + e.getMessage());
        } finally { DBConnection.closeResources(ps, conn); }
        return false;
    }
}
