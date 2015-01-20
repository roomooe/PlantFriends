/*
  Plant Friends Android App
  
  Gets data from Plant Friends base station and displays it.
  
  DATA FORMAT:
  0 DATE : 1 ERROR LEVEL : 2 SOIL MOISTURE : 3 TEMPERATURE in C : 4 HUMIDITY : 5 BATTERY VOLTAGE

  Created by Dickson Chow
  http://dicksonchow.com
  
  Edited by Johan Johansson

  First release: August 8, 2013
  Updated: July 26, 2014


  The Plant Friends MKII software, source code, Arduino sketchs and Processing sketches is released under The MIT License.
  http://opensource.org/licenses/mit-license.php

  The Plant Friends name, logo, UI and all associated graphic design is Copyright © 2014 Dickson Chow.
  
  
  
  ToDo:
  implement gestures to go between screens
  scroll through list of nodes.
  do something with errorlvl data.
  allow server settings to be entered in app.
  customizable colors.
  
  --------------------------------------------------
  
  Soil Moisture Sensor Chart:

  0 : in air @ 24c
  120 : skin
  120 - 250 : dry soil
  300 - 600 : moist soil
  600 - 700 : soaked soil
  700 > : in water @ 24c
  1021 : direct short
float[][] nodeLib = {
  {62*widthStretch,58*heightStretch},{270*widthStretch,116*heightStretch},{432*widthStretch,56*heightStretch},{574*widthStretch,128*heightStretch},{721*widthStretch,76*heightStretch},
  {72*widthStretch,329*heightStretch},{150*widthStretch,208*heightStretch},{282*widthStretch,307*heightStretch},{400*widthStretch,232*heightStretch},{544*widthStretch,281*heightStretch},{673*widthStretch,226*heightStretch},{729*widthStretch,349*heightStretch},
  {532*widthStretch,418*heightStretch},{663*widthStretch,502*heightStretch},{721*widthStretch,617*heightStretch},
  {55*widthStretch,717*heightStretch},{240*widthStretch,716*heightStretch},{448*widthStretch,759*heightStretch},{612*widthStretch,708*heightStretch},
  {37*widthStretch,923*heightStretch},{186*widthStretch,843*heightStretch},{351*widthStretch,876*heightStretch},{544*widthStretch,887*heightStretch},{697*widthStretch,834*heightStretch},
  {175*widthStretch,1004*heightStretch},{387*widthStretch,1004*heightStretch},{583*widthStretch,1011*heightStretch},{694*widthStretch,983*heightStretch},
  {79*widthStretch,1116*heightStretch},{294*widthStretch,1140*heightStretch},{490*widthStretch,1104*heightStretch},{703*widthStretch,1122*heightStretch},
};
*/

import ketai.ui.*;
KetaiGesture gesture;

// Server settings. Change IP address or hostname accordingly.
 static final String NodeIndexURL = "http://192.168.1.86";


// for accessing node specific data
static final String NodeURL = NodeIndexURL + "/index.php?NodeID=";

// Screen resolution of device, uncomment size() in void setup beforerunning on mobile
float monitorWidth = 540;
float monitorHeight = 960;

// colours
color leaf = #099500; // logotype leaf
color shadow = #eaeaea; // drop shadow
//color shadow = #d5d5d5; // drop shadow
color white = #fff9f0; //bg
color whitebox = #fffbf6; 
color whitetype = #fbf9f1; // white type
color greylit = #e9e9e9; // for graph bg
color greybg = #e8e8e8; // background
color greypas = #dad7d3; // batt and arrow
color grey = #a1a1a1; // batt
color blacktype = #555554; //black type
color blue = #2989cd; //icon
color blueskypas = #bff1f2; // humid
color bluesky = #18d6e7; // humid
color bluebaby = #63d1fd; // icon
color teal = #29b8a8; // icon
color tealpas = #7ce6da; // icon
color green = #30a526; //icon
color greenpas = #c6e7c3; // soilmoist
color greengrass = #8fb95e; // header + soilmoist
color greenlit = #d0fe4a; // icon
color yellow = #f2de00; //icon
color yellowlit = #fff19a; //icon
color brown = #8d6e63; //soil moisture
color brownlit = #d7ccc8; //soil mositure
color orangelit = #ffb767; //icon
color orange = #ff9936; //icon
color orangered = #ff452c; //icon
color orangeredpas = #ffcebb; // temp
color orangeredtemp = #ff5b22; // temp
color red = #c92b2b; //icon
color pinkhothot = #ff0387; //icon
color pinkhot = #ff2a98; //icon
color pinkmid = #ff93cb; //details screen? test with brightness
color pink = #ffbcd6; //icon pink proper
color pinkpurple = #ff65d5; //icon maybe for splash only
color purple = #b770ff; //icon
color cyanpas = #ebf8fa; //splash screen background
color cyan =  #00bcd4;
color cyanpaspas = #b2ebf2;

