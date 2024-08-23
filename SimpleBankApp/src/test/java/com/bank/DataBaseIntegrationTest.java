package com.bank;

import java.math.BigDecimal;
import java.sql.Connection;
import java.time.LocalDate;
import java.util.Map;

import org.junit.jupiter.api.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class DataBaseIntegrationTest {

    DataBaseConnection db = new DataBaseConnection();
    DataBaseIntegration dbi = new DataBaseIntegration();
    Connection conn;

    //create a test address
    Address address = new Address();

    int streetNumber = 99;
    String streetName = "Foo bang's Street";
    String suburb = "Foo bang's Neighborhood";
    String city = "Foo bang's City";
    String stateAcronym = "Foo bang's State";
    int postcode = 33222111;

    BigDecimal money = new BigDecimal("200.00");
    LocalDate birthdate = LocalDate.of(1999,12,31);
    int accountNumber = 0;
    // USER DATA
    int accountUserSocialNumber = 111222333;
    String accountUserFirstName = "Foo";
    String accountUserLastName = "Bang";
    LocalDate accountUserBirthdate = birthdate;
    String accountUserMotherFullName = "Foo bang's Mother";
    String accountUserAddress = address.address(streetNumber, streetName, suburb, city, stateAcronym, postcode);
    BigDecimal accountBalance = money;
    BigDecimal withdrawAmount = new BigDecimal("357.93");

    String username = "YourPostgreSQLUserHere";			// Insert your PostgreSQL username here - The default one is "postgres"
    String password = "YourPostgreSQLPasswordHere";		// Insert your PostgreSQL password here - The one that you set in your first login in Postgres or PGAdmin


    @BeforeEach
    void DBConnection() {
        conn = db.connectToDB("simplebankapp", username, password);
    }

    @Test
    @Order(1)
    public void createAccount_test() {

        int notExpected = -1;
        int actual = dbi.createAccount(conn, accountUserSocialNumber, accountUserFirstName, accountUserLastName, accountUserBirthdate, accountUserMotherFullName, accountUserAddress, accountBalance);

        Assertions.assertNotEquals(notExpected, actual);
    }

    @Test
    @Order(2)
    public void getAccountInfo_test() {

        String notExpected = "COULD NOT LOCATE THE ACCOUNT INFO";

        Map<String, String> acInfo;
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        String actual = acInfo.get("Account Number");

        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        Assertions.assertNotEquals(notExpected, actual);
    }

    @Test
    @Order(3)
    public void updateUserData_test() {

        accountUserAddress = "Foo Island";
        String expected = "ACCOUNT USER DATA UPDATED SUCCESSFULLY";

        // gets the account number
        Map<String, String> acInfo;
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        conn = db.connectToDB("simplebankapp", username, password);
        String actual = dbi.updateAccountInfo(conn, accountNumber, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName, accountUserFirstName, accountUserLastName, accountUserAddress);

        Assertions.assertEquals(expected, actual);
    }

    @Test
    @Order(4)
    public void withdrawMoney_testInsufficientFounds() {

        String expected = "COULD NOT WITHDRAW, INSUFFICIENT FOUNDS";

        withdrawAmount = new BigDecimal("500.00");

        Map<String, String> acInfo;
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        conn = db.connectToDB("simplebankapp", username, password);
        String actual = dbi.withdrawMoney(conn, accountNumber, withdrawAmount);

        Assertions.assertEquals(expected, actual);
    }

    @Test
    @Order(5)
    public void depositMoney_test() {

        BigDecimal depositAmount = new BigDecimal("57.93");
        String expected = "57.93 DEPOSITED, YOUR NEW ACCOUNT BALANCE IS: 257.93";

        Map<String, String> acInfo;
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        conn = db.connectToDB("simplebankapp", username, password);
        String actual = dbi.depositMoney(conn, accountNumber, depositAmount);

        Assertions.assertEquals(expected, actual);
    }

    @Test
    @Order(6)
    public void transferMoney_test(){

        BigDecimal moneyToTransfer = new BigDecimal("100.00");

        String Expected = moneyToTransfer.toString();

        // create a test account sender user
        int senderAccountNumber = dbi.createAccount(conn, 123456789, "Money", "Sender Tester", accountUserBirthdate, accountUserMotherFullName, accountUserAddress, accountBalance);

        // Get the account number
        conn = db.connectToDB("simplebankapp", username, password);
        Map<String, String> acInfo;
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        conn = db.connectToDB("simplebankapp", username, password);
        String actual = dbi.transferMoney(conn, senderAccountNumber, accountNumber, moneyToTransfer, accountUserBirthdate, accountUserSocialNumber, accountUserMotherFullName);

        Assertions.assertEquals(Expected,actual);
    }

    @Test
    @Order(7)
    public void transferMoney_testInsufficientFounds(){

        BigDecimal moneyToTransfer = new BigDecimal("1000.00");

        String Expected = "NON-SUFFICIENT FUNDS";

        // create a test account sender user
        int senderAccountNumber = dbi.createAccount(conn, 123456789, "Money", "Sender Tester", accountUserBirthdate, accountUserMotherFullName, accountUserAddress, accountBalance);

        // Get the account number
        conn = db.connectToDB("simplebankapp", username, password);
        Map<String, String> acInfo;
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        conn = db.connectToDB("simplebankapp", username, password);
        String actual = dbi.transferMoney(conn, senderAccountNumber, accountNumber, moneyToTransfer, accountUserBirthdate, accountUserSocialNumber, accountUserMotherFullName);

        Assertions.assertEquals(Expected,actual);
    }

    @Test
    @Order(8)
    public void withdrawMoney_testSuccess() {

        String expected = "357.93";

        Map<String, String> acInfo;
        conn = db.connectToDB("simplebankapp", username, password);
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        conn = db.connectToDB("simplebankapp", username, password);
        String actual = dbi.withdrawMoney(conn, accountNumber, withdrawAmount);

        Assertions.assertEquals(expected,actual);
    }

    @Test
    @Order(99)
    public void closeAccount_test() {

        String expected = "ACCOUNT CLOSED";

        Map<String, String> acInfo;
        acInfo = dbi.getAccountInfo(conn, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);
        accountNumber = Integer.parseInt(acInfo.get("Account Number"));

        conn = db.connectToDB("simplebankapp", username, password);
        String actual = dbi.closeAccount(conn, accountNumber, accountUserSocialNumber, accountUserBirthdate, accountUserMotherFullName);

        Assertions.assertEquals(expected, actual);
    }
}
