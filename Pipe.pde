public class Pipe {
  int x1;
  int y1;
  int x2;
  int y2;
  int pWidth;
  float inches;
  float flow;

  public Pipe(int x1, int y1, int x2, int y2, int pWidth, float inches, float flow) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.pWidth = pWidth;
    this.inches = inches;
    this.flow = flow;
  }
  
  
  public boolean equals(Object obj) {
    if (obj instanceof Pipe) {
      Pipe p = (Pipe) obj;
      if (x1==p.x1 && x2==p.x2 && y1==p.y1 && y2==p.y2 && pWidth==p.pWidth)
        return true;
    }
    return false;
  }
  
  
  public String toString() {
    if (x1==x2)
      return "("+x1+","+y1+")|||"+pWidth+"|||("+x2+","+y2+")";
    else
      return "("+x1+","+y1+")---"+pWidth+"---("+x2+","+y2+")";
  }
  
}

