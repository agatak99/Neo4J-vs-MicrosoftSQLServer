var express = require ('express');
var path = require ('path');
var logger = require ('morgan');
var bodyParser = require('body-parser');
var neo4j = require ('neo4j-driver');

var app = express();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(express.static(path.join(__dirname, 'public')));

var driver = neo4j.driver('bolt://localhost:7687', neo4j.auth.basic('neo4j', '123456'));
var session = driver.session();

app.get('/', function(req, res){
    session
        .run('MATCH(m:Film) RETURN m LIMIT 25')
        .then(function(result){
            var filmArray = [];
            var actorArray = [];
            var actressArray = [];
            var dirArray = [];
            var carArray = [];
            result.records.forEach(function(record){
                filmArray.push({
                    id: record._fields[0].identity.low,
                    title: record._fields[0].properties.Name,
                    year: record._fields[0].properties.Year,
                    boxOffice: record._fields[0].properties.Box
                })
            })
            res.render('index', {
                films: filmArray,
                actors: actorArray,
                actresses: actressArray,
                directors: dirArray,
                cars: carArray
            })
        })
        .catch(function(err){
            console.log(err);
        })
})

app.post('/film/search', function(req,res){
    var title = req.body.title;
    session
      .run("MATCH (m:Film {Name: $titleParam}) RETURN m", { titleParam: title })
      .then(function (result) {
        var filmArray = [];
        result.records.forEach(function (record) {
          filmArray.push({
            title: record._fields[0].properties.Name,
            year: record._fields[0].properties.Year,
            boxOffice: record._fields[0].properties.Box,
          });
        });
        session
          .run(
            "MATCH (m:Film {Name: $titleParam})<-[:AS_BOND_IN]-(p:People) RETURN p",
            { titleParam: title }
          )
          .then(function (result2) {
            var actorArray = [];
            result2.records.forEach(function (record) {
              actorArray.push({
                name: record._fields[0].properties.Name,
              });
            });
            session
              .run(
                "MATCH (m:Film {Name: $titleParam})<-[:IS_BOND_GIRL_IN]-(p:People) RETURN p",
                { titleParam: title }
              )
              .then(function (result3) {
                var actressArray = [];
                result3.records.forEach(function (record) {
                  actressArray.push({
                    name: record._fields[0].properties.Name,
                    role: record._fields[0].properties.Role,
                  });
                });
                session
                  .run(
                    "MATCH (m:Film {Name: $titleParam})<-[:DIRECTOR_OF]-(p:People) RETURN p",
                    { titleParam: title }
                  )
                  .then(function (result4) {
                    var dirArray = [];
                    result4.records.forEach(function (record) {
                      dirArray.push({
                        name: record._fields[0].properties.Name,
                      });
                    });
                    session
                      .run(
                        "MATCH (m:Film {Name: $titleParam})-[:HAS_VEHICLE]-(v:Vehicle) RETURN v",
                        { titleParam: title }
                      )
                      .then(function (result5) {
                        var carArray = [];
                        result5.records.forEach(function (record) {
                          carArray.push({
                            brand: record._fields[0].properties.Brand,
                            model: record._fields[0].properties.Model,
                          });
                        });
                        res.render("index", {
                          films: filmArray,
                          actors: actorArray,
                          actresses: actressArray,
                          directors: dirArray,
                          cars: carArray,
                        });
                      })
                      .catch(function (err) {
                        console.log(err);
                      });
                  })
                  .catch(function (err) {
                    console.log(err);
                  });
              });
          })
          .catch(function (err) {
            console.log(err);
          })
          .catch(function (err) {
            console.log(err);
          });
      })
      .catch(function (err) {
        console.log(err);
      });
})

app.listen(8080);
console.log("Server Started on Port 8080");

module.exports = app;