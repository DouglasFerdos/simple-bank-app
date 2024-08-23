package com.bank;

public class Address {

    public String address(int streetNumber, String streetName, String suburb, String city, String stateAcronym, int postcode){

        return streetName + ", " + streetNumber + " - " + suburb + ", " + city + " - " + stateAcronym + ", " + postcode;
    }

}
