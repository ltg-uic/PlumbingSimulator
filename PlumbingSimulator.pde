import controlP5.*;

// Model
private PipesModel model = new PipesModel();
// CP5
private ControlP5 cp5;
private RadioButton r;
// Processing variables
private int initialX = 10;
private int initialY = 10;
private int beginX = initialX;
private int beginY = initialY;
int pipeWidth;
int pipeSplit;
int currentSegmentId;

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
}

public void draw() {
  fill(255,0,0);
  ellipse(initialX, initialY, 5, 5);
}

public void mousePressed() {
  addpipe();
}

void addpipe () {
  if (mouseY>=0 && mouseY<=330 && pipeSplit!=1) {
    SnapGrid s = new SnapGrid(beginX,beginY,mouseX,mouseY);
    s.snap();
    model.addPipe(s.x1, s.y1, s.x2, s.y2, pipeWidth, currentSegmentId);
    beginX = s.x2;
    beginY = s.y2;
    println("segment#: "+currentSegmentId+" #pipe:"+model.getPipesN(currentSegmentId));
    println(s.x1+","+s.y2+" : "+s.x2+","+s.y2+" : "+pipeWidth);
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

