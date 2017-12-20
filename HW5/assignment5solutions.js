1. simple event
db.event.findOne()
// a different event might be returned, but it should be similar
{
	"_id" : 2,
	"eventName" : "GSA Coffee Break",
	"eventStart" : "2017-02-02 15:00:00",
	"eventEnd" : "2017-02-02 16:30:00",
	"locationId" : 7,
	"menuId" : 2
}

2. event with criteria
db.event.find({locationId:5})
{ "_id" : 31, "eventName" : "Rice Village Apt Food Truck Night", "eventStart" : "2017-07-17 16:00:00", "eventEnd" : "2017-07-17 21:00:00", "locationId" : 5, "menuId" : 1 }

db.event.find({locationId:7})
{ "_id" : 2, "eventName" : "GSA Coffee Break", "eventStart" : "2017-02-02 15:00:00", "eventEnd" : "2017-02-02 16:30:00", "locationId" : 7, "menuId" : 2 }
{ "_id" : 1, "eventName" : "GSA Coffee Break", "eventStart" : "2017-01-19 13:00:00", "eventEnd" : "2017-01-19 15:30:00", "locationId" : 7, "menuId" : 2 }
{ "_id" : 3, "eventName" : "GSA Coffee Break", "eventStart" : "2017-02-23 13:00:00", "eventEnd" : "2017-02-23 15:30:00", "locationId" : 7, "menuId" : 2 }
{ "_id" : 4, "eventName" : "GSA Coffee Break", "eventStart" : "2017-03-09 15:00:00", "eventEnd" : "2017-03-09 16:30:00", "locationId" : 7, "menuId" : 2 }
{ "_id" : 53, "eventName" : "Grad Games", "eventStart" : "2017-09-07 18:30:00", "eventEnd" : "2017-09-07 23:00:00", "locationId" : 7, "menuId" : 2 }

3. events by time
db.event.find({eventStart : {$lt: '2017-09-07'}}) .sort({eventStart: -1}).limit(5)
{ "_id" : 52, "eventName" : "Research Colloquium", "eventStart" : "2017-08-30 11:30:00", "eventEnd" : "2017-08-30 15:00:00", "locationId" : 18, "menuId" : 1 }
{ "_id" : 11, "eventName" : "Wedding", "eventStart" : "2017-08-19 17:00:00", "eventEnd" : "2017-08-19 23:00:00", "locationId" : 10, "menuId" : 2 }
{ "_id" : 43, "eventName" : "Badging", "eventStart" : "2017-08-16 08:00:00", "eventEnd" : "2017-08-16 17:00:00", "locationId" : 20, "menuId" : 3 }
{ "_id" : 50, "eventName" : "Activities Fair", "eventStart" : "2017-08-12 15:00:00", "eventEnd" : "2017-08-12 23:00:00", "locationId" : 14, "menuId" : 3 }
{ "_id" : 49, "eventName" : "Orientation Picnic", "eventStart" : "2017-08-12 11:30:00", "eventEnd" : "2017-08-12 14:30:00", "locationId" : 1, "menuId" : 3 }


4. ticket time
db.ticket.find({ticketTime: {$gte:"2017-04-12 07:10"},eventId:16} ).length()
16

5. event name
db.event.update({"eventName":"Pi Day"}, {$set:{"eventName":"Pie Day"}});
db.event.find({"eventName":{$in: ["Pi Day", "Pie Day"]}})
{ "_id" : 10, "eventName" : "Pie Day", "eventStart" : "2017-03-14 11:00:00", "eventEnd" : "2017-03-14 13:00:00", "locationId" : 9, "menuId" : 1 }

db.event.updateMany({"eventName":"GSA Coffee Break"}, {$set:{"eventName":"GSA Study Break"}});
{ "acknowledged" : true, "matchedCount" : 4, "modifiedCount" : 4 }
4

db.event.find({"eventName":{$in: ["GSA Study Break", "GSA Coffee Break"]}}).length()
6

6. menuitems 
db.menu.aggregate([
    {$match: {menuName: "Sundae"}},
    {$lookup:{from: "menuItem", localField: "_id", foreignField: "menuId", as: "myMenuItems"}},
    {$unwind: "$myMenuItems"},
    {$lookup:{from: "product", localField: "myMenuItems.productCode", foreignField: "_id", as: "myProduct"}},
    {$unwind: "$myProduct"},
    {$project: {"myProduct.productName": 1, _id:0}},
    {$sort: {"myMenuItems.productName": 1}}
])

// the name of "array" can be anything
{ "myProduct" : { "productName" : "large sundae" } }
{ "myProduct" : { "productName" : "extra sundae topping" } }
{ "myProduct" : { "productName" : "regular sundae" } }

