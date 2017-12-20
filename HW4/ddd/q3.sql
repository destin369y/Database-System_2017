/*
*Comp533, Assignment4
*Chengyin Liu, cl93
*/

#2.3 Restocking Tasks

#drop table if exists
drop table if exists eventTask;
#create a table named 'eventTask'
create table if not exists eventTask
(
	eventId integer not null,
    taskType varchar(100) not null,
    compCatId integer, 
    quantity integer,
    performTime datetime not null,
    primary key(eventId, taskType, performTime),
    foreign key(eventId) references event(eventId)
);

#drop table if exists
drop table if exists invLevel;
#create a table named 'invLevel'
create table if not exists invLevel
(
	compCatId integer not null,
    restockQty integer,
    primary key(compCatId),
    foreign key(compCatId) references componentCategory(compCatId)
);

#populate InvLevel
INSERT INTO invLevel(compCatId, restockQty)
VALUES
(5, 200),
(6, 50),
(13, 50),
(14, 50),
(16, 300);

#drop the function if already exists
drop function if exists getEventId;
#create the function 'getEventId'
delimiter //
#takes productSoldId as input
create function getEventId (productSoldId integer) 
returns integer
return (
	select ticket.eventId
    from productSold, ticket
    where productSold.productSoldId = productSoldId 
		and productSold.ticketId = ticket.ticketId
); //
delimiter ;

#run this code to check the results
SELECT getEventId(3);
SELECT getEventId(6471);


#Assumption: when we insert itemSold, we look and see how many items have been sold since either the last restock or the beginning of the event, if there are no prior restock events.
#If at least restockQty number of items has been sold, do a restock and we do a restock for each componentCategory

#drop the trigger if already exists
drop trigger if exists restockTask;

#create the trigger 'restockTask'
delimiter //
#active the trigger after inserting a new record into itemSold table
create trigger restockTask after insert on itemSold
for each row
begin
    declare compCatId int;
    declare restockQty int;
    declare currentTicketTime datetime;
    declare restockNumber int;
    declare lastRestockTime datetime;
    declare currentSum int; 
    #get compCatId of this itemSold
    set compCatId = (select component.compCatId
					from component
					where component.compId = new.compId);
	#get restock quantity of that compCatId
	set restockQty = (select invLevel.restockQty
					from invLevel
					where invLevel.compCatId = compCatId);
	#get the ticketTime of this itemSold
    set currentTicketTime = (select ticket.ticketTime
							from productSold, ticket
							where productSold.productSoldId = new.productSoldId 
								and productSold.ticketId = ticket.ticketId);
    #check how many times we did restock for this compCatId in this event before currentTicketTime                           
    set restockNumber = (select count(1)
						from eventTask
						where eventId = getEventId(new.productSoldId) 
							and taskType = 'restock' 
							and compCatId = compCatId
							and performTime <= currentTicketTime);
    #if we did restock before, get lastRestockTime; if not, set lastRestockTime as the minimal value of datetime type
	if restockNumber > 0
		then set lastRestockTime = (select performTime
									from eventTask
									where eventId = getEventId(new.productSoldId) 
										and taskType = 'restock' 
										and compCatId = compCatId
										and performTime <= currentTicketTime
									order by performTime DESC
									limit 1);
	else
		set lastRestockTime = '1000-01-01 00:00:00';
    end if;
    #compute how many items have been sold since either the last restock or the beginning of the event, if there are no prior restock events.
    set currentSum = (select sum(itemSold.qty)
						from itemSold join productSold on itemSold.productSoldId = productSold.productSoldId
							join ticket on productSold.ticketId = ticket.ticketId
							join component on component.compId = itemSold.compId
						where ticket.eventId = getEventId(new.productSoldId) 
							and component.compCatId = compCatId 
                            and ticket.ticketTime > lastRestockTime
                            and ticket.ticketTime <= currentTicketTime
						group by ticket.eventId, component.compCatId);                        
    #If at least restockQty number of items has been sold, do a restock
    if currentSum >= restockQty 
		then insert into eventTask(eventId, taskType, compCatId, quantity, performTime)
			values(getEventId(new.productSoldId), 'restock', compCatId, restockQty, currentTicketTime);
    end if;
end; //
delimiter ;

#run this code to check the results
INSERT INTO itemSold(productSoldId, compId, qty, unitId) VALUES
(6471, 48, 1, 3),
(6683, 46, 1, 3),
(6726, 46, 1, 3),
(7529, 48, 1, 3);

SELECT * FROM eventTask;


