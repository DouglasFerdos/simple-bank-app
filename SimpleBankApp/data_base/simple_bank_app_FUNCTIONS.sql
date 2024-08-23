-- SIMPLE BANK APP --

-- ALL THE PROCEDURES FOR POSTGRESQL DB IN plpgsql LANGUAGE --

-- CREATE A NEW USER --
CREATE OR REPLACE FUNCTION create_account(
    IN accountUserSocialNumber INT,
    IN accountUserFirstName VARCHAR(50),
    IN accountUserLastName VARCHAR(100),
    IN accountUserBirthdate DATE,
    IN accountUserMotherFullName VARCHAR(150),
    IN accountUserAddress VARCHAR(250),
    IN accountBalance NUMERIC
)
RETURNS INT
AS
$$
DECLARE
	v_account_number INT;
BEGIN
    -- code
    INSERT INTO clients_info(
        account_user_social_number,
        account_user_first_name,
        account_user_last_name,
        account_user_birthdate,
        account_user_mother_full_name,
        account_user_address,
        account_balance
    ) VALUES (
        accountUserSocialNumber,
        accountUserFirstName,
        accountUserLastName,
        accountUserBirthdate,
        accountUserMotherFullName,
        accountUserAddress,
        accountBalance
	) RETURNING account_number INTO v_account_number;
	RETURN v_account_number;
END;
$$ LANGUAGE plpgsql;

-- DELETE USER ACCOUNT - ONLY IF DOES NOT HAVE ANY CREDIT OR DEBIT IN THE ACCOUNT - EXACTLY 0 --
CREATE OR REPLACE FUNCTION close_account(
    IN accountNumber INT,
    IN accountUserSocialNumber INT,
    IN accountUserBirthdate DATE,
    IN accountUserMotherFullName VARCHAR
)
RETURNS TEXT
AS
$$
BEGIN
    -- code
    IF((SELECT account_balance FROM clients_info WHERE account_number = accountNumber) = 0)
    THEN
        DELETE FROM clients_info
        WHERE (
            account_number = accountNumber
            AND
            account_user_social_number = accountUserSocialNumber
            AND
            account_user_birthdate = accountUserBirthdate
            AND
            account_user_mother_full_name = accountUserMotherFullName);
		RETURN 'ACCOUNT CLOSED';
	ELSE
		RETURN 'ERROR, THE ACCOUNT BALANCE IS NOT ZERO';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- GET THE ACCOUNT TABLE WITH DATA FROM clients_info --
CREATE OR REPLACE FUNCTION get_account_info(
    IN accountUserSocialNumber INT,
    IN accountUserBirthdate DATE,
    IN accountUserMotherFullName VARCHAR
)
-- RETURN A TABLE WITH THE SPECIFIED FORMAT --
	RETURNS TABLE (
		account_number INT,
	    account_user_social_number INT,
	    account_user_first_name VARCHAR,
	    account_user_last_name VARCHAR,
	    account_user_birthdate DATE,
	    account_user_mother_full_name VARCHAR,
	    account_user_address VARCHAR,
	    account_balance NUMERIC
	)
AS
$$
#variable_conflict use_column
BEGIN
    -- code
	RETURN QUERY
		SELECT *
		FROM clients_info
		WHERE(
			account_user_social_number = accountUserSocialNumber
			AND
			account_user_birthdate = accountUserBirthdate
			AND
			account_user_mother_full_name = accountUserMotherFullName);
END;
$$ LANGUAGE plpgsql;


-- UPDATE VALID USER DATA - FIRST NAME, LAST NAME & ADDRESS --
CREATE OR REPLACE FUNCTION update_user_data(
    -- DATA TO CONFIRM THE USER INFO --
    IN accountNumber INT,
    IN accountUserSocialNumber INT,
    IN accountUserBirthdate DATE,
    IN accountUserMotherFullName VARCHAR(150),
    -- DATA THAT CAN BE CHANGED --
    IN accountUserFirstName VARCHAR(50),
    IN accountUserLastName VARCHAR(100),
    IN accountUserAddress VARCHAR(250)
)
RETURNS TEXT
AS
$$
BEGIN
    -- code
    UPDATE clients_info
    SET account_user_first_name = accountUserFirstName,
        account_user_last_name = accountUserLastName,
        account_user_address = accountUserAddress
    WHERE (
        account_number = accountNumber
        AND
        account_user_social_number = accountUserSocialNumber
        AND
        account_user_birthdate = accountUserBirthdate
        AND
        account_user_mother_full_name = accountUserMotherFullName);
	RETURN 'ACCOUNT USER DATA UPDATED SUCCESSFULLY';
