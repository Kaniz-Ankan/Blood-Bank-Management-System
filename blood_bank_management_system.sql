SET NUMWIDTH 38;
SET LINESIZE 10000;
SET PAGESIZE 10000;


CREATE TABLE blood_bank (
   blood_bank_id NUMBER(5) PRIMARY KEY,
   name VARCHAR2(50),
   phone VARCHAR2(15),
   location VARCHAR2(50)
);


CREATE TABLE app_user (
   user_id NUMBER(5) PRIMARY KEY,
   name VARCHAR2(50),
   location VARCHAR2(50),
   age NUMBER(3),
   gender VARCHAR2(10)
);


CREATE TABLE hospital (
   hospital_id NUMBER(5) PRIMARY KEY,
   hospital_name VARCHAR2(50),
   phone VARCHAR2(15),
   location VARCHAR2(50)
);


CREATE TABLE donor (
   donor_id NUMBER(5) PRIMARY KEY,
   user_id NUMBER(5),
   name VARCHAR2(50),
   gender VARCHAR2(10),
   age NUMBER(3),
   location VARCHAR2(50),
   FOREIGN KEY (user_id) REFERENCES app_user(user_id)
);


CREATE TABLE blood (
   blood_id NUMBER(5) PRIMARY KEY,
   blood_group VARCHAR2(5),
   expiry_date DATE,
   quantity NUMBER(5),
   donor_id NUMBER(5),
   blood_bank_id NUMBER(5),
   FOREIGN KEY (donor_id) REFERENCES donor(donor_id),
   FOREIGN KEY (blood_bank_id) REFERENCES blood_bank(blood_bank_id)
);


CREATE TABLE request_for_blood (
   request_id NUMBER(5) PRIMARY KEY,
   blood_group VARCHAR2(5),
   user_id NUMBER(5),
   blood_bank_id NUMBER(5),
   quantity NUMBER(5),
   location VARCHAR2(50),
   FOREIGN KEY (user_id) REFERENCES app_user(user_id),
   FOREIGN KEY (blood_bank_id) REFERENCES blood_bank(blood_bank_id)
);


CREATE TABLE hospital_request (
   hospital_id NUMBER(5),
   blood_bank_id NUMBER(5),
   blood_group VARCHAR2(5),
   quantity NUMBER(5),
   PRIMARY KEY (hospital_id, blood_bank_id, blood_group),
   FOREIGN KEY (hospital_id) REFERENCES hospital(hospital_id),
   FOREIGN KEY (blood_bank_id) REFERENCES blood_bank(blood_bank_id)
);


INSERT INTO blood_bank VALUES(1, 'Dhaka Blood Bank', '01795821979', 'Dhaka');
INSERT INTO blood_bank VALUES(2, 'Bogura Blood Bank', '01815822761', 'Bogura');


INSERT INTO app_user VALUES(101, 'Rahim', 'Dhaka', 25, 'Male');
INSERT INTO app_user VALUES(102, 'Karim', 'Bogura', 28, 'Male');
INSERT INTO app_user VALUES(103, 'Nusrat', 'Dhaka', 23, 'Female');
INSERT INTO app_user VALUES(104, 'Mim', 'Rajshahi', 26, 'Female');


INSERT INTO hospital VALUES(301, 'City Hospital', '01911113411', 'Dhaka');
INSERT INTO hospital VALUES(302, 'Central Hospital', '01622522542', 'Bogura');


INSERT INTO donor VALUES(201, 101, 'Rahim', 'Male', 25, 'Dhaka');
INSERT INTO donor VALUES(202, 103, 'Nusrat', 'Female', 23, 'Dhaka');
INSERT INTO donor VALUES(203, 104, 'Mim', 'Female', 26, 'Rajshahi');


