var lifx = require('lifx');
var restify = require('restify');
var url = require('url');

var lx = lifx.init();

lx.on('bulb', function(b) {
	console.log('New bulb found: ' + b.name);
});

lx.on('gateway', function(g) {
	console.log('New gateway found: ' + g.ipAddress.ip);
});

function set_bulb_on_off(req, res, next) {
	var bulb = lx.bulbs[parseInt(req.params.idx)];
	var state = parseInt(req.params.state);
	(state == 1) ? lx.lightsOn(bulb) : lx.lightsOff(bulb);
}

function set_bulb_color(req, res, next) {
	console.log("Setting color");
	lx.lightsColour(0x5999, 0xffff, 0x028f, 0x0dac, 0, lx.bulbs[0]);
}

function set_dim_absolute(req, res, next) {

}

function set_dim_relative(req, res, next) {

}

var server = restify.createServer();
server.use(restify.bodyParser());
server.post('/bulbs/:idx/on_off', set_bulb_on_off);
server.post('/bulbs/:idx/color', set_bulb_color);
server.post('/bulbs/:idx/dim_absolute', set_dim_absolute);
server.post('/bulbs/:idx/dim_relative', set_dim_relative);

server.listen(3000, function() {
	console.log('Server listening at %s', server.name, server.url);
});