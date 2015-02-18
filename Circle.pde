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
  void solveConstraints () {
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
  void draw () {
    ellipse(position.x, position.y, radius*2, radius*2);
  }
  void attachToPointMass (PointMass p) {
    attachedPointMass = p;
  }
}
