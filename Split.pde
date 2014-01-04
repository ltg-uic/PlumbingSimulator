public class Split {
  int x;
  int y;
  int outlets;
  boolean isActive;
  
  public Split (int x, int y, int outlets) {
    this.x = x;
    this.y = y;
    this.outlets = outlets;
    this.isActive = true ; 
  }
  
  
  public boolean equals(Object obj) {
    if (obj instanceof Split) {
      Split s = (Split) obj;
      if (x==s.x && y==s.y)
        return true;
    }
    return false;
  }
  
  
  public String toString() {
    return "("+x+","+y+")("+outlets+")";
  }
  
}
