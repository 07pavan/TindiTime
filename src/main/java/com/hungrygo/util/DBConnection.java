package com.hungrygo.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility helper class for establishing and managing database connections
 * with the MySQL Database using JDBC and MySQL Connector/J.
 * 
 * Implements a static initialization block to preload the JDBC Driver, ensuring
 * seamless connections inside servlet containers or standalone platforms.
 */
public class DBConnection {

    // Default Connection Parameters (Configurable via Environment Variables or custom configuration files)
    private static final String DEFAULT_HOST = "localhost";
    private static final String DEFAULT_PORT = "3306";
    private static final String DEFAULT_DB = "hungrygo_db";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "root";

    private static final String JDBC_URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        // Load database configuration from environment variables, using defaults as fallback
        String host = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : DEFAULT_HOST;
        String port = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : DEFAULT_PORT;
        String database = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : DEFAULT_DB;
        
        USER = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : DEFAULT_USER;
        PASSWORD = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : DEFAULT_PASS;
        
        // Construct the JDBC connection URL
        JDBC_URL = String.format("jdbc:mysql://%s:%s/%s?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useLegacyDatetimeCode=false&rewriteBatchedStatements=true", 
                host, port, database);

        try {
            // Register MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("HungryGO Logger: MySQL Connector/J Driver pre-loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("CRITICAL ERROR: MySQL JDBC Driver (com.mysql.cj.jdbc.Driver) was not found in classpath.");
            e.printStackTrace();
            throw new RuntimeException("Missing MySQL Connector/J driver.", e);
        }
    }

    /**
     * Private constructor to prevent direct instantiation of utility class.
     */
    private DBConnection() {}

    /**
     * Establishes and returns a fresh Connection object.
     * 
     * @return Connection to MySQL database
     * @throws SQLException if a database access error occurs or URL is invalid
     */
    public static Connection getConnection() throws SQLException {


        try {
            Connection connection = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            if (connection != null && !connection.isClosed()) {
                return connection;
            }
        } catch (SQLException e) {
            System.err.println("HungryGO DB Connection Failure: " + e.getMessage());
            System.err.println("JDBC Target URL requested: " + JDBC_URL);
            throw e;
        }
        throw new SQLException("Failed to establish a valid database connection.");
    }

    /**
     * Utility tool helper to close SQL resources quietly, preventing memory leaks.
     * 
     * @param closeables standard JDBC resources like Connection, PreparedStatement, Statement, or ResultSet
     */
    public static void closeResources(AutoCloseable... closeables) {
        if (closeables == null) return;
        for (AutoCloseable resource : closeables) {
            if (resource != null) {
                try {
                    resource.close();
                } catch (Exception e) {
                    System.err.println("HungryGO Warning: Error while closing JDBC resource: " + e.getMessage());
                }
            }
        }
    }
}
