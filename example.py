from GromacsTrajectory import XTCTrajectory

t = XTCTrajectory("trajectory.xtc")
while t.readStep():
    print "Frame number ", t.frame_counter
    print "Simulation step ", t.step
    print "Time %f ps" % t.time
    print "Box vectors (nm):"
    print t.box
    print "Coordinates of the first five atoms (nm):"
    print t.coordinates[:5]
    print
