/*
*Comp533, Assignment4
*Chengyin Liu, cl93
*/

#2.2 Event Booking Trigger

#Add a 'valid' field to the event table, which has a default value of 0.
#use int instead of boolean type for the field valid in case there are other valid status later
alter table event add valid integer default 0;

#Set the value of this field to 1 for all existing records in the table.
SET SQL_SAFE_UPDATES = 0;
update event set valid = 1;

#drop table if exists
drop table if exists eventIssue;
#Create a table named 'eventIssue'
create table if not exists eventIssue
(
	newEventId integer not null,
	newEventName varchar(100) not null,
	newStart datetime,
	newEnd datetime,
	existEventId integer not null,
	existEventName varchar(100) not null,
	existStart datetime,
	existEnd datetime,
	status varchar(100),
    primary key(newEventId, existEventId),
    foreign key(newEventId) references event(eventId),
    foreign key(existEventId) references event(eventId)
);

#Assumption: if the eventEnd of one event is the same as the eventStart of another event, 
#it is considered as a 'travel' status instead of 'overlap'

#drop the trigger if already exists
drop trigger if exists beforeBookEvent;
#create the trigger 'beforeBookEvent'
delimiter //
#active the trigger before inserting a new record into event table
create trigger beforeBookEvent before insert on event
for each row
begin
	#set valid value of the new event to 1 at the beginning
	set new.valid = 1;
    #set the valid value to 0 when there are overlap cases found
	if (select count(eventId) 
		from event 
		where (new.eventStart < eventStart and new.eventEnd > eventStart)
			or (new.eventStart > eventStart and new.eventStart < eventEnd)
		) > 0
        then set new.valid = 0;
	end if;
end; //
delimiter ;

#drop the trigger if already exists
drop trigger if exists afterBookEvent;
#create the trigger 'afterBookEvent'
delimiter //
#active the trigger after inserting a new record into event table
create trigger afterBookEvent after insert on event
for each row
begin
	#insert the overlap records into eventIssue
	insert into eventIssue(newEventId, newEventName, newStart, newEnd, existEventId, existEventName, existStart, existEnd, status)
		select new.eventId, new.eventName, new.eventStart, new.eventEnd, eventId, eventName, eventStart, eventEnd, 'overlap' 
		from event 
		where (new.eventStart < eventStart and new.eventEnd > eventStart)
			or (new.eventStart > eventStart and new.eventStart < eventEnd);
	#insert the travel records into eventIssue
	insert into eventIssue(newEventId, newEventName, newStart, newEnd, existEventId, existEventName, existStart, existEnd, status)
		select new.eventId, new.eventName, new.eventStart, new.eventEnd, eventId, eventName, eventStart, eventEnd, 'travel' 
		from event 
		where (new.eventEnd <= eventStart and TIMESTAMPDIFF(MINUTE, new.eventEnd, eventStart) <= 30)
			or (eventEnd <= new.eventStart and TIMESTAMPDIFF(MINUTE, eventEnd, new.eventStart) <= 30); 
end; //
delimiter ;

#Run this code to check the answer
#insert new events
INSERT INTO event(eventName, eventStart, eventEnd, locationId, menuId)
VALUES
('Mid afternoon tea', '2017-03-09 14:15:00', '2017-03-09 14:45:00', 24, 1),
('Dessert Bar', '2017-01-19 13:30:00', '2017-01-19 16:00:00', 25, 4),
('Ice cream for lunch', '2017-05-06 11:00:00', '2017-05-06 16:00:00', 17, 3);

#check the results
SELECT *
FROM event
WHERE eventName in ('Dessert Bar', 'Ice cream for lunch', 'Mid afternoon tea')
ORDER BY eventName;

SELECT *
FROM eventIssue
ORDER BY newEventName;


