// Hello World example code
// Register with the server
imp.configure("Alarm v0.01", [], []);
// Display our important message

function setup() {
    hardware.uart57.configure(9600, 8, PARITY_NONE, 4, NO_CTSRTS);
    server.log("Hello, World! "+ hardware.getimpeeid() + " reporting in.");
    const tz_offset = -4; //our time zone offset is -4 from UTC, or EDT(Eastern Daylight Time)
}

function reportTime(){
    local twelve_hour_time = true; //are we using AM/PM or 24 hour time
    local d = date();
    local day = d.day;
    local min = d.min;
    local pm = false; //it's AM by default
    local hour = d.hour + tz_offset; //account for timezone offset
    
    if (hour<=0){
        hour = hour + 24;
        day = day - 1;
        //the timezone offset has to rollback sometimes
        //E.g. if UTC is 2 and we are 4 hours backwards, then we would have -2 as our hour
        //this step converts -2 to 22
    }
    
    if (twelve_hour_time && hour>12){
        hour = hour - 12;
        pm = true;
        //convert 24 hour time range to am/pm range if necessary
    }
    
    if (min < 10) {min = format("0%d", d.min);}
    //make sure string lengths are OK for thee serial clock
    else{min = min.tostring();} //otherwise just stringify
    
    writeTimeToSerial(hour, min);
    imp.wakeup(5.0, reportTime);
}

function writeTimeToSerial(hour, min){
    hardware.uart57.write(0x76);  // Clear display command, resets cursor
    if (hour < 10){
        hardware.uart57.write(0x79); // Send the Move Cursor Command
        hardware.uart57.write(0x01); // Send the data byte, with value 1
        hardware.uart57.write(hour); // Write hour, should be displayed on 2nd digit
    }
    else{hardware.uart57.write(hour.tostring());}
    hardware.uart57.write(min);
}

setup();
reportTime();

// End of code.