INSERT INTO blood VALUES(401, 'A+', TO_DATE('30-12-2026','DD-MM-YYYY'), 2, 201, 1);
INSERT INTO blood VALUES(402, 'B+', TO_DATE('15-01-2027','DD-MM-YYYY'), 1, 202, 1);
INSERT INTO blood VALUES(403, 'O-', TO_DATE('20-01-2027','DD-MM-YYYY'), 3, 203, 2);


INSERT INTO request_for_blood VALUES(501, 'A+', 102, 1, 1, 'Dhaka');
INSERT INTO request_for_blood VALUES(502, 'B+', 101, 1, 2, 'Dhaka');
INSERT INTO request_for_blood VALUES(503, 'O-', 103, 2, 1, 'Bogura');
INSERT INTO hospital_request VALUES(301, 1, 'A+', 3);
INSERT INTO hospital_request VALUES(302, 2, 'O-', 2);


COMMIT;


SELECT DISTINCT d.*
FROM donor d
JOIN blood b
   ON d.donor_id = b.donor_id
WHERE d.gender = 'Male'
 AND d.location = 'Dhaka'
 AND b.quantity > 1;


 SELECT *
FROM app_user
WHERE (location = 'Dhaka'
      OR location = 'Rajshahi')
 AND age >= 24;


 SELECT bb.*
FROM blood_bank bb
WHERE bb.location <> 'Dhaka'
 AND EXISTS (
     SELECT 1
     FROM blood b
     WHERE b.blood_bank_id = bb.blood_bank_id
 );


 SELECT r.*
FROM request_for_blood r
JOIN blood_bank bb
   ON r.blood_bank_id = bb.blood_bank_id
WHERE r.blood_group IN ('A+', 'B+')
 AND r.quantity > 1
 AND bb.location = 'Dhaka';


 SELECT u.*
FROM app_user u
WHERE u.gender <> 'Male'
 AND u.age >= 25
 AND EXISTS (
     SELECT 1
     FROM request_for_blood r
     WHERE r.user_id = u.user_id
 );


 -- Combines app_user and donor names/locations
 SELECT name, location
FROM app_user
UNION
SELECT name, location
FROM donor;


-- Combines app_user and donor names/locations
SELECT name, location
FROM app_user
UNION ALL
SELECT name, location
FROM donor;


-- Finds locations that exist in both blood_bank and hospital
SELECT location
FROM blood_bank
WHERE location IS NOT NULL
INTERSECT
SELECT location
FROM hospital
WHERE location IS NOT NULL;




-- Finds the average age for each gender
SELECT gender,
      AVG(age) AS average_age
FROM app_user
GROUP BY gender;


-- Finds the maximum age of users in each location
SELECT location,
      MAX(age) AS maximum_age
FROM app_user
GROUP BY location;




-- Finds the minimum age of users in each location
SELECT location,
      MIN(age) AS minimum_age
FROM app_user
GROUP BY location;


-- Finds total available blood quantity for each blood bank
SELECT blood_bank_id,
      SUM(quantity) AS total_quantity
FROM blood
GROUP BY blood_bank_id;


-- Finds average blood quantity for each blood bank
SELECT blood_bank_id,
      AVG(quantity) AS average_quantity
FROM blood
GROUP BY blood_bank_id;


-- Finds total blood quantity and displays blood bank name
SELECT bb.name,
      SUM(b.quantity) AS total_quantity
FROM blood_bank bb
JOIN blood b
   ON bb.blood_bank_id = b.blood_bank_id
GROUP BY bb.name;


-- Finds average blood quantity for each blood bank
SELECT bb.name,
      AVG(b.quantity) AS average_quantity
FROM blood_bank bb
JOIN blood b
   ON bb.blood_bank_id = b.blood_bank_id
GROUP BY bb.name;


-- Finds locations whose average user age is greater than 24
SELECT location,
      AVG(age) AS average_age
FROM app_user
GROUP BY location
HAVING AVG(age) > 24;


-- Finds blood records having the highest quantity overall
SELECT *
FROM blood
WHERE quantity = (
   SELECT MAX(quantity)
   FROM blood
);


