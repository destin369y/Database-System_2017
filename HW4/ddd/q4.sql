/*
*Comp533, Assignment4
*Chengyin Liu, cl93
*/

#2.4 Event rescheduling Stored Procedure

#drop table if exists
drop table if exists badEvent;
#create a table named 'badEvent'
create table if not exists badEvent
(
	eventId integer not null,
    eventName varchar(100) not null,
    eventStart datetime,
    primary key(eventId),
    foreign key(eventId) references event(eventId)
);


#drop the procedure if already exists
drop procedure if exists eventsToCancel;

delimiter //
#create the procedure
create procedure eventsToCancel (in N int)
begin
	#variable and condition declarations
	declare done int default false;	
    declare eventId int;
    declare eventName varchar(100);
    declare eventStart datetime;
    declare daysInRow int;
    declare lastEventDate date;
    declare currentEventDate date;
    #declare the cursor for sorted event table by eventStart
    declare eventCursor cursor for 
    select eventSorted.eventId, eventSorted.eventName, eventSorted.eventStart
	from (select event.eventId, event.eventName, event.eventStart
			from event
            order by event.eventStart) eventSorted;
    #declare a handler for the NOT FOUND condition	
	declare continue handler for not found set done = true;     
    #empty the badEvent table
    delete from badEvent;
    #open the cursor
    open eventCursor;
    #set daysInRow to 0 at the beginning
    set daysInRow = 0;
    #start the loop for each existing event
    eventLoop: loop
		#fetch the data for each event
		fetch eventCursor into eventId, eventName, eventStart;
        #when done = 1, leave the loop
        if done 
			then leave eventLoop; 
        end if;
		#if it is the first event, set daysInRow to 1 and LastEventDate to the date of the first event
        if daysInRow = 0
			then set daysInRow = 1;
				set lastEventDate = DATE_FORMAT(eventStart, '%Y-%m-%d'); 
		end if;
        #set currentEventDate to the date of current event
        set currentEventDate = DATE_FORMAT(eventStart, '%Y-%m-%d'); 
        #if the difference between currentEventDate and lastEventDate is 1, there is one more day in row
        if datediff(currentEventDate, LastEventDate) = 1
			then if daysInRow <= N 
					then set daysInRow = daysInRow + 1;
				#if daysInRow is already larger than N, means last event is a bad event. So set daysInRow to 1
				else 
					set daysInRow = 1;
				end if;
                #set lastEventDate to currentEventDate so we can move forward
				set lastEventDate = currentEventDate;
        #if the difference between currentEventDate and lastEventDate is larger than 1, recount daysInRow from 1       
		elseif datediff(currentEventDate, LastEventDate) > 1
			then set daysInRow = 1;
				#set lastEventDate to currentEventDate so we can move forward
				set lastEventDate = currentEventDate;
		end if;
		#if daysInRow is larger than N, we get the bad event and insert it into badEvent table
        if daysInRow > N
			then insert into badEvent(eventId, eventName, eventStart)
				values(eventId, eventName, eventStart);
        end if;
	#end the loop
    end loop eventLoop;
    #close cursor
    close eventCursor;
end; //
delimiter ;


#Test the stored procedure by executing the following code, 
#running the results for N = 3 and N = 4.
#turn off safe update mode
set SQL_SAFE_UPDATES = 0;
#empty table badEvent
DELETE FROM badEvent;
CALL eventsToCancel(3);
SELECT * FROM badEvent ORDER BY eventName;
CALL eventsToCancel(4);
SELECT * FROM badEvent ORDER BY eventName;


#3. Survey
N = 18;
