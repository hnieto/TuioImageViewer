String imgPath = "";   //Path to images folder. leave blank for sketch data dir, else end with \\
String xmlFile = "picture_descriptions.xml";
String[] picture_names; 
Picture[] pictures;

/* UNCOMMENT FOR FULLSCREEN */
/*boolean sketchFullScreen() {
  return true;
} */

void setup() {
  //size(displayWidth,displayHeight,OPENGL); // UNCOMMENT FOR FULLSCREEN
  size(1000, 700, OPENGL);
  getPictures();
  loadPictures();
  getPictureDescriptions();
  initTUIO();
}

void draw() {
  background(0);
  moveSelectedPictureForward();
  showPictures();
  showCursors();
}

void getPictures() {
  picture_names = listFileNames(dataPath(imgPath));  // get image names from folder

  //continue only if some image files found in directory
  if ((picture_names != null)&&(picture_names.length > 0)) {
    println ("Number of pictures in data path: " + picture_names.length);
    pictures = new Picture[picture_names.length];
    
    println ("\n" + "Creating picture objects .....");
    for(int i=0; i<picture_names.length; i++) {
      pictures[i] = new Picture(imgPath + picture_names[i]);
    }
  } 
  
  else {
    println ("No compatible images found in data path");
    exit();
  }
}

void loadPictures() {
  println ("\n" + "Loading pictures .....");
  for (int i=0; i<picture_names.length; i++) {
    println (picture_names[i] + " loaded");
    pictures[i].load();
  } 
}

void getPictureDescriptions() {
  println("\n" + "Reading XML file for picture descriptions .....");
  XML xml = loadXML(dataPath(imgPath) + "/" + xmlFile); // Load an XML document
  XML[] children = xml.getChildren("picture");
  
  for(int i=0; i<children.length; i++) {
    String picture_name = children[i].getString("name");
    String description = children[i].getContent();
    for(int j=0; j<pictures.length; j++){
      if(picture_name.equals(pictures[j].getName())) pictures[j].setDescription(description); 
    }
  } 
}

void moveSelectedPictureForward() {
  // last element in array is always on top since it is drawn last
  for (int i=0; i<pictures.length; i++) {
    if(pictures[i].isPicked()){
      // no need to reorder pictures array if selected picture is already last element
      if(i !=  pictures.length-1){
        Picture temp = pictures[pictures.length-1];
        pictures[pictures.length-1] = pictures[i];
        pictures[i] = temp;         
      }
    }
  }
}

void showPictures() {
  for (int i=0; i<pictures.length; i++) {
    pictures[i].update();
    pictures[i].display();
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

/* INCOMPLETE (POSSIBLY NOT NEEDED) */
/*void overlapCheck() {
  int x1, y1, x2, y2;
  for (int i=0; i<picture_count; i++) {
    pic1_x1 = pictures[i].getX();
    pic1_y1 = pictures[i].getY();
    pic1_x2 = pic1_x1 + pictures[i].getWidth();
    pic1_y2 = pic1_y1 + pictures[i].getHeight();
    
    for (int j=0; j<picture_count: j++) {
      if(picture[i] != pictures[j]){
        pic2_x1 = pictures[j].getX();
        pic2_y1 = pictures[j].getY();
        pic2_x2 = pic2_x1 + pictures[j].getWidth();
        pic2_y2 = pic2_y1 + pictures[j].getHeight();
        
        if ( pic1_x1 < pic2_x2 && // If pic1's left edge is to the right of the pic2's right edge, then pic1 is totally to right of pic2
             pic1_x2 > pic2_x1 && // If pic1's right edge is to the left of the pic2's left edge, then pic1 is totally to left of pic2
             pic1_y1 < pic2_y2 && // If pic1's top edge is below pic2's bottom  edge, then pic1 is totally below pic2
             pic1_y2 > pic2_y1 )  // If pic1's bottom edge is above pic2's top edge, then pic1 is totally above pic2
             // no overlap
        else {
          // change pic2's coordinates to fix overlap
        }
      } 
    }
  }
} */
