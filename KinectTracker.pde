class KinectTracker {
// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan
// http://www.shiffman.net
// https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing

  // Size of kinect image
  int kw = 640;
  int kh = 480;
  float dw = 0.4;
  float dh = 0.2;
  int startX;
  int endX;
  int startY;
  int endY;
  int nearThreshold;
  int farThreshold;
  int detectThreshold;
  int closest = -100;
  int farthest = -100;
  float closestNorm = 0.8;

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
    startX = (int)((1.0-dw)*kw/2);
    endX = kw-startX;
    startY = (int)((1.0-dh)*kh/2);
    endY = kh-startY;

    kinect.processDepthImage(true);

    display = createImage(kw,kh,PConstants.RGB);

    loc = new PVector(0,0);
    lerpedLoc = new PVector(0,0);
  }

  void track() {

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
          int normalized = rawDepth-nearThreshold; 
          if (closest ==-100) {
             closest = normalized; 
          }
          else if (normalized < closest) {
              closest = normalized; 
          }
          if (farthest ==-100) {
             farthest = normalized; 
          }
          else if (normalized > farthest) {
              farthest = normalized; 
          }
          sumX += x;
          sumY += y;
          count++;
          depthSum += normalized;
        }
      }
    }
    closestNorm = ((float)closest+(float)(farthest-closest)*0.2)/(float)(farThreshold-nearThreshold);
    closest = -100;
    farthest = -100;
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

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }
  
  float getDepth() {
    return dep;
  }
  
  float getNormalizedDepth() {
    float returnValue = dep/(float)(farThreshold-nearThreshold);
    if (returnValue > 1) {
      return 1.0; 
    }
    else if (returnValue < 0) {
      return 0.0; 
    }
    else {
      return returnValue;
    }
  }
  
  float getNormalizedClosest() {
    float returnValue =  closestNorm;
    if (returnValue > 1) {
      return 1.0; 
    }
    else if (returnValue < 0) {
      return 0.0; 
    }
    else {
      return returnValue;
    }
  }

  void display() {
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

  void quit() {
    kinect.quit();
    kinect.stop();
  }

  int getNearThreshold() {
    return nearThreshold;
  }

  void setNearThreshold(int t) {
    nearThreshold =  t;
  }
  
  int getFarThreshold() {
    return farThreshold;
  }

  void setFarThreshold(int t) {
    farThreshold =  t;
  }
  
  int getDetectThreshold() {
    return detectThreshold;
  }
  
  void setDetectThreshold(int t) {
    detectThreshold =  t;
  }
}
