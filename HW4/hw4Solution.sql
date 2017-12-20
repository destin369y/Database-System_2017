
# 3.1 Ticket price
# In homework 2, we wrote an update statement to populate the totalPrice field in the ticket table.

# That approach was useful for a one time update. However, we want the totalPrice field to be updated EVERY time we sell a product.

# Write a trigger  named "updateTicketPrice" on the productSold table that updates the totalPrice field in the ticket table for the corresponding ticket when a productSold record is added.
DROP TRIGGER IF EXISTS updateTicketPrice;
DELIMITER //
CREATE TRIGGER updateTicketPrice AFTER INSERT ON productSold 
	FOR EACH ROW 
	BEGIN
		DECLARE thisTicket integer default 0;
		DECLARE thisNumProducts integer default 0;
		DECLARE thisPrice decimal(5,2) default 0;
		# what ticket does this item belong to?
		SELECT ticketId INTO thisTicket FROM productSold ps WHERE NEW.productSoldId =  ps.productSoldId;
		# get the new total
		SELECT SUM(mi.price) totalPrice, numProducts
			INTO thisPrice, thisNumProducts
						FROM ticket tkt
						JOIN event e ON e.eventId = tkt.eventId
						JOIN menu m ON m.menuId = e.menuId
						JOIN productSold ps ON ps.ticketId = tkt.ticketId
						JOIN menuItem mi ON mi.productCode = ps.productCode AND mi.menuId = e.menuId
						WHERE tkt.ticketId = thisTicket
						GROUP BY numProducts;
		# and update the ticket
		UPDATE ticket
		SET totalPrice = thisPrice, numProducts = thisNumProducts+1
		WHERE ticketId = thisTicket;
	END//
DELIMITER ;

# before
SELECT * FROM ticket
WHERE ticketId = 187;

# ticketId, eventId, ticketTime, soldBy, numProducts, totalPrice
187, 5, 2016-11-01 00:14:33, 2, 3, 0.00


INSERT INTO productSold(productCode, ticketId) VALUES ('bs', 187);

# after
SELECT * FROM ticket
WHERE ticketId = 187;

# ticketId, eventId, ticketTime, soldBy, numProducts, totalPrice
187, 5, 2016-11-01 00:14:33, 2, 4, 24.00



# Owl ice cream doesn't want to accidentally over book events.  
# add a "valid" field to the event table, which has a default value of 1. Then add a trigger to the event table that will set the valid value to 0 if a new event overlaps with any existing event.

ALTER TABLE event ADD COLUMN valid INTEGER DEFAULT 0;

# update all current records
UPDATE event SET valid = 1;

# CHECK 
SELECT count(1) FROM event where valid = 0;
# 0

CREATE TABLE eventIssue
(
	newEventId integer not null,
	newEventName varchar(50) not null,
	newStart datetime not null,
	newEnd datetime not null,
	existEventId integer not null,
	existEventName varchar(50) not null,
	existStart datetime not null,
	existEnd datetime not null,
    status varchar(10) not null,
   	PRIMARY KEY(newEventId, existEventId),
    FOREIGN KEY(existEventId) REFERENCES event(eventId)
);


DROP TRIGGER IF EXISTS eventCheckBefore;
DELIMITER //
CREATE TRIGGER eventCheckBefore BEFORE INSERT ON event 
FOR EACH ROW 
BEGIN
	# if there's a conflict, make this event invalid
 	IF EXISTS (SELECT * FROM event WHERE STR_TO_DATE(New.eventStart, '%Y-%m-%d %k:%i:%s') BETWEEN eventStart AND eventEnd OR STR_TO_DATE(New.eventEnd, '%Y-%m-%d %k:%i:%s') BETWEEN eventStart AND eventEnd ) THEN
		SET NEW.valid = 0; 
 END IF;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS eventCheckAfter;
