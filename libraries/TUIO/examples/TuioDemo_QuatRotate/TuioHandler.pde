// we need to import the TUIO library
// and declare a TuioProcessing client variable
import TUIO.*;
TuioProcessing tuioClient;
TuioCursor tuioCursor1 = null;

void initTUIO() {
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
}

// these callback methods are called whenever a TUIO event occurs
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) { 
  //  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  if (tuioCursor1 == null) {
    // rotate
    tuioCursor1 = tcur;
    arcball.mousePressed(tcur.getScreenX(width),tcur.getScreenY(height));
  } 
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) { 
  if (tuioCursor1 != null) {
    // rotate
    arcball.mouseDragged(tcur.getScreenX(width),tcur.getScreenY(height));
  } 
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (tuioCursor1 != null && tuioCursor1.getCursorID() == tcur.getCursorID()) {
    // Remove 1st cursor
    tuioCursor1 = null;
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