-- Finds blood record(s) having the lowest quantity overall
SELECT *
FROM blood
WHERE quantity = (
   SELECT MIN(quantity)
   FROM blood
);


-- Finds the blood record with the highest quantity within each blood bank
SELECT b.*
FROM blood b
WHERE b.quantity = (
   SELECT MAX(b2.quantity)
   FROM blood b2
   WHERE b2.blood_bank_id = b.blood_bank_id
);


-- Finds average requested blood quantity for each blood bank
SELECT bb.name,
      AVG(r.quantity) AS average_request_quantity
FROM blood_bank bb
JOIN request_for_blood r
   ON bb.blood_bank_id = r.blood_bank_id
GROUP BY bb.name;


-- Displays blood details with donor name and blood bank name
SELECT b.blood_id,
      b.blood_group,
      d.name AS donor_name,
      bb.name AS blood_bank_name,
      b.quantity
FROM blood b
INNER JOIN donor d
ON b.donor_id = d.donor_id
INNER JOIN blood_bank bb
ON b.blood_bank_id = bb.blood_bank_id;


-- Displays all app users, including users with no blood request
SELECT u.user_id,
      u.name,
      r.request_id,
      r.blood_group,
      r.quantity
FROM app_user u
LEFT JOIN request_for_blood r
ON u.user_id = r.user_id;


-- Displays all blood banks, including banks with no request
SELECT bb.blood_bank_id,
      bb.name AS blood_bank_name,
      r.request_id,
      r.blood_group,
      r.quantity
FROM request_for_blood r
RIGHT JOIN blood_bank bb
ON r.blood_bank_id = bb.blood_bank_id;


-- Displays all users and all blood requests including unmatched rows from both tables
SELECT u.user_id,
      u.name,
      r.request_id,
      r.blood_group,
      r.quantity
FROM app_user u
FULL JOIN request_for_blood r
ON u.user_id = r.user_id;


-- Finds users who made requests to blood bank 1 or 2
SELECT *
FROM app_user
WHERE user_id IN (
   SELECT user_id
   FROM request_for_blood
   WHERE blood_bank_id IN (1, 2)
);


-- Finds users who have never made a blood request
SELECT *
FROM app_user
WHERE user_id NOT IN (
   SELECT user_id
   FROM request_for_blood
);


-- Finds users who have made at least one blood request
SELECT u.*
FROM app_user u
WHERE EXISTS (
   SELECT 1
   FROM request_for_blood r
   WHERE r.user_id = u.user_id
);


-- Finds users whose requested blood group is available in the same blood bank where they requested it
SELECT u.user_id,
      u.name
FROM app_user u
WHERE EXISTS (
   SELECT 1
   FROM request_for_blood r
   WHERE r.user_id = u.user_id
     AND EXISTS (
         SELECT 1
         FROM blood b
         WHERE b.blood_bank_id = r.blood_bank_id
           AND b.blood_group = r.blood_group
     )
);


-- Finds blood records whose quantity is greater than at least one blood quantity in blood bank 1
SELECT *
FROM blood
WHERE quantity > ANY (
   SELECT quantity
   FROM blood
   WHERE blood_bank_id = 1
);


-- Finds blood records whose quantity is greater than every blood quantity in blood bank 1
SELECT *
FROM blood
WHERE quantity > ALL (
   SELECT quantity
   FROM blood
   WHERE blood_bank_id = 1
);


-- Finds donors whose names begin with 'R' and whose location is Dhaka
SELECT *
FROM donor
WHERE name LIKE 'R%'
 AND location = 'Dhaka';


 -- Finds total blood quantity for every blood bank
 SELECT bb.blood_bank_id,
      bb.name,
      SUM(b.quantity) AS total_quantity
FROM blood_bank bb
JOIN blood b
   ON bb.blood_bank_id = b.blood_bank_id
GROUP BY bb.blood_bank_id, bb.name;


-- Finds blood banks containing more than one different blood group
SELECT bb.blood_bank_id,
      bb.name,
      COUNT(DISTINCT b.blood_group) AS blood_group_count
