package plumbing.model;

import java.util.ArrayList;
import java.util.List;

public class Segment {
	public List<Pipe> pipes = new ArrayList<>();
	
	
	public void addPipe(int x1, int y1, int x2, int y2, int pipeWidth) {
		pipes.add(new Pipe(x1, y1, x2, y2, pipeWidth));
	}
	
	public int getPipesN() {
		return pipes.size();
	}

	
//	@Override
//	protected Object clone() throws CloneNotSupportedException {
//		//return new PipesModel(a, b);
//	}

}
