import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class plant_friends extends PApplet {

/*

  Plant Friends Android App
  
  Gets data from Plant Friends base station and displays it.
  
  DATA FORMAT:
  0 DATE : 1 ERROR LEVEL : 2 SOIL MOISTURE : 3 TEMPERATURE in C : 4 HUMIDITY : 5 BATTERY VOLTAGE

  Dickson Chow
  http://dicksonchow.com

  First release: August 8, 2013
  Updated: July 26, 2014


  The Plant Friends MKII software, source code, Arduino sketchs and Processing sketches is released under The MIT License.
  http://opensource.org/licenses/mit-license.php

  The Plant Friends name, logo, UI and all associated graphic design is Copyright \u00a9 2014 Dickson Chow.
  
  
  
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

*/

 
// Server settings. Change IP address or hostname accordingly.
static final String NodeIndexURL = "http://RASPIADDRESSS:PORT";

// for accessing node specific data
static final String NodeURL = NodeIndexURL + "/index.php?NodeID=";

// colours
int leaf = 0xff099500; // logotype leaf
int shadow = 0xffeaeaea; // drop shadow
//color shadow = #d5d5d5; // drop shadow
int white = 0xfffff9f0; //bg
int whitebox = 0xfffffbf6; 
int whitetype = 0xfffbf9f1; // white type
int greylit = 0xffe9e9e9; // for graph bg
int greybg = 0xffe8e8e8; // background
int greypas = 0xffdad7d3; // batt and arrow
int grey = 0xffa1a1a1; // batt
int blacktype = 0xff555554; //black type
int blue = 0xff2989cd; //icon
int blueskypas = 0xffbff1f2; // humid
int bluesky = 0xff18d6e7; // humid
int bluebaby = 0xff63d1fd; // icon
int teal = 0xff29b8a8; // icon
int tealpas = 0xff7ce6da; // icon
int green = 0xff30a526; //icon
int greenpas = 0xffc6e7c3; // soilmoist
int greengrass = 0xff8fb95e; // header + soilmoist
int greenlit = 0xffd0fe4a; // icon
int yellow = 0xfff2de00; //icon
int yellowlit = 0xfffff19a; //icon
int brown = 0xffdbb8a8; //icon
int orangelit = 0xffffb767; //icon
int orange = 0xffff9936; //icon
int orangered = 0xffff452c; //icon
int orangeredpas = 0xffffcebb; // temp
int orangeredtemp = 0xffff5b22; // temp
int red = 0xffc92b2b; //icon
int pinkhothot = 0xffff0387; //icon
int pinkhot = 0xffff2a98; //icon
int pinkmid = 0xffff93cb; //details screen? test with brightness
int pink = 0xffffbcd6; //icon pink proper
int pinkpurple = 0xffff65d5; //icon maybe for splash only
int purple = 0xffb770ff; //icon


// colour pallete for assigning random colours to splash
int[] pallete = {blue,green,blueskypas,bluebaby,teal,green,greengrass,greenpas,greenlit,yellow,
yellowlit,brown,orangelit,orange,orangered,red,pinkhothot,pinkhot,pink,pinkmid,pinkpurple,purple};


// colour pallete for node details and node menu icons
int[][] palleteNode = {
{pinkhot,pink},
{teal,tealpas},
{orange,orangelit},
{bluebaby,blueskypas},
{greengrass,greenpas},
{pinkmid,pink},
{yellow,yellowlit},
{purple,purple},
};



// fonts
//static PFont fontbold;
static PFont fontmed;
static PFont fontreg;
static PFont fontlit;


// shapes and images
PShape nodeshape; // draw node icon
PImage logosplash; // logotype for splash
PImage logohead; // logotype for header


// coordinates of node icons for splash screen
// x,y,rotate,scale,color
float[][] nodeLib = {
  {62,58},{270,116},{432,56},{574,128},{721,76},
  {72,329},{150,208},{282,307},{400,232},{544,281},{673,226},{729,349},
  {532,418},{663,502},{721,617},
  {55,717},{240,716},{448,759},{612,708},
  {37,923},{186,843},{351,876},{544,887},{697,834},
  {175,1004},{387,1004},{583,1011},{694,983},
  {79,1116},{294,1140},{490,1104},{703,1122},
};


// splash screen variables to generate some randomness
float[] rS = {0,45,90,135,180,225,270,315}; // rotation points
float[] rSx = {0,90,180,270}; // rotation points for node icons in node menu
int[] rSi;
int[] nodeC; // colorer
float[] nodeRs; // rotater
float[] nodeT; // timer
float[] nodeS; // scaler


// Screen / menu control
// 0:splash, 1:node menu, 2:node details
int screenSelect = 0; 
int tempSelect = 0;


// Animation
float easing = 0.14f; // splash screen icon easing
float lFade = -80; // logotype fader

// master transform cords for menu animations
float masterX = 0;
float masterY = 0;
float measing = 0.17f; // menu easing
float targetX = -768;
float targetX2 = -1538;
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
float[] refreshIDX = {712-58,712+58,76-58,76+58};


// Node menu vars
NodeBox[] nodeBoxie;
int margin = 12;
int dshadow = 3;
int pad = 6;
int headerBoxH = 248;
int nodeBoxH = 122;
int[][] bBoxNode; // bounding box array.  nodeid => x, x, y, y


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






public void setup() {
  
  // nexus 4 screen size sans bottom menu bar
  size(768, 1184);
  
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
  fontmed = createFont("Roboto-Medium.ttf", 50, true);
  fontreg = createFont("Roboto-Regular.ttf", 72, true);
  fontlit = createFont("Roboto-Light.ttf", 48, true);


}




public void draw() {
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
        if ( masterX <= -767 ) { screenSelect = 1; } 
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
        if ( masterX <= -1535) { screenSelect = 2; }
      } 
      if (tempSelect == 3 ) {
        ax = ax*1.3f;
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
        travelX = targetX - masterX;
        masterX += travelX * measing;
        if ( masterX >= -769 ) { screenSelect = 1; tempSelect=0; }
      }
    break;
    default: 
      screenSelect = 0;
    break;
  }
}