END;
$$ LANGUAGE plpgsql;

-- MONEY DEPOSIT --
CREATE OR REPLACE FUNCTION public.deposit_money(
    IN accountNumber INT,
    IN depositAmount NUMERIC
)
RETURNS TEXT
AS
$$
DECLARE
	new_account_balance TEXT;
BEGIN
    -- code
    UPDATE clients_info
    SET account_balance = account_balance + depositAmount
    WHERE account_number = accountNumber
    RETURNING account_balance INTO new_account_balance;
	RETURN new_account_balance;
END;
$$ LANGUAGE plpgsql;

-- MONEY WITHDRAW --
CREATE OR REPLACE FUNCTION withdraw_money(
    IN accountNumber INT,
    IN withdrawAmount NUMERIC
)
RETURNS TEXT
AS
$$
BEGIN
    -- code
    IF((SELECT account_balance FROM clients_info WHERE account_number = accountNumber) >= withdrawAmount)
    THEN
        UPDATE clients_info
        SET account_balance = account_balance - withdrawAmount
        WHERE account_number = accountNumber;
		RETURN CAST(withdrawAmount AS TEXT);
	ELSE
		RETURN 'COULD NOT WITHDRAW, INSUFFICIENT FOUNDS';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- MONEY TRANSFERENCE BETWEEN ACCOUNTS --
CREATE OR REPLACE FUNCTION transfer_money(
	-- Data necessary for transference
	senderAccountNumber INT,
	destinyAccountNumber INT,
	transferAmount NUMERIC,
	-- Data to confirm the account user info
	senderAccountUserBirthdate DATE,
	senderAccountUserSocialNumber INT,
	senderAccountUserMotherFullName VARCHAR
)
RETURNS TEXT
AS
$$
BEGIN
    -- code
	IF EXISTS(SELECT account_balance FROM clients_info WHERE account_number = senderAccountNumber) THEN
		IF ((SELECT account_balance FROM clients_info WHERE account_number = senderAccountNumber) >= transferAmount) THEN
			IF EXISTS(SELECT account_balance FROM clients_info WHERE account_number = destinyAccountNumber) THEN
				-- Withdraw the transfer amount from the sender account
				UPDATE clients_info
				    SET account_balance = account_balance - transferAmount
				    WHERE(
				        account_number = senderAccountNumber
				        AND
				        account_user_social_number = senderAccountUserSocialNumber
				        AND
				        account_user_birthdate = senderAccountUserBirthdate
				        AND
				        account_user_mother_full_name = senderAccountUserMotherFullName);
				-- Deposit the transfer amount to the destiny account
				UPDATE clients_info
					SET account_balance = account_balance + transferAmount
					WHERE account_number = destinyAccountNumber;
			    -- Create a log in the clients_audits_transferences table
			    INSERT INTO clients_audits_transferences(
                    account_number,
                	receiver_account_number,
                	transferred_amount,
                	amount_transferred_on
                ) VALUES (
                	senderAccountNumber,
                    destinyAccountNumber,
                	transferAmount,
                    NOW());
                -- Returns the transferred amount
                RETURN CAST(transferAmount AS TEXT);
			ELSE
				-- Return if could not find the destiny account
				RETURN 'COULD NOT FIND THE DESTINY ACCOUNT';
			END IF;
		ELSE
			-- Return if the sender has insufficient funds
			RETURN 'NON-SUFFICIENT FUNDS';
		END IF;
	ELSE
		-- Return if could not find the sender account
		RETURN 'COULD NOT FIND YOUR ACCOUNT';
	END IF;
END;
$$ LANGUAGE plpgsql;