# Assignment 3 solutions

DROP TABLE IF EXISTS itemSold;
DROP TABLE IF EXISTS productSold;
DROP TABLE IF EXISTS menuItem;
DROP TABLE IF EXISTS eventAssignment;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS recipeItem;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS component;
DROP TABLE IF EXISTS unit;
DROP TABLE IF EXISTS componentCategory;

CREATE TABLE IF NOT EXISTS product
(
	productCode char(3),
	productName varchar(25) NOT NULL,
	PRIMARY KEY(productCode),
	UNIQUE(productName)
);


CREATE TABLE IF NOT EXISTS componentCategory
(
	compCatId INTEGER AUTO_INCREMENT, 
	compCatName varchar(30) NOT NULL,
	PRIMARY KEY(compCatId),
	UNIQUE(compCatName)
);

CREATE TABLE IF NOT EXISTS component
(
	compId INTEGER AUTO_INCREMENT, 
	compName varchar(30) NOT NULL,
	compCatId INTEGER NULL,
	PRIMARY KEY(compId),
	FOREIGN KEY(compCatId) REFERENCES componentCategory(compCatId)
);

CREATE TABLE IF NOT EXISTS unit
(
	unitId integer AUTO_INCREMENT,
	unitName varchar(10) NOT NULL,
	PRIMARY KEY(unitId),
	UNIQUE (unitName)
);

CREATE TABLE IF NOT EXISTS recipeItem
(
	recipeItemId integer AUTO_INCREMENT,
	productCode char(3) NOT NULL,
	compCatId integer NOT NULL,
	qty float NOT NULL,
	unitId integer NOT NULL,
	compId integer NULL,
	PRIMARY KEY(recipeItemId),
	FOREIGN KEY(productCode) REFERENCES product(productCode),
	FOREIGN KEY(compCatId) REFERENCES componentCategory(compCatId),
	FOREIGN KEY(unitId) REFERENCES unit(unitId),
	UNIQUE(productCode,compCatId,compId)
);

CREATE TABLE IF NOT EXISTS location
(
	locationId integer AUTO_INCREMENT,
	locationName varchar(50) NOT NULL,
	locationAddress varchar(100) NULL,
	locationCity varchar(50) NULL,
	locationState char(2) NULL,
	locationZip char(5) NULL,
	PRIMARY KEY (locationId)
);


CREATE TABLE IF NOT EXISTS menu
(
	menuId integer AUTO_INCREMENT,
	menuName char(25),
	PRIMARY KEY(menuId),
	UNIQUE (menuName)
);

CREATE TABLE IF NOT EXISTS menuItem
(
	menuItemId integer AUTO_INCREMENT,
	menuId integer NOT NULL,
	productCode char(3) NOT NULL,
	price decimal (5,2) NOT NULL,
	PRIMARY KEY(menuItemId),
	UNIQUE(menuId, productCode),
	FOREIGN KEY(productCode) REFERENCES product(productCode)
);

CREATE TABLE IF NOT EXISTS event
(
	eventId INTEGER AUTO_INCREMENT,
	eventName VARCHAR(100) NOT NULL,
	eventStart DATETIME NULL,
	eventEnd DATETIME NULL,
	locationId INTEGER NULL,
	menuId INTEGER NULL,
	PRIMARY KEY (eventId),
	FOREIGN KEY(locationId) REFERENCES location(locationId),
	FOREIGN KEY(menuId) REFERENCES menu(menuId)
);

CREATE TABLE IF NOT EXISTS employee
(
	employeeId integer AUTO_INCREMENT,
	firstName varchar(50) NOT NULL,
	lastName varchar(50) NOT NULL,
	DOB date NOT NULL,
	phone varchar(12) NULL,
	PRIMARY KEY(employeeId)
);


CREATE TABLE IF NOT EXISTS eventAssignment
(
	eventAssignmentId integer AUTO_INCREMENT,
	eventId integer NOT NULL,
	employeeId integer NOT NULL,
	PRIMARY KEY(eventAssignmentId),
	FOREIGN KEY(eventId) REFERENCES event(eventId),
	FOREIGN KEY(employeeId) REFERENCES employee(employeeId)
);

CREATE TABLE IF NOT EXISTS ticket
(
	ticketId integer AUTO_INCREMENT,
	eventId integer NOT NULL,
	ticketTime dateTime NOT NULL,
	soldBy integer NOT NULL,
	numProducts integer NOT NULL,
	PRIMARY KEY (ticketId),
	FOREIGN KEY(eventId) REFERENCES event(eventId),
	FOREIGN KEY(soldBy) REFERENCES employee(employeeid)
);

