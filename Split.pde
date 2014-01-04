public class Split {
  int x;
  int y;
  boolean isActive;
  
  public Split (int x, int y) {
    this.x = x;
    this.y = y;
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
    return "("+x+","+y+")";
  }
  
}
