/****** Most Pixels Ever ******/

// MPE includes
import mpe.Process;
import mpe.Configuration;

// MPE Process thread
Process process;

// MPE Configuration object
Configuration tileConfig;

// Tiled Display configuration file
String configPath;

// Set to TRUE if using MPE + Tiled Display
boolean MPE_ON = true;

/******************************/

String[] picture_names; 
Picture[] pictures;
Cursor finger;
int sketchWidth, sketchHeight;  // makes it easy to swap between MPE dimensions and regular sketch dimensions
boolean FULLSCREEN = false;
boolean showCursor = true;

void setup() {

  if (MPE_ON) {
    FULLSCREEN = false;

    // create a new configuration object and specify the path to the configuration file
    tileConfig = new Configuration(dataPath("MPE/configuration.xml"), this);

    // set the size of the sketch based on the configuration file
    size(tileConfig.getLWidth(), tileConfig.getLHeight(), OPENGL);

    // create a new process
    process = new Process(tileConfig);

    sketchWidth  = process.getMWidth();
    sketchHeight = process.getMHeight(); 

    randomSeed(0);
  } 
  else {
    if (FULLSCREEN) size(displayWidth, displayHeight, OPENGL); // run from "Sketch -> Present"
    else size(1000, 700, OPENGL);
    sketchWidth = width;
    sketchHeight = height;
  }

  getPictures();
  loadPictures();
  getPictureDescriptions();

  initTUIO();
  finger = new Cursor(sketchWidth/64, color(255, 0, 0));

  // start the MPE process
  if (MPE_ON) process.start();
}

void draw() {
  background(0);

  if (MPE_ON) {
    // synchronize render nodes with head node 
    if (process.messageReceived()) {

      // read serialized object
      Object obj = process.getMessage();

      if (obj instanceof PictureState) {
        // cast object to a PictureState
        PictureState picState = (PictureState) obj;
        pictures[picState.id].setState(picState);
      } 

      else if (obj instanceof CursorState) { 
        // cast object to a CursorState
        CursorState curState = (CursorState) obj; 
        finger.setState(curState);
      }
    }
  }

  moveSelectedPictureForward();
  showPictures();
  showCursor();
}

void getPictures() {
  picture_names = listFileNames(dataPath("Images/"));  // get image names from folder

  //continue only if some image files found in directory
  if ((picture_names != null)&&(picture_names.length > 0)) {
    println ("Number of pictures in data path: " + picture_names.length);
    pictures = new Picture[picture_names.length];

    println ("\n" + "Creating picture objects .....");
    for (int i=0; i<picture_names.length; i++) {
      pictures[i] = new Picture(picture_names[i], i);
    }
  } 

  else {
    println ("No compatible images found in data path.");
    exit();
  }
}

void loadPictures() {
  println ("\n" + "Loading pictures .....");
  for (int i=0; i<picture_names.length; i++) {
    pictures[i].load();
    println (picture_names[i] + " loaded successfully.");
  }
}

void getPictureDescriptions() {
  println("\n" + "Reading XML file for picture descriptions .....");
  XML xml = loadXML(dataPath("picture_descriptions.xml")); // Load an XML document
  XML[] children = xml.getChildren("picture");

  for (int i=0; i<children.length; i++) {
    String picture_name = children[i].getString("name");
    String description = children[i].getContent();
    for (int j=0; j<pictures.length; j++) {
      if (picture_name.equals(pictures[j].getName())) pictures[j].setDescription(description);
    }
  }
}

void moveSelectedPictureForward() {
  // last element in array is always on top since it is drawn last
  for (int i=0; i<pictures.length; i++) {
    if (pictures[i].isPicked()) {
      // no need to reorder pictures array if selected picture is already last element
      if (i !=  pictures.length-1) {
        Picture temp = pictures[pictures.length-1];
        pictures[pictures.length-1] = pictures[i];
        pictures[i] = temp;
      }
    }
  }
}

void showPictures() {   
  for (int i=0; i<pictures.length; i++) {
    pictures[i].display(); 
  }

  for (int i=pictures.length-1; i>=0; i--) {
    pictures[i].update();    

    // prevent multiple pictures from being selected
    if (pictures[i].isPicked()) break;
  }

  if(MPE_ON) process.broadcast(pictures[pictures.length-1].getState()); 
}

void showCursor() {
  if (showCursor && tuioCursor1 != null) {
    finger.update(tuioCursor1.getScreenX(sketchWidth), tuioCursor1.getScreenY(sketchHeight));
    finger.display();
  }
}

// This function returns all the files in a directory as an array of Strings  
// only matching compatible image extensions
String[] listFileNames(String dir) {
  File file = new File(dir);
  FileFilter imgExt = new FileFilter();
  if (file.isDirectory()) {
    String names[] = file.list(imgExt);
    return names;
  } 
  else {
    // If it's not a directory
    return null;
  }
}

