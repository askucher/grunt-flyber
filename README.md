# grunt-flyber
Script generator between angularjs and expressjs 

##EXAMPLE

###Structure

```sh
app/
 components/
  user/
   user.controller.client.js
   user.api.server.js
   user.jade
```

###User.api.server.js

You declare export functions with last callback argument

```Javascript 
module.exports = function($db) {
   all : function(callback) {
         // `user` collection is declared in config.json
         $db.user.find({}, { name: 1, _id: 1, connections: 1 }, function( err, users)  {
              callback(users);
         });
   },
   one: function(id, callback) {
        $db.user.findOne({ _id: id }, function( err, user ) {
              callback(user);
        });
   }
};
```

###User.controller.client.js

And use them on client side. Flyber generates middleware for you





```Javascript 

app.controller("user", function($scope, $flyber) {
  //`user` extracted from filename
  $flyber.user.all(function(err, users)) {
    $scope.users = users;
  };
  
  $scope.getDetails = function(id) {
     $flyber.user.one(id, function(err, details) { 
        $scope.details = details;
     };
  };
});

```

###User.jade

```Jade 
.user.component(ng:controller="user")
 .details(ng:if="details")
  h3 details.name
  p Connections: {{details.connections.length}}
  p Events: {{details.events.length}}
 .users
   .user(ng:repeat="user in users" ng:click="getDetails(user._id)")
      h3 {{user.name}}
      p Connections: {{user.connections.length}}
```





#install
* npm install flyber grunt-flyber
* add grunt task grunt-flyber into your gruntfile.js

```Javascript
grunt.initConfig({
  flyber: {
      options: {
        input: {
          controllers: [ 'user.controller.server.js' ]
        },
        output: {
           angularService: "flyber.service.js"
           /*,makeService: function() { ... } */
           ,expressRoute: "flyber.route.js"
           /*,makeRoute: function() { ... } */
  }
 }
});

grunt.registerTask("grunt-flyber");
```
This task generates 2 files flyber.service.js, flyber.route.js based on input controllers

flyber.service.js contains angular service declaration with generated functions for communication with server
flyber.route.js contains express routes for communication with client

* add line into your server.js file in order to attach flyber.route.js into your express

```Javascript
var express = 
  require("express");
var flyber = 
  require("flyber");

var router = express();
flyber.object("$router", router);
flyber.require("./flyber.route.js")
```

* add line into your angular.js module declaration file

```Html
<head>
  ...
  <script type="text/javascript" src="angular.js" />
  <script type="text/javascript" src="flyber.service.js" />
  ...
</head>
```

```Javascript
angular.module("app", ["flyber"]);
```