// colour pallete for assigning random colours to splash
color[] pallete = {blue,green,blueskypas,bluebaby,teal,green,greengrass,greenpas,greenlit,yellow,yellowlit,brown,orangelit,orange,orangered,red,pinkhothot,pinkhot,pink,pinkmid,pinkpurple,purple};

// colour pallete for node details and node menu icons
color[][] palleteNode = {
{pinkhot,pink},
{orange,orangelit},
{greengrass,greenpas},
{cyan,cyanpaspas},
{yellow,yellowlit},
{teal,tealpas},
{bluebaby,blueskypas},
{pinkmid,pink},
};

color[] pastell = {pink,tealpas,orangelit,blueskypas,greenpas,yellowlit,purple};

// fonts
//static PFont fontbold;
static PFont fontmed;
static PFont fontreg;
static PFont fontlit;


// shapes and images
PShape nodeshape; // draw node icon
PImage logosplash; // logotype for splash
PImage logohead; // logotype for header


//Stretches GUI
float widthStretch = monitorWidth/768;
float heightStretch = monitorHeight/1184;


// coordinates of node icons for splash screen
// x,y,rotate,scale,color
float[][] nodeLib = {
  {62*widthStretch,58*heightStretch},{270*widthStretch,116*heightStretch},{574*widthStretch,128*heightStretch},{721*widthStretch,76*heightStretch},
{150*widthStretch,208*heightStretch},{282*widthStretch,307*heightStretch},{544*widthStretch,281*heightStretch},{673*widthStretch,226*heightStretch},
  {532*widthStretch,418*heightStretch},{663*widthStretch,502*heightStretch},
  {55*widthStretch,717*heightStretch},{240*widthStretch,716*heightStretch},{612*widthStretch,708*heightStretch},
  {37*widthStretch,923*heightStretch},{351*widthStretch,876*heightStretch},{544*widthStretch,887*heightStretch},
  {175*widthStretch,1004*heightStretch},{387*widthStretch,1004*heightStretch},{694*widthStretch,983*heightStretch},
  {79*widthStretch,1116*heightStretch},{490*widthStretch,1104*heightStretch},{703*widthStretch,1122*heightStretch},
};

// splash screen variables to generate some randomness
float[] rS = {0,45,90,135,180,225,270,315}; // rotation points
float[] rSx = {0,90,180,270}; // rotation points for node icons in node menu
int[] rSi;
color[] nodeC; // colorer
float[] nodeRs; // rotater
float[] nodeT; // timer
float[] nodeS; // scaler
float[] nodeCurves; // flower sketch
float[] nodeCurves1;
float[] nodeCurves2;
float[] nodeCurves3;


// Screen / menu control
// 0:splash, 1:node menu, 2:node details
int screenSelect = 0; 
int tempSelect = 0;


// Animation
float easing = 0.14; // splash screen icon easing
float lFade = -80; // logotype fader

// master transform cords for menu animations
float masterX = 0;
float masterY = 0;
float measing = 0.14; // menu easing
float targetX = -monitorWidth;
float targetX2 = -monitorWidth*2;
float travelX = 0;


// details screen vars
int[]dateForward = {60-58,60+58,500-58,500+58}; // date forward bounding box <
int[]dateBack = {768-60-58,768-60+58,500-58,500+58}; // date back bounding box >
int dataDay = 0; // temp var for day select
boolean tempToggle = false; // toggle temperature c/f
boolean dateForwardx;
boolean dateBackx;
boolean tempTogglex;
int[][] bBoxDetail; // bounding boxes