DELIMITER //
CREATE TRIGGER eventCheckAfter AFTER INSERT ON event 
FOR EACH ROW 
BEGIN
	# are there any events that conflict with the new one?
 	IF EXISTS (SELECT * FROM event 
			WHERE (STR_TO_DATE(New.eventStart, '%Y-%m-%d %k:%i:%s') BETWEEN eventStart AND eventEnd 
					OR STR_TO_DATE(New.eventEnd, '%Y-%m-%d %k:%i:%s') BETWEEN eventStart AND eventEnd)
				AND eventId != New.eventId ) THEN
	# record which events conflict in the eventIssue table
    INSERT INTO eventIssue(newEventId, newEventName, newStart, newEnd, existEventId, existEventName, existStart, existEnd, status)
        SELECT NEW.eventId, NEW.eventName, NEW.eventStart, NEW.eventEnd, eventId, eventName, eventStart, eventEnd, 'overlap' 
			FROM event WHERE STR_TO_DATE(New.eventStart, '%Y-%m-%d %k:%i:%s') BETWEEN eventStart AND eventEnd AND eventId != New.eventId;
 END IF;
 # check for travel issues
 IF EXISTS (SELECT * FROM event 
			WHERE (ABS(TIMESTAMPDIFF(MINUTE,NEW.eventEnd, eventStart)) <= 30 
					OR ABS(TIMESTAMPDIFF(MINUTE,NEW.eventStart, eventEnd)) <= 30)
				AND eventId != New.eventId ) THEN
	# record which events have travel issues
    INSERT INTO eventIssue(newEventId, newEventName, newStart, newEnd, existEventId, existEventName, existStart, existEnd, status)
        SELECT NEW.eventId, NEW.eventName, NEW.eventStart, NEW.eventEnd, eventId, eventName, eventStart, eventEnd, 'travel' 
			FROM event WHERE (ABS(TIMESTAMPDIFF(MINUTE,NEW.eventEnd, eventStart)) <= 30 
					OR ABS(TIMESTAMPDIFF(MINUTE,NEW.eventStart, eventEnd)) <= 30)
				AND eventId != New.eventId ;
 END IF;
END//
DELIMITER ;

# a valid solution could also just consist of an AFTER INSERT trigger that updates the valid flag on the new event correctly

# make sure the eventIssue table is empty before we start
DELETE FROM eventIssue;

# add some new events
INSERT INTO event(eventName, eventStart, eventEnd, locationId, menuId) VALUES
('Mid afternoon tea',  '2017-03-09 14:15:00',  '2017-03-09 14:45:00', 24, 1),
('Dessert Bar',  '2017-01-19 13:30:00',  '2017-01-19 16:00:00', 25, 4),
('Ice cream for lunch',  '2017-05-06 11:00:00',  '2017-05-06 16:00:00', 17, 3);

SELECT * FROM event WHERE eventName in ('Dessert Bar', 'Ice cream for lunch', 'Mid afternoon tea') ORDER BY eventName;
# eventId, eventName, eventStart, eventEnd, locationId, menuId, valid
64, Dessert Bar, 2017-01-19 13:30:00, 2017-01-19 16:00:00, 25, 4, 0
65, Ice cream for lunch, 2017-05-06 11:00:00, 2017-05-06 16:00:00, 17, 3, 1
63, Mid afternoon tea, 2017-03-09 14:15:00, 2017-03-09 14:45:00, 24, 1, 1

select * from eventIssue ORDER BY newEventName;
# newEventId, newEventName, newStart, newEnd, existEventId, existEventName, existStart, existEnd, status
64, Dessert Bar, 2017-01-19 13:30:00, 2017-01-19 16:00:00, 1, GSA Coffee Break, 2017-01-19 13:00:00, 2017-01-19 15:30:00, overlap
63, Mid afternoon tea, 2017-03-09 14:15:00, 2017-03-09 14:45:00, 4, GSA Coffee Break, 2017-03-09 15:00:00, 2017-03-09 16:30:00, travel


### 3.3 Restock

