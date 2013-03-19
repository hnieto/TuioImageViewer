class Picture {
  private PImage img;
  private String imgName;
  private String imgDescription;

  /* Size */
  private float scalePercent;
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
  private int xOffset;
  private int yOffset;
  
  /* Y-Axis Rotation */
  private float theta;
  private boolean showPicture;
  private boolean showText;
  
  /* Description Text */
  private float currentScreenRes;
  private float STALLION_SCREEN_RES = 3.2768e8;  // in megapixels
  private float MACBOOK_SCREEN_RES = 1.296e6;    // in megapixels
  private int fontSize;

  private boolean timerStarted;
  private int hoverStartTime;
  private boolean picked;
  private boolean unavailable; // used to prevent multiple pictures from being selected

  Picture(String _imgName) {
    imgName = _imgName;
    expectedPictureWidth = width/8;
    borderThickness = 5;
    borderColor = color(255); // white border
    theta = 0.0;
    
    currentScreenRes = width * height;
    fontSize = (int) map(currentScreenRes,MACBOOK_SCREEN_RES,STALLION_SCREEN_RES,14,128); // scale font size according to screen resolution   
    
    timerStarted = false;
    picked = false;
    unavailable = false;
    showPicture = true;
    showText = false;
  }

  public void load() {
    img = loadImage(imgName);
    scalePercent = expectedPictureWidth/img.width;
    scaledWidth = img.width * scalePercent;
    scaledHeight = img.height * scalePercent;
    location = new PVector((int) random(width-scaledWidth), (int) random(height-scaledHeight));
    velocity = new PVector(0,0);
  }
  
  public void update() {
    // friction has the opposite direction of velocity
    float normal = 1;
    float u = 0.02; // coefficent of friction
    float frictionMag = u*normal;
    PVector friction = velocity.get();
    friction.normalize();
    friction.mult(frictionMag);
    // end friction     

    location.add(velocity);
    velocity.sub(friction);
    constrainToSketchWindow();
    
    if (tuioCursor1 != null && !picked && !unavailable){
      // highlight with red border when hovering over pic for > 1s
      if(tuioCursor1.getScreenX(width) > location.x-scaledWidth/2 && tuioCursor1.getScreenX(width) < location.x+scaledWidth/2 && tuioCursor1.getScreenY(height) > location.y-scaledHeight/2 && tuioCursor1.getScreenY(height) < location.y+scaledHeight/2) {
        // start timer once mouse is over picture
        if(!timerStarted) {
          timerStarted = true;
          hoverStartTime = millis();
        }
        
        if(millis()-hoverStartTime > 1000) {
          picked = true;
          borderColor = color(255,0,0);       
          
          // required to move picture smoothly regardless over where user touches the screen
          xOffset = (int) (tuioCursor1.getScreenX(width) - location.x);
          yOffset = (int) (tuioCursor1.getScreenY(height) - location.y); 
          
          velocity.x = tuioCursor1.getXSpeed();
          velocity.y = tuioCursor1.getYSpeed();
        }
      } else timerStarted = false; // restart timer if user stops hovering over image before 1 second limit is reached
    }
    
    // no need to check for hovering if pictures has already been selected
    else if (tuioCursor1 != null && picked && !unavailable){
      
      // must keep updated as picture is translated and zoomed
      xOffset = (int) (tuioCursor1.getScreenX(width) - location.x);
      yOffset = (int) (tuioCursor1.getScreenY(height) - location.y);  
      
      velocity.x = tuioCursor1.getXSpeed();
      velocity.y = tuioCursor1.getYSpeed();  
    }
  }
  
  public void display() {  
    imageMode(CENTER);
    rectMode(CENTER);
    textAlign(CENTER);
    
    pushMatrix();
      if(showText) {
        translate(location.x, location.y); 
        
        // flip animation will require 50 frames
        if(theta < PI) { 
          rotateY(theta);
          theta += PI/50;
          scale(scalePercent);
          image(img, 0, 0);
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
            text(imgDescription, 0, 0, scaledWidth-10, scaledHeight-10);
          popStyle();
        }
      } 
      
      if(showPicture) {
        translate(location.x, location.y); 
        
        // flip animation will require 50 frames
        if(theta > 0) {
          rotateY(theta);
          theta -= PI/50;
          pushStyle();
            fill(0); // black infobox background
            stroke(borderColor); 
            rect(0, 0, scaledWidth+borderThickness, scaledHeight+borderThickness);
          popStyle();
        } 
        
        // flip animation complete        
        else {
          rotateY(0);
          fill(borderColor);
          rect(0, 0, scaledWidth+borderThickness, scaledHeight+borderThickness);
          scale(scalePercent);
          image(img, 0, 0); 
        }
      }
    popMatrix(); 
  }
  
  private void constrainToSketchWindow() {
    if (location.x+scaledWidth/2 > width) {
      velocity.x = velocity.x * -0.6; //wall friction
      location.x = width-scaledWidth/2; 
    }
    else if (location.x-scaledWidth/2 < 0) {
      velocity.x = velocity.x * -0.6; 
      location.x = scaledWidth/2;
    }

    if (location.y+scaledHeight/2 > height) {
      velocity.y = velocity.y * -0.6;
      velocity.x = velocity.x * 0.6; 
      location.y = height - scaledHeight/2; 
    }
    else if (location.y-scaledHeight/2 < 0) {
      velocity.y = velocity.y * -0.6; 
      location.y = scaledHeight/2;
    } 
  }
  
  /* SET METHODS */
  
  public void setDescription(String str) {
    imgDescription = str; 
  }

  public void setXY(int _xpos, int _ypos) {
    location.x = _xpos; 
    location.y = _ypos;
  }
  
  public void setX(int _xpos) {
    location.x = _xpos; 
  }
  
  public void setY(int _ypos) {
    location.y = _ypos; 
  }
  
  public void setxOffset(int _xOffset){
    xOffset = _xOffset; 
  }

  public void setyOffset(int _yOffset){
    yOffset = _yOffset; 
  }
  
  public void setVelX(float xspeed) {
    velocity.x = xspeed;
  }
  
  public void setVelY(float yspeed) {
    velocity.y = yspeed;
  }
  
  public void setScalePercent(float zoomFactor) {
    scalePercent = zoomFactor;
    scaledWidth = img.width * scalePercent;
    scaledHeight = img.height * scalePercent;
  }
   
  public void unPick() {
    picked = false;
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
    
  /* GET METHODS */
  
  public String getDescription() {
    return imgDescription; 
  }
  
  public int getX() {
    return (int) location.x; 
  }
  
  public int getY() {
    return (int) location.y; 
  }
  
  public int getxOffset() {
    return xOffset; 
  }
  
  public int getyOffset() {
    return yOffset; 
  }
  
  public int getWidth() {
    return (int) scaledWidth; 
  }
  
  public int getHeight() {
    return (int) scaledHeight;
  }
  
  public String getName(){
    return imgName; 
  }
  
  public float getScalePercent() {
    return scalePercent; 
  }
  
  public boolean isPicked() {
    return picked; 
  }
}
