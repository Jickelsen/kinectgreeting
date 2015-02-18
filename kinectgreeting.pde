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
Image img;

PImage renderedImg;

int margin = 0;
String path, images_dir_path;
float x, y, z;
  
int numFrames = 150,  // The number of frames in the animation
    frame = 0,
    fps = 60;
ArrayList<Image> images = new ArrayList<Image>();
Image[] imagesArray = new Image[numFrames];
String[] filenames;
int   lastTime = 0,
      measureTimer = 0,
      measureDelay = 200;

float sensorDepth = 0, lastDepth = 0, frameLerp = 0, frameFloat = 0;
     
void setup()
{
  size(1024, 768);
  frameRate(fps);
  
  path = sketchPath;
  images_dir_path = path + "/data/klot/";
  filenames = findImgFiles(listFileNames(images_dir_path));
  println(filenames);
   for (int i = 0; i < numFrames; i++) {
//    images.add(new Image(images_dir_path+filenames[i], 1520));
      imagesArray[i] = new Image(images_dir_path+filenames[i], 1024);
  }
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  ragdollsetup();
  
}
  
void draw()
{
  
  background(255,125,0);
  ragdolldraw();
  
  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();
  
  

  measureTimer += millis()-lastTime;
  lastTime = millis();
  if (measureTimer >= measureDelay) {
    sensorDepth = tracker.getNormalizedDepth();
    frameFloat = lastDepth-sensorDepth;
    lastDepth = sensorDepth;
    measureTimer = 0;
  }
  
  
  //  int frameInc = (int)((lastDepth-sensorDepth)*50);
  //  frame = frame + frameInc;
  
  frameLerp = PApplet.lerp(frameLerp, frameFloat, (float)measureDelay/(float)(1000 * fps));
  frame = frame + (int)frameLerp;
  if (frame>=numFrames){
   frame=0;
  }
  else if (frame < 0) {
    frame = numFrames-1; 
  }
  
  
  //  image(images.get(frame).img, 0, 0, images.get(frame).dimensions.x, images.get(frame).dimensions.y);
  image(imagesArray[frame].img, 0, 0, imagesArray[frame].dimensions.x, imagesArray[frame].dimensions.y);
  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + (int)frameRate + "    " + "UP increase threshold, DOWN decrease threshold. Depth :" + frameFloat,10,600);
}  

void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } 
    else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }
}

void stop() {
  tracker.quit();
  super.stop();
}