FROM blood_bank bb
JOIN blood b
   ON bb.blood_bank_id = b.blood_bank_id
GROUP BY bb.blood_bank_id, bb.name
HAVING COUNT(DISTINCT b.blood_group) > 1;


-- Finds the blood bank that received the highest number of user blood requests
SELECT bb.blood_bank_id,
      bb.name,
      COUNT(r.request_id) AS total_requests
FROM blood_bank bb
JOIN request_for_blood r
   ON bb.blood_bank_id = r.blood_bank_id
GROUP BY bb.blood_bank_id, bb.name
HAVING COUNT(r.request_id) = (
   SELECT MAX(request_count)
   FROM (
       SELECT COUNT(*) AS request_count
       FROM request_for_blood
       GROUP BY blood_bank_id
   )
);




-- Finds blood banks whose total requested quantity is greater than the average total requested quantity across all blood banks


SELECT bb.blood_bank_id,
      bb.name,
      SUM(r.quantity) AS total_requested
FROM blood_bank bb
JOIN request_for_blood r
   ON bb.blood_bank_id = r.blood_bank_id
GROUP BY bb.blood_bank_id, bb.name
HAVING SUM(r.quantity) > (
   SELECT AVG(bank_total)
   FROM (
       SELECT SUM(quantity) AS bank_total
       FROM request_for_blood
       GROUP BY blood_bank_id
   )
);


                                     -- PL/SQL
-- Retrieves one user's name and stores it in a variable
DECLARE
   v_name app_user.name%TYPE;
BEGIN
   SELECT name
   INTO v_name
   FROM app_user
   WHERE user_id = 101;


   DBMS_OUTPUT.PUT_LINE('User Name: ' || v_name);
END;
/


-- Stores a blood bank name inside a variable and displays it
DECLARE
   v_bank_name VARCHAR2(50);
BEGIN
   v_bank_name := 'Dhaka Blood Bank';


   DBMS_OUTPUT.PUT_LINE(
       'Blood Bank: ' || v_bank_name
   );
END;
/


-- Retrieves an entire app_user row into one record variable
DECLARE
   v_user app_user%ROWTYPE;
BEGIN
   SELECT *
   INTO v_user
   FROM app_user
   WHERE user_id = 103;


   DBMS_OUTPUT.PUT_LINE(
       'Name: ' || v_user.name ||
       ', Age: ' || v_user.age ||
       ', Location: ' || v_user.location
   );
END;
/


-- Retrieves the blood group of blood ID 401 and stores it in a variable
DECLARE
   v_blood_group blood.blood_group%TYPE;
BEGIN
   SELECT blood_group
   INTO v_blood_group
   FROM blood
   WHERE blood_id = 401;


   DBMS_OUTPUT.PUT_LINE(
       'Blood Group: ' || v_blood_group
   );
END;
/




-- Calculates total bank stock and categorizes the stock level
DECLARE
   v_total NUMBER;
BEGIN
   SELECT SUM(quantity)
   INTO v_total
   FROM blood
   WHERE blood_bank_id = 1;


   IF v_total >= 5 THEN


       DBMS_OUTPUT.PUT_LINE('Stock Level: HIGH');


   ELSIF v_total >= 3 THEN


       DBMS_OUTPUT.PUT_LINE('Stock Level: MEDIUM');


   ELSE


       DBMS_OUTPUT.PUT_LINE('Stock Level: LOW');


   END IF;
END;
/


-- Retrieves donor name, age and location for donor 201
DECLARE
   v_name donor.name%TYPE;
   v_age donor.age%TYPE;
   v_location donor.location%TYPE;
BEGIN
   SELECT name, age, location
   INTO v_name, v_age, v_location
   FROM donor
   WHERE donor_id = 201;


   DBMS_OUTPUT.PUT_LINE(
       'Donor Name: ' || v_name
   );


   DBMS_OUTPUT.PUT_LINE(
       'Age: ' || v_age
   );


   DBMS_OUTPUT.PUT_LINE(
       'Location: ' || v_location
   );
