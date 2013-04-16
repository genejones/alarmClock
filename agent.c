function router(request, res){
	try{
		switch(request.path){
			case "param/TZ":
				set_tz(request, res);
			case "param/12":
				set_twelve(request, res);
			case "alert":
				//for emergency alerts
				//not implemented yet
				alert(request, res) ;//send dummy response
			default:
				if (request.method == "OPTIONS" && request.path == ""){
					res.header("ALLOW", "GET,PUT,DELETE,OPTIONS");
					res.send(200, "OK");
				}
				res.send(400, "Bad Request");
		}
	}
	catch(e){
		res.send(500, "Server Error" + e);
	}
}

function updatePermanent(name, value){
	server.log("adding/changing " +name + " to " + value);
	cachedPerm = server.permanent;
	cachedPerm <- {name = value};
	server.setpermanentvalues(cachedPerm);
}

function permanentSetIfEmpty(name, value){
	server.log("adding/changing " +name + " to " + value);
	cachedPerm = server.permanent;
	if (value in cachedPerm){
		return true;
	}
	else{
		cachedPerm <- {name = value};
		server.setpermanentvalues(cachedPerm);
	}
}

function alert(request, res){
	if ("alertType" in request.query){
		switch (request.method){
			case "PUT":
				res.send(200, "Not implemented yet, sorry");
				break;
			case "OPTIONS":
				res.header("ALLOW", "PUT,OPTIONS");
				res.send(200, "None of this is implemented yet. In the future, you can PUT a request with a secret key to allow for emergeny alerts");
				break;
			default:
				res.send(405, "Method not implemented. See HTTP OPTIONS for valid options.");
				break;
		}
	}
	else{
		throw("queryString Error");
	}
}

function set_twelve(request, res){
	switch (request.method){
		case "GET":
			res.send(200, server.permanent.isTwelveHour);
			break;
		case "PUT":
			local value = request.body.tointeger();
			switch (value){
				case '1':
					updatePermanent("isTwelveHour", true);
				case '0':
					updatePermanent("isTwelveHour", false);
				default:
					throw("Not a valid value");
			}
			res.send(200, "OK");
			break;
		case "OPTIONS":
			res.header("ALLOW", "PUT,GET,OPTIONS");
			res.send(200, "PUT or GET. Valid options are 1 or 0. 1 indicates 12 hour time, 0 indicates 24 hour time.");
			break;
		default:
			res.send(405, "Method not implemented. See HTTP OPTIONS for valid options.");
			break;
	}
}

function set_tz(request, res){
	if ("offset" in request.query){
		if (request.method == "GET"){
			res.send(200, server.permanent.tz_offset);
		}
		if (request.method == "PUT"){
			offset = request.body.tointeger();
			if (offset && offset>-12 && offset<14){
				updatePermanent("tz_offset",request.body);
			}
			else{
				throw("offset incorrect");
			}
			res.send(200, "OK");
		}
		if (request.method == "OPTIONS"){
			res.header("ALLOW", "GET,PUT,OPTIONS");
			res.send(200, "Sets Timezone offset. Must be an integer between -12 and 14(sorry for any people living in .5 UTC offsets).");
		}
		else{
			res.send(405, "Bad Request");
		}
	}	
	else{
		res.send(400, "Method not implemented. See HTTP OPTIONS for valid options.");
	}
}

function init(){
	//when an imp is first configured, set some defaults
	permanentSetIfEmpty("tz_offset", -4);
	permanentSetIfEmpty("isTwelveHour", true);
}
device.onconnect(init);

http.onrequest(router); //accept incoming HTTP requests