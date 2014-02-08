var lifx = require('lifx');
var restify = require('restify');
var url = require('url');
var packet = require('lifx/packet');
var util = require('util');

var lx = lifx.init();

lx.on('bulb', function(b) {
	console.log('New bulb found: ' + b.name);
});

lx.on('gateway', function(g) {
	console.log('New gateway found: ' + g.ipAddress.ip);
});

function set_bulb_on_off(req, res, next) {
	var p = req.params;
	var bulb = lx.bulbs[parseInt(p.idx)];

	var state = parseInt(p.state);
	(state == 1) ? lx.lightsOn(bulb) : lx.lightsOff(bulb);
	res.writeHead(200);
	res.end();
}

function set_bulb_color(req, res, next) {
	var p = req.params;
	var bulb = lx.bulbs[parseInt(p.idx)];

	lx.lightsColour(parseInt(p.hue), parseInt(p.saturation), parseInt(p.luminance), parseInt(p.whiteColor), parseInt(p.fadeTime), bulb);
	res.writeHead(200);
	res.end();
}

function set_dim_absolute(req, res, next) {
	var p = req.params;
	var bulb = lx.bulbs[parseInt(p.idx)];

	var pkt = packet.setDimAbsolute({brightness:parseInt(p.brightness), duration:parseInt(p.duration)});
	lx.sendToOne(pkt, bulb);
	res.writeHead(200);
	res.end();
}

function set_dim_relative(req, res, next) {
	var p = req.params;
	var bulb = lx.bulbs[parseInt(p.idx)];

	var pkt = packet.setDimAbsolute({brightness:parseInt(p.brightness), duration:parseInt(p.duration)});
	lx.sendToOne(pkt, bulb);
	res.writeHead(200);
	res.end();
}

function get_bulbs(req, res, next) {
	res.writeHead(200, {'Content-Type' : 'application/json'});
	res.write(JSON.stringify(lx.bulbs));
	res.end();
	return lx.bulbs;
}

function get_bulb_state(req, res, next) {
	var bulb = lx.bulbs[parseInt(req.params.idx)];
	lx.sendToOne(packet.getLightState(), bulb);
	// This is kind of fragile since the response could be for a different bulb,
	// but hey, HACKATHON.
	lx.once('bulbstate', function(b) {
		res.writeHead(200);
		res.write(JSON.stringify(b));
		res.end();
	});	
}

var server = restify.createServer();
server.use(restify.bodyParser());
server.get('/bulbs', get_bulbs);
server.get('/bulbs/:idx', get_bulb_state);
server.post('/bulbs/:idx/on_off', set_bulb_on_off);
server.post('/bulbs/:idx/color', set_bulb_color);
server.post('/bulbs/:idx/dim_absolute', set_dim_absolute);
server.post('/bulbs/:idx/dim_relative', set_dim_relative);

server.listen(3000, function() {
	console.log('Server listening at %s', server.name, server.url);
});