END;
/




-- Stores different blood groups inside an array
DECLARE
   TYPE blood_group_array IS TABLE OF VARCHAR2(5)
   INDEX BY PLS_INTEGER;


   groups blood_group_array;


BEGIN
   groups(1) := 'A+';
   groups(2) := 'B+';
   groups(3) := 'O-';


   DBMS_OUTPUT.PUT_LINE(groups(1));
   DBMS_OUTPUT.PUT_LINE(groups(2));
   DBMS_OUTPUT.PUT_LINE(groups(3));
END;
/


-- Retrieves an entire blood record using %ROWTYPE
DECLARE
   v_blood blood%ROWTYPE;
BEGIN
   SELECT *
   INTO v_blood
   FROM blood
   WHERE blood_id = 403;


   DBMS_OUTPUT.PUT_LINE(
       'Blood ID: ' || v_blood.blood_id
   );


   DBMS_OUTPUT.PUT_LINE(
       'Blood Group: ' || v_blood.blood_group
   );


   DBMS_OUTPUT.PUT_LINE(
       'Quantity: ' || v_blood.quantity
   );
END;
/


-- Checks whether a blood record has sufficient quantity
DECLARE
   v_quantity blood.quantity%TYPE;
BEGIN
   SELECT quantity
   INTO v_quantity
   FROM blood
   WHERE blood_id = 401;


   IF v_quantity >= 2 THEN
       DBMS_OUTPUT.PUT_LINE(
           'Sufficient Blood Available'
       );
   ELSE
       DBMS_OUTPUT.PUT_LINE(
           'Low Blood Quantity'
       );
   END IF;
END;
/






-- Stores blood groups in a VARRAY and displays them using a FOR loop
DECLARE
   TYPE blood_group_array IS VARRAY(3) OF VARCHAR2(5);


   groups blood_group_array :=
       blood_group_array('A+', 'B+', 'O-');


BEGIN
   FOR i IN 1..groups.COUNT LOOP


       DBMS_OUTPUT.PUT_LINE(
           'Blood Group: ' || groups(i)
       );


   END LOOP;
END;
/


-- Attempts to retrieve a nonexistent user  and handles the error using WHEN OTHERS
DECLARE
   v_name app_user.name%TYPE;
BEGIN
   SELECT name
   INTO v_name
   FROM app_user
   WHERE user_id = 999;


   DBMS_OUTPUT.PUT_LINE(v_name);


EXCEPTION
   WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE(
           'Error while retrieving user'
       );
END;
/


-- Creates a procedure that calculates and displays total blood quantity for a supplied blood bank ID
CREATE OR REPLACE PROCEDURE show_bank_stock (
   p_bank_id NUMBER
)
IS
   v_total NUMBER;
BEGIN


   SELECT NVL(SUM(quantity), 0)
   INTO v_total
   FROM blood
   WHERE blood_bank_id = p_bank_id;


   DBMS_OUTPUT.PUT_LINE(
       'Total Blood Quantity: ' || v_total
   );


END;
/


-- Creates a function that calculates and returns total blood stock for a supplied blood bank ID
CREATE OR REPLACE FUNCTION get_bank_stock (
   p_bank_id NUMBER
)
RETURN NUMBER
IS
   v_total NUMBER;
BEGIN


   SELECT NVL(SUM(quantity), 0)
   INTO v_total
   FROM blood
   WHERE blood_bank_id = p_bank_id;


   RETURN v_total;


END;
/


-- Categorizes a user's age
DECLARE
   v_age app_user.age%TYPE;
