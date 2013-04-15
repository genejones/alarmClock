// Hello World example code
// Register with the server
imp.configure("Alarm v0.01", [], []);
// Display our important message

function setup() {
    hardware.uart57.configure(9600, 8, PARITY_NONE, 4, NO_CTSRTS);
    server.log("Hello, World! "+ hardware.getimpeeid() + " reporting in.");
	agent.on("set_tz", set_timeOffset);
	agent.on("set_twelve", set_twelve_hour);
}

function set_timeOffset(timeOffset){
	server.setpermanentvalues({timeOffset = timeOffset});
	nv.timeOffset <- {timeOffset = timeOffset}
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
	day, hour, min
}


class serialDisplay{
	constructor(){
		hardware.uart57.write(0x76); //init
	}
	function writeTime(hour, min){
		if (hour <10){
			hardware.uart57.write(0x79); // Send the Move Cursor Command
			hardware.uart57.write(0x01); // Send the data byte, with value 1
			// now Write hour, should be displayed on 2nd digit
		}
		hardware.uart57.write(hour);
		if (min < 10){
			hardware.uart.write(0x79);
			hardware.uart.write(0x03); //move the cursor to the third digit
			//minute will be displayed on the fourth digit now
		}
		hardware.uart57.write(min);
	}
}

setup();

// End of code.