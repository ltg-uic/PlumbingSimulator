import java.util.HashSet;
import java.util.Set;

public class PipesModel {
  private Set<Pipe> pipes = new HashSet<Pipe>();
  private Set<Split> splits = new HashSet<Split>(); 
  private int tolerance = 3;
  
  // Initializes the model
  public void init(int initialX, int initialY) {
    splits.add(new Split(initialX, initialY, 2));
  }

  // Adds a pipe
  public void addPipe(int x1, int y1, int x2, int y2, int pWidth) {
    pipes.add(new Pipe(x1, y1, x2, y2, pWidth));
  }
  
  // Adds a split
  public void addSplit(int x, int y, int outlets) {
    splits.add(new Split(x, y, outlets));
  }

  // Returns all pipes
  public Set<Pipe> getPipes(){
    return pipes;
  }
  
  // Returns all splits
  public Set<Split> getSplits(){
    return splits;
  }
  
  // Returns the pipe at x and y coordinates or null if no pipe is selected
  public Pipe selectPipe(int x, int y) {
    Pipe temp = null;
    for (Pipe p: pipes) {
      // Horizontal pipe
      if (p.y1==p.y2) {
        if (x>=p.x1 && x<=p.x2 && y>=p.y1-tolerance && y<=p.y1+tolerance)
          return p;
      } else {
        if (x>=p.x1-tolerance && x<=p.x1+tolerance && y>=p.y1 && y<=p.y2)
          return p;
      }
    }
    return null;
  }
  
  // Removes a pipe (p) and replaces with two pipes (x1, x) (
  public void splitPipe(Pipe p, int x, int y) {
    pipes.add(new Pipe(p.x1, p.y1, x, y, p.pWidth));
    pipes.add(new Pipe(x, y, p.x2, p.y2, p.pWidth));
    pipes.remove(p);
  }
  
}
