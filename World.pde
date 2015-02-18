// World
// All physics and objects, as well as the time step stuff, are handled here.
class World {
  // All of our objects
  ArrayList pointMasses = new ArrayList(); 
  ArrayList circles = new ArrayList();
  
  // Psh. Who needs gravity!
  float gravity = 0;
  
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
  
  void update () {
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
  void addCircle (Circle c) {
    circles.add(c);  
  }
  void removeCircle (Circle c) {
    circles.remove(c);  
  }
  void addPointMass (PointMass p) {
    pointMasses.add(p);
  }
  void removePointMass (PointMass p) {
    pointMasses.remove(p);
  }
}