DROP TABLE IF EXISTS eventTask;
CREATE TABLE eventTask
(
	eventId integer not null,
    taskType varchar(20) not null,
    compCatId integer null,
    qty integer null,
    taskTime datetime null,
   	PRIMARY KEY(eventId, taskType, taskTime),
    FOREIGN KEY(eventId) REFERENCES event(eventId),
    FOREIGN KEY(compCatId) REFERENCES componentCategory(compCatId)
);

# inventory level
DROP TABLE IF EXISTS invLevel;
CREATE TABLE invLevel
(
    compCatId integer NOT NULL,
    restockQty integer NOT NULL,
   	PRIMARY KEY(compCatId, restockQty),
    FOREIGN KEY(compCatId) REFERENCES componentCategory(compCatId)
);

INSERT INTO invLevel(compCatId, restockQty) VALUES
(5, 200), # paper products
(6, 50), # plastic products
(13, 50), # spoons
(14, 50), # cups
(16, 300); # straws

DROP FUNCTION IF EXISTS getEventId ;
DELIMITER //
CREATE FUNCTION getEventId(thisProductSoldId INTEGER) RETURNS INTEGER
BEGIN
	# returns the event id for the event where the product was sold
  DECLARE thisEventId INTEGER DEFAULT 0;

    SET @thisEventId = (SELECT evt.eventId 
			            FROM productSold ps  
			            JOIN ticket tkt ON tkt.ticketId = ps.ticketId
			            JOIN event evt on evt.eventId = tkt.eventId
			            WHERE ps.productSoldId = thisProductSoldId);
  RETURN @thisEventId;
END;//


SELECT getEventId(3);
# 1
SELECT getEventId(6471);
# 41

DROP TRIGGER IF EXISTS timeToRestock ;
DELIMITER //
CREATE TRIGGER timeToRestock AFTER INSERT ON itemSold 
FOR EACH ROW 
BEGIN
    DECLARE thisCompCatId integer default 0;
    DECLARE thisRestockQty integer default 0;
    DECLARE thisNumSold integer default 0;
    DECLARE thisEventId integer default 0;
    DECLARE lastRestock datetime;
    DECLARE lastTicketTime datetime;
    DECLARE thisTicketTime datetime;
    
    #temp code for inserts
    SET @thisEventId = getEventId(NEW.productSoldId);
    
    # what category of item is this?
    SET @thisCompCatId = (SELECT c.compCatId FROM component c WHERE c.compId = NEW.compId);
    #INSERT INTO eventTask(eventId, taskType, compCatId, qty, taskTime) VALUES
    #            (@thisEventId, 'compCat', @thisCompCatId, 0, @lastRestock);     
    # do we care about this category?
    SET @thisRestockQty = (SELECT restockQty FROM invLevel WHERE compCatId = @thisCompCatId);
    # check if it's valid
    IF NOT ISNULL(@thisRestockQty) THEN
        # get the current event id just once
        SET @thisEventId = getEventId(NEW.productSoldId);
        # get the timestamp for the current ticket, we care about sales before this ticket time
        SET @thisTicketTime = (SELECT ticketTime FROM productSold ps JOIN ticket t on ps.ticketId = t.ticketId WHERE ps.productSoldId = New.productSoldId);
        #INSERT INTO eventTask(eventId, taskType, compCatId, qty, taskTime) VALUES
         #       (@thisEventId, 'thisTicketTime', @thisCompCatId, 0, @thisTicketTime);       

        # do we need to restock?
        # check to see how many items have been sold since the last restock eventTask
        # ideally, there would be a 'restocked' event that confirms when the restocking was actually performed
        # for now, just assume it's been done

        # what was the time of the last restock event task?
        SET @lastRestock = (    SELECT  MAX(taskTime)
                                FROM eventTask i 
                                WHERE i.eventId = @thisEventId AND i.compCatId = @thisCompCatId AND taskType = 'restock');   
        #INSERT INTO eventTask(eventId, taskType, compCatId, qty, taskTime) VALUES
        #            (@thisEventId, 'maxLastRestock', @thisCompCatId, 0, @lastRestock);  
        # default restock time is the start of the event
        IF ISNULL(@lastRestock) THEN 
            SET @lastRestock = (SELECT eventStart
                                FROM event e
                                WHERE e.eventId = @thisEventId);
            #log the last restock event
            #INSERT INTO eventTask(eventId, taskType, compCatId, qty, taskTime) VALUES
             #           (@thisEventId, 'lastRestock', @thisCompCatId, 0, @lastRestock);     
        END IF;
        # check the current inventory level for this event
        SET @thisNumSold = (    SELECT SUM(i.qty) 
                                FROM itemSold i 
                                JOIN component c ON c.compId = i.compId
                                JOIN productSold ps ON ps.productSoldId = i.productSoldId
                                JOIN ticket tkt ON tkt.ticketId = ps.ticketID
                                JOIN event evt ON evt.eventId = tkt.eventId
                                    AND evt.eventId = @thisEventId 
                                WHERE c.compCatId = @thisCompCatId 
                                    AND tkt.ticketTime > @lastRestock
                                    AND tkt.ticketTime < @thisTicketTime);
        #INSERT INTO eventTask(eventId, taskType, compCatId, qty, taskTime) VALUES
        #            (@thisEventId, 'numSold', @thisCompCatId, @thisNumSold, @thisTicketTime);       

        # and see if we still need to restock
            IF @thisNumSold >=  @thisRestockQty THEN
                # use the ticket timestamp
                #SET @lastTicketTime = (SELECT ticketTime FROM ticket WHERE  );
                # restock
                INSERT INTO eventTask(eventId, taskType, compCatId, qty, taskTime) VALUES
                    (@thisEventId, 'restock', @thisCompCatId, @thisRestockQty, @thisTicketTime);
        END IF;
    END IF;
