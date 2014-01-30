db.users.drop();
db.subscribers.drop();
db.games.drop();
db.credits.drop();

db.games.save({
	name: "game1",
	phrasegenerator: "singlephrasegenerator", 
	durationcalculator: "simpledurationcalculator"
});

db.games.save({
	name: "game2",
	phrasegenerator: "simplephrasegenerator", 
	durationcalculator: "simpledurationcalculator"
});

db.users.save({
	email: "user@gmail.com", 
	password: "$2a$10$C0kXk9XgrSLdmeVjqSjYN.EoMnrUpkoig5C5Yl1BswkgWdO/og3wO",
	activated: true
});

for (var i = 1; i <= 25; i++) {
	db.credits.save({
		owner: db.users.find()[0]._id,
		value: 1
	});
}
