

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
    #declare the cursor
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
		#fetch the data
		fetch eventCursor into eventId, eventName, eventStart;
        #when done = 1, leave the loop
        if done 
			then leave eventLoop; 
        end if;
		
        if daysInRow = 0
			then set daysInRow = 1;
				set LastEventDate = DATE_FORMAT(eventStart, '%Y-%m-%d'); 
			#	iterate eventLoop;
		end if;
        
        set currentEventDate = DATE_FORMAT(eventStart, '%Y-%m-%d'); 
        if datediff(currentEventDate, LastEventDate) = 1
			then if daysInRow <= N 
					then set daysInRow = daysInRow + 1;
				else 
					set daysInRow = 1;
				end if;
				set LastEventDate = currentEventDate;
		elseif datediff(currentEventDate, LastEventDate) > 1
			then set daysInRow = 1;
				set LastEventDate = currentEventDate;
		end if;

        if daysInRow > N
			then insert into badEvent(eventId, eventName, eventStart)
				values(eventId, eventName, eventStart);
        end if;
        
    end loop eventLoop;
    
    #close cursor
    close eventCursor;
end; //
delimiter ;

