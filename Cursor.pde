class Cursor {
  private float x;
  private float y;
  private float w;
  private float h;
  private color c;

  Cursor(float _w, color _c) {
    w = _w;
    h = _w;
    c = _c;
  } 
  
  public void display() {
    ellipseMode(CENTER);
    pushMatrix();
    pushStyle();
    stroke(255); // white border
    strokeWeight(3);
    fill(c); // cursor filling
    translate(x,y,1); // use z=1 to draw cursor on top of images
    ellipse(0, 0, w, h);
    popStyle();
    popMatrix();
  }
  
  public void update(float _x, float _y) {
    x = _x; 
    y = _y;
    if(MPE_ON) process.broadcast(getState());
  }
  
  public void setState(final CursorState state) {
    x = state.x;
    y = state.y;
    w = state.w;
    h = state.h;
    c = unhex(state.cursorColor);
    
    display();
  } 
  
  private CursorState getState() {
    return new CursorState(x, y, w, h, hex(c)); 
  }
}
