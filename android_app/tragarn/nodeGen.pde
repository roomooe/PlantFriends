
// Draws node menu boxes
// this is a class. called from nodeScreen
class NodeBox {
  
  float posx;
  float posy;
  color nodeColorx;
  int nodeRstempx;
  int tempNodeIDx;
  String tempNodeNamex;
  String tempPlantx;
  float tempSoilx;
  float tempHumidx;
  float tempTempx;
  float tempVoltx;

  NodeBox (float tempposx, float tempposy, color nodeColor, String nodeRstemp, String tempNodeID, String tempNodeName, String tempPlant, String tempSoil, String tempTemp, String tempHumid, String tempVolt){
    
    posx = tempposx;
    posy = tempposy;
    tempPlantx = tempPlant;
    tempNodeIDx = int(tempNodeID);
    tempNodeNamex = tempNodeName;
    tempSoilx = float(tempSoil);
    tempHumidx = float(tempHumid);
    tempTempx = float(tempTemp);
    tempVoltx = float(tempVolt);
    nodeColorx = color(nodeColor);
    nodeRstempx = int(nodeRstemp);
    //nodeColorx = int(nodeColor);

  }

  void display() {
    

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
    kurbits(margin+18*widthStretch+46*widthStretch,(nodeBoxH/2),rSx[nodeRstempx],2*0.8,nodeColorx, #fffbf6, #ffea00);

    //Draw type
    float textMargin = 148*widthStretch;
    
    textAlign(LEFT);
    fill(blacktype);

    // Node Name
    textFont(fontmed,45*heightStretch);

    tempNodeNamex = tempNodeNamex.toUpperCase();
    text(tempNodeNamex, textMargin, (nodeBoxH-12*heightStretch));

    // Plant Name
    textFont(fontlit,64*heightStretch);
    tempPlantx = tempPlantx.toUpperCase();
    text(tempPlantx, textMargin-2*widthStretch, 60*heightStretch);

    miniGraph(); // draws mini grap via function
    
    // arrow
    // x,y,rotate,scale,color
    nodeIcon(714*widthStretch,nodeBoxH/2,135,0.6,greylit);
    
    popMatrix();
  }
  
  void miniGraph(){
    //Draw quick graphs
    pushMatrix();
    translate(580*widthStretch,16*heightStretch);
    noStroke();
    rectMode(CORNERS);
    
    float mGw = 22*widthStretch;
    float mPad = 4*widthStretch;
    float vOffset = 0;

    // soil moist. scale is mapped to 0 - 600 ADC value
    fill(brownlit);
    rect(0,0,mGw,90*heightStretch);
    vOffset = constrain(map(tempSoilx,0,600,90*heightStretch,0),0,90*heightStretch);
    fill(brown);
    rect(0,vOffset,mGw,90*heightStretch);
    
    // humid. scale mapped to 0 - 90%
    fill(blueskypas);
    rect(mGw+mPad,0,mGw*2+mPad,90*heightStretch);
    vOffset = constrain(map(tempHumidx,0,90,90*heightStretch,0),0,90*heightStretch);
    fill(bluesky);
    rect(mGw+mPad,vOffset,mGw*2+mPad,90*heightStretch);
    
    // temp. cale mapped to 0 - 46c
    fill(orangeredpas);
    rect(mGw*2+mPad*2,0,mGw*3+mPad*2,90*heightStretch);
    vOffset = constrain(map(tempTempx,0,46,90*heightStretch,0),0,90*heightStretch);
    fill(orangeredtemp);
    rect(mGw*2+mPad*2,vOffset,mGw*3+mPad*2,90*heightStretch);
    
    
    //batt. mapped to 3 - 6v
    fill(yellowlit);
    rect(mGw*3+mPad*3,0,mGw*4+mPad*3,90*heightStretch);
    vOffset = constrain(map(tempVoltx,3.3,6,90*heightStretch,0),0,90*heightStretch);
    fill(yellow);
    rect(mGw*3+mPad*3,vOffset,mGw*4+mPad*3,90*heightStretch);

    popMatrix();
  }


}





















