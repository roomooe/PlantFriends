

// Node details screen
// NodeIdex controls everything

void detailScreen() {
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
  kurbits(100*widthStretch,90*heightStretch,0,3,white,palleteNode[NodeIdex][0],white);
  
  // back icon
  nodeIcon(712*widthStretch,76*heightStretch,-45,0.8,white);

  float textMargin1 = 208*widthStretch;
  
  float textMargin2 = 112*widthStretch;
  
  // Plant name
  textFont(fontreg,68*heightStretch*1.5);
  textAlign(LEFT);

  fill(blacktype);
  
  String nName = NodeIndex[NodeIdex][2];
  nName = nName.toUpperCase();
  text(nName, textMargin1-4, 104*heightStretch);
    
  //node name
  textFont(fontmed,26*heightStretch*1.5);
  nName = NodeIndex[NodeIdex][1];
  nName = nName.toUpperCase();
  text(nName, textMargin1, 150*heightStretch*0.99);
    
  // node id
  nName = "id " + NodeIndex[NodeIdex][0];
  nName = nName.toUpperCase();
  text(nName, textMargin1, 180*heightStretch);

  
  // location
  textFont(fontmed,18*heightStretch*1.5);
  nName = "plats";
  nName = nName.toUpperCase();
  text(nName, textMargin1, 234*heightStretch*0.99);

  // comments
  nName = "kommentarer";
  nName = nName.toUpperCase();
  text(nName, textMargin1, 312*heightStretch*0.99);
    
  // location text
  textFont(fontlit,32*heightStretch*1.5);
  nName = NodeIndex[NodeIdex][3];
  text(nName, textMargin1, 270*heightStretch);

  // comments text
  nName = NodeIndex[NodeIdex][4];
  text(nName, textMargin1, 348*heightStretch);
  
  
  popMatrix();
  

  //  data details
  pushMatrix();
  translate(0,400*heightStretch);
  rectMode(CORNER);
  fill(palleteNode[NodeIdex][1]);
  rect(0,0,width,496*heightStretch);

  // date forward < icon
  nodeIcon(60*widthStretch,100*heightStretch,-45,0.6,white);
  
  // date back > icon
  nodeIcon(width-60*widthStretch,100*heightStretch,135,0.6,white);

  textFont(fontmed,18*heightStretch*1.8);
  fill(blacktype);
  
  // generate day display cycling
  // make sure dataDay doesn't go out of bounds
  if ( dataDay < 0 ) { dataDay = 5; }
  if ( dataDay > 5 ) { dataDay = 0; }
  
  // showing data for
  if (dataDay == 0) { nName = "i dag"; } else { nName = "visar data för"; }

  nName = nName.toUpperCase();
  text(nName, textMargin2, 68*heightStretch*0.9);

  // date
  textFont(fontmed,50*heightStretch*1.5);
  nName = NodeDetail[NodeIdex][dataDay][0].replace("-"," ");
  text(nName, textMargin2, 120*heightStretch);

  //spacing=74
    
  // soil moist title
  textFont(fontmed,24*heightStretch*1.8);
  nName = "jordfuktighet";
  nName = nName.toUpperCase();
  text(nName, textMargin2, 198*heightStretch);
    
  // humidity title
  nName = "Luftfuktighet";
  nName = nName.toUpperCase();
  text(nName, textMargin2, 272*heightStretch);

  // warmth title
  nName = "temperatur";
  nName = nName.toUpperCase();
  text(nName, textMargin2, (272+74)*heightStretch);

  // Water title
  nName = "Vattennivå";
  nName = nName.toUpperCase();
  text(nName, textMargin2, (272+74+74)*heightStretch);
    
  // data margin
  float dMargin = 390*widthStretch;

  // soil moist data
  textFont(fontlit,46*heightStretch*1.5);
  float moist = float(NodeDetail[NodeIdex][dataDay][2])-200;
  
  nName = nf((moist/900*100),0,-1) + " %";
  // nName = nf((float(NodeDetail[NodeIdex][dataDay][2])/900*100),2,1) + " %";
  // nName = NodeDetail[NodeIdex][dataDay][2]+ " %";
  nName = nName.toUpperCase();
  text(nName, dMargin, 204*heightStretch);
    
    
    
  // humid data
  nName = NodeDetail[NodeIdex][dataDay][4] + " %";
  text(nName, dMargin, (204+74)*heightStretch);

  // toggle temperature C or F
  if (tempToggle) { 
    nName = nf((float(NodeDetail[NodeIdex][dataDay][3])*9/5+32),2,1) + "\u00baF";
  } else { 
    nName = NodeDetail[NodeIdex][dataDay][3] + " \u00baC";
  }
    
  // warmth data
  text(nName, dMargin, (204+74+74)*heightStretch);
  
  // water level data
  
  nName = nf((100-float(NodeDetail[NodeIdex][dataDay][5])/22*100),0,-1) + " %";
  text(nName, dMargin, (204+74+74+74)*heightStretch);

  // color legend
  float cMargin = 608*widthStretch;

  // soil moist
  fill(greengrass);
  rect(cMargin,180*heightStretch,46*widthStretch,14*heightStretch);
    
  // humid
  fill(bluesky);
  rect(cMargin,(180+74)*heightStretch,46*widthStretch,14*heightStretch);
   
  // warmth
  fill(orangeredtemp);
  rect(cMargin,(180+74+74)*heightStretch,46*widthStretch,14*heightStretch);

  // water level
  fill(brown);
  rect(cMargin,(180+74+74+74)*heightStretch,46*widthStretch,14*heightStretch);
   
  popMatrix();
  

  //  graph
  pushMatrix();
  translate(0,890*heightStretch);
  rectMode(CORNER);
  fill(white);
  noStroke();
  rect(0,0,width,298*heightStretch);
   
  int gMargin = int(48*widthStretch);
  int gspace = (width-(gMargin*2))/5;

  // graph type
  textFont(fontmed,18*heightStretch*1.8);
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
        if ( i == 0 ) { nName = "NU"; }
    } else { nName = "No Data"; }
    text(nName, gspace*i+7, 44*heightStretch);
  }
  

  // GRAPHS!!

  // draw the graph for each datatype. NodeIndex is global set and changed before entering the details screen. 
  //int datatype, int contLow, int contHigh, color gColor, int dGdot, int dGstroke, int gspace
  
  // Soil Moisture graph. Mapped to 150 - 900 ADC value.
  grapher(2,250,900,greengrass,14,3,gspace);

  // humidity graph. Mapped to 0 - 90%
  grapher(4,0,90,bluesky,12,3,gspace);

  // Temperature graph. Mapped to 0 - 49c.
  grapher(3,0,49,orangeredtemp,10,3,gspace);
  
  // water level graph. Mapped to 21 - 3 cm.
  grapher(5,21,3,brown,8,3,gspace);
  
  popMatrix();
  popMatrix();
  popMatrix();
}
