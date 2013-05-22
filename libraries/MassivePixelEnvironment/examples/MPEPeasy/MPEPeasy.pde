import processing.opengl.*;


// MPE includes
import mpe.Process;
import mpe.Configuration;

// MPE Process thread
Process process;

// MPE Configuration object
Configuration tileConfig;

void setup() {
  
  // create a new configuration object and specify the path to the configuration file
  tileConfig = new Configuration("/Users/eddie/Programming/Processing/TuioImageViewer/data/MPE/configuration.xml", this);
  
  // set the size of the sketch based on the configuration file
  size(tileConfig.getLWidth(), tileConfig.getLHeight(), OPENGL);
  
  // create a new process
  process = new Process(tileConfig);
  
  // disable camera placement by MPE, because it interferes with PeasyCam
  process.disableCameraReset();
 
  
  // start the MPE process
  process.start();
}
void draw() {
  
  // draw a couple boxes
  scale(5);
  rotateX(-.5);
  rotateY(-.5);
  background(0);
  fill(255,0,0);
  box(200);
  pushMatrix();
  translate(0,0,200);
  fill(0,0,255);
  box(50);
  popMatrix();
}

