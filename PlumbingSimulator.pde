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
    .addItem("Split",4);
  model.init(initialX, initialY);
}

public void draw() {
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
}

void addpipe () {
  if (mouseY<0 || mouseY>330) return;
  if (model.selectPipe(mouseX, mouseY)!=null) {
    println("I'm not drawing on top of another pipe!");
    return;
  }
  SnapGrid s = new SnapGrid(beginX,beginY,mouseX,mouseY);
  s.snap();
  elbow = false;
  totalLen = pLength(s.x1, s.y1, s.x2, s.y2);
  endPressure = beginPressure - pressureDrop(totalLen, inches, rCoeff, flow); 
  model.addPipe(s.x1, s.y1, s.x2, s.y2, pipeWidth, beginPressure, endPressure);
  if(s.x1 == s.x2) vPipe = true;
  if(s.y1 == s.y2) hPipe = true;
  model.deActivateAllSplits();
  model.addSplit(s.x2, s.y2, 1); 
  beginX = s.x2;
  beginY = s.y2;
  beginPressure = endPressure;
  println(endPressure);
}


void addSplit() {
  if (mouseY<0 || mouseY>330) return;
  Pipe t = model.selectPipe(mouseX, mouseY);
  if (t!=null) {
    SnapGrid s = new SnapGrid(t.x1,t.y1,mouseX,mouseY);
    s.snap();
    elbow = false;
    totalLen = pLength(t.x1, t.y1, s.x2, s.y2);
    beginPressure = t.beginP;
    endPressure = beginPressure - pressureDrop(totalLen, inches, rCoeff, flow);
    model.splitPipe(t, s.x2, s.y2, beginPressure, endPressure);
    
     
    model.deActivateAllSplits();
    model.addSplit(s.x2, s.y2, 1);
    beginX = s.x2;
    beginY = s.y2;
    beginPressure = endPressure;
    println(endPressure);
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
    case 4:  // user wants to split from the last pipe
      tool = "split";
      break;
  }
  
}

