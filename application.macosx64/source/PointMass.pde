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
  void updatePhysics (float timeStep) { 
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
    PVector nextPos = PVector.add(PVector.add(position, velocity), PVector.mult(PVector.mult(acceleration, 0.5), timeStep * timeStep));
    // reset variables
    lastPosition.set(position);
    position.set(nextPos);
    acceleration.set(0,0,0);

    // make sure the particle stays in its place if it's pinned
    // (This isn't used for this simulation, but it's there anyways.)
    if (pinned)
      position.set(pinLocation);
  } 
  void updateInteractions () {
    // this is where our interaction comes in.
    if (mousePressed) {
      float distanceSquared = sq(mouseX - position.x) + sq(mouseY - position.y);
      if (mouseButton == LEFT) {
        if (distanceSquared < mouseInfluenceSize) { // remember mouseInfluenceSize was squared in setup()
          // move particles towards where the mouse is moving
          // amount to add onto the particle position:
          position.x += (mouseX - pmouseX) * 0.1 * (sqrt(mouseInfluenceSize) - sqrt(distanceSquared)) / sqrt(mouseInfluenceSize);
          position.y += (mouseY - pmouseY) * 0.1 * (sqrt(mouseInfluenceSize) - sqrt(distanceSquared)) / sqrt(mouseInfluenceSize);
        }
      }
      else { // if the right mouse button is clicking, we tear the cloth by removing links
        if (distanceSquared < mouseTearSize) 
          links.clear();
      }
    }
  }

  void draw () {
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
  void solveConstraints () {
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
  void attachTo (PointMass P, float restingDist, float stiff, boolean drawThis) {
    Link lnk = new Link(this, P, restingDist, stiff, drawThis);
    links.add(lnk);
  }
  void removeLink (Link lnk) {
    links.remove(lnk);
  }  
  void removeLink (PointMass P) {
    for (int i = 0; i < links.size(); i++) {
      Link lnk = (Link) links.get(i);
      if ((lnk.p1 == P) || (lnk.p2 == P))
        links.remove(i);
    }
  }

  void applyForce (PVector f) {
    // acceleration = (1/mass) * force
    // or
    // acceleration = force / mass
    acceleration.add(PVector.div(PVector.mult(f,1), mass));
  }

  void pinTo (PVector location) {
    pinned = true;
    pinLocation.set(location);
  }
}