// Loads the NodeIndex and NodeDetails
// connects to raspi to grab all the sensor node data and dumps into arrays

// Load node index
public void loadNodeIndex() {
  String[] tempData1;
  String[] tempData2;

  tempData1 = loadStrings(NodeIndexURL);
  
  NodeIndex = new String[tempData1.length][0];

  // split the data into multi dim array
  for (int x = 0 ; x < tempData1.length ; x++ ) {
    tempData2 = split(tempData1[x],':');
      for (int xi = 0 ; xi < tempData2.length ; xi++ ) {
        NodeIndex[x]= append(NodeIndex[x],tempData2[xi]);
      }
  }

  // generate random color for node icons on menu and details screen. currently not used
  for (int xix = 0 ; xix < NodeIndex.length ; xix++ ) {
    NodeIndex[xix]= append(NodeIndex[xix],str(random(0,palleteNode.length)));
  }
  
  // generate random rotation for node icons on node menu screen and details screen. appends to Nodeindex  
  for (int xix = 0 ; xix < NodeIndex.length ; xix++ ) {
    NodeIndex[xix]= append(NodeIndex[xix],str(random(0,rSx.length)));
  }

  //printArray(NodeIndex[1]); // debug
  //println("load index done"); // debug
  
  loadIndexStatus = 1; // done loading
  
  // Load node details
  int xDays = 6; // number of days of data. first dataset is right now.
  String[][] NodeDetailY;
  NodeDetail = new String[NodeIndex.length][xDays][0]; // initialize array. append datatypes
  
  for (int x = 0 ; x < NodeIndex.length ; x++ ) {
    
    NodeID = NodeIndex[x][0];
    NodeDetailY = loadNodeDetail(NodeID);

    for (int xi = 0 ; xi < NodeDetailY.length ; xi++ ) {
      for (int xe = 0 ; xe < NodeDetailY[xi].length ; xe++ ) {
        NodeDetail[x][xi] = append(NodeDetail[x][xi],NodeDetailY[xi][xe]);
        //println (NodeDetail[x][xi]);
      }
    }
  }
  
  // Generates array of objects for each node. display on node menu screen
  //NodeIndex[yy][5] // for color
  int offset = 0;
  int index = 0;
  
  // bounding box init
  bBoxNode = new int[NodeIndex.length][4];
  
  // get node index stuff
  nodeBoxie = new NodeBox[NodeIndex.length];
  
  for (int yy = 0; yy < nodeBoxie.length; yy++) {
    offset = (nodeBoxH+dshadow+pad) * yy; // offsets each node. for spacing
    
    //NodeB(int tempposx, int tempposy, color nodeColor, String nodeRstemp, String tempNodeID, String tempNodeName, String tempPlant, String tempSoil, String tempTemp, String tempHumid, String tempVolt)
    nodeBoxie[yy] = new NodeBox(0,offset,palleteNode[yy][0],NodeIndex[yy][6],NodeIndex[yy][0],NodeIndex[yy][1],NodeIndex[yy][2],NodeDetail[yy][0][2],NodeDetail[yy][0][3],NodeDetail[yy][0][4],NodeDetail[yy][0][5]);
   
    //generate bounding box
    bBoxNode[yy][0] = 0;
    bBoxNode[yy][1] = width;
    bBoxNode[yy][2] = headerBoxH+dshadow+2+offset;
    bBoxNode[yy][3] = headerBoxH+dshadow+2+nodeBoxH+dshadow+pad+offset;

  }
  
  //println("load details done"); // debug
  loadDetailStatus = 1; // done loading
}





