// TODO: This will come from the configuration HTML
var URL = "http://192.168.1.250:3000";

var LIFX = {};

LIFX.request = function(method, path, cb) {
	var req = new XMLHttpRequest();
	var fullURL = URL + path;
  	req.open(method, fullURL, true);
  	console.log(method + " request to " + fullURL);

  	req.onload = function(e) {
	    if (req.readyState == 4 && req.status == 200) {
	      if (req.status == 200) {
	      	console.log(fullURL + " > " + req.responseText);

	        var response = JSON.parse(req.responseText);
	        cb(response);
	        return;
	      } 
	    }

	    console.log("Error in request to " + fullURL);
	    //  + " (" + JSON.stringify(e) + ")");
      	cb(null);
	};
	req.send();
};

LIFX.GET = function(path, cb) {
	this.request("GET", path, cb);
};

LIFX.POST = function(path, cb) {
	this.request("POST", path, cb);
};

LIFX.getBulbs = function(cb) {
	this.GET("/bulbs", cb);
};

LIFX.getBulbState = function(bulbIndex, cb) {
	this.GET("/bulb/" + bulbIndex, cb);
};

// 

var LIFX_JS = {};

LIFX_JS.sendAppMessage = function(message, ack, nack) {
	transactionID = Pebble.sendAppMessage(message, function(transactionID) {
		console.log("Sent message with transaction ID = " + JSON.stringify(transactionID));

		if (ack) {
			ack(transactionID);
		}
	}, function(error) {
		console.log("Error sending app message: " + JSON.stringify(error));

		if (nack) {
			nack(error);
		}
	});

	console.log("Sending App Message " + JSON.stringify(message) + " (transaction id = " + transactionID + ")");
};

LIFX_JS.handleAppMessage = function(appMessage) {
	console.log("Received message: " + JSON.stringify(appMessage));

	var appMessageMethod = appMessage.payload["APPMSG_METHOD_KEY"];

	switch(appMessageMethod) {
		case "get_bulbs":
			LIFX_JS.handleGetBulbs();
		break;
		default:
			console.log("Unhandled appMessage");
		break;
	}
};

/**
 * @param iterator = function(item, cb(result))
 * Calls iterator with one item of array at a time until you call the cb it provides.
 * At the end it calls finishedCB with the results provided by each iterator.
 */
LIFX_JS.serializeFunctionCalls = function(array, iterator, finishedCB) {
	var results = [];

	(function next() {
		item = array.pop()

		iterator(item, function(result) {
			results.push(result);

			if (array.length) {
				next();
			} else {
				finishedCB(results);
			}
		});
	})();
}

LIFX_JS.getStateForBulbs = function(bulbs, cb) {
	var idx = 0;

	this.serializeFunctionCalls(bulbs, function(bulb, f) {
		LIFX.getBulbState(idx, function(state) {
			f(state);
		});
		idx++;
	}, cb);
};

LIFX_JS.handleGetBulbs = function() {
	var bulbs = LIFX.getBulbs(function(bulbs) {
		if (bulbs.length == 0) {
			console.log("No bulbs to send to the watch");
			return;
		}

		LIFX_JS.getStateForBulbs(bulbs, function(states) {
			LIFX_JS.sendAppMessage({
				"APPMSG_METHOD_KEY": "begin_reload_bulbs",
				"APPMSG_COUNT_KEY": states.length
			}, function() {
				var idx = 0;

				LIFX_JS.serializeFunctionCalls(states, function(bulb, f) {
					LIFX_JS.sendAppMessage({
						"APPMSG_METHOD_KEY": "bulb",
						"APPMSG_INDEX_KEY" : idx,
						"APPMSG_BULB_STATE_KEY" : 0,
						"APPMSG_LABEL_KEY" : "test"
					}, function() {
						f();
					}, function() {
						f();
					});

					idx++;
				}, function() {
					LIFX_JS.sendAppMessage({
						"APPMSG_METHOD_KEY": "end_reload_bulbs",
					});
				});
			});
		});
	});
};

//

Pebble.addEventListener("ready", function(e) {
    console.log("Hello world! - Sent from your javascript application.");
    LIFX.getBulbs(function(bulbs) {
    	console.log("bulbs: " + JSON.stringify(bulbs));
    });

	Pebble.addEventListener("appmessage", LIFX_JS.handleAppMessage);
});