CREATE TABLE IF NOT EXISTS productSold
(
	productSoldId integer AUTO_INCREMENT,
	productCode char(3) NOT NULL,
	ticketId integer NOT NULL,
	PRIMARY KEY(productSoldId),
	FOREIGN KEY(productCode) REFERENCES product(productCode),
	FOREIGN KEY(ticketId) REFERENCES ticket(ticketId)
);


CREATE TABLE IF NOT EXISTS itemSold
(
	itemSoldId integer AUTO_INCREMENT,
	productSoldId integer NOT NULL,
	compId integer NOT NULL,
	qty float NOT NULL,
	unitId integer NOT NULL,
	PRIMARY KEY(itemSoldId),
	FOREIGN KEY(productSoldId) REFERENCES productSold(productSoldId),
	FOREIGN KEY(compId) REFERENCES component(compId),
	FOREIGN KEY(unitId) REFERENCES unit(unitId)
);

LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/product.txt' INTO TABLE product fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/componentCategory.txt' INTO TABLE componentCategory fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/component.txt' INTO TABLE component fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/unit.txt' INTO TABLE unit fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/recipeItem.txt' INTO TABLE recipeItem fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/location.txt' INTO TABLE location fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/menu.txt' INTO TABLE menu fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/menuItem.txt' INTO TABLE menuItem fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/eventV3.tsv' INTO TABLE event fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/employee.txt' INTO TABLE employee fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/eventAssignment.txt' INTO TABLE eventAssignment fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/ticket.txt' INTO TABLE ticket fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/productSold.txt' INTO TABLE productSold fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/Users/risamyers/Documents/School/Rice/533/assignment/3iceDB/data/itemSold.txt' INTO TABLE itemSold fields terminated by '\t'  escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n' IGNORE 1 LINES;

# Query 1
# How many products are there? Return an integer count of unique product codes in a column named "numProducts".
SELECT count(1) numProducts
FROM product;

# numProducts
27


# Query 2
# What is the recipe for a "turtle sundae"? Return the component category name, the component name, the quantity, and the unit name. Order by recipeItemId.
SELECT cc.compCatName, c.compName, r.qty, u.unitName
FROM recipeItem r
JOIN product p ON p.productCode = r.productCode
JOIN componentcategory cc ON r.compCatId = cc.compCatid
LEFT OUTER JOIN component c ON r.compId = c.compid
JOIN unit u ON u.unitId = r.unitId
WHERE productName like 'turtle sundae'
ORDER BY r.recipeItemId;

ice cream base		8	ounce
topping	hot fudge	1.5	ounce
topping	caramel	1.5	ounce
topping	pecans	1.5	ounce
topping	whipped cream	1.5	ounce
fruit	stem cherry	1	item
cup	16 oz dish	1	item
spoon	short spoon	1	item
paper product	tall napkin	1	item

# Query 3 

# Show the number of cones (of any size, including waffle cones) sold at each event that took place at Valhalla.
# List each event and the total number of cones sold. Order by the event start date/time.
SELECT e.eventName, e.eventStart, count(productCode) total
FROM productSold ps
JOIN ticket t on t.ticketId = ps.ticketId
JOIN event e on e.eventId = t.eventId
JOIN location l on l.locationId = e.locationId
WHERE ps.productCode in ('wc', 'c1', 'c2', 'c3') AND l.locationname = 'Valhalla'
GROUP BY eventName,eventStart
ORDER BY e.eventStart;


# eventName, eventStart, total
Valhalloween, 2016-10-31 19:00:00, 145
GSA Culture Night, 2017-03-10 15:30:00, 145
GSA Spring Picnic, 2017-03-24 15:30:00, 366
GSA Picnic, 2017-03-31 19:00:00, 54
St. Arnolds Tap Takeover, 2017-05-03 16:00:00, 70
Stone Brewery Tap Takeover, 2017-05-11 16:00:00, 82
Karbach Tap Takeover, 2017-05-17 16:00:00, 29
Magic Hat Tap Takeover, 2017-05-24 16:00:00, 22
Valhalla Food Truck Night, 2017-06-15 16:00:00, 70
Orientation Picnic, 2017-08-12 11:30:00, 261
GSA Fall Picnic, 2017-09-15 15:30:00, 203


# Query 4
/*
Compute the cost of each ticket.

Add a field named "totalPrice" to the ticket table and populate it.
*/

ALTER TABLE ticket ADD totalPrice decimal(5,2);


UPDATE ticket tgt, (SELECT tkt.ticketId, SUM(mi.price) totalPrice
						FROM ticket tkt
						JOIN event e ON e.eventId = tkt.eventId
						JOIN menu m ON m.menuId = e.menuId
						JOIN productSold ps ON ps.ticketId = tkt.ticketId
						JOIN menuItem mi ON mi.productCode = ps.productCode AND mi.menuId = e.menuId
                        GROUP BY tkt.ticketId) src
SET tgt.totalPrice = src.totalPrice WHERE tgt.ticketId = src.ticketId;

