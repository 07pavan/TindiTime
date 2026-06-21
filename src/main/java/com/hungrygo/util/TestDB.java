package com.hungrygo.util;

import java.sql.Connection;

public class TestDB {

    public static void main(String[] args) {
        try (Connection con = DBConnection.getConnection();
             java.sql.Statement stmt = con.createStatement()) {
            
            if (con != null) {
                System.out.println("Database Connected Successfully");
                
                try (java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM restaurants")) {
                    if (rs.next()) System.out.println("Restaurants count: " + rs.getInt(1));
                }
                
                try (java.sql.ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM menu_items")) {
                    if (rs.next()) System.out.println("Menu items count: " + rs.getInt(1));
                }
                
                try (java.sql.ResultSet rs = stmt.executeQuery("SELECT id, name FROM menu_items LIMIT 5")) {
                    System.out.println("Sample menu items:");
                    while (rs.next()) {
                        System.out.println("  ID: " + rs.getInt("id") + ", Name: " + rs.getString("name"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}