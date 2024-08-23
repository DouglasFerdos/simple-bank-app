package com.bank;

import java.sql.Connection;
import java.sql.DriverManager;

// All this class do is to provide a method to connect to a database
public class DataBaseConnection {

    public Connection connectToDB(String dBName, String user, String pass){
        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/"+dBName, user, pass);
            if(conn != null){
                System.out.println("Connected Successfully");
            }else{
                System.out.println("Connection Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return conn;
    }
}