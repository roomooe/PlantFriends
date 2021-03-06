/*

Plant Friends Gateway

Moteino communicates with the Pi via UART


RPI		Moteino
PIN2	5v	VIN
PIN6	GND	GND
PIN8	TX	RX
PIN10	RX	TX


Dickson Chow
http://dicksonchow.com

Edited for RFM69w by Johan Johansson

First Release: July 1, 2013.
Updated: June 25, 2014.


MIT License
http://opensource.org/licenses/mit-license.php


*/

#include <RFM69.h> //RFM69 transciever library
#include <SPI.h>

#define SERIAL_BAUD 115200 // define serial port speed
#define NODEID  1  // Node ID used for this unit. 1 is reserved for gateway
#define NETWORKID  20  //the network ID we are on
#define FREQUENCY     RF69_433MHZ
// #define ENCRYPTKEY    "sampleEncryptKey" //exactly the same 16 characters/bytes on all nodes!

RFM69 radio;

int RedLedPin = 3;
int GreenLedPin = 5;
int BlueLedPin = 6;

bool promiscuousMode = false; //set to 'true' to sniff all packets on the same network

void setup() {
  
  // open serial port
  Serial.begin(SERIAL_BAUD);
  
  // LED
  pinMode(RedLedPin, OUTPUT);
  pinMode(GreenLedPin, OUTPUT);
  pinMode(BlueLedPin, OUTPUT);
  
  delay(1000);
  LEDBlink(500);
  LEDBlink(500);
  delay(1000);
  LEDPulse(0);
  delay(1000);
  LEDPulse(1);
  delay(1000);
  LEDPulse(2);
  
  // initialize radio
  radio.initialize(FREQUENCY,NODEID,NETWORKID);
 // radio.encrypt(ENCRYPTKEY);
  radio.promiscuous(promiscuousMode);

}


void loop() {
  
  int datalen;
  char charbuf;
  int nodeID;
  
  if (radio.receiveDone()) // radio finishes recieving data
  {
      
      // get length
      for (byte i = 0; i < radio.DATALEN; i++)
      
      // dumps data to the serial port
      Serial.print((char)radio.DATA[i]);
      Serial.println();
     
      // sends ack to sensor node
      if (radio.ACKRequested())
      {
        radio.sendACK();
       
      // blink led
      nodeID = radio.DATA[0]- '0'-2;
      Serial.println(nodeID);
 LEDPulse(nodeID); 
 
      }
  }
}

// LED Pulse function
void LEDPulse(int a) {
  
  //define array for color pulses, (1/R, 1/G, 1/B)
  float nodeRGBColor[3][3]={
 {1,5,255},
 {1,5,3},
 {40,1,40}
};


  int i;
  delay (12);
  for (int i = 0; i < 255; i++) { // loop from 0 to 254 (fade in)
    analogWrite(RedLedPin, i/(nodeRGBColor[a][0]));      // set the LED brightness
    analogWrite(GreenLedPin, i/(nodeRGBColor[a][1]));      // set the LED brightness
    analogWrite(BlueLedPin, i/(nodeRGBColor[a][2]));      // set the LED brightness
    delay(10);
  }

  for (int i = 255; i > 0; i--) { // loop from 255 to 1 (fade out)
    analogWrite(RedLedPin, i/(nodeRGBColor[a][0]));      // set the LED brightness
    analogWrite(GreenLedPin, i/(nodeRGBColor[a][1]));      // set the LED brightness
    analogWrite(BlueLedPin, i/(nodeRGBColor[a][2]));      // set the LED brightness
    
    delay(10);       
  }
  digitalWrite(RedLedPin, LOW);
  digitalWrite(GreenLedPin, LOW);
  digitalWrite(BlueLedPin, LOW);
}


// LED Blink function
void LEDBlink(int DELAY_MS)
{
  digitalWrite(RedLedPin,HIGH);
  delay(DELAY_MS);
  digitalWrite(RedLedPin,LOW);
  delay(DELAY_MS);
}