// Load Node Details function called from loadNodeIndex
public String[][] loadNodeDetail(String NodeID) {
  String[] tempData1;
  String[] tempData2;

  //tempData1 = loadStrings(NodeIndexURL);
  tempData1 = loadStrings(NodeURL+NodeID);
  
  //printArray(tempData1);
  
  String[][] NodeDetailx = new String[tempData1.length][0];

  // split the data into multi dim array
  for (int x = 0 ; x < tempData1.length ; x++ ) {
    tempData2 = split(tempData1[x],':');
      for (int xi = 0 ; xi < tempData2.length ; xi++ ) {
        NodeDetailx[x]= append(NodeDetailx[x],tempData2[xi]);

      }
  }
 // printArray(NodeDetailx[5]);
  //loadDetailStatus = 1; // done loading
  return(NodeDetailx);
}



// Node details screen
// NodeIdex controls everything

public void detailScreen() {
  pushMatrix();
  
  translate(masterX+width+width, masterY);
  rectMode(CORNER);
  fill(palleteNode[NodeIdex][0]);
  noStroke();
  rect(0,0,width,height);

  //background(palleteNode[NodeIdex][0]);
  
  pushMatrix();
  //translate(0,0);
  
  // large icon
  nodeIcon(112,112,0,3,white);
  
  // back icon
  nodeIcon(712,76,-45,0.8f,white);

  int textMargin1 = 208;
  
  int textMargin2 = 112;
  
  // Plant name
  textFont(fontreg,68);
  textAlign(LEFT);

  fill(blacktype);
  
  String nName = NodeIndex[NodeIdex][2];
  nName = nName.toUpperCase();
  text(nName, textMargin1-4, 104);
    
  // node name
  textFont(fontmed,26);
  nName = NodeIndex[NodeIdex][1];
  nName = nName.toUpperCase();
  text(nName, textMargin1, 150);
    
  // node id
  nName = "node id " + NodeIndex[NodeIdex][0];
  nName = nName.toUpperCase();
  text(nName, textMargin1, 180);

  
  // location
  textFont(fontmed,18);
  nName = "location";
  nName = nName.toUpperCase();
  text(nName, textMargin1, 234);

  // comments
  nName = "comments";
  nName = nName.toUpperCase();
  text(nName, textMargin1, 312);
    
  // location text
  textFont(fontlit,32);
  nName = NodeIndex[NodeIdex][3];
  text(nName, textMargin1, 270);

  // comments text
  nName = NodeIndex[NodeIdex][4];
  text(nName, textMargin1, 348);
  
  
  popMatrix();
  

  //  data details
  pushMatrix();
  translate(0,400);
  rectMode(CORNER);
  fill(palleteNode[NodeIdex][1]);
  rect(0,0,width,496);

  // date forward < icon
  nodeIcon(60,100,-45,0.6f,white);
  
  // date back > icon
  nodeIcon(width-60,100,135,0.6f,white);

  textFont(fontmed,18);
  fill(blacktype);
  
  // generate day display cycling
  // make sure dataDay doesn't go out of bounds
  if ( dataDay < 0 ) { dataDay = 0; }
  if ( dataDay > 5 ) { dataDay = 5; }
  
  // showing data for
  if (dataDay == 0) { nName = "right now"; } else { nName = "showing data for"; }

  nName = nName.toUpperCase();
  text(nName, textMargin2, 68);

  // date
  textFont(fontmed,50);
  nName = NodeDetail[NodeIdex][dataDay][0].replace("-"," ");
  text(nName, textMargin2, 120);

  //spacing=74
    
  // soil moist title
  textFont(fontmed,24);
  nName = "soil moisture";
  nName = nName.toUpperCase();
  text(nName, textMargin2, 198);
    
  // humidity title
  nName = "humidity";
  nName = nName.toUpperCase();
  text(nName, textMargin2, 272);

  // warmth title
  nName = "warmth";
  nName = nName.toUpperCase();
  text(nName, textMargin2, 272+74);

  // battery title
  nName = "battery";
  nName = nName.toUpperCase();
  text(nName, textMargin2, 272+74+74);
    
  // data margin
  int dMargin = 390;

  // soil moist data
  textFont(fontlit,46);
  nName = NodeDetail[NodeIdex][dataDay][2];
  nName = nName.toUpperCase();
  text(nName, dMargin, 204);
    
    
    
  // humid data
  nName = NodeDetail[NodeIdex][dataDay][4] + "%";
  text(nName, dMargin, 204+74);

  // toggle temperature C or F
  if (tempToggle) { 
    nName = nf((PApplet.parseFloat(NodeDetail[NodeIdex][dataDay][3])*9/5+32),2,1) + " \u00baF";
  } else { 
    nName = NodeDetail[NodeIdex][dataDay][3] + " \u00baC";
  }
    
  // warmth data
  text(nName, dMargin, 204+74+74);
  
  // battery data
  nName = nf(PApplet.parseFloat(NodeDetail[NodeIdex][dataDay][5]),1,2) + "v";
  text(nName, dMargin, 204+74+74+74);

  // color legend
  int cMargin = 608;

  // soil moist
  fill(greengrass);
  rect(cMargin,180,46,14);
    
  // humid
  fill(bluesky);
  rect(cMargin,180+74,46,14);
   
  // warmth
  fill(orangeredtemp);
  rect(cMargin,180+74+74,46,14);

  // battery
  fill(grey);
  rect(cMargin,180+74+74+74,46,14);
   
  popMatrix();
  

  //  graph
  pushMatrix();
  translate(0,890);
  rectMode(CORNER);
  fill(white);
  noStroke();
  rect(0,0,width,298);
   
  int gMargin = 48;
  int gspace = (width-(gMargin*2))/5;

  // graph type
  textFont(fontmed,18);
  textAlign(CENTER);
  fill(blacktype);
   
  
  // draw dates in as M/dd on graph 
  pushMatrix();
  translate(gMargin,0);
  nName = "No Data";
  String[] dateGx;
  for ( int i = 0 ; i < 6 ; i++ ) {
    if ( NodeDetail[NodeIdex][i][0].equals("No Data") == false) {
      dateGx = split(NodeDetail[NodeIdex][i][0],'-');
      dateGx[0] = dateGx[0].substring(0,3);
      dateGx[1] = dateGx[1].substring(0,2);
      dateGx[1] = dateGx[1].replace("s","");
      dateGx[1] = dateGx[1].replace("t","");
      nName = dateGx[0] + " " + dateGx[1];
        if ( i == 0 ) { nName = "NOW"; }
    } else { nName = "No Data"; }
    text(nName, gspace*i, 44);
  }
  

  // GRAPHS!!

  // draw the graph for each datatype. NodeIndex is global set and changed before entering the details screen. 
  //int datatype, int contLow, int contHigh, color gColor, int dGdot, int dGstroke, int gspace
  
  // Soil Moisture graph. Mapped to 150 - 750 ADC value.
  grapher(2,150,750,greengrass,14,3,gspace);

  // humidity graph. Mapped to 0 - 90%
  grapher(4,0,90,bluesky,12,3,gspace);

  // Temperature graph. Mapped to 0 - 49c.
  grapher(3,0,49,orangeredtemp,10,3,gspace);
  
  // Battery voltage graph. Mapped to 3.3 - 6 volts.
  grapher(5,3.3f,6,grey,8,3,gspace);
  
  popMatrix();
  popMatrix();
  popMatrix();
}

