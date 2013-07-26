/****** Massive Pixel Environment ******/

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
boolean MPE_ON = false;

/************************************/

boolean useFlickr = true;
String flickrURL; 
String flickrGetInfo;
String userID = "93737221@N07"; // heri = 93737221@N07
                                // brandt = 14626663@N08
                                // library = 8623220@N02
                                // blanton museum = 34255061@N03
                                // smithsonian = 25053835@N03
int maxNumberOfImages = 3;

String[] picture_names; 
ArrayList<Picture> pictures;
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

  if(useFlickr) getPicturesFromFlickr();
  else {
    getPicturesFromFolder();
    getPictureDescriptions();
    loadPictures();
  }

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
        pictures.get(picState.id).setState(picState);
      } 

      else if (obj instanceof CursorState) { 
        // cast object to a CursorState
        CursorState curState = (CursorState) obj; 
        finger.setState(curState);
      }
    }
  }

  //moveSelectedPictureForward();
  showPictures();
  showCursor();
}

void getPicturesFromFolder() {
  println("Using your /Images folder as source folder");
  picture_names = listFileNames(dataPath("Images/"));  // get image names from folder

  //continue only if some image files found in directory
  if ((picture_names != null)&&(picture_names.length > 0)) {
    println ("Number of pictures in data path: " + picture_names.length);
    pictures = new ArrayList<Picture>();

    println ("\n" + "Creating picture objects .....");
    for (int i=0; i<picture_names.length; i++) {
      pictures.add(new Picture(picture_names[i], i));
    }
  } 

  else {
    println ("No compatible images found in data path.");
    exit();
  }
}

void getPicturesFromFlickr() {
  println("Using Flickr API to obtain images.");
  flickrURL = "http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=f738223233556d4560000fef045e19ec&user_id="+userID+"&extras=url_o&per_page="+maxNumberOfImages;
  XML xmlFlickr = loadXML(flickrURL);
  XML[] xmlImages = xmlFlickr.getChildren("photos/photo");
  println("Number of pictures pulled from Flickr: " + xmlImages.length);
  pictures = new ArrayList<Picture>();
  
  for(int i = 0 ; i < xmlImages.length; i++) {
    String desc = xmlImages[i].getString("title");
    String farm = xmlImages[i].getString("farm");
    String server = xmlImages[i].getString("server");
    String id = xmlImages[i].getString("id");
    String secret = xmlImages[i].getString("secret");  
    String h = xmlImages[i].getString("height_o");
    String w = xmlImages[i].getString("width_o");
    String url_o = xmlImages[i].getString("url_o");
    pictures.add(new Picture(url_o, i));
    pictures.get(i).load();
    
    // get picture description if available
    flickrGetInfo = "http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=d23ef69291abb4a7c7a3c5d578f0d982&photo_id="+id+"&format=rest";
    XML xmlGetInfo = loadXML(flickrGetInfo);
    XML xmlInfo = xmlGetInfo.getChild("photo/description");
    if(xmlInfo.getContent().length() == 0) pictures.get(i).setDescription("This picture does not have it's description paramter set");
    else pictures.get(i).setDescription(xmlInfo.getContent());
  }  
}

void loadPictures() {
  println ("\n" + "Loading pictures .....");
  for (int i=0; i<pictures.size(); i++) {
    pictures.get(i).load();
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
    for (int j=0; j<pictures.size()-1; j++) {
      if (picture_name.equals(pictures.get(j).getName())) pictures.get(j).setDescription(description);
    }
  }
}

void showPictures() {   
  for (int i=0; i<pictures.size(); i++) {
    pictures.get(i).display(); 
  }

  for (int i=pictures.size()-1; i>=0; i--) {
    pictures.get(i).update();    

    // reorder array. move selected picture to back of the array so it will be drawn last
    if (pictures.get(i).isPicked()) {
      // no need to reorder pictures array if selected picture is already last element
      if (i !=  pictures.size()-1) {
        Picture temp = pictures.get(pictures.size()-1);
        pictures.set(pictures.size()-1,pictures.get(i));
        pictures.set(i,temp);
      }
      break; // prevent multiple pictures from being prevented
    }
  }

  if(MPE_ON) process.broadcast(pictures.get(pictures.size()-1).getState()); 
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
