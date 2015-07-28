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
void reset () {
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

void ragdollsetup() {
 // The "sizes" are squared here, so they don't need to be when compared in the PointMass class
  mouseInfluenceSize *= mouseInfluenceSize;
  mouseTearSize *= mouseTearSize;
  
  // Reset function initializes World, the bodies, and the circles in our environment.
  reset(); 
}

void ragdolldraw () {
  
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
