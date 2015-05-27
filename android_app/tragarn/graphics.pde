
// Draw node icon
// x,y,rotate,scale,color
void nodeIcon(float posx, float posy, float srotate, float sscale, color scolor){
  pushMatrix();
  translate(posx,posy);
  rotate(radians(srotate));
  scale(sscale*(widthStretch+heightStretch)*0.5);
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
// Draw kurbits node icon
// x,y,rotate,scale,color
void kurbits (float posx, float posy, float srotate, float sscale, color scolor, color fill, color pistill){
  pushMatrix();

  noFill();
  translate (posx,posy);
  rotate(radians(srotate));
  scale(sscale*(widthStretch+heightStretch)*0.5*1.2);
    pushMatrix();

  
  for( int i = 0; i<4; i++){
  beginShape();
  stroke(scolor);
  fill(scolor);
  vertex(0, -14);
  bezierVertex(3, -24, 22, -16, 0, -2);
  vertex(0, -14);
  bezierVertex(-3, -24, -22, -16, 0, -2);
  endShape();
  rotate(PI/2);
  }
  noStroke();
  fill(fill);
  ellipse(0,0,18,15);
  ellipse(0,0,15,18);
  stroke(fill);
  strokeWeight(1.7);
  line(-16,16,16,-16);
  line(16,16,-16,-16);
  noStroke();
  fill(pistill);
  ellipse(0,0,14,7);
  ellipse(0,0,7,14); 
  endShape(CLOSE);
  popMatrix();
  popMatrix();

}


// flower sketch, not used
// x,y,rotate,scale,color
void flower(float posx, float posy, float srotate, float sscale, color scolor) {

  for ( int j=0; j<5; j++) {
    pushMatrix();
    translate(posx,posy);
    scale(sscale/3);
    // line(0,0,random(-50,50), height*2 );
    rotate(radians(srotate));
    rotate(j * TWO_PI/5);
    noStroke();
    fill(scolor);
    beginShape();
  curveVertex(0, 0 );
  curveVertex(0 + random(-10, 10), 0+ random(-10, 10) );
  curveVertex(-50+ random(-10, 10), -100+ random(-10, 10) );
  curveVertex( 0+ random(-10, 10), -100+ random(-10, 10));
  curveVertex(50+ random(-10, 10), -100+ random(-10, 10));
  curveVertex(0+ random(-10, 10), 0+ random(-10, 10));
    curveVertex(0, 0);

    endShape();

    stroke(#dad7d3);
    noFill();
    for ( int i=0; i<3; i++) {
  beginShape();
  curveVertex(0, 0 );
  curveVertex(0 + random(-10, 10), 0+ random(-10, 10) );
  curveVertex(-50+ random(-10, 10), -100+ random(-10, 10) );
  curveVertex( 0+ random(-10, 10), -100+ random(-10, 10));
  curveVertex(50+ random(-10, 10), -100+ random(-10, 10));
  curveVertex(0+ random(-10, 10), 0+ random(-10, 10));
  curveVertex(0, 0);
  endShape();
    }
    popMatrix();
  }
  }
  
  void flower2 (float posx, float posy, float srotate, float sscale, color scolor) {
    
    for (int j =0; j<3; j++){
    translate(posx,posy);
    scale(sscale);
    rotate(radians(srotate));
    rotate(j * TWO_PI/3);
    smooth();
    noStroke();
    fill(scolor);
    beginShape();
    vertex(50, 15);
    bezierVertex(50, -5, 90, 5, 50, 40);
    vertex(50, 15);
    bezierVertex(50, -5, 10, 5, 50, 40);
    endShape();

      }
  }
    
    
    
  

  

// generate purdy splash image
void splashGen () {
  // Generate node icons for splash image
  nodeRs = new float [nodeLib.length];
  nodeC = new int [nodeLib.length];
  nodeT = new float [nodeLib.length];
  nodeS = new float [nodeLib.length];
  nodeCurves = new float [nodeLib.length];
  nodeCurves1 = new float [nodeLib.length];
  nodeCurves2 = new float [nodeLib.length];
  nodeCurves3 = new float [nodeLib.length];
  for (int i = 0; i < nodeLib.length; i++) {
     nodeLib[i][0] = nodeLib[i][0] + random(-18,18);
     nodeLib[i][1] = nodeLib[i][1] + random(-18,18);
     nodeRs[i] = rS[int(random(rS.length))];
     nodeC[i] = pallete[int(random(pallete.length))];
     nodeT[i] = random(-6,-1);
     nodeS[i] = 0;


}
}




// draws graph points and lines in node details screen
void grapher ( int dataTypeX, float contLow, float contHigh, color gColor, int dGdot, int dGstroke, int gspace) {

  float dG;
  float dGx;
  float dGx2;
  int iG = 0;
  float cont1 = 0;
  float cont2 = 204;
  
  pushMatrix();
  translate(0,66*heightStretch);
  // points
  noStroke();
  fill(gColor);
  //dGdot = 12;
  ellipseMode(CENTER);
  for ( iG = 0; iG < NodeDetail[NodeIdex].length ; iG++ ) {
    dG = constrain(map(float(NodeDetail[NodeIdex][iG][dataTypeX]),contHigh,contLow,cont1,cont2),cont1,cont2);
    ellipse(gspace*iG, dG*heightStretch, dGdot*widthStretch, dGdot*heightStretch);
  }
  
  //lines
  iG = 0; // reset
  noFill();
  stroke(gColor);
  strokeWeight(dGstroke);
  for ( iG = 0; iG < NodeDetail[NodeIdex].length ; iG++ ) {
    dG = constrain(map(float(NodeDetail[NodeIdex][iG][dataTypeX]),contHigh,contLow,cont1,cont2),cont1,cont2);
    if ( iG < NodeDetail[NodeIdex].length - 1 ) {
      dGx = constrain(map(float(NodeDetail[NodeIdex][iG+1][dataTypeX]),contHigh,contLow,cont1,cont2),cont1,cont2);
      dGx2 = (gspace*iG)+gspace;
    } else { 
      dGx = dG; 
      dGx2 = gspace*iG;
    }
    line(gspace*iG,dG*heightStretch,dGx2,dGx*heightStretch);
  }
  
  

  
  
  popMatrix();
}
