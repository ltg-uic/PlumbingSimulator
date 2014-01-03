package plumbing.model;

import java.util.ArrayList;
import java.util.List;

public class PipesModel {
	private List<Segment> segments = new ArrayList<>();


	public void addSegment(Segment segment) {
		segments.add(segment);
	}
	
}