// Draw node icon
// x,y,rotate,scale,color
public void nodeIcon(float posx, float posy, float srotate, float sscale, int scolor){
  pushMatrix();
  translate(posx,posy);
  rotate(radians(srotate));
  scale(sscale);
  pushMatrix();
  translate(-23,-23);
  noStroke();
  fill(scolor);
  beginShape();
  vertex(0,0);
  vertex(46,0);
  vertex(46,23);
  vertex(23,23);
  vertex(23,46);
  vertex(0,46);
  endShape(CLOSE);
  popMatrix();
  popMatrix();
}



// generate purdy splash image
public void splashGen () {
  // Generate node icons for splash image
  nodeRs = new float [nodeLib.length];
  nodeC = new int [nodeLib.length];
  nodeT = new float [nodeLib.length];
  nodeS = new float [nodeLib.length];
  for (int i = 0; i < nodeLib.length; i++) {
     nodeLib[i][0] = nodeLib[i][0] + random(-18,18);
     nodeLib[i][1] = nodeLib[i][1] + random(-18,18);
     nodeRs[i] = rS[PApplet.parseInt(random(rS.length))];
     nodeC[i] = pallete[PApplet.parseInt(random(pallete.length))];
     nodeT[i] = random(-6,-1);
     nodeS[i] = 0;
  }
}