BEGIN
   SELECT age
   INTO v_age
   FROM app_user
   WHERE user_id = 102;


   IF v_age >= 30 THEN


       DBMS_OUTPUT.PUT_LINE(
           'Age Group: 30 or Above'
       );


   ELSIF v_age >= 25 THEN


       DBMS_OUTPUT.PUT_LINE(
           'Age Group: 25 to 29'
       );


   ELSE


       DBMS_OUTPUT.PUT_LINE(
           'Age Group: Below 25'
       );


   END IF;
END;
/


-- Displays blood bank IDs from 1 to 2
DECLARE
   i NUMBER := 1;
BEGIN
   WHILE i <= 2 LOOP


       DBMS_OUTPUT.PUT_LINE(
           'Blood Bank ID: ' || i
       );


       i := i + 1;


   END LOOP;
END;
/




-- Retrieves multiple donor/blood rows and processes them one record at a time
DECLARE


   CURSOR c_blood IS
       SELECT d.name,
              b.blood_group,
              b.quantity
       FROM donor d
       JOIN blood b
           ON d.donor_id = b.donor_id;


   v_name donor.name%TYPE;
   v_group blood.blood_group%TYPE;
   v_quantity blood.quantity%TYPE;


BEGIN


   OPEN c_blood;


   LOOP


       FETCH c_blood
       INTO v_name, v_group, v_quantity;


       EXIT WHEN c_blood%NOTFOUND;


       DBMS_OUTPUT.PUT_LINE(
           'Donor: ' || v_name ||
           ', Blood Group: ' || v_group ||
           ', Quantity: ' || v_quantity
       );


   END LOOP;


   CLOSE c_blood;


END;
/


-- Stores blood bank locations in an associative array
DECLARE
   TYPE location_array IS TABLE OF VARCHAR2(50)
   INDEX BY PLS_INTEGER;


   locations location_array;


BEGIN
   locations(1) := 'Dhaka';
   locations(2) := 'Bogura';
   locations(3) := 'Rajshahi';


   DBMS_OUTPUT.PUT_LINE(
       'Location 1: ' || locations(1)
   );


   DBMS_OUTPUT.PUT_LINE(
       'Location 2: ' || locations(2)
   );


   DBMS_OUTPUT.PUT_LINE(
       'Location 3: ' || locations(3)
   );
END;
/


-- Stores blood bank names in a VARRAY and displays them using a FOR loop


DECLARE
   TYPE bank_array IS VARRAY(2) OF VARCHAR2(50);


   banks bank_array :=
       bank_array(
           'Dhaka Blood Bank',
           'Bogura Blood Bank'
       );


BEGIN
   FOR i IN 1..banks.COUNT LOOP


       DBMS_OUTPUT.PUT_LINE(
           'Bank: ' || banks(i)
       );


   END LOOP;
END;
/


-- Attempts to retrieve a blood bank that does not exist
DECLARE
   v_name blood_bank.name%TYPE;
BEGIN
   SELECT name
   INTO v_name
   FROM blood_bank
   WHERE blood_bank_id = 99;


   DBMS_OUTPUT.PUT_LINE(
       'Bank Name: ' || v_name
   );


EXCEPTION
   WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE(
           'Blood bank not found'
       );
END;
/


-- Returns the age of a particular app user
CREATE OR REPLACE FUNCTION get_user_age (
   p_user_id NUMBER
)
RETURN NUMBER
IS
   v_age NUMBER;
BEGIN
   SELECT age
   INTO v_age
   FROM app_user
   WHERE user_id = p_user_id;


   RETURN v_age;
END;
/


-- Displays all blood bank names and locations one row at a time
DECLARE


   CURSOR c_bank IS
       SELECT name, location
       FROM blood_bank;


   v_name blood_bank.name%TYPE;
   v_location blood_bank.location%TYPE;


BEGIN


   OPEN c_bank;


   LOOP


       FETCH c_bank
       INTO v_name, v_location;


       EXIT WHEN c_bank%NOTFOUND;


       DBMS_OUTPUT.PUT_LINE(
           'Bank: ' || v_name ||
           ', Location: ' || v_location
       );


   END LOOP;


   CLOSE c_bank;


END;
/



