DROP TABLE if exists ItemSold;
DROP TABLE if exists ProductSold;
DROP TABLE if exists Ticket;
DROP TABLE if exists EventAssignment;
DROP TABLE if exists employee;

#3
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

#4
ALTER TABLE Ticket 
ADD COLUMN totalPrice DOUBLE(9, 2);

CREATE VIEW TicketPrice AS
SELECT A.ticketId, SUM(D.price) AS totalPrice
FROM ProductSold A LEFT JOIN Ticket B ON A.ticketId = B.ticketId
		LEFT JOIN Event C ON B.eventId = C.eventId
		LEFT JOIN MenuItem D ON (C.menuId = D.menuId AND A.productCode = D.productCode)
GROUP BY A.ticketId;

SET SQL_SAFE_UPDATES = 0;
UPDATE Ticket A, TicketPrice B SET A.totalPrice = B.totalPrice
WHERE A.ticketId = B.ticketId;

SELECT ticketId, numProducts, totalPrice
FROM Ticket
WHERE ticketId = 170 
	OR ticketId = 1089
ORDER BY ticketId;

#5a
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

#5b
SELECT A.eventId, B.locationName, ROUND((C.eventTotalPrice/C.eventMinutes)*60, 2) AS pricePerHour
FROM Event A LEFT JOIN location B ON A.locationId = B.locationId
		LEFT JOIN EventPrice C ON A.eventId = C.eventId
WHERE B.locationName LIKE '%College%'
ORDER BY pricePerHour DESC
LIMIT 2;

#6a
SELECT A.compName, COUNT(C.compId) AS quantity
FROM Component A LEFT JOIN ComponentCategory B ON A.compCatId = B.compCatId
	LEFT JOIN ItemSold C ON A.compId = C.compId
    LEFT JOIN ProductSold D ON C.productSoldId = D.productSoldId
WHERE B.compCatName = 'topping'
	AND D.productCode IN ('c1', 'c2', 'c3', 'cx', 'd1', 'd2', 'd3', 'dx', 'wc', 'wx')
GROUP BY C.compId
ORDER BY quantity DESC
LIMIT 3;

#6b
SELECT A.compId, A.compName, A.compCatId, B.compCatName
FROM Component A LEFT JOIN ComponentCategory B ON A.compCatId = B.compCatId
WHERE A.compId NOT IN (
	SELECT C.compId
	FROM ItemSold C)
ORDER BY A.compId;

#7a
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


#7b
SELECT A.menuName, B.productCode, C.productName, B.price
FROM Menu A RIGHT JOIN MenuItem B ON A.menuId = B.menuId
	LEFT JOIN Product C ON B.productCode = C.productCode
WHERE A.menuName = 'Beer event'
ORDER BY productCode;

#7c
SELECT C.compCatName, D.compName, A.qty, E.unitName
FROM RecipeItem A LEFT JOIN Component D ON A.compId = D.compId, 
	Product B, ComponentCategory C, Unit E
WHERE B.productName = 'beer float' 
	AND A.productCode = B.productCode 
	AND A.compCatId = C.compCatId
    AND A.unitId = E.unitId
ORDER BY A.recipeItemId;

#8a
UPDATE Menu 
SET menuName = 'Beer Debate Menu' 
WHERE menuName = 'Beer event';

# 8b
SELECT A.menuName, B.productCode, C.productName, B.price
FROM Menu A RIGHT JOIN MenuItem B ON A.menuId = B.menuId
	LEFT JOIN Product C ON B.productCode = C.productCode
WHERE A.menuName = 'Beer event'
	OR A.menuName = 'Beer Debate Menu'
ORDER BY productCode;

#
SELECT A.ticketId, A.productSoldId, A.productCode, D.price
FROM ProductSold A LEFT JOIN Ticket B ON A.ticketId = B.ticketId
		LEFT JOIN Event C ON B.eventId = C.eventId
		LEFT JOIN MenuItem D ON (C.menuId = D.menuId AND A.productCode = D.productCode)
WHERE A.ticketId = 170;


SELECT A.compName, COUNT(C.compId) AS quantity
FROM Component A LEFT JOIN ComponentCategory B ON A.compCatId = B.compCatId
	LEFT JOIN ItemSold C ON A.compId = C.compId
    LEFT JOIN ProductSold D ON C.productSoldId = D.productSoldId
WHERE B.compCatName = 'topping'
	AND D.productCode IN ('c1', 'c2', 'c3', 'cx', 'd1', 'd2', 'd3', 'dx', 'wc')
GROUP BY C.compId
ORDER BY quantity DESC
LIMIT 3;


