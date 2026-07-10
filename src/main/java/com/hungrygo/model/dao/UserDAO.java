package com.hungrygo.model.dao;

import com.hungrygo.model.User;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object (DAO) interface for User profile storage and authentication.
 */
public interface UserDAO {

    // Create
    boolean registerUser(User user);

    // Read
    User getUserById(int id);
    User getUserByEmail(String email);
    User validateUser(String email, String password);
    List<User> getAllUsers();

    // Update
    boolean updateUserProfile(User user);
    boolean updatePassword(int userId, String oldPassword, String newPassword);

    // Delete
    boolean deleteUser(int id);

    // ── Admin-only methods ───────────────────────────────────────────────────

    /**
     * Paginated, filterable user list for the admin user-management table.
     * @param role    filter by role (CUSTOMER / RESTAURANT_OWNER / SUPER_ADMIN) — null = all
     * @param status  filter by ban status: "BANNED" | "ACTIVE" — null = all
     * @param query   search term matching name or email — null = no filter
     * @param page    1-based page number
     * @param pageSize rows per page
     */
    List<User> getAllUsersAdmin(String role, String status, String query, int page, int pageSize);

    /** Total row count matching the same filters (for pagination). */
    int countUsersAdmin(String role, String status, String query);

    /**
     * Count of users grouped by role.
     * Guaranteed keys: CUSTOMER, RESTAURANT_OWNER, SUPER_ADMIN, BANNED
     */
    Map<String, Long> getUserRoleCounts();

    /** Set is_banned = 1 for the given user. */
    boolean banUser(int userId);

    /** Set is_banned = 0 for the given user. */
    boolean unbanUser(int userId);

    /** Change the role column for the given user. */
    boolean updateUserRole(int userId, String newRole);
}