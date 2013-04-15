// Hello World example code
// Register with the server
imp.configure("Alarm v0.01", [], []);
// Display our important message

function setup() {
    hardware.uart57.configure(9600, 8, PARITY_NONE, 4, NO_CTSRTS);
    server.log("Hello, World! "+ hardware.getimpeeid() + " reporting in.");
	agent.on("set_tz", set_timeOffset);
	agent.on("set_twelve", set_twelve_hour);
	nv <- {displayTime = true}; //time should always be displayed while starting
}

function set_timeOffset(timeOffset){
	server.setpermanentvalues({timeOffset = timeOffset});
	nv <- {timeOffset = timeOffset}
}

function set_twelve_hour(isTwelveHour){
	server.setpermanentvalues({isTwelveHour = isTwelveHour});
	nv <- {isTwelveHour = isTwelveHour};
}

function tz_adjusted_time(){
	local d = date(); //the current time
	local day = d.day;
	local min = d.min;
	local hour = d.hour;
	hour = hour + server.permanent.timeOffset;

	if (hour <=0){
		//the tz_offset moved us into negative time, meaning we are in the previous day
		hour = hour + 24;
		day = day - 1;
		//E.G. if UTC is 2 and we are -4 from UTC, than our hour would be -2
		//this step converts -2 back to 22
		//this really doesn't matter as much as we might suppose; timezone adjusted time is only used for user-level-display
	}
	return {'day
	'day':day, 'hour': hour, 'min': min}
}

function adjust_twelveHour(date){
	if (date.hour >= 12){
		date.isPM <- true;
		date.hour = date.hour - 12;
	}
	else{
		date.isPM <- false;
	}
	if (date.hour == 0){
		date.hour = 12;
		//so it is 12:01am in the morning, not 0:01am
	}
	return date;
}

function get_time(){
	local time = tz_adjusted_time();
	if(server.permanent.isTwelveHour){
		time = adjust_twelveHour(time);
	}
	return time;
}

function checkInNV(name){
	if ("nv" in getroottable()) && (name in nv)){
		return true;
	}
	return false;
}

function displayWrite(){
	local time = get_time();
	writeTime(time);
	if (checkInNV("displayTime"){
		imp.wakeup(0.4, displayWrite);
	}
}
	

class serialDisplay{
	constructor(){
		hardware.uart57.write(0x76); //init
	}
	function writeTime(time){
			hardware.uart57.write(0x79); // Send the Move Cursor Command
			hardware.uart57.write(0x00); // Send the data byte, with value 0 (reset the cursor area)
		if (time.hour <10){
			hardware.uart57.write(0x79); // Send the Move Cursor Command
			hardware.uart57.write(0x01); // Send the data byte, with value 1
			// now Write hour, should be displayed on 2nd digit
		}
		hardware.uart57.write(time.hour);
		if (time.min < 10){
			hardware.uart.write(0); //place a blank 0 here
		}
		hardware.uart57.write(time.min);
	}
}

setup();

// End of code.