/*

Plant Friends Sensor Node

Sensor Node communicates with Moteino gateway.
Node contains soil moisture probe, temperature/humidity sensor and battery meter.


By Dickson Chow
http://dicksonchow.com

Edited for RFM69W by Johan Johansson

First Release: July 28th, 2013.
Updated: July 7th, 2014.

MIT License
http://opensource.org/licenses/mit-license.php


------------------------------

Soil Moisture Chart

 0 : in air @ 24c
 120 : skin
 0 - 250 : dry
 300 - 600 : moist 
 600 - 700 : soaked
 700 > : in water @ 24c
 1021 : direct short
 
 Needs further calibration
 
------------------------------
 
 Sensor Node Data Format
 
 NODEID:ErrorLvl:SoilMoist:TempC:Humid:Voltage
 
------------------------------

*/


// Include libraries
#include <DHT.h> // DHT sensor library
#include <LowPower.h> // low power library
#include <RFM69.h> // RFM69 radio library
#include <avr/sleep.h> // sleep library
#include <stdlib.h> // library for maths
#include <SPI.h>

// Soil moisture sensor define
#define moistPIN1 A2 // soil probe pin 1 with 56kohm resistor
#define moistPIN2 7 // soil probe pin 2 with 100ohm resistor
#define moistREADPIN1 A0 // analog read pin. connected to A2 PIN with 56kohm resistor


// DHT Humidity + Temperature sensor define
#define DHTPIN 5 // Data pin (D5) for DHT
#define DHTPWR 4 // turn DHT on and off via transistor
#define DHTTYPE DHT11 // sensor model DHT11
DHT dht(DHTPIN, DHTTYPE); // define DHT11


// Water level meter 
#define trigPin 8 // analogue voltage read pin for batery meter
#define echoPin 9 // current sink pin. ( enable voltage divider )
#define VoltageDivider 2 // if you have a voltage divider to read voltages, enter the multiplier here.

//Water pump pin
#define waterPumpPin 10



// LED Pin
#define led 6


// RADIO SETTINGS
// You will need to initialize the radio by telling it what ID it has and what network it's on
// The NodeID takes values from 1-127, 0 is reserved for sending broadcast messages (send to all nodes)
// The Network ID takes values from 0-255
#define NODEID       3  // The ID of this node. Has to be unique. 1 is reserved for the gateway!
#define NETWORKID    20  //the network ID we are on
#define GATEWAYID     1  //the gateway Moteino ID (default is 1)
#define ACK_TIME     2800  // # of ms to wait for an ack
//Match frequency to the hardware version of the radio on your Moteino (uncomment one):
#define FREQUENCY   RF69_433MHZ
//#define FREQUENCY   RF69_868MHZ
//#define FREQUENCY     RF69_915MHZ
// #define ENCRYPTKEY    "sampleEncryptKey" //exactly the same 16 characters/bytes on all nodes!



// Power Management Sleep cycles
int sleepCycledefault = 1; // Sleep cycle 450*8 seconds = 1 hour. DEFAULT 450
int soilMoistThresh = 250; // soil moisture threshold. reference chart
long minWaterLevel = 21; // Water level threshold, dependant on water tank

String senseDATA; // sensor data STRING
String ErrorLvl = "0"; // Error level. 0 = normal. 1 = soil moisture, 2 = Temperature , 3 = Humidity, 4 = Battery voltage


// Need an instance of the Radio Module
RFM69 radio;
bool requestACK=true;


void setup()
{
  
  Serial.begin(9600);
 
  //LED setup. 
  pinMode(led, OUTPUT);
  
  // Water Meter setup
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  
  // Water pump setup
  pinMode(waterPumpPin, OUTPUT);
  digitalWrite(waterPumpPin, LOW);
 
  // Moisture sensor pin setup
  pinMode(moistPIN1, OUTPUT);
  pinMode(moistPIN2, OUTPUT);
  pinMode(moistREADPIN1, INPUT);
  
  // Humidity sensor setup
  pinMode(DHTPWR, OUTPUT);
  dht.begin();

  // power on indicator
  LEDBlink(80);
  LEDBlink(80);
   
  // Initialize the radio
  radio.initialize(FREQUENCY,NODEID,NETWORKID);
  // radio.encrypt(ENCRYPTKEY);
  radio.sleep(); //sleep right away to save power
  
}

