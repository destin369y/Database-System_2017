/**
* COMP533
* assignment5
* Chengyin Liu, cl93
*
*/


//1 Create the Collections
mongoimport --db ricedb --collection componentCategory --jsonArray --file componentCat.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection component --jsonArray --file component.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection employee --jsonArray --file employee.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection event --jsonArray --file event.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection eventAssignment --jsonArray --file eventAssignment.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection itemSold --jsonArray --file itemSold.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection location --jsonArray --file location.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection menu --jsonArray --file menu.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection menuItem --jsonArray --file menuItem.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection product --jsonArray --file product.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection productSold --jsonArray --file productSold.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection recipeItem --jsonArray --file recipeItem.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection ticket --jsonArray --file ticket.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection unit --jsonArray --file unit.json --username ricedb --password <myPassword>
mongoimport --db ricedb --collection tkt --jsonArray --file tkt.json --username ricedb --password <myPassword>


//2 Documents queries and actions
//2.1 Simple Event
db.event.findOne()

//2.2 Event with criteria
db.event.find({locationId : 5})

//2.3 Events by Time
db.event.find({eventStart : {$lt : "2017-09-07 00:00:00"}})
        .sort({eventStart : -1})
        .limit(5)

//2.4 Ticket Time
db.ticket.find({eventId : 16, ticketTime : {$lt : "2017-04-12 19:10:00"}})
        .size()

//2.5 Event Name
//Change the name of the event named "Pi Day" to "Pie Day".
db.event.updateMany({eventName : "Pi Day"}, {$set : {eventName : "Pie Day"}})
//Give a query that returns events named "Pi Day" OR "Pie Day".
db.event.find({eventName : {$in : ["Pi Day", "Pie Day"]}})
//Change the name of all events named "GSA Coffee Break" to "GSA Study Break".
db.event.updateMany({eventName : "GSA Coffee Break"}, {$set : {eventName : "GSA Study Break"}})
//How many documents were updated?
    4
//{ "acknowledged" : true, "matchedCount" : 4, "modifiedCount" : 4 }
//Give a query that returns the number of events named "GSA Study Break" OR "GSA Coffee Break".
db.event.find({eventName : {$in : ["GSA Study Break", "GSA Coffee Break"]}})
        .size()

//2.6 MenuItems
//assume that here the names of the menu items means the names of the products and we only care about the productName in the result
db.product.aggregate([   
    {$lookup : {
        from: "menuItem",
        localField: "_id",
        foreignField: "productCode",
        as: "menuItem"}
    },
    {$lookup : {
        from: "menu",
        localField: "menuItem.menuId",
        foreignField: "_id",
        as: "menu"}
    },    
    {$match : {"menu.menuName" : "Sundae"}}, 
    {$project : {_id : 0, productName : 1}},
    {$sort : {productName : 1}}
])

//2.7 TotalPrice
//sum the productPrice of each ticket and store them in a cursor
var cursor = db.tkt.aggregate({$project : {totalPrice : {$sum : "$productSold.productPrice"}}})
//update the value of totalPrice in tkt collection for each ticket
cursor.forEach(function(x){
    db.tkt.updateMany({_id : x._id}, {$set : {totalPrice : x.totalPrice}})
})
//return the id and totalPrice for tickets 5, 18, 343, and 1003. Sort the results by totalPrice, descending.
db.tkt.find({_id : {$in : [5, 18, 343, 1003]}}, {totalPrice : 1})
    .sort({totalPrice : -1})

//2.8 Turtle Sundae recipe
db.recipeItem.aggregate([   
    {$lookup : {
        from: "product",
        localField: "productCode",
        foreignField: "_id",
        as: "product"}
    },
    {$lookup : {
        from: "componentCategory",
        localField: "compCatId",
        foreignField: "_id",
        as: "componentCategory"}
    },
    {$lookup : {
        from: "component",
        localField: "compId",
        foreignField: "_id",
        as: "component"}
    },
    {$lookup : {
        from: "unit",
        localField: "unitId",
        foreignField: "_id",
        as: "unit"}
    },
    {$unwind : {path : "$componentCategory", preserveNullAndEmptyArrays : true}}, 
    {$unwind : {path : "$component", preserveNullAndEmptyArrays : true}},
    {$unwind : {path : "$unit", preserveNullAndEmptyArrays : true}},
    {$match : {"product.productName" : "turtle sundae"}}, 
    {$project : {_id : 0, compCatName : "$componentCategory.compCatName", compName : "$component.compName", qty : "$qty", unitName : "$unit.unitName"}},
    {$sort : {compCatName : 1, compName : 1}}
])


//3 Open ended questions
//3.1 Tkt: ProductSold & ItemSold
Advantage: 
    Query becomes more convenient and faster. 
    We do not need to do a lot of joins when we are looking for or changing data from sold products and items.
Disadvantage: 
    Not quite convenient to get statistic information of productSold or itemSold.
    And gathering too much data in a single tkt collection sometimes makes complicated when we analyze tickets.
    
//3.2 Tkt: ProductPrice
Advantage: 
    1. We do not need to access the menuItem collection to find the price, only need to deal with one collection.
    2. Sometimes the price of the product we finally sold will be different with the price listed on the menu.
        We can handle these cases as we stored the price in the tkt collection to represent the price on the ticket.
Disadvantage: 
    Duplicate information. I mean there will be data repetition in our database.
    The price data is stored both in menuItem and tkt, 
    which is a waste of storage and it is not good for maintainance when the price changes.
        
//3.3 Event collection
Advantage: 
    1. The event can exit independently and events may have zero tickets sold.
        So it is more clear to keep event a collection and let it be referenced from tkt.
    2. Avoid too much repition. Save storage space.
        If we embed event to each ticket, many same event will be embedded multiple times in the tkt collection.
Disadvantage: 
    Since MongoDB has no joining facilites as in Relational Database, 
    we need to lookup and do more queries when we need to gather data from multiple collections.
  
//3.4 Phone numbers
    I prefer they are embedded documents in the employee collection.
        MongoDB has a good structure to deal with embedded documents and arrays.
        Phone numbers belong to employees, so embedded documents can provide a more natural representation of information.
        And it is not that conveninent to join collections in MongoDB if we store them as a separate collection.


//4 Survey
//It took me approximately N hours to complete this assignment, where N is:
    15
        
//What I like most about MongoDB / document stores is:
    Conveninent to execute functions.
            
//What I like least about MongoDB / document stores is:        
    Not that suitable to deal with M-M relations.
        
        
    
    
    
    
    
    
    
    
    