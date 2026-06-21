package com.hungrygo.util;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Enumeration;

/**
 * ServletContextListener to perform clean shutdowns of the database connection driver 
 * and cleanup threads when the web application context is stopped or reloaded.
 * Prevents memory leaks and IllegalStateExceptions in Apache Tomcat.
 */
@WebListener
public class DatabaseCleanupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("HungryGO Context Initialized: Database cleanup listener active.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("HungryGO Context Destroyed: Cleaning up database threads and drivers...");

        // 1. Shut down AbandonedConnectionCleanupThread cleanly
        try {
            AbandonedConnectionCleanupThread.checkedShutdown();
            System.out.println("HungryGO Cleanup: AbandonedConnectionCleanupThread stopped successfully.");
        } catch (Throwable t) {
            System.err.println("HungryGO Warning: Failed to shut down AbandonedConnectionCleanupThread: " + t.getMessage());
        }

        // 2. Deregister JDBC drivers loaded by the webapp classloader
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            if (driver.getClass().getClassLoader() == getClass().getClassLoader()) {
                try {
                    DriverManager.deregisterDriver(driver);
                    System.out.println("HungryGO Cleanup: Deregistered JDBC driver: " + driver);
                } catch (Exception e) {
                    System.err.println("HungryGO Error: Error deregistering driver " + driver + ": " + e.getMessage());
                }
            }
        }
    }
}