7. TotalPrice
db.tkt.find().forEach( function(thisDoc) {
     mytotal = 0;     
     for (var i=0; i < thisDoc.productSold.length; i++)          
        { mytotal = mytotal + thisDoc.productSold[i].productPrice; };     
    db.tkt.update({"_id":thisDoc._id}, {$set:{"totalPrice":mytotal}}); 
    }
)

// clear all values
db.tkt.updateMany({}, {"$set" :{totalPrice:0}})
// or
db.tkt.find().forEach( function(thisDoc) {
    mytotal = 0;     
    db.tkt.update({"_id":thisDoc._id}, {$set:{"totalPrice":0}}); 
    }
)

db.tkt.find({_id: {$in: [5, 18, 343, 1003]}}, {_id: 1, totalPrice: 1}).sort({totalPrice:-1})
{ "_id" : 1003, "totalPrice" : 51 }
{ "_id" : 343, "totalPrice" : 8 }
{ "_id" : 18, "totalPrice" : 7.5 }
{ "_id" : 5, "totalPrice" : 4 }

8. Turtle Sundae
 
db.recipeItem.aggregate([
    { $lookup:{   from: "product", localField: "productCode", foreignField: "_id", as: "ts"}  },
    { $match: {"ts.productName": "turtle sundae"}},
    { $unwind: "$ts"},
    { $lookup: {from: "componentCategory",localField: "compCatId",foreignField: "_id",as: "cat"} } ,
    { $unwind: "$cat"},
    { $lookup: {from: "component",localField: "compId",foreignField: "_id",as: "comp"} } ,
    { $unwind: "$comp"},
    { $lookup: {from: "unit",localField: "unitId",foreignField: "_id",as: "unit"} } ,
    { $unwind: "$unit"},
    { $project: {"_id": 0, "cat.compCatName": 1, "comp.compName" : 1, "qty": 1,  "unit.unitName": 1}},
    {$sort: {"cat.compCatName": 1, "comp.compName" : 1}}]);

{ "qty" : 1, "cat" : { "compCatName" : "cup" }, "comp" : { "compName" : "16 oz dish" }, "unit" : { "unitName" : "item" } }
{ "qty" : 1, "cat" : { "compCatName" : "fruit" }, "comp" : { "compName" : "stem cherry" }, "unit" : { "unitName" : "item" } }
{ "qty" : 8, "cat" : { "compCatName" : "ice cream base" }, "comp" : { "compName" : "Optional" }, "unit" : { "unitName" : "ounce" } }
{ "qty" : 1, "cat" : { "compCatName" : "paper product" }, "comp" : { "compName" : "tall napkin" }, "unit" : { "unitName" : "item" } }
{ "qty" : 1, "cat" : { "compCatName" : "spoon" }, "comp" : { "compName" : "short spoon" }, "unit" : { "unitName" : "item" } }
{ "qty" : 1.5, "cat" : { "compCatName" : "topping" }, "comp" : { "compName" : "caramel" }, "unit" : { "unitName" : "ounce" } }
{ "qty" : 1.5, "cat" : { "compCatName" : "topping" }, "comp" : { "compName" : "hot fudge" }, "unit" : { "unitName" : "ounce" } }
{ "qty" : 1.5, "cat" : { "compCatName" : "topping" }, "comp" : { "compName" : "pecans" }, "unit" : { "unitName" : "ounce" } }
{ "qty" : 1.5, "cat" : { "compCatName" : "topping" }, "comp" : { "compName" : "whipped cream" }, "unit" : { "unitName" : "ounce" } }

Open Ended Questions
1. productSold / itemSold
 + locality; easier to update ticket statistics; provides transaction support for prodcuts and items associated with a ticket
 - harder to determine how many of each item/component was sold

2. productPrice
 + actual price when sold the value is now protected from changes in the menuItem collection, so we have that historical information;
 + locality - the price is right where we need it.
 + less complex code for computing total price
 - redundant storage of information

3. Event collection
 + easier to perform statistics on event data (location, dates, etc.); same event documents can be referenced by other collections (e.g. EventAssignment)
 - harder to connect to tickets from the events which could make it more challenging to compute some event statistics; 
 	we might start keeping track of things besides tickets for events. Embedding events in ticket would make it difficult to connect events with these other documents.

4. Phone numbers
Embedded. Since we almost never start with a phone number to find a person, it makes more sense to embed the numbers in the Employee document.
In addition, phone numbers are pretty small in size and we are unlikely to want or be able to reuse them for multiple Employees, so embedding makes more sense.