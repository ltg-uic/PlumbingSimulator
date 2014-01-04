import java.util.HashSet;
import java.util.Set;

public class PipesModel {
  private Set<Pipe> pipes = new HashSet<Pipe>();

  public void addPipe(int x1, int y1, int x2, int y2, int pWidth) {
    pipes.add(new Pipe(x1, y1, x2, y2, pWidth));
  }

  public Set<Pipe> getPipes(){
    return pipes;
  }
}
