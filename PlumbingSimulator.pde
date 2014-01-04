import controlP5.*;

// Model
PipesModel model = new PipesModel();
// CP5
ControlP5 cp5;
RadioButton r;
// Processing variables
int initialX = 10;
int initialY = 10;
int beginX = initialX;
int beginY = initialY;
int pipeWidth;
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
  model.addPipe(s.x1, s.y1, s.x2, s.y2, pipeWidth);
  model.deActivateAllSplits();
  model.addSplit(s.x2, s.y2, 1); 
  beginX = s.x2;
  beginY = s.y2;
}


void addSplit() {
  if (mouseY<0 || mouseY>330) return;
  Pipe t = model.selectPipe(mouseX, mouseY);
  if (t!=null) {
    SnapGrid s = new SnapGrid(t.x1,t.y1,mouseX,mouseY);
    s.snap();
    model.splitPipe(t, s.x2, s.y2);
    model.deActivateAllSplits();
    model.addSplit(s.x2, s.y2, 1);
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


// which radio button pipe size did the user select?
void pipeButton(int a) {
  switch(a) {
    case 0:
      tool =  "select";
      break;
    case 1:  // pipe diameter 1 inch 
      pipeWidth = 10;
      tool = "pipe";
      break;
    case 2:  // pipe diameter 3/4 inch
      pipeWidth = 5;
      tool = "pipe";
      break;
    case 3:  // pipe diameter 3/4 inch
      pipeWidth = 1;
      tool = "pipe";
      break;
    case 4:  // user wants to split from the last pipe
      tool = "split";
      break;
  }
  
}

