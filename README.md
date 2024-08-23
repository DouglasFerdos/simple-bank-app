# simplebankapp

A simple bank application using Java and SQL for learning where it is possible to create, close, consult, and update the account, besides the common transactions of deposit, withdraw, and transfer money, all of which are auditable in PostgreSQL, that are done automatically with the help of triggers.

You can use the following steps to execute the program yourself:


# You can execute the code from the .sql files inside the data_base folder in this order:

1. DBCREATION: Creates the simplebankapp database where the subsequent SQL code should be executed.

2. TABLES: Creates all the necessary tables for clients and audits data.

3. FUNCTIONS: Contains all the necessary functions that will be called by the Java JDBC Driver for communication between the DB and Java.

4. TRIGGERS: To automatically update the audit tables when data is changed.



After you have all the necessary SQL for the database part created, it is possible to run the program by opening the folder in IntelliJ IDEA. For the Eclipse IDE, extra steps may be necessary.

## This project has two dependencies:

* PostgreSQL JDBC Driver: version can be seen in the pom.xml file.

* JUnit 5 (Jupiter): version can also be seen in the pom.xml file.

With everything set it is possible to either test it yourself or use the already created Test for database integration.

#### All the methods in database integration are executed as a transaction, respecting Atomicity, Consistency, Isolation and Durability. The detailed information can be found in the code.
