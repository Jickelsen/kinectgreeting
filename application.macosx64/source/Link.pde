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
  
  void constraintSolve () {
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