// draws graph points and lines in node details screen
public void grapher ( int dataTypeX, float contLow, float contHigh, int gColor, int dGdot, int dGstroke, int gspace) {

  float dG;
  float dGx;
  float dGx2;
  int iG = 0;
  float cont1 = 0;
  float cont2 = 204;
  
  pushMatrix();
  translate(0,66);
  // points
  noStroke();
  fill(gColor);
  //dGdot = 12;
  ellipseMode(CENTER);
  for ( iG = 0; iG < NodeDetail[NodeIdex].length ; iG++ ) {
    dG = constrain(map(PApplet.parseFloat(NodeDetail[NodeIdex][iG][dataTypeX]),contHigh,contLow,cont1,cont2),cont1,cont2);
    ellipse(gspace*iG, dG, dGdot, dGdot);
  }
  
  //lines
  iG = 0; // reset
  noFill();
  stroke(gColor);
  strokeWeight(dGstroke);
  for ( iG = 0; iG < NodeDetail[NodeIdex].length ; iG++ ) {
    dG = constrain(map(PApplet.parseFloat(NodeDetail[NodeIdex][iG][dataTypeX]),contHigh,contLow,cont1,cont2),cont1,cont2);
    if ( iG < NodeDetail[NodeIdex].length - 1 ) {
      dGx = constrain(map(PApplet.parseFloat(NodeDetail[NodeIdex][iG+1][dataTypeX]),contHigh,contLow,cont1,cont2),cont1,cont2);
      dGx2 = (gspace*iG)+gspace;
    } else { 
      dGx = dG; 
      dGx2 = gspace*iG;
    }
    line(gspace*iG, dG,dGx2,dGx);
  }
  
  

  
  
  popMatrix();
}

// Mouse clicks and bounding box detection

// function to test if mouse is over bounding box
public boolean overBox(int x, int xx, int y, int yy) {
  if (mouseX > x && mouseX < xx && mouseY > y && mouseY < yy) {
    return true;
  } 
  else { 
    return false;
  }
}


