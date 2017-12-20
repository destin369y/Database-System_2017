#1 Create Tables
#1.1 Product
#Assumption: the length of productCode and productName will not be larger than 255
#Though productCode is supposed to be 1 to 3 characters long, 
#we still use a larger max-length varchar here in case we have more products and need a longer productCode in the future.  
CREATE TABLE Product (
productCode VARCHAR(255) NOT NULL,
productName VARCHAR(255) NOT NULL,
UNIQUE(productCode),
UNIQUE(productName),
PRIMARY KEY(productCode)
);

#1.2 ComponentCategory
#Assumption: the length of compCatName will not be larger than 255
CREATE TABLE ComponentCategory (
compCatId INTEGER NOT NULL AUTO_INCREMENT,
compCatName varchar(255) NOT NULL,
UNIQUE(compCatId),
UNIQUE(compCatName),
PRIMARY KEY(compCatId)
);

#1.3 Component
#Assumption: the length of compName will not be larger than 255
CREATE TABLE Component (
compId INTEGER NOT NULL AUTO_INCREMENT,
compName varchar(255),
compCatId INTEGER NOT NULL,
UNIQUE(compId),
PRIMARY KEY(compId),
FOREIGN KEY(compCatId) references ComponentCategory(compCatId)
);

#1.4 Unit
#Assumption: the length of unitName will not be larger than 255
CREATE TABLE Unit (
unitId INTEGER NOT NULL AUTO_INCREMENT,
unitName varchar(255) NOT NULL,
UNIQUE(unitId),
UNIQUE(unitName),
PRIMARY KEY(unitId)
);

#1.5 RecipeItem
#Assumption: the length of productCode will not be larger than 255
CREATE TABLE RecipeItem (
recipeItemId INTEGER NOT NULL AUTO_INCREMENT,
productCode VARCHAR(255) NOT NULL,
compCatId INTEGER NOT NULL,
qty DOUBLE,
unitId INTEGER NOT NULL,
compId INTEGER NULL,
UNIQUE(productCode, compCatId, compId),
PRIMARY KEY(recipeItemId),
FOREIGN KEY(productCode) references Product(productCode),
FOREIGN KEY(compCatId) references ComponentCategory(compCatId),
FOREIGN KEY(unitId) references Unit(unitId),
FOREIGN KEY(compId) references Component(compId)
);

#1.6 Location
#Assumption: the length of locationName, locationAddress, locationCity, locationState, and locationZip will not be larger than 255
CREATE TABLE Location (
locationId INTEGER NOT NULL AUTO_INCREMENT,
locationName VARCHAR(255),
locationAddress VARCHAR(255),
locationCity VARCHAR(255),
locationState VARCHAR(255),
locationZip VARCHAR(255),
PRIMARY KEY(locationId)
);

#1.7 Menu
#Assumption: the length of menuName will not be larger than 255
CREATE TABLE Menu (
menuId INTEGER NOT NULL AUTO_INCREMENT,
menuName VARCHAR(255) NOT NULL,
UNIQUE(menuName),
PRIMARY KEY(menuId)
);

#1.8 MenuItem
#Assumption: a productCode may only be included up to one time on a menu.
#Assumption: the length of productCode will not be larger than 255
#Assumption: the price will not be larger than 100,000,000
CREATE TABLE MenuItem (
menuItemId INTEGER NOT NULL AUTO_INCREMENT,
menuId INTEGER NOT NULL,
productCode VARCHAR(255) NOT NULL,
price DOUBLE(9, 2),
UNIQUE(menuId, productCode),
PRIMARY KEY(menuItemId),
FOREIGN KEY(menuId) references Menu(menuId),
FOREIGN KEY(productCode) references Product(productCode)
);

#1.9 Event
#Assumption: the length of eventName will not be larger than 255
CREATE TABLE Event (
eventId INTEGER NOT NULL AUTO_INCREMENT,
eventName VARCHAR(255),
eventStart DATETIME,
eventEnd DATETIME,
locationId INTEGER,
menuId INTEGER NOT NULL,
PRIMARY KEY(eventId),
FOREIGN KEY(locationId) references Location(locationId),
FOREIGN KEY(menuId) references Menu(menuId)
);

#1.10 Employee
#Assumption: the length of firstName, lastName, and phone will not be larger than 255
CREATE TABLE Employee (
employeeId INTEGER NOT NULL AUTO_INCREMENT,
firstName VARCHAR(255),
lastName VARCHAR(255),
DOB DATE,
phone VARCHAR(255),
PRIMARY KEY(employeeId)
);

