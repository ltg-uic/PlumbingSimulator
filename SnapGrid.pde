class SnapGrid {
  int x1;
  int x2;
  int y1;
  int y2;

  SnapGrid(int x1, int y1, int x2, int y2) {
    this.x1=x1;
    this.y1=y1;
    this.x2=x2;
    this.y2=y2;
  }

  void snap() {
    if(abs(x2-x1) < abs(y2-y1))
      x2=x1;
    else 
      y2=y1;
  }
  
}

