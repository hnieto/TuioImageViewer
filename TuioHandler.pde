// we need to import the TUIO library
// and declare a TuioProcessing client variable
import TUIO.*;
TuioProcessing tuioClient;
int port = 3333;
TuioCursor tuioCursor1 = null;
TuioCursor tuioCursor2 = null;
TuioCursor tuioCursor3 = null;

float desiredImageWidth = width/8;
float startDistance, currDistance;
float prevZoomFactor, zoomFactor;

float prevTapTimeStamp;
float tapTimeStamp = 0;

// distance between finger and selected picture's center
int dx, dy;

void initTUIO() {
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this, port);
  println("\n" + "TUIO client listening on port " + port + " .....");
}

void showCursors(){
  if(tuioCursor1 != null){
    pushStyle();
    stroke(255);
    strokeWeight(3);
    fill(255,0,0);
    ellipse(tuioCursor1.getScreenX(width), tuioCursor1.getScreenY(height), width/64, width/64);
    popStyle();
  }

  if(tuioCursor2 != null){
    pushStyle();
    stroke(255);
    strokeWeight(3);
    fill(255,0,0);
    ellipse(tuioCursor2.getScreenX(width), tuioCursor2.getScreenY(height), width/64, width/64);
    popStyle();
  }
  
  if(tuioCursor3 != null){
    pushStyle();
    stroke(255);
    strokeWeight(3);
    fill(255,0,0);
    ellipse(tuioCursor3.getScreenX(width), tuioCursor3.getScreenY(height), width/64, width/64);
    popStyle();
  }
}

float getDistance(TuioCursor tuioCursor1, TuioCursor tuioCursor2) {
  return dist(tuioCursor1.getScreenX(width), tuioCursor1.getScreenY(height), 
              tuioCursor2.getScreenX(width), tuioCursor2.getScreenY(height));
}

boolean doubleTapped(TuioCursor finger) {
  if(tapTimeStamp == 0) {
    tapTimeStamp = finger.getTuioTime().getTotalMilliseconds()*0.001;
    return false;
  } else {
    prevTapTimeStamp = tapTimeStamp;
    tapTimeStamp = finger.getTuioTime().getTotalMilliseconds()*0.001;
    if((tapTimeStamp-prevTapTimeStamp) < 0.5) {
      tapTimeStamp = 0; // reset for next time
      return true;
    } else return false;
  }
}

// these callback methods are called whenever a TUIO event occurs
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) { 
  if (tuioCursor1 == null) {
    tuioCursor1 = tcur;
    for(int i=0; i<pictures.length; i++) {
      if(pictures[i].isPicked()) {
        dx = (int) (tuioCursor1.getScreenX(width) - pictures[i].getX());
        dy = (int) (tuioCursor1.getScreenY(height) - pictures[i].getY());
        if(doubleTapped(tuioCursor1)) pictures[i].flip();
      } else {
        // reset dx,dy if no image has been selected yet
        dx = 0;
        dy = 0; 
      }
    }
  } 
  else if (tuioCursor2 == null) {
    // zooming & rotating
    tuioCursor2 = tcur; 
    startDistance = getDistance(tuioCursor1, tuioCursor2);
    prevZoomFactor = zoomFactor;
  }
  else if (tuioCursor3 == null) {
    tuioCursor3 = tcur;
    // deselect picture with 3 finger touch. 
    for (int i=0; i<pictures.length; i++){
      pictures[i].unPick(); 
    }     
  }
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) { 
  if (tuioCursor1 != null && tuioCursor2 != null) {    
    for (int i=0; i<pictures.length; i++) {
      if(pictures[i].isPicked()) {
        // zoom
        currDistance = getDistance(tuioCursor1, tuioCursor2);
        zoomFactor = prevZoomFactor*(currDistance/startDistance);
        pictures[i].setScalePercent(zoomFactor); // get picture's scale value in case user zooms
        
        // prevent multiple pictures from being selected
        for (int j=0; j<pictures.length; j++) {
          if(j != i) pictures[j].setUnavailable(); 
        }
      }
    }
  } 
  
  else if (tuioCursor1 != null) {
    // move selected picture to current cursor position
    for (int i=0; i<pictures.length; i++) {
      if(pictures[i].isPicked()) {
        zoomFactor = pictures[i].getScalePercent();
        pictures[i].setXY(tuioCursor1.getScreenX(width)-dx, tuioCursor1.getScreenY(height)-dy);
        
        // prevent multiple pictures from being selected
        for (int j=0; j<pictures.length; j++) {
          if(j != i) pictures[j].setUnavailable(); 
        }
      }
    }
  } 
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (tuioCursor3 != null && tuioCursor3.getCursorID() == tcur.getCursorID()) {
    // remove 3rd cursor
    tuioCursor3 = null;
  }
  
  if (tuioCursor2 != null && tuioCursor2.getCursorID() == tcur.getCursorID()) {
    // remove 2nd cursor
    tuioCursor2 = null;
    // If 3rd cursor still exists, make it the 2nd cursor
    if (tuioCursor3 != null) {
      tuioCursor2 = tuioCursor3;
      tuioCursor3 = null; 
    }
  }
  
  if (tuioCursor1 != null && tuioCursor1.getCursorID() == tcur.getCursorID()) {
    // remove 1st cursor
    tuioCursor1 = null;
    // If 2nd cursor still exists, make it the 1st cursor
    if (tuioCursor2 != null) {
      tuioCursor1 = tuioCursor2;
      tuioCursor2 = null; 
      
      // update dx,dy due to cursor exchange
      for(int i=0; i<pictures.length; i++) {
        if(pictures[i].isPicked()) {
          dx = (int) (tuioCursor1.getScreenX(width) - pictures[i].getX());
          dy = (int) (tuioCursor1.getScreenY(height) - pictures[i].getY());
        } 
      }
    }    
    // If 3rd cursor still exists, make it the 2nd cursor
    if (tuioCursor3 != null) {
      tuioCursor2 = tuioCursor3;
      tuioCursor3 = null; 
    }
  }
  
}

// called after each message bundle representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
} 

// NOT NEEDED
public void addTuioObject(TuioObject tobj) {}
public void updateTuioObject(TuioObject tobj) {}  
public void removeTuioObject(TuioObject tobj) {}

