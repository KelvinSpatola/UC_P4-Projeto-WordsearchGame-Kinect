
class Hand {
  Trigger open, close, lasso;
  PVector pos, originalPos;
  int handType;
  Particle particlePoint;

  // CONSTRUCTOR
  Hand(String hand) {
    open  = new Trigger(applet);
    close = new Trigger(applet);
    lasso = new Trigger(applet);

    physics = new ParticleSystem(0, 0.1);
    particlePoint = physics.makeParticle();
    particlePoint.makeFixed();

    pos = new PVector();
    handType = hand.equals("left") ? 7 : hand.equals("right") ? 11 : 7;
  }

  void trackHand() { // update
    physics.tick();

    if (kinect.getSkeletonColorMap().size() > 0) { // if there's at least one body skeleton tracked

      KSkeleton skeleton = kinect.getSkeletonColorMap().get(0); // get that skeleton

      KJoint hand = skeleton.getJoints()[handType]; // get the hand joint

      pos = hand.getPosition(); // get hand position

      particlePoint.position().set(pos.x, pos.y, 0);

      // get hand states
      open.callTrigger(hand.getState()  == KinectPV2.HandState_Open);
      close.callTrigger(hand.getState() == KinectPV2.HandState_Closed);
      lasso.callTrigger(hand.getState() == KinectPV2.HandState_Lasso);

      noStroke();
      if (close.isActive()) {
        fill(255, 0, 0, 100);
        circle(pos.x, pos.y, 100);
      } else if (lasso.isActive()) {
        fill(0, 255, 0, 100);
        circle(pos.x, pos.y, 100);
      }
    }
  }
}
