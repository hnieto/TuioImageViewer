# TUIO Image Viewer

![TuioImageViewer](https://dl.dropbox.com/u/25652072/TuioImageViewer.jpg)

This [Processing](http://processing.org/) sketch uses the [Processing TUIO library](http://www.tuio.org/?processing) to control the interaction between images via multitouch gestures.

## Description

The main sketch file, `TuioImageViewer.pde`, will load images from the directory specified by the `imgPath` variable. Leaving this variable blank will tell the program to search for 
images in the sketch's `/data` directory. The `FileFilter` class will ensure that only files with image extensions specified within the class are loaded. A `Picture` Object that 
handles an image's look, position, and velocity  will be created for each image. Each image's description will be read from the XML file `picture_descriptions.xml` stored in the `/data` directory. 
These descriptions will be displayed when the user double taps a selected picture (see image above). The `TuioHandler.pde` file encapsulates the sketch's multitouch capabilities such 
as detecting fingers and gestures. Read on for an in depth description of valid gestures.

## TUIO

The TUIO protocol allows touch information from multitouch devices (iPhone, iPad, Android smartphones, etc.) to reach a client application over the network. The multitouch sensing hardware
needs to run a TUIO server application that broadcasts the touch data, most commonly over port 3333. These multitouch events will then be captured by the client device listeninig on the
same port and used to remote control the client applicaiton.

TUIO Server Applications:
* Iphone/Ipad: [TuioPad](https://itunes.apple.com/us/app/tuiopad/id412446962)
* Android: [TuioDroid](https://play.google.com/store/apps/details?id=tuioDroid.impl)


## XML File Format

**IMPORTANT**  
Follow the following XML format and append `<picture>` child elements for each picture in your directory.

```
<?xml version='1.0'?>
<pictures>
  <picture name="img1.jpg">Insert picture description here</picture>
</pictures>
```


## Gestures

Each finger will be marked on the screen as a Red circle. A maximum of 3 fingers will be detected with all others being ignored.

**Select Picture:** Hover over image using 1 finger for 1 second   
**Move Picture:** 1 finger drag  
**Throw Picture:** drag 1 finger quickly and release  
**Flip Picture:** 1 finger double tap to display text info  
**Zoom In:** 2 finger reverse pinch  
**Zoom Out:** 2 finger pinch   
**Unselect Picture:** 3 finger touch  


## Requirements

* [Processing](http://processing.org/) 
* [Processing TUIO library](ttp://www.tuio.org/?processing)
