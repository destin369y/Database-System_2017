SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS location;

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


INSERT INTO location VALUES ('1', 'Valhalla', '6100 Main Street', 'Houston', 'TX', '77005');
INSERT INTO menu VALUES ('1', 'Full menu');

DROP TABLE IF EXISTS EventByDate;
CREATE TABLE IF NOT EXISTS EventByDate (
	 neweventId INTEGER auto_increment,
     eventId INTEGER NOT NULL,
	 eventName VARCHAR(100) NULL,
	 eventDate DATETIME NULL,
     PRIMARY KEY(neweventId)
);
INSERT INTO EventByDate(eventId,eventName,eventDate)
SELECT  eventId,eventName,date(eventStart) FROM event 
ORDER BY eventStart;

# T1
truncate event;

insert into event values (1, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');
insert into event values (2, 'GSA Coffee Break', '2016-01-02 12:00:00', '2016-01-02 15:30:00', '1', '1');
insert into event values (3, 'GSA Coffee Break', '2016-01-03 12:00:00', '2016-01-03 15:30:00', '1', '1');
insert into event values (4, 'GSA Coffee Break', '2016-01-04 12:00:00', '2016-01-04 15:30:00', '1', '1');

insert into event values (5, 'GSA Coffee Break', '2016-01-06 12:00:00', '2016-01-06 15:30:00', '1', '1');
insert into event values (6, 'GSA Coffee Break', '2016-01-07 12:00:00', '2016-01-07 15:30:00', '1', '1');
insert into event values (7, 'GSA Coffee Break', '2016-01-08 12:00:00', '2016-01-08 15:30:00', '1', '1');
insert into event values (8, 'GSA Coffee Break', '2016-01-09 12:00:00', '2016-01-09 15:30:00', '1', '1');

insert into event values (9, 'GSA Coffee Break', '2016-03-01 12:00:00', '2016-03-01 15:30:00', '1', '1');
insert into event values (10, 'GSA Coffee Break', '2016-03-02 12:00:00', '2016-03-02 15:30:00', '1', '1');
insert into event values (11, 'GSA Coffee Break', '2016-03-03 12:00:00', '2016-03-03 15:30:00', '1', '1');
insert into event values (12, 'GSA Coffee Break', '2016-03-04 12:00:00', '2016-03-04 15:30:00', '1', '1');
insert into event values (13, 'GSA Coffee Break', '2016-03-05 12:00:00', '2016-03-05 15:30:00', '1', '1');

insert into event values (14, 'GSA Coffee Break', '2016-04-01 12:00:00', '2016-04-01 15:30:00', '1', '1');
insert into event values (15, 'GSA Coffee Break', '2016-04-02 12:00:00', '2016-04-02 15:30:00', '1', '1');
insert into event values (16, 'GSA Coffee Break', '2016-04-03 12:00:00', '2016-04-03 15:30:00', '1', '1');
insert into event values (17, 'GSA Coffee Break', '2016-04-04 12:00:00', '2016-04-04 15:30:00', '1', '1');
insert into event values (18, 'GSA Coffee Break', '2016-04-05 12:00:00', '2016-04-05 15:30:00', '1', '1');

insert into event values (19, 'GSA Coffee Break', '2016-05-11 12:00:00', '2016-05-11 15:30:00', '1', '1');
insert into event values (20, 'GSA Coffee Break', '2016-05-12 12:00:00', '2016-05-12 15:30:00', '1', '1');
insert into event values (21, 'GSA Coffee Break', '2016-05-13 12:00:00', '2016-05-13 15:30:00', '1', '1');

truncate badEvent;
Call eventsToCancel(4);
SELECT * FROM badEvent ORDER BY eventStart;
# 13, 18


# T2
truncate event;

insert into event values (1, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');
insert into event values (2, 'GSA Coffee Break', '2016-01-02 12:00:00', '2016-01-02 15:30:00', '1', '1');
insert into event values (3, 'GSA Coffee Break', '2016-01-03 12:00:00', '2016-01-03 15:30:00', '1', '1');
insert into event values (4, 'GSA Coffee Break', '2016-01-04 12:00:00', '2016-01-04 15:30:00', '1', '1');

insert into event values (5, 'GSA Coffee Break', '2016-01-06 12:00:00', '2016-01-06 15:30:00', '1', '1');
insert into event values (6, 'GSA Coffee Break', '2016-01-07 12:00:00', '2016-01-07 15:30:00', '1', '1');

truncate badEvent;
Call eventsToCancel(3);
SELECT * FROM badEvent ORDER BY eventStart;

# 4


#T3
truncate event;

insert into event values (1, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');
insert into event values (2, 'GSA Coffee Break', '2016-01-02 12:00:00', '2016-01-02 15:30:00', '1', '1');

insert into event values (3, 'GSA Coffee Break', '2016-01-06 12:00:00', '2016-01-06 15:30:00', '1', '1');
insert into event values (4, 'GSA Coffee Break', '2016-01-07 12:00:00', '2016-01-07 15:30:00', '1', '1');
insert into event values (5, 'GSA Coffee Break', '2016-01-08 12:00:00', '2016-01-08 15:30:00', '1', '1');
insert into event values (6, 'GSA Coffee Break', '2016-01-09 12:00:00', '2016-01-09 15:30:00', '1', '1');

truncate badEvent;
Call eventsToCancel(3);
SELECT * FROM badEvent ORDER BY eventStart;

# 6


#T4
truncate event;

insert into event values (1, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');

insert into event values (2, 'GSA Coffee Break', '2016-02-01 12:00:00', '2016-02-01 15:30:00', '1', '1');
insert into event values (3, 'GSA Coffee Break', '2016-02-02 12:00:00', '2016-02-02 15:30:00', '1', '1');
insert into event values (4, 'GSA Coffee Break', '2016-02-03 12:00:00', '2016-02-03 15:30:00', '1', '1');
insert into event values (5, 'GSA Coffee Break', '2016-02-04 12:00:00', '2016-02-04 15:30:00', '1', '1');
insert into event values (6, 'GSA Coffee Break', '2016-02-05 12:00:00', '2016-02-05 15:30:00', '1', '1');
insert into event values (7, 'GSA Coffee Break', '2016-02-06 12:00:00', '2016-02-06 15:30:00', '1', '1');
insert into event values (8, 'GSA Coffee Break', '2016-02-07 12:00:00', '2016-02-07 15:30:00', '1', '1');

insert into event values (9, 'GSA Coffee Break', '2016-03-01 12:00:00', '2016-03-01 15:30:00', '1', '1');


truncate badEvent;
Call eventsToCancel(3);
SELECT * FROM badEvent ORDER BY eventStart;

#5


#T5
truncate event;

insert into event values (1, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');
insert into event values (2, 'GSA Coffee Break', '2016-01-02 12:00:00', '2016-01-02 15:30:00', '1', '1');
insert into event values (3, 'GSA Coffee Break', '2016-01-03 12:00:00', '2016-01-03 15:30:00', '1', '1');
insert into event values (4, 'GSA Coffee Break', '2016-01-04 12:00:00', '2016-01-04 15:30:00', '1', '1');
insert into event values (5, 'GSA Coffee Break', '2016-01-04 12:00:00', '2016-01-04 15:30:00', '1', '1');
insert into event values (6, 'GSA Coffee Break', '2016-01-05 12:00:00', '2016-01-05 15:30:00', '1', '1');
insert into event values (7, 'GSA Coffee Break', '2016-01-06 12:00:00', '2016-01-06 15:30:00', '1', '1');
insert into event values (8, 'GSA Coffee Break', '2016-01-07 12:00:00', '2016-01-07 15:30:00', '1', '1');


truncate badEvent;
Call eventsToCancel(3);
SELECT * FROM badEvent ORDER BY eventStart;

# 4, 5


#T6
truncate event;

insert into event values (1, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 5:30:00', '1', '1');
insert into event values (2, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');
insert into event values (3, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');
insert into event values (4, 'GSA Coffee Break', '2016-01-01 12:00:00', '2016-01-01 15:30:00', '1', '1');


truncate badEvent;
Call eventsToCancel(3);
SELECT * FROM badEvent ORDER BY eventStart;

#

drop procedure eventsToCancel;


# T1 - 13, 18
# T2 - 4
# T3 - 6
# T4 - 5
# T5- 4, 5
# T6 -
 