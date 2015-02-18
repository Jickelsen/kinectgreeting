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
  void solveCollision(PointMass pointM) {
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
  void draw () {
    ellipse(position.x, position.y, radius * 2, radius * 2);  
  }
}
