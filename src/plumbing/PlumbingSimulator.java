package plumbing;

import plumbing.model.PipesModel;
import plumbing.model.Segment;
import processing.core.PApplet;

public class PlumbingSimulator extends PApplet {
	private static final long serialVersionUID = 1L;

	public static void main(String args[]) {
	    PApplet.main(new String[] { "--present", "PlumbingSimulator" });
	}
	
	// Model
	private PipesModel model = new PipesModel();
	// Processing variables
	private int beginX = 10;
	private int beginY = 10;
	private int endX;
	private int endY;
	
	public void setup() {
	}

	public void draw() {
		background(255, 0, 0);
	}


	public void mousePressed() {
		addpipe();
	}
	
	
	void addpipe() {
		endX = 0;
		endX = 0;
		model.addSegment(new Segment(beginX, beginY, endX, endY, 0));
	}

}
