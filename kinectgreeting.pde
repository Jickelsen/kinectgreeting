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
import processing.video.*;

KinectTracker tracker;
// Kinect Library object
Kinect kinect;
String  path, 
        images_dir_path;
ArrayList<Image> images = new ArrayList<Image>();

String[] filenames;
int   WINDOWSIZE = 1280,
      imageSize = 1280,
      lastTime = 0,
      measureTimer = 0,
      measureDelay = 200,
      fps = 60,
      kAngle = 0,
      frameSkip = 2;
      
//int numFrames = 150/frameSkip;
//int numFrames = 655/frameSkip;
int numFrames = floor(377/frameSkip);
      
Image[] imagesArray = new Image[numFrames];
Movie greetMovie,
      byeMovie;

float screenAspect = 16.0/9.0,
      sensorDepth = 0,
      frame = 0, 
      frameLerp = 0, 
      displayValue = 0,
      transp = 0.0,
      transp2 = 0.0,
      transpSpeed = 6;

boolean showTracker = true;
PImage bgImg;

boolean showGreet = false,
        showBye = false;
     
void setup() {
  size(WINDOWSIZE, (int)(WINDOWSIZE/screenAspect));
  frameRate(fps);
  greetMovie = new Movie(this, "gubb_hen.mov");
  greetMovie.frameRate(24);
  greetMovie.loop();
  byeMovie = new Movie(this, "gubbhen_corner.mov");
  byeMovie.frameRate(24);
  byeMovie.loop();
  path = sketchPath;
  images_dir_path = path + "/data/jpg_gothenburg_1280/";
//  bgImg = loadImage("bg.jpg");
//  images_dir_path = path + "/data/gbg/";
//  images_dir_path = path + "/data/klot/";
  filenames = findImgFiles(listFileNames(images_dir_path));
  // println(filenames);
  for (int i = 0; i < numFrames; i++) {
      imagesArray[i] = new Image(images_dir_path+filenames[i*frameSkip], imageSize);
  }
  kinect = new Kinect(this);
//  tracker = new KinectTracker(400, 700, 0.03);
  tracker = new KinectTracker(850, 1028, 0.015);
  ragdollsetup();
}
  
void draw() {
  background(255,255,255);
  measureTimer += millis()-lastTime;
  lastTime = millis();
//  image(bgImg, 0, 0, imageSize*1.15, imageSize/screenAspect*1.15);
  if (measureTimer >= measureDelay) {
    // Run the tracking analysis
    tracker.track();
    sensorDepth = tracker.getNormalizedDepth();
    measureTimer = 0;
  }
  if (tracker.detected && sensorDepth < 0.52) {
    frameLerp -= 1000.0/(float)(6000* frameRate);
     if (frameLerp < 0) { frameLerp = 0;}
  }
  else if (tracker.detected) {
     frameLerp = PApplet.lerp(frameLerp, bezierPoint(0.0, 0.1, 0.0, 1.0, sensorDepth) 
, 1000.0/(float)(measureDelay * frameRate));
  }
 else {
//     frameLerp = PApplet.lerp(frameLerp, 1, 1000.0/(float)(1000* frameRate));
     frameLerp += 1000.0/(float)(3000* frameRate);
     if (frameLerp > 1) { frameLerp = 1;}
  }
  frame = (float)numFrames*(1-frameLerp);
  displayValue = (int)(WINDOWSIZE/screenAspect);
//  if (frame>=numFrames){
//   frame=0;
//  }
//  else if (frame < 0) {
//    frame = numFrames-1; 
//  }
  int frameInt = (int)frame;
  if (frameInt == numFrames) { frameInt--;}
  image(imagesArray[frameInt].img, 0, 0, imagesArray[frameInt].dimensions.x, imagesArray[frameInt].dimensions.y);
//  ragdolldraw();
  // Display some info
  if (frame <= 1) {
    showGreet = true;
//    greetMovie.play();
    transp += transpSpeed;
    if (transp > 255.0) {transp = 255.0;}
  }
  else if (frame > (int)(0.98*numFrames)) {
    showBye = true;
//    byeMovie.play();
    transp2 += transpSpeed;
    if (transp2 > 255.0) {transp2 = 255.0;}
    tint(255, transp2);
  }
  else {
    transp -= transpSpeed;
    if (transp < 0.0) {
        transp = 0.0;
    }
    tint(255, transp);
    transp2 -= transpSpeed;
    if (transp2 < 0.0) {
        transp2 = 0.0;
    }
    tint(255, transp2);
  }
  if (transp==0) {
    showGreet = false;
//    if (greetMovie.time() != 0.0) {
//        greetMovie.stop();
//    }
  }
  if (transp2==0) {
    showBye = false;
//    if (byeMovie.time() != 0.0) {
//        byeMovie.stop();
//    }
  }
  tint(255, transp);
  image(greetMovie, 0, 0, 1280, 720);
  tint(255, transp2);
  image(byeMovie, 640, 360, 640, 360);
  tint(255, 255);
  if (showTracker) {
      // Show the image
      tracker.display();
    int nt = tracker.getNearThreshold();
    int ft = tracker.getFarThreshold();
    int dt = tracker.getDetectThreshold();
    fill(0);
    text("Near threshold: " + nt + "  Far threshold: " + ft +  " Detect  " + dt + " framerate: " + (int)frameRate + "    " + "UP: +far, DOWN: -far, RIGHT: +near, LEFT: -near. W,S: Tilt. Depth :" + displayValue + " and depth " + sensorDepth ,10,600);
  }
}  

void movieEvent(Movie m) {
  if (m == greetMovie && showGreet){
    m.read();
  }
  else if (m == byeMovie && showBye){
    m.read();
  }
}

void keyPressed() {
  int nt = tracker.getNearThreshold();
  int ft = tracker.getFarThreshold();
  int dt = tracker.getDetectThreshold();
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
  if (key == 'a') {
    dt-=1000;
    tracker.setDetectThreshold(dt);
  } else if (key == 'd') {
    dt+=1000;
    tracker.setDetectThreshold(dt);
  }
  kAngle = constrain(kAngle, 0, 30);
  kinect.tilt(kAngle);
  
}

void stop() {
  tracker.quit();
  super.stop();
}