// back button on node menu and node details
float[] refreshIDX = {(712-58)*widthStretch,(712+58)*widthStretch,(76-58)*heightStretch,(76+58)*heightStretch};


// Node menu vars
NodeBox[] nodeBoxie;
float margin = 12*widthStretch;
float dshadow = 3*(widthStretch+heightStretch)*0.5;
float pad = 6*(widthStretch+heightStretch)*0.5;
float  headerBoxH = 248*heightStretch;
float nodeBoxH = 122*heightStretch;
float[][] bBoxNode; // bounding box array.  nodeid => x, x, y, y


// global vars for storing data of all nodes
String[][] NodeIndex; // data format INDEX => NODEID : NODE ALIAS : PLANT NAME : LOCATION : COMMENTS :  NODE ICON ROTATION : NODE ICON COLOR(not used right now)
String[][][] NodeDetail; // data format INDEX => 0 DATE : 1 ERROR LEVEL : 2 SOIL MOISTURE : 3 TEMPERATURE in C : 4 HUMIDITY : 5 BATTERY VOLTAGE
String NodeID; // the id number of the actual node. relate this to NodeIdex to access all the data in arrays
int NodeIdex = 0; // see above
int loadIndexStatus = 0;
int loadDetailStatus = 0;
int allLoaded = 0;
float xk;
float sum; // count to make sure splah image is done animating itself






void setup() {
  // nexus 4 screen size sans bottom menu bar
 size(540, 960);
 
  // the hamburger way
  orientation(PORTRAIT);  

  // doesn't do anything on android?
  smooth(); 
  
  // Load images
  logosplash = loadImage("logotype_bow.png");
  logohead = requestImage("logotype_wog.png");

  // Generate node icons for splash image. spawns thread
  thread("splashGen");
  
  // Loads the NodeIndex. Spawns thread.
  thread("loadNodeIndex");

  // Alternate font set. from google, safe to distribute
  fontmed = createFont("Penelope-Anne.ttf", 50*(widthStretch+heightStretch)*0.5, true);
  fontreg = createFont("Penelope-Anne.ttf", 72*(widthStretch+heightStretch)*0.5, true);
  fontlit = createFont("Penelope-Anne.ttf", 48*(widthStretch+heightStretch)*0.5, true);//
}




void draw() {
  // Screen selection

  switch (screenSelect) {
    case 0:
      //display splash screen
      splashScreen();
      allLoaded = loadIndexStatus+loadDetailStatus; // make sure everything is loaded ie. data from server
      // animate into node menu screen
      if (allLoaded == 2 && sum > xk) { 
        nodeScreen();
        travelX = targetX - masterX;
        masterX += travelX * measing;
        if ( masterX <= -767*widthStretch ) {masterX=-width; screenSelect = 1; } 
      } else { screenSelect = 0; }
    break;
    case 1: 
      // display nodes. main menu
      nodeScreen();
      // make sure to not switch modes too prematurely cause shit breaks. boo.
      // animate into details screen
      if (tempSelect == 1 ) {
        detailScreen();
        travelX = targetX2 - masterX;
        masterX += travelX * measing;
        if ( masterX <= -1535*widthStretch) {masterX=-width*2; screenSelect = 2; }
      } 
      if (tempSelect == 3 ) {
        ax = ax*1.3;
        if (ax <= 265) {
          fill(white,ax);
          rect(0,0,width,height);
          //println(ax);
        }
        if (ax > 255) {
          //reset everything
          screenSelect = 0;
          tempSelect = 0;
          masterX = 0;
          splashScreen();
          ax = 255;
          thread("splashGen");
          thread("loadNodeIndex");
        }
      }
    break;
    case 2: 
      // display details screen
      detailScreen();
      // animate back to node menu screen
      if (tempSelect == 2 ) {
        nodeScreen();
        travelX =  - masterX / widthStretch/ widthStretch;
        masterX += travelX * measing;
        if ( masterX >= -767*widthStretch){masterX=-width; screenSelect = 1; tempSelect=0; }
      }

    break;
    default: 
      screenSelect = 0;
    break;
  }
}





