// on mouse click / android tap do stuff
// 0:splash, 1:node menu, 2:node details
public void mousePressed() {

  // NODE MENU SCREEN
  if (screenSelect == 1 && tempSelect == 0){
    // test bounding boxes from nodescreen. goto details screen for selected node.
    for (int i = 0; i < bBoxNode.length; i++){
      if (mouseX > bBoxNode[i][0] && mouseX < bBoxNode[i][1] && mouseY > bBoxNode[i][2] && mouseY < bBoxNode[i][3]) {
        //println (i);
        NodeIdex = i;
        tempSelect = 1;
      }
    }
    
  // refresh button on node menu screen
  if (mouseX > refreshIDX[0] && mouseX < refreshIDX[1] && mouseY > refreshIDX[2] && mouseY < refreshIDX[3]) {
      // reset parameters for full refresh
      
      ax = 0.1f;
      allLoaded = 0;
      tempSelect = 3;
      //screenSelect = 0;
      loadIndexStatus = 0;
      loadDetailStatus = 0;
      sum = 0;
      //masterX = 0;
      
      // regenerate splash image
      //thread("splashGen");
      
      // reload all data from server
      //thread("loadNodeIndex");
      
      // show the splash screen again
      //splashScreen();
      

    }
  }



  // DETAILS SCREEN
  if (screenSelect == 2 && tempSelect == 1){

    // refresh button
    if (mouseX > refreshIDX[0] && mouseX < refreshIDX[1] && mouseY > refreshIDX[2] && mouseY < refreshIDX[3]) {
      // reset parameters
      tempSelect = 2;
    }
      
    // dateForward < button
    dateForwardx = overBox(dateForward[0],dateForward[1],dateForward[2],dateForward[3]); 
    if ( dateForwardx ) {
      dataDay = dataDay-1;
      //println ("forward");
    }

    // dateBack > button
    dateBackx = overBox(dateBack[0],dateBack[1],dateBack[2],dateBack[3]); 
    if ( dateBackx ) {
      dataDay = dataDay+1;
      //println ("back");
    }
   
    // temp toggle c/f
    tempTogglex = overBox(382,748,750-48,750+48);
    if ( tempTogglex ) {
      tempToggle = !tempToggle;
      //println ("temp toggle"); // debug
    }
  }
}

// Draws node menu boxes
// this is a class. called from nodeScreen
class NodeBox {
  
  int posx;
  int posy;
  int nodeColorx;
  int nodeRstempx;
  int tempNodeIDx;
  String tempNodeNamex;
  String tempPlantx;
  float tempSoilx;
  float tempHumidx;
  float tempTempx;
  float tempVoltx;

  NodeBox (int tempposx, int tempposy, int nodeColor, String nodeRstemp, String tempNodeID, String tempNodeName, String tempPlant, String tempSoil, String tempTemp, String tempHumid, String tempVolt){
    
    posx = tempposx;
    posy = tempposy;
    tempPlantx = tempPlant;
    tempNodeIDx = PApplet.parseInt(tempNodeID);
    tempNodeNamex = tempNodeName;
    tempSoilx = PApplet.parseFloat(tempSoil);
    tempHumidx = PApplet.parseFloat(tempHumid);
    tempTempx = PApplet.parseFloat(tempTemp);
    tempVoltx = PApplet.parseFloat(tempVolt);
    nodeColorx = color(nodeColor);
    nodeRstempx = PApplet.parseInt(nodeRstemp);
    //nodeColorx = int(nodeColor);

  }

  public void display() {
    

    // node box
    pushMatrix();

    translate(posx, posy + pad);

    //pushMatrix();
    noStroke();
    rectMode(CORNERS);
    
    //drop shadow
    fill(shadow);
    rect(margin,nodeBoxH,width-margin,nodeBoxH+dshadow);

    //the actual box
    fill(255);
    rect(margin,0,width-margin,nodeBoxH);

    // Node Icon. x,y,rotate,scale,color
    nodeIcon(margin+18+46,(nodeBoxH/2),rSx[nodeRstempx],2,nodeColorx);

    //Draw type
    int textMargin = 148;
    
    textAlign(LEFT);
    fill(blacktype);

    // Node Name
    textFont(fontmed,32);

    tempNodeNamex = tempNodeNamex.toUpperCase();
    text(tempNodeNamex, textMargin, (nodeBoxH-24));

    // Plant Name
    textFont(fontlit,46);
    tempPlantx = tempPlantx.toUpperCase();
    text(tempPlantx, textMargin-2, 54);

    miniGraph(); // draws mini grap via function
    
    // arrow
    // x,y,rotate,scale,color
    nodeIcon(714,nodeBoxH/2,135,0.6f,greylit);
    
    popMatrix();
  }
  
