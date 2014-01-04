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
int pipeSplit;

public void setup() {
  size(640,360);
  cp5 = new ControlP5(this);
  r = cp5.addRadioButton("pipeButton")
    .setPosition(20,330)
    .setSize(40,20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(0))
    .setItemsPerRow(4)
    .setSpacingColumn(100)
    .addItem("1 inch",1)
    .addItem("1/2 inch",2)
    .addItem("3/4 inch",3)
    .addItem("Split",4);
  model.init(initialX, initialY);
}

public void draw() {
  for(Pipe p: model.getPipes())
    drawPipe(p);
  for(Split s: model.getSplits())
    drawSplit(s);
}

public void drawPipe(Pipe p) {
  strokeWeight(p.pWidth);
  line(p.x1,p.y1,p.x2,p.y2);
  strokeWeight(1);
}

public void drawSplit(Split s) {
  stroke(0,0,255);
  fill(0,0,255);
  ellipse(s.x,s.y,12,12);
  fill(0);
  stroke(0);
}

public void mousePressed() {
  if (pipeSplit==1) 
    addSplit(); 
  else
    addpipe();
}

void addpipe () {
  if (mouseY>=0 && mouseY<=330 && pipeSplit!=1) {
    SnapGrid s = new SnapGrid(beginX,beginY,mouseX,mouseY);
    s.snap();
    model.addPipe(s.x1, s.y1, s.x2, s.y2, pipeWidth);
    beginX = s.x2;
    beginY = s.y2;
    println(s.x1+","+s.y2+" : "+s.x2+","+s.y2+" : "+pipeWidth);
  }
}


void addSplit() {
  if (mouseY<0 || mouseY>330) return;
  Pipe t = model.selectPipe(mouseX, mouseY);
  if (t!=null) {
    SnapGrid s = new SnapGrid(t.x1,t.y1,mouseX,mouseY);
    s.snap();
    model.splitPipe(t, s.x2, s.y2);
    model.addSplit(s.x2, s.y2, 1);
  }
}


// which radio button pipe size did the user select?
void pipeButton(int a) {
  println("a radio Button event: "+a);
  //set strokewidth to draw different pipe diameters based on user input
  if (a==1) { // pipe diameter 1 inch
    pipeWidth = 10;
    pipeSplit = 0;
  } else if (a==2) { // pipe diameter 1/2 inch
    pipeWidth = 5;
    pipeSplit = 0;
  } else if (a==3) { // pipe diameter 3/4 inch
    pipeWidth = 1;
    pipeSplit = 0;
  } else if (a==4) { // user wants to split from the last pipe
    pipeSplit = 1;
  }
}

