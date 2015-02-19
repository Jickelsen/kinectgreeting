// Modified by Jacob Michelsen tii.se February 2015. ORIGINAL CREDITS:

//This code is modded from Sequential by James Patterson. 
//Displaying a sequence of images creates the illusion of motion.
//Images are loaded and each is displayed individually in a loop.

// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan
// http://www.shiffman.net
// https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing

/* 
  Ragdoll Aquarium
  Made by BlueThen on February 21, 2011
*/

import org.openkinect.*;
import org.openkinect.processing.*;

KinectTracker tracker;
// Kinect Library object
Kinect kinect;
String  path, 
        images_dir_path;
ArrayList<Image> images = new ArrayList<Image>();

String[] filenames;
int   lastTime = 0,
      measureTimer = 0,
      measureDelay = 200,
      numFrames = 150,  // The number of frames in the animation
      fps = 60,
      kAngle = 15;
      
Image[] imagesArray = new Image[numFrames];

float sensorDepth = 0,
      frame = 0, 
      frameLerp = 0, 
      displayValue = 0;

boolean showTracker = true;
     
void setup() {
  size(1024, 768);
  frameRate(fps);
  path = sketchPath;
  images_dir_path = path + "/data/klot/";
  filenames = findImgFiles(listFileNames(images_dir_path));
  println(filenames);
  for (int i = 0; i < numFrames; i++) {
      imagesArray[i] = new Image(images_dir_path+filenames[i], 1024);
  }
  kinect = new Kinect(this);
  tracker = new KinectTracker(370, 745);
  ragdollsetup();
}
  
void draw() {
  background(255,125,0);
  ragdolldraw();
  measureTimer += millis()-lastTime;
  lastTime = millis();
  if (measureTimer >= measureDelay) {
    // Run the tracking analysis
    tracker.track();
    sensorDepth = tracker.getNormalizedDepth();
    measureTimer = 0;
  }
  if (showTracker) {
      // Show the image
      tracker.display();
  }
  frameLerp = PApplet.lerp(frameLerp, sensorDepth, 1000.0/(float)(measureDelay * frameRate));
  frame = (float)numFrames*(1-frameLerp);
  displayValue = frame;
  if (frame>=numFrames){
   frame=0;
  }
  else if (frame < 0) {
    frame = numFrames-1; 
  }
  int frameInt = (int)frame;
  image(imagesArray[frameInt].img, 0, 0, imagesArray[frameInt].dimensions.x, imagesArray[frameInt].dimensions.y);
  // Display some info
  if (showTracker) {
    int nt = tracker.getNearThreshold();
    int ft = tracker.getFarThreshold();
    fill(0);
    text("Near threshold: " + nt + "  Far threshold: " + ft +  " framerate: " + (int)frameRate + "    " + "UP: +far, DOWN: -far, RIGHT: +near, LEFT: -near. W,S: Tilt. Depth :" + displayValue,10,600);
  }
}  

void keyPressed() {
  int nt = tracker.getNearThreshold();
  int ft = tracker.getFarThreshold();
  float deltaFT = 2000/(ft-300);
  float deltaNT = 2000/(nt-300);
  if (key == CODED) {
    if (keyCode == RIGHT) {
      nt+=deltaNT;
      tracker.setNearThreshold(nt);
    } 
    else if (keyCode == LEFT) {
      nt-=deltaNT;
      tracker.setNearThreshold(nt);
    }
    if (keyCode == UP) {
      ft+=deltaFT;
      tracker.setFarThreshold(ft);
    } 
    else if (keyCode == DOWN) {
      ft-=deltaFT;
      tracker.setFarThreshold(ft);
    }
    if (keyCode == SHIFT) {
      showTracker = !showTracker; 
    }
  }
  if (key == 'w') {
    kAngle++;
  } else if (key == 's') {
    kAngle--;
  }
  kAngle = constrain(kAngle, 0, 30);
  kinect.tilt(kAngle);
  
}

void stop() {
  tracker.quit();
  super.stop();
}

