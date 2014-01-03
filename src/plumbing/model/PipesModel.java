package plumbing.model;

import java.util.ArrayList;
import java.util.List;

public class PipesModel {
	private List<Segment> segments = new ArrayList<>();

	public void addPipe(int x1, int y1, int x2, int y2, int pipeWidth, int currentSegmentId) {
		// If there is not a segment
		if ( currentSegmentId <= segments.size() ) {
			Segment s = new Segment();
			s.addPipe(x1, y1, x2, y2, pipeWidth);
			segments.add(s);
		}
	}

	public int getPipesN(int currentSegmentId) {
		return segments.get(currentSegmentId).getPipesN();
	}
	
}
