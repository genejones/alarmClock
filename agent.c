function router(request, res)
{
	try{
		switch(request.path){
			case 'param/TZ':
				function set_tz(request, res);
			case 'param/12':
				function set_twelve(request, res);
			case 'alert':
				//for emergency alerts
				//not implemented yet
				alert(request, res) ;//send dummy response
			default:
				if (request.method == 'OPTIONS' && request.path == ''){
					res.header('ALLOW', 'GET,PUT,DELETE,OPTIONS');
					res.send(200, "OK");
				res.send(400, "Bad Request");
		}
	}
	catch{
		res.send(500, "Server Error");
	}
}

function updatePermanent(name, value){
	cachedPerm = server.permanent;
	cachedPerm <- {name = value};
	server.setpermanentvalues(cachedPerm);
}

function set_tz(request, res){
	if ('offset' in request.query){
		if (request.method == 'GET'){
			res.send(200, server.permanent.tz_offset);
		}
		if (request.method == 'PUT' || request.method == ''){
			offset = request.body.tointeger();
			if (offset && offset.body>12 || request.body<14){
				throw("offset incorrect");
			}
			updatePermanent('tz_offset'=request.body);
			res.send(200, "OK");
		}
		if (request.method == 'OPTIONS'){
			res.header('ALLOW', 'GET,PUT,OPTIONS');
			res.send(200, "OK");
		}
		else{
			res.send(400, "Bad Request");
		}
	}	
	else{
		res.send(400, "Bad Request");
	}
}

function init(){
	//when an imp is first configured, set some defaults
	previous = server.permanant;
	//grab the previous server permanant table
	if (previous.
	
	server.setpermanentvalues({tz_offset=-4, isTwelveHour=true});
}
device.onconnect(init);

http.onrequest(router); //accept incoming HTTP requests