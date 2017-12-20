db.unit.drop()
db.itemSold.drop()
db.event.drop()
db.employee.drop()
db.ticket.drop()
db.componentCategory.drop()
db.component.drop()
db.eventAssignment.drop()
db.location.drop()
db.menu.drop()
db.menuItem.drop()
db.product.drop()
db.productSold.drop()
db.recipeItem.drop()
db.tkt.drop()


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