void loop()
{
  
  int distance;
  int moistREADavg;
  int sleepCYCLE = sleepCycledefault; // Sleep cycle reset
  ErrorLvl = "0"; // Reset error level
  
  delay(5000);
  
  // Water level check
  distance = waterLevelREAD();
  
  // Soil Moisture sensor reading
  moistREADavg = moistREAD();
  
    // Turn on waterpump if there is water in tank and soil moisture is low
  while ( moistREADavg < soilMoistThresh && distance < minWaterLevel && distance != 0 ){
    watering();
    moistREADavg = moistREAD();  // update soil moisture and distance after watering in case tank is empty.
    distance = waterLevelREAD();
  }
    
  // if water level is below threshold assign error level
  if (distance > minWaterLevel){
    ErrorLvl = "4"; 
    LEDBlink(128);
    LEDBlink(128);
    LEDBlink(128);
  }
    
  if (distance == 0){
    ErrorLvl = "5"; 
    LEDBlink(128);
    LEDBlink(128);
    LEDBlink(128);
  }
  
  // if soil is below threshold, error level 1
  if ( moistREADavg < soilMoistThresh ) {
    ErrorLvl += "1"; // assign error level
    LEDBlink(128);
    LEDBlink(128);
    LEDBlink(128);
  }
    
    
    
  // Humidity + Temperature sensor reading
  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  digitalWrite(DHTPWR, HIGH); // turn on sensor
  delay (38); // wait for sensor to stabalize
  int dhttempc = dht.readTemperature(); // read temperature as celsius
  int dhthumid = dht.readHumidity(); // read humidity
  Serial.println(dhttempc);
  
  // check if returns are valid, if they are NaN (not a number) then something went wrong!
  if (isnan(dhttempc) || isnan(dhthumid) || dhttempc == 0 || dhthumid == 0 ) {
    dhttempc = 0;
    dhthumid = 0;
    ErrorLvl += "23";
  }
  delay (18);
  digitalWrite(DHTPWR, LOW); // turn off sensor


  // PREPARE READINGS FOR TRANSMISSION
  senseDATA = String(NODEID);
  senseDATA += ":";
  senseDATA += ErrorLvl;
  senseDATA += ":";
  senseDATA += String(moistREADavg);
  senseDATA += ":";
  senseDATA += String(dhttempc);
  senseDATA += ":";
  senseDATA += String(dhthumid);
  senseDATA += ":";
  senseDATA += String(distance);
  //char VoltagebufTemp[10];
 // dtostrf(distance,5,3,VoltagebufTemp); // convert float Voltage to string
 // senseDATA += VoltagebufTemp;
  byte sendSize = senseDATA.length();
  sendSize = sendSize + 1;
  char sendBuf[sendSize];
  senseDATA.toCharArray(sendBuf, sendSize); // convert string to char array for transmission
  Serial.println(senseDATA);

  
    
  //Transmit the data
   // pulse the LED
  if (radio.sendWithRetry(GATEWAYID, sendBuf, sendSize)) // send the data
 {
    Serial.println(" ok!");
      //ack recieved
 }else {
        //ack not recieved
		Serial.println(" nothing...");
        LEDPulse ();
        sleepCYCLE = sleepCYCLE / 2; // since we didnt recieve ack, halve sleep cycle
      }
 
  radio.sleep(); // sleep the radio to save power
  
  
  

  // Error Level handing
  // If any error level is generated, halve the sleep cycle
  if ( ErrorLvl.toInt() > 0 ) {
    // sleepCYCLE = sleepCYCLE / 2;
    LEDBlink(30);
    LEDBlink(30);
    LEDBlink(30);
  }
  
  
  
  
  // Randomize sleep cycle a little to prevent collisions with other nodes
  sleepCYCLE = sleepCYCLE;



  // POWER MANAGEMENT DEEP SLEEP
  // after everything is done, go into deep sleep to save power
  for ( int sleepTIME = 0; sleepTIME < sleepCYCLE; sleepTIME++ ) {
    LowPower.powerDown(SLEEP_8S, ADC_OFF, BOD_OFF); //sleep duration is 8 seconds multiply by the sleep cycle variable.
  }

}

// LED Blink function
void LEDBlink(int DELAY_MS)
{
  digitalWrite(led,HIGH);
  delay(DELAY_MS);
  digitalWrite(led,LOW);
  delay(DELAY_MS);
}

// Watering function
void watering () {


    digitalWrite(waterPumpPin, HIGH);
    delay(1000);
    digitalWrite(waterPumpPin, LOW);
    delay(1000);
    
    
    
  }


// LED Pulse function
void LEDPulse() {
  int i;
  delay (88);
  for (int i = 0; i < 88; i++) { // loop from 0 to 254 (fade in)
    analogWrite(led, i);      // set the LED brightness
    delay(12);
  }

  for (int i = 88; i > 0; i--) { // loop from 255 to 1 (fade out)
    analogWrite(led, i); // set the LED brightness
    delay(12);       
  }
  digitalWrite(led, LOW);
  delay (128);
}


int waterLevelREAD() {
  long duration;
  int distance = 0; // reset distance before read
  digitalWrite(trigPin, LOW);  
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10); 
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance =+ (duration/2) / 29.1;
  digitalWrite(trigPin, LOW); // reset the water meter
  Serial.print("Water level: ");
  Serial.println(distance);

  return distance;
  
}

// Moisture sensor reading function

int moistREAD() {
  
  int moistCycle = 3; // how many times to read the moisture level. default is 3 times
  int moistREADavg = 0; // reset the moisture level before reading

  
  for ( int moistReadCount = 0; moistReadCount < moistCycle; moistReadCount++ ) {
  
    int moistAVG = 0; // reset before reading
    int moistREADdelay = 88; // delay to reduce capacitive effects
    // polarity 1 read
    digitalWrite(moistPIN1, HIGH);
    digitalWrite(moistPIN2, LOW);
    delay (moistREADdelay);
    int moistVal1 = analogRead(moistREADPIN1);
    Serial.println(moistVal1);
    digitalWrite(moistPIN1, LOW);
    delay (moistREADdelay);
    // polarity 2 read
    digitalWrite(moistPIN1, LOW);
    digitalWrite(moistPIN2, HIGH);
    delay (moistREADdelay);
    int moistVal2 = analogRead(moistREADPIN1);
    //Make sure all the pins are off to save power
    digitalWrite(moistPIN2, LOW);
    digitalWrite(moistPIN1, LOW);
    moistVal1 = 1023 - moistVal1; // invert the reading
    Serial.println(moistVal2);
    moistAVG = (moistVal1 + moistVal2) / 2; // average readings. report the levels
    moistREADavg += moistAVG;
  }
  moistREADavg = moistREADavg / moistCycle; // average the results
  Serial.print("Soil Moisture: ");
  Serial.println(moistREADavg);
  return moistREADavg;
}





