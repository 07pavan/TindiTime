package com.hungrygo.util;

import java.sql.Connection;

public class TestDB {

    public static void main(String[] args) {

        try {

            Connection con = DBConnection.getConnection();

            if (con != null) {
                System.out.println("Database Connected Successfully");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}