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
#define ENCRYPTKEY    "sampleEncryptKey" //exactly the same 16 characters/bytes on all nodes!

RFM69 radio;

int LedPin = 5;

void setup() {
  
  // open serial port
  Serial.begin(SERIAL_BAUD);
  
  // LED
  pinMode(LedPin, OUTPUT);
  
  LEDBlink(80);
  LEDBlink(80);
  
  // initialize radio
  radio.initialize(FREQUENCY,NODEID,NETWORKID);
  radio.encrypt(ENCRYPTKEY);
  radio.promiscuous(false);

}


void loop() {
  
  int datalen;
  char charbuf;
  
  LEDPulse();
  
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
        //Serial.print(" - ACK sent");
      }
      
      // blink led
      LEDBlink(30);
      LEDBlink(30);
    
      
  }
}



// LED Pulse function
void LEDPulse() {
  int i;
  delay (12);
  for (int i = 18; i < 128; i++) { // loop from 0 to 254 (fade in)
    analogWrite(LedPin, i);      // set the LED brightness
    delay(12);
  }

  for (int i = 128; i > 18; i--) { // loop from 255 to 1 (fade out)
    analogWrite(LedPin, i); // set the LED brightness
    delay(12);       
  }
  //digitalWrite(LedPin, LOW);
  //delay (128);
}


// LED Blink function
void LEDBlink(int DELAY_MS)
{
  digitalWrite(LedPin,HIGH);
  delay(DELAY_MS);
  digitalWrite(LedPin,LOW);
  delay(DELAY_MS);
}


