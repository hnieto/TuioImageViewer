class Picture {
  private PImage img;
  private String imgPath;
  private String imgName;
  private String imgDescription;
  private int id;

  /* Size */
  private float zoom;
  private float expectedPictureWidth;
  private float scaledWidth;
  private float scaledHeight;
  
  /* Border */
  private int borderThickness;
  private color borderColor;

  /* Movement */
  private PVector location;  
  private PVector velocity;
  private PVector friction;
  private float u; // coefficent of friction
  private float xOffset;
  private float yOffset;
  
  /* Y-Axis Rotation */
  private float theta;
  private boolean showPicture;
  private boolean showText;
  
  /* Description Text */
  private float currentScreenRes;
  private float LASSO_SCREEN_RES = 1.24416e7;  // in pixels
  private float MACBOOK_SCREEN_RES = 1.296e6;    // in pixels
  private int fontSize;

  private boolean timerStarted;
  private int hoverStartTime;
  private boolean picked;
  private boolean unavailable; // used to prevent multiple pictures from being selected

  Picture(String _imgPath, String _imgName, int _id) {
    imgPath = _imgPath;
    imgName = _imgName;
    id = _id;
    expectedPictureWidth = sketchWidth/8;
    borderThickness = 5;
    borderColor = color(255); // white border
    theta = 0.0;
    
    currentScreenRes = sketchWidth * sketchHeight;
    fontSize = (int) map(currentScreenRes,MACBOOK_SCREEN_RES,LASSO_SCREEN_RES,20,70); // scale font size according to screen resolution  

    timerStarted = false;
    picked = false;
    unavailable = false; // true if another picture has already been selected. 
    showPicture = true;
    showText = false;
  }

  public void load() {
    img = loadImage(imgPath + imgName);
    zoom = expectedPictureWidth/img.width;
    scaledWidth = img.width * zoom;
    scaledHeight = img.height * zoom;
    location = new PVector(random(sketchWidth-scaledWidth), random(sketchHeight-scaledHeight));
    velocity = new PVector(0,0);
    friction = new PVector(0,0);
  }
  
  public void update() {
    // friction has the opposite direction of velocity
    friction = velocity.get();
    friction.normalize();
    friction.mult(u);
    // end friction  
    
    velocity.sub(friction); 
    location.add(velocity); 
    
    // only check boundaries if the picture is smaller than the sketch window
    if(scaledWidth < sketchWidth && scaledHeight < sketchHeight) {
      u = 0.02; 
      constrainToSketchWindow(); 
    } else u = 0.5; // decrease throwing ability by increasing friction
                
    if (tuioCursor1 != null && !picked && !unavailable){
      // highlight with red border when hovering over pic for > 1s
      if(tuioCursor1.getScreenX(sketchWidth) > location.x-scaledWidth/2 && 
         tuioCursor1.getScreenX(sketchWidth) < location.x+scaledWidth/2 && 
         tuioCursor1.getScreenY(sketchHeight) > location.y-scaledHeight/2 && 
         tuioCursor1.getScreenY(sketchHeight) < location.y+scaledHeight/2) {
           
        // start timer once mouse is over picture
        if(!timerStarted) {
          timerStarted = true;
          hoverStartTime = millis();
        }
        
        if(millis()-hoverStartTime > 1000) {
          location.z = 1;
          picked = true;
          borderColor = color(255,0,0);     
          showCursor = false;  
          
          // required to move picture smoothly regardless over where user touches the screen
          xOffset = (int) (tuioCursor1.getScreenX(sketchWidth) - location.x);
          yOffset = (int) (tuioCursor1.getScreenY(sketchHeight) - location.y); 
          
          velocity.x = tuioCursor1.getXSpeed();
          velocity.y = tuioCursor1.getYSpeed();
        }
      } else timerStarted = false; // restart timer if user stops hovering over image before 1 second limit is reached
    }
    
    // no need to check for hovering if pictures has already been selected
    else if (tuioCursor1 != null && picked && !unavailable){
      
      // must keep updated as image is moved
      xOffset = (tuioCursor1.getScreenX(sketchWidth) - location.x);
      yOffset = (tuioCursor1.getScreenY(sketchHeight) - location.y);  
      
      velocity.x = tuioCursor1.getXSpeed();
      velocity.y = tuioCursor1.getYSpeed();   
    }   
    
    if(MPE_ON) process.broadcast(getState()); 
  }
  
  public void display() {  
    imageMode(CENTER);
    rectMode(CENTER);
    textAlign(CENTER);
    
    pushMatrix();
      if(showText) {
        translate(location.x, location.y, location.z); 
        
        // begin flip animation
        if(theta < PI/2) { 
          scale(zoom);
          rotateY(theta);
          image(img, 0, 0);
          theta += 0.05;
        } 
        
        // picture is now out of sight
        else if(theta > PI/2 && theta < PI) {
          rotateY(theta);
          pushStyle();
            fill(0); // black infobox background
            stroke(255);
            rect(0, 0, scaledWidth+borderThickness, scaledHeight+borderThickness);
            fill(255); // white text
            textSize(fontSize);
            if(imgDescription != null) text(imgDescription, 0, 0, scaledWidth-10, scaledHeight-10);
            else {
              println("Image Description String is Null");
              text("Description is not available.\n\nVerify that this image's description has been included in picture_descriptions.xml", 0, 0, scaledWidth-10, scaledHeight-10);
            }
          popStyle();
          theta += 0.05;
        }
        
        // flip animation complete
        else {
          rotateY(0);
          pushStyle();
            fill(0); // black infobox background
            stroke(borderColor);
            rect(0, 0, scaledWidth+borderThickness, scaledHeight+borderThickness);
            fill(255); // white text
            textSize(fontSize);
            if(imgDescription != null) text(imgDescription, 0, 0, scaledWidth-10, scaledHeight-10);
            else {
              println("Image Description String is Null");
              text("Description is not available.\n\nVerify that this image's description has been included in picture_descriptions.xml", 0, 0, scaledWidth-10, scaledHeight-10);
            }
          popStyle();
          theta = PI;
        }
      } 
      
      if(showPicture) {
        translate(location.x, location.y, location.z); 
        
        // reverse flip animation
        if(theta > PI/2 && theta <= PI) {
          rotateY(theta);
          pushStyle();
            fill(0); // black infobox background
            stroke(255);
            rect(0, 0, scaledWidth+borderThickness, scaledHeight+borderThickness);
            fill(255); // white text
            textSize(fontSize);
            if(imgDescription != null) text(imgDescription, 0, 0, scaledWidth-10, scaledHeight-10);
            else {
              println("Image Description String is Null");
              text("Description is not available.\n\nVerify that this image's description has been included in picture_descriptions.xml", 0, 0, scaledWidth-10, scaledHeight-10);
            }
          popStyle();
          theta -= 0.05;
        }
        
        // picture is now in sight
        else if(theta > 0 && theta < PI/2) {
          scale(zoom);
          rotateY(theta);
          image(img, 0, 0);
          theta -= 0.05;
        } 
        
        // flip animation complete        
        else {
          rotateY(0);
          fill(borderColor);
          rect(0, 0, scaledWidth+borderThickness, scaledHeight+borderThickness);
          scale(zoom);
          image(img, 0, 0); 
        }
      }
    popMatrix(); 
  }
  
  private void constrainToSketchWindow() {
    if (location.x+scaledWidth/2 > sketchWidth) {
      velocity.x = velocity.x * -0.6; //wall friction
      location.x = sketchWidth-scaledWidth/2; 
    }
    else if (location.x-scaledWidth/2 < 0) {
      velocity.x = velocity.x * -0.6; 
      location.x = scaledWidth/2;
    }

    if (location.y+scaledHeight/2 > sketchHeight) {
      velocity.y = velocity.y * -0.6;
      velocity.x = velocity.x * 0.6; 
      location.y = sketchHeight - scaledHeight/2; 
    }
    else if (location.y-scaledHeight/2 < 0) {
      velocity.y = velocity.y * -0.6; 
      location.y = scaledHeight/2;
    } 
  }
  
  /***************/
  /* SET METHODS */
  /***************/
  
  public void setDescription(String str) {
    imgDescription = str; 
  }

  public void setXY(float _xpos, float _ypos) {
    location.x = _xpos; 
    location.y = _ypos;
  }
  
  public void setX(int _xpos) {
    location.x = _xpos; 
  }
  
  public void setY(int _ypos) {
    location.y = _ypos; 
  }
  
  public void setxOffset(float _xOffset){
    xOffset = _xOffset; 
  }

  public void setyOffset(float _yOffset){
    yOffset = _yOffset; 
  }
  
  public void setVelX(float xspeed) {
    velocity.x = xspeed;
  }
  
  public void setVelY(float yspeed) {
    velocity.y = yspeed;
  }
  
  public void setZoom(float zoomFactor) {
    zoom = zoomFactor;
    scaledWidth = img.width * zoom;
    scaledHeight = img.height * zoom;
  }
   
  public void unPick() {
    location.z = 0;
    picked = false;
    showCursor = true;
    unavailable = false;
    timerStarted = false;
    borderColor = color(255); // revert to white border
  }
  
  // true if any other image has already been selected
  public void setUnavailable() { 
    unavailable = true; 
  }
  
  public void flip() {
    showText = !showText; 
    showPicture = !showPicture;
  }
  
  public void setState(final PictureState state) {
    // total tiled display width / head node sketch window width    
    float scaler = (float) process.getMWidth() / state.leaderWidth;
        
    location = PVector.mult(state.location, scaler);
    zoom = state.zoom * scaler;
    scaledWidth = state.dim[0] * scaler;
    scaledHeight = state.dim[1] * scaler;
    theta = state.theta;
    imgDescription = state.imgDescription;
    showPicture = state.showPicture;
    showText = !showPicture;
    fontSize = state.fontSize * (int)scaler;
    borderColor = unhex(state.borderColor); 
  } 
    
  /***************/  
  /* GET METHODS */
  /***************/
  
  public String getDescription() {
    return imgDescription; 
  }
  
  public int getX() {
    return (int) location.x; 
  }
  
  public int getY() {
    return (int) location.y; 
  }
  
  public float getxOffset() {
    return xOffset; 
  }
  
  public float getyOffset() {
    return yOffset; 
  }
  
  public float getWidth() {
    return scaledWidth; 
  }
  
  public float getHeight() {
    return scaledHeight;
  }
  
  public String getName(){
    return imgName; 
  }
  
  public float getZoom() {
    return zoom; 
  }

  public boolean isPicked() {
    return picked; 
  }
  
  private PictureState getState() {
    float[] dim = { scaledWidth, scaledHeight };
    return new PictureState(id, location, dim, zoom, theta, imgDescription, showPicture, fontSize, hex(borderColor), (float) process.getMWidth()); 
  }
}
