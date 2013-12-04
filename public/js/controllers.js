'use strict';

/* Controllers */

var bangmanControllers = angular.module('bangmanControllers', []);
bangmanControllers.controller('HangmanCtrl', ['$scope', '$socket', function($scope, $socket) {
	$socket.on('hangman', function(hangman) {
		$scope.word = hangman.phrase;
	})

	$scope.guess = function() {
    	$socket.emit('guess', $scope.letter)
  	};
}]);

var landingpageControllers = angular.module('landingpageControllers', []);
landingpageControllers.controller('LandingpageCtrl', function($scope, $http) {
	$scope.signup = function() {
	  //$scope.message = 'Thanks for signing up! You will receive an invitation at ' + $scope.email + '.';
		$http.put('/subscribe/' + $scope.email, {email: $scope.email}).success(function (data, status) {
		 	$scope.message = JSON.stringify(data);
		});
	}
});