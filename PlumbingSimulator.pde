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
boolean pipeEndOverlap;
boolean pipeOverlap;
int pConstant = 15;
int tolerance = 5;
String tool;
int controlPos = 680; //set the y value of where the controls would be displayed
int displaceX;
int displaceY;

public void setup() {
  size(1280,720);
  cp5 = new ControlP5(this);
  r = cp5.addRadioButton("pipeButton")
    .setPosition(20,controlPos)
    .setSize(20,20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(0))
    .setItemsPerRow(7)
    .setSpacingColumn(100)
    .setNoneSelectedAllowed(false)
    .setValue(0)
    .addItem("Select split", 0)
    .addItem("1 inch",1)
    .addItem("3/4 inch",2)
    .addItem("1/2 inch",3)
    .addItem("Split",4)
    .addItem("Remove",5)
    .addItem("Displace",6);
  model.init(initialX, initialY, initPressure);
}

public void draw() {
  background(255);
  fill(150);
  noStroke();
  rect(0, controlPos-10, width, 40);
  for(Pipe p: model.getPipes())
    drawPipe(p);
  for(Split s: model.getSplits())
    drawSplit(s);
  drawFixtures();
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

public void drawFixtures() {
  stroke(0,0,255);
  //1st fixture
  noFill();
  ellipse(width-50,40,25,25);
  fill(0,0,255);
  text("A",width-55,44);
  text("10 psi",width-55,20);
  //2nd fixture
  noFill();
  ellipse(width-50,100,25,25);
  fill(0,0,255);
  text("B",width-55,104);
  text("15 psi",width-55,80);
  //3rd fixture
  noFill();
  ellipse(width-300,500,25,25);
  fill(0,0,255);
  text("C",width-305,504);
  text("8 psi",width-305,480);
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
  if (tool.equals("displace")) {
    for(Pipe p: model.getPipes())
      displacePipe();
  }
}

void addpipe () {
  if (mouseY<0 || mouseY>controlPos) return;
  if (model.selectPipe(mouseX, mouseY)!=null) {
    println("I'm not drawing on top of another pipe!");
    return;
  }
  SnapGrid s = new SnapGrid(beginX,beginY,mouseX,mouseY);
  s.snap();
  
  //check if endpoint of new pipe is the begining of an existing pipe. Have to iterate through Pipes and NOT Splits because old split had been removed with the previous pipe
  for(Pipe p: model.getPipes()) {
//    pipeEndOverlap = checkEndOverlap();
    if (s.x2>=p.x1-tolerance && s.x2<=p.x1+tolerance && s.y2>=p.y1-tolerance && s.y2<=p.y1+tolerance) { //snap end of new pipe to beginning of existing pipe 
      println("overlap");
      s.x2 = p.x1;
      s.y2 = p.y1;
      pipeEndOverlap = true;
  }
  }
  
  //checkOverlap();
      
  model.addPipe(s.x1, s.y1, s.x2, s.y2, pipeWidth, inches, flow);
  model.deActivateAllSplits();
  if(s.x1 == s.x2) vPipe = true;     //set flag to indicate vertical pipe
  if(s.y1 == s.y2) hPipe = true;     //set flag to indicate horizontal pipe
  
  //calculate pressure at the end of the new pipe segment that has replaced the previous pipe
  elbow = false;                                //reset flag for checking if pipes are at 90 degrees 
  totalLen = pLength(s.x1, s.y1, s.x2, s.y2);  
  Split a = model.selectSplit(s.x1, s.y1);     //get the split at the beginning of this new pipe to calculate the pressure drop across the new pipe 
  endPressure = a.pressure - pressureDrop(totalLen, inches, rCoeff, flow);   //pressure calculations for new pipe so inches and flow have been correctly set by use input
  model.addSplit(s.x2, s.y2, 1, endPressure);
  
  //recalculate pressure for all pipes as the network is complete now
  if(pipeEndOverlap) {
    println("recalculating pressures");
    for(Pipe p: model.getPipes()) {
    elbow = false;                                //reset flag for checking pipes at 90 degrees 
    totalLen = pLength(p.x1, p.y1, p.x2, p.y2);    
    Split f = model.selectSplit(p.x1, p.y1);      
    endPressure = f.pressure - pressureDrop(totalLen, p.inches, rCoeff, p.flow);   //pressure at end of pipe; inches and flow values associated with every pipe should be used 
    Split q = model.selectSplit(p.x2, p.y2);    
    q.pressure = endPressure;
    }
  }  

//  model.addSplit(s.x2, s.y2, 1, endPressure);
  beginX = s.x2;
  beginY = s.y2;
}


void addSplit() {
  if (mouseY<0 || mouseY>controlPos) return;
  Pipe t = model.selectPipe(mouseX, mouseY);
  if (t!=null) {
    SnapGrid s = new SnapGrid(t.x1,t.y1,mouseX,mouseY);
    s.snap();
    
    elbow = false;                                //reset flag for checking pipes at 90 degrees 
    totalLen = pLength(t.x1, t.y1, s.x2, s.y2);    // length of 1st pipe created by the split
    Split a = model.selectSplit(t.x1, t.y1);     //get the split at the beginning of 1st pipe to calculate the pressure drop across the new pipe 
    endPressure = a.pressure - pressureDrop(totalLen, t.inches, rCoeff, t.flow);   //pressure at end of pipe 
    
    model.splitPipe(t, s.x2, s.y2);
    model.deActivateAllSplits();
    model.addSplit(s.x2, s.y2, 1, endPressure);  //add new split point along with the pressure at this point
    
    totalLen = pLength(s.x2, s.y2, t.x2, t.y2);    // length of 2nd pipe created by the split
    Split b = model.selectSplit(s.x2, s.y2);   //get the new split to use to calculate the pressure at the end of the 2nd pipe  
    endPressure = b.pressure - pressureDrop(totalLen, t.inches, rCoeff, t.flow);   //pressure at end of pipe
    Split c = model.selectSplit(t.x2, t.y2);   //get the split at the end of the original pipe to calculate new pressure at this split
    c.pressure = endPressure;
    
    beginX = s.x2;
    beginY = s.y2;
  }
}

//boolean checkEndOverlap() {
//  if (s.x2>=p.x1-tolerance && s.x2<=p.x1+tolerance && s.y2>=p.y1-tolerance && s.y2<=p.y1+tolerance) { //snap end of new pipe to beginning of existing pipe 
//      println("overlap");
//      s.x2 = p.x1;
//      s.y2 = p.y1;
//      return true;
//  }

//void checkOverlap() {
//  if (s.x1 == s.x2)
//    for(int y = s.y1; y<= s.y2; y++) {
//      Pipes w = model.selectPipe(s.x1,y);
//      if(w != null) println("bridge needed at "+s.x1+","+y);
//    }
//  else if (s.y1 == s.y2) {
//    for(int x = s.x1; x<= s.x2; x++) {
//      Pipes g = model.selectPipe(x,s.y1);
//      if(g != null) println("bridge needed at "+x+","+s.y1);
//    }
//  }
//}
      
void selectSplit() {
  if (mouseY<0 || mouseY>controlPos) return;
  Split t = model.selectSplit(mouseX, mouseY);
  if (t!=null) {
    model.deActivateAllSplits();
    model.activateSplit(t);
    beginX = t.x;
    beginY = t.y;
  } 
}

void removePipe(){
  if (mouseY<0 || mouseY>controlPos) return;
  Pipe r = model.selectPipe(mouseX, mouseY);
  if (r!=null) {
    println(r.toString());
    model.deActivateAllSplits();
    Split b = model.selectSplit(r.x2, r.y2); //set the value of pressure at the end of the removed pipe to zero because there is no pipe 
    b.pressure = 0;
    
    Split t = model.selectSplit(r.x1, r.y1); //activate the previous split so that new pipes can be added here by default
    model.activateSplit(t);
    beginX = t.x;
    beginY = t.y;
    
    model.deletePipe(r);
    
    //re-calculate pressures at all nodes because of the removed pipe. Effectively all pressures after the removed section should be set to zero because network is incomplete now
    for(Pipe p: model.getPipes()) {
      elbow = false;                                //reset flag for checking pipes at 90 degrees 
      totalLen = pLength(p.x1, p.y1, p.x2, p.y2);    
      Split a = model.selectSplit(p.x1, p.y1);      
      if (a == null) {
        model.deleteSplit(b);
        return;
      }
      endPressure = a.pressure - pressureDrop(totalLen, p.inches, rCoeff, p.flow);   //pressure at end of pipe 
      Split q = model.selectSplit(p.x2, p.y2);   
      if (endPressure > 0) 
        q.pressure = endPressure;
      else q.pressure = 0;        //all pressures after the removed section will be negative so set them to zero
    }
   model.deleteSplit(b); 
  }  
}

void displacePipe() {
//  if (mouseY<0 || mouseY>controlPos) return; 
  Split t = model.knowActiveSplit(); //finding the active split that is the target destination for open pipe end
  println("Active split: "+t.x+","+t.y);
  Pipe p = model.getOpenPipe(); //finding the pipe with open end; will be recongnized when there is a pipe which does not have a split at x1,y1 as it was removed when the old pipe was removed
  if (p == null) return;
  println("Open pipe: "+p.toString());
  displaceX = p.x1 - t.x;
  displaceY = p.y1 - t.y;
  Split g = model.selectSplit(p.x2, p.y2);  //select the split for removal at the end of the pipe being displaced (equivalent to removing the pipe and adding a new one at the active node) 
  model.deleteSplit(g);
  p.x1 = p.x1 - displaceX;
  p.y1 = p.y1 - displaceY;
  p.x2 = p.x2 - displaceX;
  p.y2 = p.y2 - displaceY;
  //Calculate pressure at the end of this displaced pipe
  elbow = false;                                //reset flag for checking if pipes are at 90 degrees 
  totalLen = pLength(p.x1, p.y1, p.x2, p.y2);   
  endPressure = t.pressure - pressureDrop(totalLen, p.inches, rCoeff, p.flow);   //pressure calculations for new pipe so inches and flow have been correctly set by use input
  model.addSplit(p.x2, p.y2, 1, endPressure);
  model.deActivateAllSplits();
  Split n = model.selectSplit(p.x2, p.y2);
  model.activateSplit(n);
}

//calculate the pressure drop across the pipe
float pressureDrop(float pipeLength, float dia, float constant, float fRate) { 
  constant = constant/1.0;
  fRate = fRate/1.0;
  dia = dia/1.0;
  float pLossPer100ft = (43/100.0) * (2083/10000.0) * pow(100/constant, 1852/1000.0) * pow(fRate, 1852/1000.0) / pow(dia, 48655/10000.0);
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
    case 6:  // user wants to displace pipe
      tool = "displace";
      break;
  }
  
}