# To check your results, return the ticketId, numProducts and totalPrice for tickets 170 and 1089. Sort by ticketId.  
SELECT ticketId, numProducts, totalPrice FROM ticket
WHERE ticketId IN (170, 1089) 
ORDER BY ticketId;

# ticketId, numProducts, totalPrice
170, 4, 22.00
1089, 7, 27.50

# Query 5a
/*
We want to maximize sales and work the most valuable events. To do that, we need to know which events generate the most money per hour.

List the top 10 events by sales per hour. List the eventId, eventName, locationName and price per hour, rounded to the nearest penny. List in order from highest price per hour to lowest.

To determine the number of minutes between 2 timestamps, you may use:
TIME_TO_SEC(TIMEDIFF(endTime,startTime))/60
*/
CREATE OR REPLACE VIEW eventDurations AS
	SELECT e.*, l.locationName, TIME_TO_SEC(TIMEDIFF(eventEnd,eventStart))/3600 eventHours
	FROM event e
	JOIN location l ON e.locationId = l.locationId;

CREATE OR REPLACE VIEW eventSales AS
	SELECT e.eventId, SUM(totalPrice) totalSales
	FROM event e
    JOIN ticket t on t.eventId = e.eventId
    GROUP BY e.eventId;

SELECT es.eventId, ed.eventName, ed.locationName, ROUND(es.totalSales/ed.eventHours, 2) pricePerHour
FROM eventDurations ed
JOIN eventSales es ON ed.eventId = es.eventId
JOIN event e on e.eventId = es.eventId
ORDER BY es.totalSales/ed.eventHours desc  LIMIT 10;


# eventId, eventName, locationName, pricePerHour
49, Orientation Picnic, Valhalla, 1256.33
41, GSA Spring Picnic, Valhalla, 715.56
40, GSA Culture Night, Valhalla, 584.06
25, Data Science Conference, Duncan Hall, 541.63
5, Valhalloween, Valhalla, 524.36
20, GSA Study Break, Valhalla, 493.33
27, Valhalla Food Truck Night, Valhalla, 396.90
42, GSA Fall Picnic, Valhalla, 388.06
8, Commencement, Founders Court, 368.58
55, Football Game, Rice Stadium, 324.44

# Query 5b
/*
Now restrict the query to the colleges. Which are the top 2 colleges for sales per hour?
Show the eventId, locationName and price per hour, rounded to the nearest penny. Sory by price per hour.
*/
SELECT es.eventId, ed.locationName, ROUND(es.totalSales/ed.eventHours,2) pricePerHour
FROM eventDurations ed
JOIN eventSales es ON ed.eventId = es.eventId
WHERE locationName IN ('Baker College',	 'Brown College',  'Duncan College', 'Hanszen College',
	 	'Jones College', 'Lovett College', 'Martel College', 'McMurtry College',
		'Sid Richardson College', 'Weiss College', 	'Will Rice College')
ORDER BY ROUND(es.totalSales/ed.eventHours,2) DESC LIMIT 2;

# eventId, locationName, pricePerHour
59, Weiss College, 258.86
12, Baker College, 250.50

/*
Query 6a

In order to stock inventory, it's important to know the most popular items.

Which 3 toppings are ordered most frequently on ice cream cones, dishes and waffle cones (including extra toppings)?
You may use product codes in your query.

List the component name and quantity. Sort by quantity, descending.
*/
SELECT compName, COUNT(1) qty
FROM productSold p
JOIN itemSold i ON i.productSoldId = p.productSoldId
JOIN component c ON c.compId = i.compId
JOIN componentCategory cc ON cc.compCatId = c.compCatId
WHERE productCode in ('c1', 'c2', 'c3', 'cx', 'd1', 'd2','d3', 'wc', 'dx')  AND cc.compCatName = 'topping'
GROUP BY compName 
ORDER BY qty DESC LIMIT 3;

# compName, qty
vanilla, 1156
pecans, 403
thin mint, 392


# Query 6b
/*
Similarly, we want to stop stocking items that do not get sold. Which components are not used?

List the component id, name and category. Sory by component id.
*/
SELECT compId, compName, compCatName 
FROM component c
JOIN componentcategory cc ON c.compCatId = cc.compCatId
WHERE compId NOT IN (SELECT DISTINCT compId FROM itemsold)
ORDER BY compid;

# compId, compName, compCatName
2, cherry dip, topping
9, peanuts, topping
13, cookie dough, topping
18, pineapple, topping
36, cookie, baked good
39, popsicle stick, other
69, pint, other


