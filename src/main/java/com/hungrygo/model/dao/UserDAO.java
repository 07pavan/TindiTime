package com.hungrygo.model.dao;

import com.hungrygo.model.User;
import java.util.List;

public interface UserDAO {

    boolean registerUser(User user);

    User getUserById(int id);

    User getUserByEmail(String email);

    User validateUser(String email, String password);

    List<User> getAllUsers();

    boolean updateUserProfile(User user);

    boolean updatePassword(int userId, String oldPassword, String newPassword);

    boolean deleteUser(int id);
}