import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.openkinect.*; 
import org.openkinect.processing.*; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class kinectgreeting extends PApplet {

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
      frameSkip = 1;
      
//int numFrames = 150/frameSkip;
//int numFrames = 655/frameSkip;
int numFrames = floor(375/frameSkip);
      
Image[] imagesArray = new Image[numFrames];
Movie greetMovie,
      byeMovie;

float screenAspect = 16.0f/9.0f,
      sensorDepth = 0,
      frame = 0, 
      frameLerp = 0, 
      displayValue = 0,
      transp = 0.0f,
      transp2 = 0.0f,
      transpSpeed = 6;

boolean showTracker = true;
PImage bgImg;

boolean showGreet = false,
        showBye = false;
     
public void setup() {
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
  tracker = new KinectTracker(400, 700, 0.03f);
//  tracker = new KinectTracker(850, 1028, 0.015);
  ragdollsetup();
}
  
public void draw() {
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
  if (tracker.detected && sensorDepth < 0.52f) {
    frameLerp -= 1000.0f/(float)(6000* frameRate);
     if (frameLerp < 0) { frameLerp = 0;}
  }
  else if (tracker.detected) {
     frameLerp = PApplet.lerp(frameLerp, bezierPoint(0.0f, 0.1f, 0.0f, 1.0f, sensorDepth) 
, 1000.0f/(float)(measureDelay * frameRate));
  }
 else {
//     frameLerp = PApplet.lerp(frameLerp, 1, 1000.0/(float)(1000* frameRate));
     frameLerp += 1000.0f/(float)(3000* frameRate);
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
    if (transp > 255.0f) {transp = 255.0f;}
  }
  else if (frame > (int)(0.98f*numFrames)) {
    showBye = true;
//    byeMovie.play();
    transp2 += transpSpeed;
    if (transp2 > 255.0f) {transp2 = 255.0f;}
    tint(255, transp2);
  }
  else {
    transp -= transpSpeed;
    if (transp < 0.0f) {
        transp = 0.0f;
    }
    tint(255, transp);
    transp2 -= transpSpeed;
    if (transp2 < 0.0f) {
        transp2 = 0.0f;
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

public void movieEvent(Movie m) {
  if (m == greetMovie && showGreet){
    m.read();
  }
  else if (m == byeMovie && showBye){
    m.read();
  }
}

public void keyPressed() {
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

public void stop() {
  tracker.quit();
  super.stop();
}
class Body {
  /*
     O
    /|\
   / | \
    / \
   |   |
  */
  // each pointmass will be a joint to the body.
  PointMass head;
  PointMass shoulder;
  PointMass elbowLeft;
  PointMass elbowRight;
  PointMass handLeft;
  PointMass handRight;
  PointMass pelvis;
  PointMass kneeLeft;
  PointMass kneeRight;
  PointMass footLeft;
  PointMass footRight;
  Circle headCircle;
  
  float headLength;
  Body (PVector position, float bodyHeight) {
    headLength = bodyHeight / 7.5f;

    // PointMasses
    // Here, they're initialized with random positions. 
    head = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    shoulder = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    elbowLeft = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    elbowRight = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    handLeft = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    handRight = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    pelvis = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    kneeLeft = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    kneeRight = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    footLeft = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    footRight = new PointMass(new PVector(position.x + random(-5,5),position.y + random(-5,5)));
    
    // Masses
    // Uses data from http://www.humanics-es.com/ADA304353.pdf
    head.mass = 4;
    shoulder.mass = 26; // shoulder to torso
    elbowLeft.mass = 2; // upper arm mass
    elbowRight.mass = 2; 
    handLeft.mass = 2;
    handRight.mass = 2;
    pelvis.mass = 15; // pelvis to lower torso
    kneeLeft.mass = 10;
    kneeRight.mass = 10;
    footLeft.mass = 5; // calf + foot
    footRight.mass = 5;
    
    // Limbs
    // PointMasses are attached to each other here.
    // Proportions are mainly used from http://www.idrawdigital.com/2009/01/tutorial-anatomy-and-proportion/
    head.attachTo(shoulder, 5/4 * headLength, 1, true);
    elbowLeft.attachTo(shoulder, headLength*3/2, 1, true);
    elbowRight.attachTo(shoulder, headLength*3/2, 1, true);
    handLeft.attachTo(elbowLeft, headLength*2, 1, true);
    handRight.attachTo(elbowRight, headLength*2, 1, true);
    pelvis.attachTo(shoulder,headLength*2.5f,0.8f,true);
    kneeLeft.attachTo(pelvis, headLength*2, 1, true);
    kneeRight.attachTo(pelvis, headLength*2, 1, true);
    footLeft.attachTo(kneeLeft, headLength*2, 1, true);
    footRight.attachTo(kneeRight, headLength*2, 1, true);
    
    // Head
    headCircle = new Circle(head.position, headLength*0.75f);
    headCircle.attachToPointMass(head);
    
    // Invisible Constraints. These add resistance to some limbs from pointing in odd directions.
    // this keeps the head from tilting in extremely uncomfortable positions
    pelvis.attachTo(head, headLength*4.75f, 0.02f, false);
    // these constraints resist flexing the legs too far up towards the body
    footLeft.attachTo(shoulder, headLength*7.5f, 0.001f, false);
    footRight.attachTo(shoulder, headLength*7.5f, 0.001f, false);
    elbowLeft.attachTo(elbowRight, headLength*7.5f, 0.001f, false);
    elbowRight.attachTo(elbowLeft, headLength*7.5f, 0.001f, false);
    kneeRight.attachTo(kneeLeft, headLength*4, 0.001f, false);
    kneeLeft.attachTo(kneeRight, headLength*4, 0.001f, false);
    
    // The PointMasses (and circle!) is added to the world
    world.addCircle(headCircle);
    world.addPointMass(head);
    world.addPointMass(shoulder);
    world.addPointMass(pelvis);
    world.addPointMass(elbowLeft);
    world.addPointMass(elbowRight);
    world.addPointMass(handLeft);
    world.addPointMass(handRight);
    world.addPointMass(kneeLeft);
    world.addPointMass(kneeRight);
    world.addPointMass(footLeft);
    world.addPointMass(footRight);
  }
  // This must be used if the body is ever deleted
  public void removeFromWorld () {
    world.removeCircle(headCircle);
    world.removePointMass(head);
    world.removePointMass(shoulder);
    world.removePointMass(pelvis);
    world.removePointMass(elbowLeft);
    world.removePointMass(elbowRight);
    world.removePointMass(handLeft);
    world.removePointMass(handRight);
    world.removePointMass(kneeLeft);
    world.removePointMass(kneeRight);
    world.removePointMass(footLeft);
    world.removePointMass(footRight);
  }
  
  public PointMass GetPin() {
    return shoulder;
  }
  public PointMass GetHead() {
    return head;
  }
}
// Could be called "Head" if we wanted, since it's basically all it's used for.
class Circle {
  PVector position;
  float radius;
  
  // Most of the physics is done in the PointMass the Circle is attached to.
  boolean attachedToPointMass = false;
  PointMass attachedPointMass;
  
  Circle (PVector pos, float r) {
    position = pos.get();
    radius = r;
  }
  public void solveConstraints () {
    // First move the circle to where its attached PointMass is.
    position = attachedPointMass.position.get();
    
    // Make sure it isn't outside of the screen
    if (position.y < radius)
      position.y = 2*(radius) - position.y;
    if (position.y > height-radius)
      position.y = 2 * (height - radius) - position.y;
    if (position.x > width-radius)
      position.x = 2 * (width - radius) - position.x;
    if (position.x < radius)
      position.x = 2*radius - position.x;
      
    // Move the PointMass to the corrected position.
    attachedPointMass.position = position.get();
  }
  public void draw () {
    ellipse(position.x, position.y, radius*2, radius*2);
  }
  public void attachToPointMass (PointMass p) {
    attachedPointMass = p;
  }
}
// The EnvCircle
// These are the static circles floating around that the bodies collide with.
class EnvCircle {
  PVector position;
  float radius;
  float radiusSquared;
  
  EnvCircle (PVector pos, float rad) {
    position = pos.get();
    radius = rad;
    radiusSquared = radius*radius;
  }
  
  // detect whether or not a point is colliding with circle, and correct it
  // The algorithm here is modified ball collision handling algorithm, which I wrote about here:
  // www.bluethen.com/wordpress/index.php/processing-app/do-you-like-balls/
  public void solveCollision(PointMass pointM) {
    // first we see if the point is inside the circle.
    PVector delta = PVector.sub(pointM.position, position);  
    if (radiusSquared > (sq(delta.x) + sq(delta.y))) {
      float d = sqrt(delta.x * delta.x + delta.y * delta.y);
      
      // Instead of moving the point to the edge of the circle, 
      // we move it outside of the circle depending on how far inside it got.
      // This allows for a proper "bounce" to any collision with the circle.
      float difference = (radius - d) / d;
      pointM.position.add(PVector.mult(delta, difference));
      
      // We allow 3 frames for the bodies to position themselves in empty space before velocities are accounted for.
      if (frameCount < 3)
        pointM.lastPosition.set(pointM.position);
    }
  }
  public void draw () {
    ellipse(position.x, position.y, radius * 2, radius * 2);  
  }
}
class Image
{
  PVector dimensions;
  PImage img;

  Image(String filename, float startWidth)
  {
    if (!filename.equals("none") && filename != null) {
        // println("Loading image: "+filename);
        img = loadImage(filename);
        dimensions = new PVector(startWidth, startWidth*img.height/img.width);
        img.resize((int)startWidth, (int)(startWidth*img.height/img.width));
        // println("Size "+ dimensions.x + " and " + dimensions.y);
    }
    else {
      img = loadImage("head.png");
      // img = nul
      dimensions = new PVector(0.0f, 0.0f);
    }

  }
}

public String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

public String[] findImgFiles( String[] filenames ) {
// http://computationalphoto.mlog.taik.fi/2011/03/05/processing-finding-images-in-a-directory-listing/

  // this is where we'll put the found image files
  String[] outList_of_foundImageFiles = {
  };

  // to find out what a valid image file suffic might be
  String[] list_of_imageFileSuffixes = {
    "jpeg", "jpg", "tif", "tiff", "png"
  };

  if( images_dir_path.charAt( images_dir_path.length() -1 ) == '/' ) {
    println(" looks like there's a slash at the end of the dir path\u2026 no need for modifications ");
  }
  else {
    images_dir_path = images_dir_path+'/' ;
    println(" aha! it's missing a slash at the end, let's add one. \n\t images_dir_path is now = "+images_dir_path );
  }

  // ____ go through all the filenames
  // and check whether the fileending is not one for images
  for( int file_i = 0; file_i < filenames.length ; file_i++ ) {

    // println(" looking at file "+filenames[file_i]+" checking if it might not just be a image file ");

    String[] curr_filenameSplit = splitTokens( filenames[ file_i], "." );

    // ___ now check whether file suffix matches any in
    // our little list of filesuffixes
    for( int fileSuffix_i = 0 ; fileSuffix_i < list_of_imageFileSuffixes.length ; fileSuffix_i++ ) { // only do this is the file has a suffix!! // (i.e. which it hopefully has if a split string results // in more than one part/length ) if( curr_filenameSplit.length > 1 ) {
      // fetch the filesuffixes as strings
      // (this might be a long-winded way of doing it,
      // but it takes out some the common instances of bugs\u2026 )
      String examinedFile_filesuffix = curr_filenameSplit[curr_filenameSplit.length-1] ;
      String listOfValid_fileSuffixed = list_of_imageFileSuffixes[fileSuffix_i] ;

      // do the actual comparison
      if( examinedFile_filesuffix.equals( listOfValid_fileSuffixed ) ) {
        // and if it's a matching image file suffix, add the whole
        // filepath to the file to the list out outfilenames
        outList_of_foundImageFiles = append( outList_of_foundImageFiles,filenames[ file_i ] );
      }
    }
  }
  // and return something nice
  return outList_of_foundImageFiles;
}
class KinectTracker {



  // Size of kinect image
  int kw = 640;
  int kh = 480;
  float dw = 0.4f;
  float dh = 0.2f;
  int startX;
  int endX;
  int startY;
  int endY;
  int nearThreshold;
  int farThreshold;
  int detectThreshold;

  // Raw location
  PVector loc;
  // Avarage depth;
  float dep;

  // Interpolated location
  PVector lerpedLoc;
  float lerpedDep;

  // Depth data
  int[] depth;

  boolean detected = false;

  PImage display;

    KinectTracker(int pNearThreshold, int pFarThreshold, float pDetectThreshold) {
    kinect.start();
    kinect.enableDepth(true);
    
    nearThreshold = pNearThreshold;
    farThreshold = pFarThreshold;
    detectThreshold = (int)(pDetectThreshold*kw*kh*dw*dh);
    startX = (int)((1.0f-dw)*kw/2);
    endX = kw-startX;
    startY = (int)((1.0f-dh)*kh/2);
    endY = kh-startY;

    // We could skip processing the grayscale image for efficiency
    // but this example is just demonstrating everything
    kinect.processDepthImage(true);

    display = createImage(kw,kh,PConstants.RGB);

    loc = new PVector(0,0);
    lerpedLoc = new PVector(0,0);
  }

  public void track() {

    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float depthSum = 0;
    float count = 0;
    for(int x = startX; x < endX; x++) {
      for(int y = startY; y < endY; y++) {
        // Mirroring the image
        int offset = kw-x-1+y*kw;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against farThreshold and nearThreshold
        if (rawDepth < farThreshold && rawDepth > nearThreshold) {
          sumX += x;
          sumY += y;
          count++;
          depthSum += (rawDepth-nearThreshold);
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count,sumY/count);
      dep = depthSum/(float)count;
      // dep -= dep*detectThreshold/count;
    }
    detected = (count > detectThreshold);
    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
    lerpedDep = PApplet.lerp(lerpedDep, dep, 0.1f); 
  }

  public PVector getLerpedPos() {
    return lerpedLoc;
  }

  public PVector getPos() {
    return loc;
  }
  
  public float getDepth() {
    return dep;
  }
  
  public float getNormalizedDepth() {
    float returnValue = dep/(float)(farThreshold-nearThreshold);
    if (returnValue > 1) {
      return 1.0f; 
    }
    else if (returnValue < 0) {
      return 0.0f; 
    }
    else {
      return returnValue;
    }
  }

  public void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for(int x = startX; x < endX; x++) {
      for(int y = startY; y < endY; y++) {
        // mirroring image
        int offset = kw-x-1+y*kw;
        // Raw depth
        int rawDepth = depth[offset];

        int pix = x+y*display.width;
        if (rawDepth < farThreshold && rawDepth > nearThreshold) {
          // A red color instead
          float colorTone = 200*((float)(farThreshold-rawDepth)/(float)(farThreshold-nearThreshold));
          if (detected) {
            display.pixels[pix] = color(colorTone,colorTone+50,colorTone);
          }
          else {
            display.pixels[pix] = color(colorTone+50,colorTone,colorTone);
          }
        } 
        else {
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Draw the image
    image(display,0,0);
  }

  public void quit() {
    kinect.quit();
  }

  public int getNearThreshold() {
    return nearThreshold;
  }

  public void setNearThreshold(int t) {
    nearThreshold =  t;
  }
  
  public int getFarThreshold() {
    return farThreshold;
  }

  public void setFarThreshold(int t) {
    farThreshold =  t;
  }
  
  public int getDetectThreshold() {
    return detectThreshold;
  }
  
  public void setDetectThreshold(int t) {
    detectThreshold =  t;
  }
}
// The Link class is used for handling constraints between particles.
class Link {
  float restingDistance;
  float stiffness;
  
  PointMass p1;
  PointMass p2;
  
  // the scalars are how much "tug" the particles have on each other
  // this takes into account masses and stiffness, and are set in the Link constructor
  float scalarP1;
  float scalarP2;
  
  // if you want this link to be invisible, set this to false
  boolean drawThis;
  
  Link (PointMass which1, PointMass which2, float restingDist, float stiff, boolean drawMe) {
    p1 = which1; // when you set one object to another, it's pretty much a reference.
    p2 = which2; // Anything that'll happen to p1 or p2 in here will happen to the paticles in our array
    
    restingDistance = restingDist;
    stiffness = stiff;
    
    // Masses are accounted for. If you remember the cloth simulator,
    // http://www.openprocessing.org/visuals/?visualID=20140
    // we added this ability in anticipation of future applets that might use mass
    float im1 = 1 / p1.mass; 
    float im2 = 1 / p2.mass;
    scalarP1 = (im1 / (im1 + im2)) * stiffness;
    scalarP2 = (im2 / (im1 + im2)) * stiffness;
    
    drawThis = drawMe;
  }
  
  public void constraintSolve () {
    // calculate the distance between the two particles
    PVector delta = PVector.sub(p1.position, p2.position);  
    float d = sqrt(delta.x * delta.x + delta.y * delta.y);
    float difference = (restingDistance - d) / d;
    
    // Uncomment this if you want the ragdolls to be able to tear. 
    //if (d > 30) 
    //  p1.removeLink(this);

    // P1.position += delta * scalarP1 * difference
    // P2.position -= delta * scalarP2 * difference
    p1.position.add(PVector.mult(delta, scalarP1 * difference));
    p2.position.sub(PVector.mult(delta, scalarP2 * difference));
  }
}
// PointMass
// This is pretty much the Particle class used in Curtain
// http://www.openprocessing.org/visuals/?visualID=20140
class PointMass {
  PVector lastPosition; // for calculating position change (velocity)
  PVector position;

  PVector acceleration; 

  float mass = 1;
  float damping = 20; // friction

  // An ArrayList for links, so we can have as many links as we want to this PointMass
  ArrayList links = new ArrayList();

  boolean pinned = false;
  PVector pinLocation = new PVector(0,0);

  // PointMass constructor
  PointMass (PVector pos) {
    position = pos.get();
    lastPosition = pos.get();
    acceleration = new PVector(0,0);
  }
  
  // The update function is used to update the physics of the particle.
  // motion is applied, and links are drawn here
  public void updatePhysics (float timeStep) { 
    // gravity:
    // f(gravity) = m * g
    PVector fg = new PVector(0, mass * world.gravity, 0);
    this.applyForce(fg);

    /*
       We use Verlet Integration to simulate the physics
       In Verlet Integration, the rule is simple: any change in position will result in a change of velocity
       Therefore, things in motion will stay in motion. If you want to push a PointMass towards a direction,
       just move its position and it'll continue going that way.   
    */
    // velocity = position - lastPosition
    PVector velocity = PVector.sub(position, lastPosition);
    // apply damping: acceleration -= velocity * (damping/mass)
    acceleration.sub(PVector.mult(velocity,damping/mass)); 
    // newPosition = position + velocity + 0.5 * acceleration * deltaTime * deltaTime
    PVector nextPos = PVector.add(PVector.add(position, velocity), PVector.mult(PVector.mult(acceleration, 0.5f), timeStep * timeStep));
    // reset variables
    lastPosition.set(position);
    position.set(nextPos);
    acceleration.set(0,0,0);

    // make sure the particle stays in its place if it's pinned
    // (This isn't used for this simulation, but it's there anyways.)
    if (pinned)
      position.set(pinLocation);
  } 
  public void updateInteractions () {
    // this is where our interaction comes in.
    if (mousePressed) {
      float distanceSquared = sq(mouseX - position.x) + sq(mouseY - position.y);
      if (mouseButton == LEFT) {
        if (distanceSquared < mouseInfluenceSize) { // remember mouseInfluenceSize was squared in setup()
          // move particles towards where the mouse is moving
          // amount to add onto the particle position:
          position.x += (mouseX - pmouseX) * 0.1f * (sqrt(mouseInfluenceSize) - sqrt(distanceSquared)) / sqrt(mouseInfluenceSize);
          position.y += (mouseY - pmouseY) * 0.1f * (sqrt(mouseInfluenceSize) - sqrt(distanceSquared)) / sqrt(mouseInfluenceSize);
        }
      }
      else { // if the right mouse button is clicking, we tear the cloth by removing links
        if (distanceSquared < mouseTearSize) 
          links.clear();
      }
    }
  }

  public void draw () {
    // draw the links and points
    stroke(15);
    if (links.size() > 0) {
      for (int i = 0; i < links.size(); i++) {
        Link currentLink = (Link) links.get(i);
        if (currentLink.drawThis) // some links are invisible
          line(position.x, position.y, currentLink.p2.position.x, currentLink.p2.position.y);
      }
    }
    else
      point(position.x, position.y);
  }
  // here we tell each Link to solve constraints
  public void solveConstraints () {
    for (int i = 0; i < links.size(); i++) {
      Link currentLink = (Link) links.get(i);
      currentLink.constraintSolve();
    }
    for (int i = 0; i < circles.size(); i++) {
      EnvCircle circle = (EnvCircle) circles.get(i);
      circle.solveCollision(this);
    }
    
    // These if statements keep the particles within the screen
    if (position.y < 1)
      position.y = 2 - position.y;
    if (position.y > height-1)
      position.y = 2 * (height - 1) - position.y;
    if (position.x > width-1)
      position.x = 2 * (width - 1) - position.x;
    if (position.x < 1)
      position.x = 2 - position.x;
  }

  // attachTo can be used to create links between this particle and other particles
  public void attachTo (PointMass P, float restingDist, float stiff, boolean drawThis) {
    Link lnk = new Link(this, P, restingDist, stiff, drawThis);
    links.add(lnk);
  }
  public void removeLink (Link lnk) {
    links.remove(lnk);
  }  
  public void removeLink (PointMass P) {
    for (int i = 0; i < links.size(); i++) {
      Link lnk = (Link) links.get(i);
      if ((lnk.p1 == P) || (lnk.p2 == P))
        links.remove(i);
    }
  }

  public void applyForce (PVector f) {
    // acceleration = (1/mass) * force
    // or
    // acceleration = force / mass
    acceleration.add(PVector.div(PVector.mult(f,1), mass));
  }

  public void pinTo (PVector location) {
    pinned = true;
    pinLocation.set(location);
  }
}
// World
// All physics and objects, as well as the time step stuff, are handled here.
class World {
  // All of our objects
  ArrayList pointMasses = new ArrayList(); 
  ArrayList circles = new ArrayList();

  float gravity = 2000;
  
  // These variables are used to keep track of how much time is elapsed between each frame
  // they're used in the physics to maintain a certain level of accuracy and consistency
  // this program should run the at the same rate whether it's running at 30 FPS or 300,000 FPS
  long previousTime;
  long currentTime;
  // Delta means change. It's actually a triangular symbol, to label variables in equations
  // some programmers like to call it elapsedTime, or changeInTime. It's all a matter of preference
  // To keep the simulation accurate, we use a fixed time step
  int fixedDeltaTime;
  float fixedDeltaTimeSeconds;
  // the leftOverDeltaTime carries over change in time that isn't accounted for over to the next frame
  int leftOverDeltaTime;

  // How many times constraints are solved each frame
  int constraintAccuracy;
  
  World (int deltaTimeLength, int constraintAcc) {
    fixedDeltaTime = deltaTimeLength;
    fixedDeltaTimeSeconds = (float)fixedDeltaTime / 1000;
    previousTime = millis();
    currentTime = previousTime;  
    constraintAccuracy = constraintAcc;
  }
  
  public void update () {
    /* Time related stuff */
    currentTime = millis();
    // deltaTimeMS: change in time in milliseconds since last frame
    long deltaTimeMS = currentTime - previousTime;
    // Reset previousTime.
    previousTime = currentTime;
    // timeStepAmt will be how many of our fixedDeltaTime's can fit in the physics for this frame.
    int timeStepAmt = (int)((float)(deltaTimeMS + leftOverDeltaTime) / (float)fixedDeltaTime);
    // reset leftOverDeltaTime.
    leftOverDeltaTime = (int)deltaTimeMS - (timeStepAmt * fixedDeltaTime); 
    float fixedDeltaTimeSeconds = (float)fixedDeltaTime / 1000;
    
    /* Physics */
    for (int iteration = 1; iteration <= timeStepAmt; iteration++) {
      // update each PointMass's position
      for (int i = 0; i < pointMasses.size(); i++) {
        PointMass p = (PointMass) pointMasses.get(i);
        p.updatePhysics(fixedDeltaTimeSeconds);
      }
      // solve the constraints
      for (int x = 0; x < constraintAccuracy; x++) {
        for (int i = 0; i < pointMasses.size(); i++) {
          PointMass p = (PointMass) pointMasses.get(i);
          p.solveConstraints();
        }
        for (int i = 0; i < circles.size(); i++) {
          Circle c = (Circle) circles.get(i);
          c.solveConstraints();  
        }
      }
    }
    
    // we use a separate loop for drawing so points and their links don't get drawn more than once
    // (rendering can be a major resource hog if not done efficiently)
    // also, interactions (mouse dragging) is applied
    for (int i = 0; i < pointMasses.size(); i++) {
      PointMass p = (PointMass) pointMasses.get(i);
      p.updateInteractions();
      p.draw();
    }
    for (int i = 0; i < circles.size(); i++) {
      Circle c = (Circle) circles.get(i);
      c.draw();  
    }
  }
  // Functions for adding PointMasses and Circles.
  public void addCircle (Circle c) {
    circles.add(c);  
  }
  public void removeCircle (Circle c) {
    circles.remove(c);  
  }
  public void addPointMass (PointMass p) {
    pointMasses.add(p);
  }
  public void removePointMass (PointMass p) {
    pointMasses.remove(p);
  }
}
// This arraylist will keep track of the circles all of the bodies will collide with.
ArrayList circles = new ArrayList();
PointMass pin;
PointMass head;
PImage headImg;
// See: World class
// All of the physics and objects are handled inside the "World"
World world;

// Distance from each PointMass where interaction is done from the cursor.
// We keep tear size from the cloth simulator for the fun of it.
// The cloth simulator can be found at http://www.openprocessing.org/visuals/?visualID=20140
float mouseInfluenceSize = 100; 
float mouseTearSize = 20;


int bodyCount = 1;
int circleCount = 0;
// How tall is everyone? (Pixels)
int bodyHeights = 300;
float headWidth = bodyHeights/3;
float headHeight = bodyHeights/3;
// How big are the circles? (Radius)
int circleMin = 50;
int circleMax = 100;

// The reset function randomly places bodies and circles around the screen.
public void reset () {
  // World class is constructed with 2 parameters: (int deltaTimeLength, int constraintAcc)
  // deltaTimeLength is the timestep used. Smaller would be more accurate.
  // constraintAcc is how many times constraints are solved per timestep.
  world = new World(15, 5);
  
  // Clear the cirlces just in case reset() has already been called
  circles.clear();
  
  headImg = loadImage("head.png");
  // Create the Bodies. in the Body constructor, everything is added to the World automatically.
  for (int i = 0; i < bodyCount; i++) {
    Body body = new Body(new PVector(random(width), random(height)), bodyHeights);
    if (i == 0) {
      pin = body.GetPin();
      head = body.GetHead();
      pin.pinTo(new PVector(width/2, height/3));
    }
  }  
  // Add circles to the environment
  for (int i = 0; i < circleCount; i++) {
    EnvCircle circle = new EnvCircle(new PVector(random(width), random(height)), random(circleMin,circleMax));
    circles.add(circle);
  }  
  // set frameCount to 0
  // The first constraint solve can cause ragdolls to go a little crazy
  // (bodies spawned inside circles will fly out)
  // So in EnvCircle, when bodies are pushed away, their velocities are kept to 0 if the frameCount is too low
  frameCount = 0;
}

public void ragdollsetup() {
 // The "sizes" are squared here, so they don't need to be when compared in the PointMass class
  mouseInfluenceSize *= mouseInfluenceSize;
  mouseTearSize *= mouseTearSize;
  
  // Reset function initializes World, the bodies, and the circles in our environment.
  reset(); 
}

public void ragdolldraw () {
  
  // Update physics, draw bodies, etc.
  world.update();
  
  image(headImg, head.position.x-headWidth/2, head.position.y-headHeight/2, headWidth, headHeight);
  // Draw the environment
  for (int i = 0; i < circles.size(); i++) {
    EnvCircle circle = (EnvCircle) circles.get(i);
    circle.draw();
  }
  
  if (frameCount % 60 == 0)
    println("Frame rate is " + frameRate);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "kinectgreeting" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