#1.11 EventAssignment
CREATE TABLE EventAssignment (
eventAssignmentId INTEGER NOT NULL AUTO_INCREMENT,
eventId INTEGER,
employeeId INTEGER,
PRIMARY KEY(eventAssignmentId),
FOREIGN KEY(eventId) references Event(eventId),
FOREIGN KEY(employeeId) references Employee(employeeId)
);

#1.12 Ticket
CREATE TABLE Ticket (
ticketId INTEGER NOT NULL AUTO_INCREMENT,
eventId INTEGER NOT NULL,
ticketTime DATETIME,
soldBy INTEGER NOT NULL,
numProducts INTEGER,
PRIMARY KEY(ticketId),
FOREIGN KEY(eventId) references Event(eventId),
FOREIGN KEY(soldBy) references Employee(employeeId)
);

#1.13 ProductSold
#Assumption: the length of productCode will not be larger than 255
CREATE TABLE ProductSold (
productSoldId INTEGER NOT NULL AUTO_INCREMENT,
productCode VARCHAR(255) NOT NULL,
ticketId INTEGER NOT NULL,
PRIMARY KEY(productSoldId),
FOREIGN KEY(productCode) references Product(productCode),
FOREIGN KEY(ticketId) references Ticket(ticketId)
);

#1.14 ItemSold 
CREATE TABLE ItemSold (
itemSoldId INTEGER NOT NULL AUTO_INCREMENT,
productSoldId INTEGER NOT NULL,
compId INTEGER,
qty DOUBLE,
unitId INTEGER NOT NULL,
PRIMARY KEY(itemSoldId),
FOREIGN KEY(productSoldId) references ProductSold(productSoldId),
FOREIGN KEY(compId) references Component(compId),
FOREIGN KEY(unitId) references Unit(unitId)
);


#2 Load Data
LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/product.txt' INTO TABLE Product 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/componentCategory.txt' INTO TABLE ComponentCategory 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/component.txt' INTO TABLE Component 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/unit.txt' INTO TABLE Unit 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/recipeItem.txt' INTO TABLE RecipeItem 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/location.txt' INTO TABLE Location 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/menu.txt' INTO TABLE Menu 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/menuItem.txt' INTO TABLE MenuItem 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/eventV3.tsv' INTO TABLE Event 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/employee.txt' INTO TABLE Employee 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/eventAssignment.txt' INTO TABLE EventAssignment 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/ticket.txt' INTO TABLE Ticket 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/productSold.txt' INTO TABLE ProductSold 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW3/itemSold.txt' INTO TABLE ItemSold 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;


#3 Queries
#3.0.1 Query 1
SELECT COUNT(DISTINCT productCode) AS numProducts
FROM Product;

#3.0.2 Query 2
SELECT C.compCatName, D.compName, A.qty, E.unitName
FROM RecipeItem A LEFT JOIN Component D ON A.compId = D.compId, 
	Product B, ComponentCategory C, Unit E
WHERE B.productName = 'turtle sundae' 
	AND A.productCode = B.productCode 
	AND A.compCatId = C.compCatId
    AND A.unitId = E.unitId
ORDER BY A.recipeItemId;

#3.0.3 Query 3
#"Cones" here refers to products, not components. So, look for product codes: 'wc', 'c1', 'c2', 'c3'
#Assumption: when asked to list events, list both the eventId and eventName
SELECT A.eventId, A.eventName, COUNT(
	CASE D.productCode
		WHEN 'wc' THEN 1
        WHEN 'c1' THEN 1
        WHEN 'c2' THEN 1
        WHEN 'c3' THEN 1
		ELSE NULL
	END) AS numberConesSold
FROM Event A LEFT JOIN Location B ON A.locationId = B.locationId
		LEFT JOIN Ticket C ON A.eventId = C.eventId 
		LEFT JOIN ProductSold D ON C.ticketId = D.ticketId        
WHERE B.locationName = 'Valhalla' 
GROUP BY A.eventId
ORDER BY A.eventStart;

#3.0.4 Query 4
#Assumption: the totalPrice will not be larger than 100,000,000
ALTER TABLE Ticket 
ADD COLUMN totalPrice DOUBLE(9, 2);

CREATE VIEW TicketPrice AS
SELECT A.ticketId, SUM(D.price) AS totalPrice
FROM ProductSold A LEFT JOIN Ticket B ON A.ticketId = B.ticketId
		LEFT JOIN Event C ON B.eventId = C.eventId
		LEFT JOIN MenuItem D ON (C.menuId = D.menuId AND A.productCode = D.productCode)
GROUP BY A.ticketId;

#disable safe update mode
SET SQL_SAFE_UPDATES = 0;
UPDATE Ticket A, TicketPrice B SET A.totalPrice = B.totalPrice
WHERE A.ticketId = B.ticketId;

