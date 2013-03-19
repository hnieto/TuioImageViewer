ArcBall arcball;

void setup() {
  //size(displayWidth, displayHeight, OPENGL);
  size(300, 300, OPENGL);  
  arcball = new ArcBall(width/2, height/2, min(width - 20, height - 20) * 0.8);
  initTUIO(width,height);
}

void draw() {
  background(255);

  fill(0, 255, 0);
  lights();
 // pushMatrix();
  translate(getNewX(), getNewY());
  scale(getZoomScaler());
  arcball.update();
  box(20);
//  popMatrix();
}
/*
boolean sketchFullScreen(){
 return true; 
} */