END//



# give away an extra cup with this product
INSERT INTO itemSold(productSoldId, compId, qty, unitId) VALUES 
    (6471, 48, 1, 3), 
    (6683, 46, 1, 3), 
    (6726, 46, 1, 3), 
    (7529, 48, 1, 3); 

SELECT * FROM eventTask;
# eventId, taskType, compCatId, qty, taskTime
41, restock, 14, 50, 2017-03-24 16:14:02
41, restock, 14, 50, 2017-03-24 22:40:58

# extra tests
truncate table eventTask;
# insert an item we don't track at this time
INSERT INTO itemSold(productSoldId, compId, qty, unitId) VALUES 
    (6471, 48, 1, 3);
SELECT * FROM eventTask;
# no rows

# now try something from componentCategory 5
# add an itemSold to these productSold tickets
INSERT INTO itemSold(productSoldId, compId, qty, unitId) VALUES 
    (5438, 37, 1, 3), # too soon
    (6266, 37, 1, 3), # restock
    (6186,37, 1, 3); # too soon
# eventId, taskType, compCatId, qty, taskTime
40, restock, 5, 200, 2017-03-10 22:51:44

# add an itemSold to these productSold tickets
INSERT INTO itemSold(productSoldId, compId, qty, unitId) VALUES 
    (2932, 37, 1, 3), # too soon
    (3340, 37, 1, 3); # restock
# eventId, taskType, compCatId, qty, taskTime
25, restock, 5, 200, 2017-02-20 15:34:28

# now try something from componentCategory 13
# add an itemSold to these productSold tickets
INSERT INTO itemSold(productSoldId, compId, qty, unitId) VALUES 
    (475, 40, 1, 3), # restock
    (490, 40, 1, 3), # too soon
    (741, 40, 1, 3); # restock
# eventId, taskType, compCatId, qty, taskTime
5, restock, 13, 50, 2016-11-01 00:14:33
5, restock, 13, 50, 2016-11-01 01:56:48

# now try something from componentCategory 16
# add an itemSold to these productSold tickets
INSERT INTO itemSold(productSoldId, compId, qty, unitId) VALUES 
    (7697, 42, 1, 3), # restock
    (7695, 42, 1, 3), # too soon
    (7699, 42, 1, 3); # restock