SELECT ticketId, numProducts, totalPrice
FROM Ticket
WHERE ticketId = 170 
	OR ticketId = 1089
ORDER BY ticketId;

#3.0.5 Query 5a
#The End DateTime of event 35 should be '2017-05-09 02:00:00'
UPDATE EVENT 
SET eventEnd = '2017-05-09 02:00:00' 
WHERE eventId = 35;

CREATE VIEW EventPrice AS
SELECT A.eventId, TIME_TO_SEC(TIMEDIFF(A.eventEnd, A.eventStart))/60 AS eventMinutes, SUM(B.totalPrice) AS eventTotalPrice
FROM Event A LEFT JOIN Ticket B ON A.eventId = B.eventId
GROUP BY A.eventId;

SELECT A.eventId, A.eventName, B.locationName, ROUND((C.eventTotalPrice/C.eventMinutes)*60, 2) AS pricePerHour
FROM Event A LEFT JOIN location B ON A.locationId = B.locationId
		LEFT JOIN EventPrice C ON A.eventId = C.eventId
ORDER BY pricePerHour DESC
LIMIT 10;

#3.0.6 Query 5b
#A "college event" is an event held at one of Rice's colleges. Look for locations with "College" in the name.
#Assumption: Also sort by price per hour from highest to lowest as 3.0.5 Query 5a
SELECT A.eventId, B.locationName, ROUND((C.eventTotalPrice/C.eventMinutes)*60, 2) AS pricePerHour
FROM Event A LEFT JOIN location B ON A.locationId = B.locationId
		LEFT JOIN EventPrice C ON A.eventId = C.eventId
WHERE B.locationName LIKE '%College%'
ORDER BY pricePerHour DESC
LIMIT 2;

#3.0.7 Query 6a
#We want to see which toppings are ordered most frequently - how many times is each type of topping ordered
#Assumption: So we assume the 'quantity' asked in the question means the number of times the toppings are ordered
#You may use product codes in your query
#Assumption: The productCode for ice cream cones, dishes and waffle cones(including extra toppings) 
#are 'c1', 'c2', 'c3', 'cx', 'd1', 'd2', 'd3', 'dx', 'wc', and 'wx'
#Here 'extra topping' does not include extra slush topping and extra sundae topping
#The compCatId of component 1 should be 1
UPDATE Component 
SET compCatId = 1 
WHERE compId = 1;

SELECT A.compName, COUNT(C.compId) AS quantity
FROM Component A LEFT JOIN ComponentCategory B ON A.compCatId = B.compCatId
	LEFT JOIN ItemSold C ON A.compId = C.compId
    LEFT JOIN ProductSold D ON C.productSoldId = D.productSoldId
WHERE B.compCatName = 'topping'
	AND D.productCode IN ('c1', 'c2', 'c3', 'cx', 'd1', 'd2', 'd3', 'dx', 'wc', 'wx')
GROUP BY C.compId
ORDER BY quantity DESC
LIMIT 3;

#3.0.8 Query 6b
#Assumption: To find components which are not used, we are based on which components do not appear in ItemSold instead of in MenuItem,
#which mean even if a component is listed on the menu, we consider it as 'not used' if it does appear on any tickets or in ItemSold.
#Assumption: When asked to show category, we show both the category id and category name.
SELECT A.compId, A.compName, A.compCatId, B.compCatName
FROM Component A LEFT JOIN ComponentCategory B ON A.compCatId = B.compCatId
WHERE A.compId NOT IN (
	SELECT C.compId
	FROM ItemSold C)
ORDER BY A.compId;

#3.0.9 Query 7a
#Assumption: The recipe for "Beer" (product code 'be') is a single can of beer.
#Assumption: Assume the 5 ounces ice cream means 'ice cream base'. 
#Since we did not know the which ice cream will be ordered yet, so set the compId of ice cream recipeItem for beer float as NULL for now.
INSERT INTO Product (productCode, productName)
VALUES ('be', 'beer'),
	('bd', 'beer float');

INSERT INTO ComponentCategory (compCatName)
VALUES ('alcoholic beverage'); 

INSERT INTO Component (compName, compCatId)
VALUES ('beer', (
		SELECT compCatId
		FROM ComponentCategory
		WHERE compCatName = 'alcoholic beverage'));

