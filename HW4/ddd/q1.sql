/*
*Comp533, Assignment4
*Chengyin Liu, cl93
*/

#2.1 Ticket Price Trigger

/*
*if we can use SQL from the earlier assignment to compute the value of ticket.totalPrice for existing productSold before the trigger,
*we only need to add the price of the productSold being inserted to the corresponding ticket. 
*/

#set MySQL safe update mode to 0 in order to update multiple rows
SET SQL_SAFE_UPDATES = 0;
#compute the cost of each ticket
UPDATE ticket tgt, (SELECT tkt.ticketId, SUM(mi.price) totalPrice
						FROM ticket tkt
						JOIN event e ON e.eventId = tkt.eventId
						JOIN menu m ON m.menuId = e.menuId
						JOIN productSold ps ON ps.ticketId = tkt.ticketId
						JOIN menuItem mi ON mi.productCode = ps.productCode AND mi.menuId = e.menuId
                        GROUP BY tkt.ticketId) src
SET tgt.totalPrice = src.totalPrice WHERE tgt.ticketId = src.ticketId;

#drop the trigger if already exists
drop trigger if exists updateTicket;

#create the trigger 'updateTicket'
delimiter //
#active the trigger before inserting a new record into productSold table
create trigger updateTicket before insert on productSold
for each row
begin
    update ticket, menuItem, event
    #add one to numProducts and add the price of the product to totalPrice
    set ticket.numProducts = ticket.numProducts + 1, 
		ticket.totalPrice = ticket.totalPrice + menuItem.price
	#find the price of the product in the menuItem table
	where ticket.ticketId = new.ticketId 
		and menuItem.productCode = new.productCode 
		and menuItem.menuId = event.menuId 
		and event.eventId = ticket.eventId;
end; //
delimiter ;

#Run this code to check the answer
#Check the ticket information before adding another product:
SELECT * FROM ticket WHERE ticketId = 187;
#Add another product to the ticket:
INSERT INTO productSold(productCode, ticketId) VALUES ('bs', 187);
#Check the ticket information after adding the brownie sundae:
SELECT * FROM ticket WHERE ticketId = 187;


/*
*if we are not supposed to use any SQL to compute the value of ticket.totalPrice for existing productSold before the trigger 
*and we are required to update only the corresponding ticket of the productSold which is being inserted,
*we may count numProducts and totalPrice of the corresponding ticket in our trigger. 
*/

#drop the trigger if already exists
drop trigger if exists updateTicket;

#create the trigger 'updateTicket'
delimiter //
##active the trigger after inserting a new record into productSold table
create trigger updateTicket after insert on productSold
for each row
begin
	#update numProducts and totalPrice of the corresponding ticket
    UPDATE ticket tgt, (SELECT tkt.ticketId, COUNT(ps.ProductSoldId) numProducts, SUM(mi.price) totalPrice
						FROM ticket tkt
						JOIN event e ON e.eventId = tkt.eventId
						JOIN productSold ps ON ps.ticketId = tkt.ticketId
						JOIN menuItem mi ON mi.productCode = ps.productCode AND mi.menuId = e.menuId
                        WHERE tkt.ticketId = NEW.ticketId
                        GROUP BY tkt.ticketId) src
	SET tgt.numProducts = src.numProducts, tgt.totalPrice = src.totalPrice 
    WHERE tgt.ticketId = src.ticketId;
end; //
delimiter ;

#Run this code to check the answer
#Check the ticket information before adding another product:
SELECT * FROM ticket WHERE ticketId = 187;
#Add another product to the ticket:
INSERT INTO productSold(productCode, ticketId) VALUES ('bs', 187);
#Check the ticket information after adding the brownie sundae:
SELECT * FROM ticket WHERE ticketId = 187;


