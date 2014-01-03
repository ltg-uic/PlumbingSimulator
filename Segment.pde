import java.util.ArrayList;
import java.util.List;

public class Segment {
  public List<Pipe> pipes = new ArrayList<Pipe>();
  
  
  public void addPipe(int x1, int y1, int x2, int y2, int pipeWidth) {
    pipes.add(new Pipe(x1, y1, x2, y2, pipeWidth));
  }
  
  public void makePipe(int x1, int y1, int x2, int y2, int pipeWidth){
    strokeWeight(pipeWidth);
    line(x1,y1,x2,y2);
  }

  public int getPipesN() {
    return pipes.size();
  }

  public List<Pipe> getPipes(){
    return pipes;
  }
  
//  @Override
//  protected Object clone() throws CloneNotSupportedException {
//    //return new PipesModel(a, b);
//  }

}
