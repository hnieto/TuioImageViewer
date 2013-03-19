ArcBall arcball;

void setup() {
  //size(displayWidth, displayHeight, OPENGL);
  size(200, 200, OPENGL);
  arcball = new ArcBall(width/2, height/2, min(width - 20, height - 20) * 0.8);
  initTUIO();
}

void draw() {
  background(255);

  fill(0, 255, 0);
  lights();
  translate(width/2,height/2);
  arcball.update();
  box(30);
}
/*
boolean sketchFullScreen(){
 return true;
} */