# eventId, taskType, compCatId, qty, taskTime
41, restock, 16, 300, 2017-03-24 23:06:51

# Rice wants the students to be healthier and decides to only let dessert food trucks be on campus for a maximum of N days in row. 
# Which events would have to be rescheduled?
# Write a stored procedure name eventsToCancel that populates a table with a list of events that have to be rescheduled.
# Return the results for N = 3 and N = 4
DROP TABLE IF EXISTS badEvent;
CREATE TABLE IF NOT EXISTS badEvent
( eventId INTEGER,
  eventName VARCHAR(100),
  eventStart DATETIME
);


DROP PROCEDURE IF EXISTS eventsToCancel;
delimiter //
create procedure eventsToCancel (IN thisDayLimit int)
BEGIN
    DECLARE thisEventId integer default 1;
    DECLARE thisStartDate date;
    DECLARE prevStartDate date;
    DECLARE dateDelta integer default 0;
    DECLARE numDaysInARow integer default 0;
    DECLARE weKnowAlready integer default 0;
    DECLARE done integer default 0;
    # set up the cursor for the events 
    DECLARE eventCursor CURSOR FOR SELECT eventId, DATE(eventStart) FROM event ORDER BY eventStart;
    # declare not found handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    # empty the temporary table
    TRUNCATE TABLE badEvent;

    SET numDaysInARow = 0;

    # open the cursor
    OPEN eventCursor;
    eventLoop:
        LOOP
        # set the previous date
        SET prevStartDate = thisStartDate;
        
        # get the next event info
        FETCH eventCursor INTO thisEventId, thisStartDate;
        # check for entries
        IF done THEN
            LEAVE eventLoop;
        END IF;

        # have we already excluded this event?
        SELECT count(1) INTO weKnowAlready FROM badevent WHERE eventId = thisEventId;
        IF weKnowAlready = 0 THEN
        # new event, keep going
            # is this the first event? 
            IF numDaysInARow = 0 THEN
                SET numDaysInARow = 1;
            ELSE 
                # was there a gap?
                SET dateDelta = DATEDIFF(thisStartDate, prevStartDate);
                # how big was the gap?
                IF dateDelta > 1 THEN
                    # big enough gap, reset the counter
                    SET numDaysInARow = 1;
                ELSEIF dateDelta = 1 THEN
                    # if it's 1 day, increment our counter
                    SET numDaysInARow = numDaysInARow + 1;
                    #SELECT prevStartDate, thisStartDate, dateDelta;
                END IF;
            END IF;
            # Did we go over the number of allowed sequential days?
            IF numDaysInARow > thisDayLimit THEN
                # exclude all events that occur on this day
                INSERT INTO badEvent(eventId, eventName, eventStart) SELECT eventId, eventName, eventStart from event where DATE(eventStart) = DATE(thisStartDate);
                # reset the counter since we're going to exclude this day
                SET numDaysInARow = 0;
            END IF;
        END IF; 
    END LOOP eventLoop;
    CLOSE eventCursor; 
END //
delimiter ;

Call eventsToCancel(3);


SELECT * FROM badEvent ORDER BY eventName;

# thisDayLimit
3


SELECT * FROM badEvent ORDER BY eventName;
# eventId, eventName, eventStart, numDaysInARow
20, GSA Study Break, 2017-04-15 19:00:00, 3
15, Hanszen College Study Break, 2017-04-06 19:00:00, 3
61, Intramural Sport Xtravaganza, 2017-09-16 10:30:00, 3
19, McMurty College Study Break, 2017-04-15 14:00:00, 3
62, Will Rice College Study Break, 2017-04-10 20:00:00, 3


Call eventsToCancel(4);
# eventId, eventName, eventStart, numDaysInARow
13, Brown College Study Break, 2017-04-07 19:00:00, 4
58, Sid Rich College Study Break, 2017-04-16 20:00:00, 4
