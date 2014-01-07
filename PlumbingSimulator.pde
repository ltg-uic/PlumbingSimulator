import controlP5.*;

// Model
PipesModel model = new PipesModel();
// CP5
ControlP5 cp5;
RadioButton r;
// Processing variables
int initialX = 10;
int initialY = 10;
float initPressure = 60;  //psi
int beginX = initialX;
int beginY = initialY;
float beginPressure = initPressure;
float endPressure;
int pipeWidth;
float flow;
float rCoeff = 150; //Hazen-Williams roughness constant for PVC Schedule 40 pipes
float inches; 
float pipeLen;
float bendLen;
float totalLen;
boolean hPipe;
boolean vPipe;
boolean elbow;
int pConstant = 15;
String tool;


public void setup() {
  size(640,360);
  cp5 = new ControlP5(this);
  r = cp5.addRadioButton("pipeButton")
    .setPosition(20,330)
    .setSize(20,20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(0))
    .setItemsPerRow(5)
    .setSpacingColumn(100)
    .setNoneSelectedAllowed(false)
    .setValue(0)
    .addItem("Select split", 0)
    .addItem("1 inch",1)
    .addItem("1/2 inch",2)
    .addItem("3/4 inch",3)
    .addItem("Split",4)
    .addItem("Remove",5);
  model.init(initialX, initialY, initPressure);
}

public void draw() {
  background(200);
  fill(150);
  noStroke();
  rect(0, 320, width, 40);
  for(Pipe p: model.getPipes())
    drawPipe(p);
  for(Split s: model.getSplits())
    drawSplit(s);
}

public void drawPipe(Pipe p) {
  stroke(0);
  strokeWeight(p.pWidth);
  line(p.x1,p.y1,p.x2,p.y2);
  strokeWeight(1);
}

public void drawSplit(Split s) {
  if (s.isActive) {
    stroke(255,0,0);
    fill(255,0,0);
  } else {
    stroke(0,0,255);
    fill(0,0,255);
  }
  ellipse(s.x,s.y,12,12);
  //write the pressure values at the split
  text(s.pressure, s.x+pConstant, s.y+pConstant);
  fill(0);
  stroke(0);
}


public void mousePressed() {
  if (tool==null) return;
  if (tool.equals("select")) {
    selectSplit();  
  }
  if (tool.equals("split")) { 
    addSplit(); 
  }
  if (tool.equals("pipe")) {
    addpipe();
  }
  if (tool.equals("remove")) {
    removePipe();
  }
}

void addpipe () {
  if (mouseY<0 || mouseY>330) return;
  if (model.selectPipe(mouseX, mouseY)!=null) {
    println("I'm not drawing on top of another pipe!");
    return;
  }
  SnapGrid s = new SnapGrid(beginX,beginY,mouseX,mouseY);
  s.snap();
  
  elbow = false;                                //reset flag for checking if pipes are at 90 degrees 
  totalLen = pLength(s.x1, s.y1, s.x2, s.y2);  
  Split a = model.selectSplit(s.x1, s.y1);     //get the split at the beginning of this new pipe to calculate the pressure drop across the new pipe 
  endPressure = a.pressure - pressureDrop(totalLen, inches, rCoeff, flow);   //pressure at end of pipe 
  
  model.addPipe(s.x1, s.y1, s.x2, s.y2, pipeWidth);
  if(s.x1 == s.x2) vPipe = true;     //set flag to indicate vertical pipe
  if(s.y1 == s.y2) hPipe = true;     //set flag to indicate horizontal pipe
  
  model.deActivateAllSplits();
  model.addSplit(s.x2, s.y2, 1, endPressure);
  beginX = s.x2;
  beginY = s.y2;
}