  public void miniGraph(){
    //Draw quick graphs
    pushMatrix();
    translate(580,16);
    noStroke();
    rectMode(CORNERS);
    
    int mGw = 22;
    int mPad = 4;
    float vOffset = 0;

    // soil moist. scale is mapped to 0 - 600 ADC value
    fill(greenpas);
    rect(0,0,mGw,90);
    vOffset = constrain(map(tempSoilx,0,600,90,0),0,90);
    fill(green);
    rect(0,vOffset,mGw,90);
    
    // humid. scale mapped to 0 - 90%
    fill(blueskypas);
    rect(mGw+mPad,0,mGw*2+mPad,90);
    vOffset = constrain(map(tempHumidx,0,90,90,0),0,90);
    fill(bluesky);
    rect(mGw+mPad,vOffset,mGw*2+mPad,90);
    
    // temp. cale mapped to 0 - 46c
    fill(orangeredpas);
    rect(mGw*2+mPad*2,0,mGw*3+mPad*2,90);
    vOffset = constrain(map(tempTempx,0,46,90,0),0,90);
    fill(orangeredtemp);
    rect(mGw*2+mPad*2,vOffset,mGw*3+mPad*2,90);
    
    
    //batt. mapped to 3 - 6v
    fill(greylit);
    rect(mGw*3+mPad*3,0,mGw*4+mPad*3,90);
    vOffset = constrain(map(tempVoltx,3.3f,6,90,0),0,90);
    fill(grey);
    rect(mGw*3+mPad*3,vOffset,mGw*4+mPad*3,90);

    popMatrix();
  }


}






















// node menu screen
// shows all nodes

public void nodeScreen() {
  
  //reset dataday
  dataDay = 0;
  
  pushMatrix();
  translate(masterX+width, masterY);
  
  
  rectMode(CORNER);
  fill(greybg);
  noStroke();
  rect(0,0,width,height);
  
  // Header
  noStroke();
  rectMode(CORNERS);

  fill(greengrass);
  rect(0,0,width,headerBoxH);
  image(logohead, 18, 12);
  
  // back icon
  nodeIcon(712,76,-45,0.8f,white);
  

  // Node Boxes
  pushMatrix();
  translate (0,headerBoxH+dshadow+2);
  

  // draw the node boxes
  for (int i = 0; i < nodeBoxie.length; i++){
    nodeBoxie[i].display();
  }


  popMatrix();
  popMatrix();
}











// splash screen
float ax = 255;
public void splashScreen() {
  
pushMatrix();
  translate(masterX, masterY);
  
  background(white);
  
   
  
  
  
  // logotype fade in * does not work properly on android
  //tint(255,lFade);
  image(logosplash, 40, 400);
  //lFade = lFade + 8;
  
  xk = nodeLib.length - 0.001f;
  sum = 0;
  // Draw splash screen
  for ( int is = 0; is < nodeLib.length; is++) {
    float dx = 1 - nodeS[is];
    if ( nodeS[is] >= 1.08f ) { nodeS[is] = 1.01f; }
      nodeIcon(nodeLib[is][0],nodeLib[is][1],nodeRs[is],nodeS[is],nodeC[is]);
      //nodeRs[i] = nodeRs[i] + 0.8;
      nodeT[is] = nodeT[is] + 0.08f;
      //if ( nodeT[i] >= -0.1 ) { nodeS[i] = nodeS[i] * 1.16 ; }
      if ( nodeT[is] >= -0.1f ) { nodeS[is] += dx * easing ; }
  }

  for (int i=0; i < nodeLib.length; i++) {
   sum += nodeS[i];
  }
  

 ax = ax/1.08f;
  if(ax > 1){
    fill(white,ax);
    rect(0,0,width,height);
    //println(ax);
  }

  //println (nodeS[0]);
  //println (sum);
  popMatrix();
  
  

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "plant_friends" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
