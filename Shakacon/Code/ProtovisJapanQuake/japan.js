var words = ["earthquake", "japan", "nuclear", "tsunami", "japanese", "plants", "reactors", "power", "disaster", "tokyo", "crisis", "devastating", "plant", "fuel", "officials", "percent", "monday", "washington", "buildings", "caused", "city", "coast", "magnitude", "radiation", "spent", "struck", "survivors", "weekend"];

var frequencies = [
{ date:  "2/23/11", earthquake: 1, japan: 0, nuclear: 0, tsunami: 0, japanese: 0, plants: 0, reactors: 0, power: 0, disaster: 0, tokyo: 0, crisis: 0, devastating: 0, plant: 0, fuel: 0, officials: 0, percent: 0, monday: 0, washington: 0, buildings: 0, caused: 1, city: 1, coast: 0, magnitude: 0, radiation: 0, spent: 1, struck: 0, survivors: 1, weekend: 0 }, 
{ date:  "2/24/11", earthquake: 1, japan: 0, nuclear: 0, tsunami: 0, japanese: 0, plants: 0, reactors: 0, power: 0, disaster: 0, tokyo: 0, crisis: 0, devastating: 1, plant: 0, fuel: 0, officials: 0, percent: 0, monday: 0, washington: 0, buildings: 0, caused: 0, city: 1, coast: 0, magnitude: 1, radiation: 0, spent: 0, struck: 0, survivors: 0, weekend: 0 },
{ date:  "3/11/11", earthquake: 3, japan: 1, nuclear: 0, tsunami: 1, japanese: 0, plants: 0, reactors: 0, power: 0, disaster: 0, tokyo: 0, crisis: 0, devastating: 1, plant: 0, fuel: 0, officials: 0, percent: 0, monday: 0, washington: 0, buildings: 0, caused: 0, city: 0, coast: 1, magnitude: 0, radiation: 0, spent: 0, struck: 0, survivors: 0, weekend: 0 },
{ date: "3/12/11", earthquake: 13, japan: 2, nuclear: 1, tsunami: 6, japanese: 3, plants: 5, reactors: 0, power: 1, disaster: 1, tokyo: 1, crisis: 0, devastating: 1, plant: 0, fuel: 0, officials: 1, percent: 2, monday: 0, washington: 1, buildings: 1, caused: 2, city: 1, coast: 2, magnitude: 2, radiation: 1, spent: 0, struck: 3, survivors: 1, weekend: 0 },
{ date:  "3/13/11", earthquake: 5, japan: 5, nuclear: 5, tsunami: 3, japanese: 1, plants: 0, reactors: 3, power: 0, disaster: 1, tokyo: 1, crisis: 1, devastating: 3, plant: 1, fuel: 0, officials: 1, percent: 0, monday: 0, washington: 1, buildings: 1, caused: 0, city: 0, coast: 2, magnitude: 1, radiation: 0, spent: 0, struck: 0, survivors: 1, weekend: 0 },
{ date: "3/14/11", earthquake: 8, japan: 13, nuclear: 12, tsunami: 2, japanese: 6, plants: 3, reactors: 7, power: 5, disaster: 3, tokyo: 3, crisis: 2, devastating: 2, plant: 5, fuel: 1, officials: 2, percent: 1, monday: 3, washington: 4, buildings: 0, caused: 2, city: 2, coast: 0, magnitude: 1, radiation: 2, spent: 0, struck: 1, survivors: 0, weekend: 3 },
{ date:  "3/15/11", earthquake: 6, japan: 7, nuclear: 5, tsunami: 3, japanese: 2, plants: 2, reactors: 2, power: 2, disaster: 4, tokyo: 1, crisis: 0, devastating: 0, plant: 1, fuel: 2, officials: 2, percent: 2, monday: 3, washington: 0, buildings: 2, caused: 0, city: 0, coast: 0, magnitude: 0, radiation: 0, spent: 2, struck: 0, survivors: 2, weekend: 1 },
{ date: "3/16/11", earthquake: 6, japan: 6, nuclear: 11, tsunami: 4, japanese: 4, plants: 4, reactors: 2, power: 4, disaster: 2, tokyo: 3, crisis: 5, devastating: 0, plant: 1, fuel: 4, officials: 1, percent: 2, monday: 0, washington: 0, buildings: 1, caused: 0, city: 0, coast: 0, magnitude: 0, radiation: 2, spent: 2, struck: 1, survivors: 0, weekend: 1 }
];

(function() {
  var format = pv.Format.date("%m/%d/%y");
  crimea.forEach(function(d) { d.date = format.parse(d.date); });
})();