INSERT INTO recipeItem (productCode, compCatId, qty, unitId, compId)
VALUES ('bd', (
		SELECT compCatId
		FROM ComponentCategory
		WHERE compCatName = 'alcoholic beverage'), 12, 1, (
		SELECT compId
		FROM Component
		WHERE compName = 'beer')),
	('bd', 7, 5, 1, NULL),
	('bd', 5, 1, 3, 38),
	('bd', 13, 1, 3, 41),
	('bd', 14, 1, 3, 46),
	('be', (
		SELECT compCatId
		FROM ComponentCategory
		WHERE compCatName = 'alcoholic beverage'), 1, 2, (
		SELECT compId
		FROM Component
		WHERE compName = 'beer'));

INSERT INTO Location (locationName,	locationAddress, locationCity, locationState, locationZip)
VALUES ("Willy's Pub", 'RMC Basement', 'Houston', 'TX', '77005');

INSERT INTO Menu (menuId, menuName)
VALUES (5, 'Beer event');

INSERT INTO MenuItem (menuId, productCode, price)
VALUES ((
		SELECT menuId
		FROM Menu
		WHERE menuName = 'Beer event'), 'be', 5.00),
	((
		SELECT menuId
		FROM Menu
		WHERE menuName = 'Beer event'), 'dk', 1.00),
	((
		SELECT menuId
		FROM Menu
		WHERE menuName = 'Beer event'), 'bd', 7.00);
        
INSERT INTO Event (eventName, eventStart, eventEnd, locationId, menuId)
VALUES ('Beer Debate', '2017-11-09 19:00:00', '2017-11-09 23:00:00', (
		SELECT locationId
		FROM Location
		WHERE locationName = "Willy's Pub"), (
		SELECT menuId
		FROM Menu
		WHERE menuName = 'Beer event'));

#3.0.10 Query 7b
SELECT A.menuName, B.productCode, C.productName, B.price
FROM Menu A RIGHT JOIN MenuItem B ON A.menuId = B.menuId
	LEFT JOIN Product C ON B.productCode = C.productCode
WHERE A.menuName = 'Beer event'
ORDER BY productCode;

#3.0.11 Query 7c
SELECT C.compCatName, D.compName, A.qty, E.unitName
FROM RecipeItem A LEFT JOIN Component D ON A.compId = D.compId, 
	Product B, ComponentCategory C, Unit E
WHERE B.productName = 'beer float' 
	AND A.productCode = B.productCode 
	AND A.compCatId = C.compCatId
    AND A.unitId = E.unitId
ORDER BY A.recipeItemId;

#3.0.12 Query 8a
UPDATE Menu 
SET menuName = 'Beer Debate Menu' 
WHERE menuName = 'Beer event';

#3.0.13 Query 8b
SELECT A.menuName, B.productCode, C.productName, B.price
FROM Menu A RIGHT JOIN MenuItem B ON A.menuId = B.menuId
	LEFT JOIN Product C ON B.productCode = C.productCode
WHERE A.menuName = 'Beer event'
	OR A.menuName = 'Beer Debate Menu'
ORDER BY productCode;


#3.1 Short answer questions
#3.1.1 Short answer 1
Typically we may have the following choices for string in MySQL: 
CHAR, VARCHAR, BLOB(TINYBLOB, BLOB, MEDIUMBLOB, LONGBLOB), and TEXT(TINYTEXT, TEXT, MEDIUMTEXT, LONGTEXT).
BLOB is mostly used for long text in binary form, and it is case insensitive;
TEXT cannnot set default value and it is slower than VARCHAR when running query;
And obviously the string length of our attributes will not be very very larg, so we do not need to consider the larger space types.
For CHAR and VARCHAR, CHAR(n) has a fixed length, which means no matter how long the actual data is, it need n characters to store the data;
while VARCHAR(n) variable storage length, which can save more space when we are not sure about the length of our string data.

So I choose VARCHAR as the data type in our database, where most of the string lengths are different.
And I set a maximum length as 255, which is enough for most daily life easage.
This is also the maximum length of CHAR in case we need to transfer our data to CHAR column for specific reason.

#3.1.2 Short answer 2
I used INTEGER and DOUBLE.
INTEGER is the most common data type for integral type
The range of INTEGER is (-2147483648 to 2147483647), which is suitable for most cases. 
If we cannot be sure that our data is small enough, it is not necessary to use TINYINT, SMALLINT, or MEDIUMINT.
And BIGINT is also not necessary because it cost too much space.

For float type, we can use FLOAT or DOUBLE. FLOAT is 8 bits precision and DOUBLE has a 16 bits precision.
So DOUBLE has a more large range and a smaller bias when we store data. 
Comparing with DECIMAL, DOUBLE is more convenient for float number computation.
And the storage usage is always smaller than DECIMAL type too for the same range of number.


#3.2 Survey
N = 21;
Vanilla, thanks.