void addSplit() {
  if (mouseY<0 || mouseY>330) return;
  Pipe t = model.selectPipe(mouseX, mouseY);
  if (t!=null) {
    SnapGrid s = new SnapGrid(t.x1,t.y1,mouseX,mouseY);
    s.snap();
    
    elbow = false;                                //reset flag for checking pipes at 90 degrees 
    totalLen = pLength(t.x1, t.y1, s.x2, s.y2);    // length of 1st pipe created by the split
    Split a = model.selectSplit(t.x1, t.y1);     //get the split at the beginning of 1st pipe to calculate the pressure drop across the new pipe 
    endPressure = a.pressure - pressureDrop(totalLen, inches, rCoeff, flow);   //pressure at end of pipe 
    
    model.splitPipe(t, s.x2, s.y2);
    model.deActivateAllSplits();
    model.addSplit(s.x2, s.y2, 1, endPressure);  //add new split point along with the pressure at this point
    
    totalLen = pLength(s.x2, s.y2, t.x2, t.y2);    // length of 2nd pipe created by the split
    Split b = model.selectSplit(s.x2, s.y2);   //get the new split to use to calculate the pressure at the end of the 2nd pipe  
    endPressure = b.pressure - pressureDrop(totalLen, inches, rCoeff, flow);   //pressure at end of pipe
    Split c = model.selectSplit(t.x2, t.y2);   //get the split at the end of the original pipe to calculate new pressure at this split
    c.pressure = endPressure;
    
    beginX = s.x2;
    beginY = s.y2;
  }
}


void selectSplit() {
  if (mouseY<0 || mouseY>330) return;
  Split t = model.selectSplit(mouseX, mouseY);
  if (t!=null) {
    model.deActivateAllSplits();
    model.activateSplit(t);
    beginX = t.x;
    beginY = t.y;
  } 
}

void removePipe(){
  if (mouseY<0 || mouseY>330) return;
  Pipe r = model.selectPipe(mouseX, mouseY);
  if (r!=null) {
    println(r.toString());
    model.deActivateAllSplits();
    model.deletePipe(r);
  }  
}

//calculate the pressure drop across the pipe
float pressureDrop(float pipeLength, float dia, float constant, float fRate) { 
  float pLossPer100ft = 0.43 * (2083/10000.0) * pow(100/constant, 1852/1000.0) * pow(fRate, 1852/1000.0) / pow(dia, 48655/10000.0);
  float pLossSection = pLossPer100ft * pipeLength / 100;
  return pLossSection;     
} 

float pLength(int posX1, int posY1, int posX2, int posY2) {
  if(posX1 == posX2)
    pipeLen = abs(posY2-posY1);
  else if(posY1 == posY2)
    pipeLen = abs(posX2-posX1);
  if(bendPipe(posX1, posY1, posX2, posY2)) 
    return pipeLen+bendLen;
  else
    return pipeLen;
}

boolean bendPipe(int posX1, int posY1, int posX2, int posY2) {
  if((posX1 == posX2) && hPipe) {
    hPipe = false;
    elbow = true;
  }
  else if((posY1 == posY2) && vPipe) {
    vPipe = false;
    elbow = true;
  }
  return elbow;
}

// which radio button pipe size did the user select?
void pipeButton(int a) {
  switch(a) {
    case 0:
      tool =  "select";
      break;
    case 1:  // pipe diameter 1 inch 
      pipeWidth = 10;
      inches = 1;
      flow = 10; //gallons per minute
      bendLen = 3; //equivalent length of pipe bends
      tool = "pipe";
      break;
    case 2:  // pipe diameter 3/4 inch
      pipeWidth = 5;
      inches = 0.75;
      flow = 8;  //gallons per minute
      bendLen = 2.5; //equivalent length of pipe bends
      tool = "pipe";
      break;
    case 3:  // pipe diameter 1/2 inch
      pipeWidth = 1;
      inches = 0.5;
      flow = 2; //gallons per minute
      bendLen = 2; //equivalent length of pipe bends
      tool = "pipe";
      break;
    case 4:  // user wants to split pipe
      tool = "split";
      break;
    case 5:  // user wants to remove pipe
      tool = "remove";
      break;
  }
  
}

