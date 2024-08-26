-- THE CREATE OR REPLACE FOR ALL THE NECESSARY TABLES FOR THIS APP DATA BASE --

-- CREATE FOR THE clients_info table --

CREATE TABLE clients_info (
    account_number INT GENERATED ALWAYS AS IDENTITY ( INCREMENT 1823 START 535199981 MINVALUE 100000000 MAXVALUE 999999999 CACHE 1 ) PRIMARY KEY, -- MORE THAN 250 THOUSAND UNIQUE NUMBER BUT NOT SAFE, FOR EXAMPLE ONLY --
    account_user_social_number INT NOT NULL,
    account_user_first_name VARCHAR(50) NOT NULL,
    account_user_last_name VARCHAR(100) NOT NULL,
    account_user_birthdate DATE NOT NULL,
    account_user_mother_full_name VARCHAR(150) NOT NULL,
    account_user_address VARCHAR(250) NOT NULL,
    account_balance NUMERIC
);

-- CREATE FOR THE clients_audits_changes table --

CREATE TABLE clients_audits_changes (
    id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    account_number INT NOT NULL,
    account_user_first_name VARCHAR(50),
    account_user_last_name VARCHAR(100),
    account_user_address VARCHAR(250),
    changed_on TIMESTAMPTZ
);

-- CREATE FOR THE clients_audits_deletes table --

CREATE TABLE clients_audits_deletes (
    id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    account_number INT NOT NULL,
    account_user_social_number INT NOT NULL,
    account_user_first_name VARCHAR(50) NOT NULL,
    account_user_last_name VARCHAR(100) NOT NULL,
    account_user_birthdate DATE NOT NULL,
    account_user_mother_full_name VARCHAR(150) NOT NULL,
    account_user_address VARCHAR(250) NOT NULL,
    deleted_on TIMESTAMPTZ
);

-- CREATE FOR THE clients_audits_withdraws table --

CREATE TABLE clients_audits_withdraws (
    id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    account_number INT NOT NULL,
    withdraw_amount NUMERIC NOT NULL,
    amount_withdrawn_on TIMESTAMPTZ
);

-- CREATE FOR THE clients_audits_deposits table --

CREATE TABLE clients_audits_deposits(
    id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    account_number INT NOT NULL,
    deposit_amount NUMERIC NOT NULL,
    amount_deposited_on TIMESTAMPTZ
);

-- CREATE FOR THE clients_audits_transferences table --

CREATE TABLE clients_audits_transferences(
    id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    account_number INT NOT NULL,
    receiver_account_number INT NOT NULL,
    transferred_amount NUMERIC NOT NULL,
    amount_transferred_on TIMESTAMPTZ
);