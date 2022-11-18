# Original Python implementation by Shao Zhang and Phil Saltzman
# Author: 
# Last Updated: 2022-10-15
#
# This tutorial is intended as a initial panda scripting lesson going over
# display initialization, loading models, placing objects, and the scene graph.
#
# Step 1: ShowBase contains the main Panda3D modules. Importing it
# initializes Panda and creates the window. The run() command causes the
# real-time simulation to begin
import nimpanda3d/direct/showbase

var base = ShowBase() # The ShowBase constructor doesn't open a window.
base.openDefaultWindow() # To do so, call openDefaultWindow().

base.run()