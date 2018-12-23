// Aysad Kozanoglu
//before use npm install express

var express = require('express');
var app = express();
var port = 8000;

app.get('/', function (req, res) {
  res.send('die Welt ist grösser als nur die Fünf ;)!');
});

app.listen(port, function () {
  console.log(' Service lauscht auf dem port '+8000);
});
