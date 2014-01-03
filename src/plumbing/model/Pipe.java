package plumbing.model;

public class Pipe {

	int posX;
	int posY;
	int newposX;
	int newposY;
	int pWidth;

	Pipe(int tempposX, int tempposY, int newtempposX, int newtempposY, int temppipewidth){
		posX = tempposX;
		posY = tempposY;
		newposX = newtempposX;
		newposY = newtempposY;
		pWidth = temppipewidth;	
	}

}