# Query 7a
/*
The food truck's budget is pretty small. Consequently, there is no money available to hire a web developer to create 
a product builder front-end. Instead, we will write SQL code to add elements to the database.

A long standing Rice Undergraduate tradition is "Beer Debates." This year there is a new twist: serving beer floats. 

Write the SQL code to add a new event "Beer Debate", held at "Willy's Pub". Willy's Pub's address is "RMC Basement". 
The Beer debate will be held on November 9, 2017, from 7 - 11 PM.  The event will have a new, restricted menu, named "Beer event", with menuId 5. The only  products that will be sold are Beer (product code 'be'), existing drinks, and beer floats (product code 'bd' for beer debate). Beer will cost $5 and a beer float $7. Regular drinks will cost $1.

Beer and beer floats fall into the category "alcoholic beverage". 

A float consists of 12 ounces of beer, 5 ounces of ice cream and is sold with a tall napkin and a long spoon. 
It is served in a 20 ounce cup.

When adding the recipe items, you may only use product and component names and categories, not ids for the newly 
added items. Use may use compId, compCatId, unitId, etc. for existing items. 
*/

INSERT INTO product VALUES
('be', 'beer'), 
('bd', 'beer float');

INSERT INTO componentCategory(compCatName) VALUES
('alcoholic beverage');

INSERT INTO component(compName, compCatId)
SELECT 'beer', compCatId
FROM componentCategory 
WHERE compCatName = 'alcoholic beverage';

INSERT INTO recipeItem(productCode, compCatId, qty, unitId, compId)
SELECT 'bd', (SELECT compCatId FROM componentCategory WHERE compCatName = 'alcoholic beverage'),
        12, 1, (SELECT compId FROM component WHERE compName = 'beer');

INSERT INTO recipeItem(productCode, compCatId, qty, unitId, compId) VALUES
	( 'bd', 7, 5, 1, null),	# ice cream
	( 'bd', 13,	1, 3, 41), # long spoon
	( 'bd', 5,	1, 3, 38), # tall napkin
	( 'bd', 14, 1, 3, 46); # 20 oz cup

INSERT INTO menu(menuId, menuName) VALUES (5, 'Beer event');  
INSERT INTO menuItem(menuId, productCode, price) VALUES 
    (5, 'be', 5.00),  
    (5, 'bd', 7.00),
    (5, 'dk', 1.00);

INSERT INTO location(locationName, locationAddress, locationCity, locationState, locationZip) VALUES
( 'Willy''s Pub', 'RMC Basement', 'Houston', 'TX', '77005');

INSERT INTO event(eventName, eventStart, eventEnd, locationId, menuId) VALUES
 ('Beer Debate', '2017-11-09 19:00:00', '2017-11-09 23:00:00', 
      (SELECT locationId FROM location WHERE locationName = 'Willy''s Pub'), 5);

# Query 7b
# Write a query to show the menu items on the new menu. For each item, list the menu name, productCode, productName and price. Sort by product code.

SELECT m.menuId, m.menuName, p.productCode, p.productName, mi.price
FROM menu m, menuItem mi, product p
WHERE m.menuId = mi.menuId AND mi.productCode = p.productCode
    AND m.menuName = 'Beer event'
ORDER by productCode;

# menuId, menuName, productCode, productName, price
5, Beer event, bd, beer float, 7.00
5, Beer event, be, beer, 5.00
5, Beer event, dk, drink, 1.00


# Query 7c
# Run your query from #2 to show the recipe for a beer float.
SELECT cc.compCatName, c.compName, r.qty, u.unitName
FROM recipeItem r
JOIN product p ON p.productCode = r.productCode
JOIN componentcategory cc ON r.compCatId = cc.compCatid
LEFT OUTER JOIN component c ON r.compId = c.compid
JOIN unit u ON u.unitId = r.unitId
WHERE productName = 'Beer Float'
ORDER BY r.recipeItemId;

# compCatName, compName, qty, unitName
alcoholic beverage, beer, 12, ounce
ice cream base, , 5, ounce
spoon, long spoon, 1, item
paper product, tall napkin, 1, item
cup, 20 oz cup, 1, item


# Query 8a

# In hindsight, 'Beer event' is too general of a menu name. 
# Change the menu name to 'Beer Debate Menu'. Access the existing record by the menu name, not the id.
UPDATE menu 
SET menuName = 'Beer Debate Menu'
WHERE menuName = 'Beer event';

# Query 8b
# Rerun your query from 7b, but showing menu items for menus named 'Beer event' and 'Beer Debate Menu'.
SELECT m.menuId, m.menuName, p.productCode, p.productName, mi.price
FROM menu m, menuItem mi, product p
WHERE m.menuId = mi.menuId AND mi.productCode = p.productCode
    AND m.menuName IN ('Beer event', 'Beer Debate Menu')
ORDER by productCode;
# menuId, menuName, productCode, productName, price
5, Beer Debate Menu, bd, beer float, 7.00
5, Beer Debate Menu, be, beer, 5.00
5, Beer Debate Menu, dk, drink, 1.00



