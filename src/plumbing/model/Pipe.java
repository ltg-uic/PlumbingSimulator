package plumbing.model;

public class Pipe {

	int posX;
	int posY;
	int newposX;
	int newposY;
	int pWidth;
	int newtempposX;
	int newtempposY; 
	int pipeSegment;
	int pLength;

	Pipe(int tempposX, int tempposY, int newtempposX, int newtempposY, int temppipewidth, int tempSegment){
		posX = tempposX;
		posY = tempposY;
		newposX = newtempposX;
		newposY = newtempposY;
		//pipelength = temppipelength;
		pWidth = temppipewidth;
		pipeSegment = tempSegment;
		//align = tempalign;
	}

}
