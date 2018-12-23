//nodejs

var express = require('express');
var mongodb = require('mongodb');
var app = express();
var port = 8000;

var MongoClient = require('mongodb').MongoClient;
var db;

// Initialize connection once
MongoClient.connect("mongodb://localhost:27017/test_db", function(err, database) {
  if(err) throw err;
  db = database;
  // Start the application after the database connection is ready
  app.listen(port);
  console.log("Listening on port "+port);
});

// Reuse database object in request handlers
app.get("/", function(req, res) {
  db.collection("replicaset_mongo_client_collection").find({}, function(err, docs) {
    docs.each(function(err, doc) {
      if(doc) {
        console.log(doc);
      }
      else {
        res.end();
      }
    });
  });
});
