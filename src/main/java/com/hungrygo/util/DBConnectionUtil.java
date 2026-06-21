package com.hungrygo.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * Utility class for managing database connections.
 * Supports JNDI connection pools first (recommended for Apache Tomcat)
 * and falls back to manual JDBC driver registration for standalone/Docker testing.
 */
public class DBConnectionUtil {

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
        } catch (ClassNotFoundException e) {
            System.err.println("CRITICAL ERROR: MySQL JDBC Driver (com.mysql.cj.jdbc.Driver) was not found in classpath.");
            e.printStackTrace();
            throw new RuntimeException("Missing MySQL Connector/J driver.", e);
        }
    }

    /**
     * Gets a connection to the database.
     * Tries JNDI lookup for Tomcat connection pooling first, then falls back to direct JDBC.
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Try fetching from connection pool
            InitialContext context = new InitialContext();
            DataSource dataSource = (DataSource) context.lookup("java:comp/env/jdbc/HungryGoDS");
            if (dataSource != null) {
                return dataSource.getConnection();
            }
        } catch (NamingException e) {
            // Log fallback when lookup fails
            System.out.println("Tomcat JNDI lookup failed. Using fallback direct JDBC connection...");
        }

        // Standard direct connection fallback
        try {
            Connection connection = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            if (connection != null && !connection.isClosed()) {
                return connection;
            }
        } catch (SQLException e) {
            System.err.println("HungryGO DB Connection Failure in DBConnectionUtil: " + e.getMessage());
            System.err.println("JDBC Target URL requested: " + JDBC_URL);
            throw e;
        }
        throw new SQLException("Failed to establish a valid database connection in DBConnectionUtil.");
    }

    /**
     * Helper to close standard database result sets, statements and connections safely.
     */
    public static void closeResources(AutoCloseable... resources) {
        if (resources == null) return;
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    System.err.println("Exception closing JDBC resource: " + e.getMessage());
                }
            }
        }
    }
}
