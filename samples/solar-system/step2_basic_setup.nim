# Original Python implementation by Shao Zhang and Phil Saltzman
# Adapted to Nim by:
# Last Updated: 2022-10-24
#
# This tutorial is intended as a initial panda scripting lesson going over
# display initialization, loading models, placing objects, and the scene graph.
#
# Step 2: After initializing panda, we define an object called World. We use
# the World object to provide a convenient way to keep track of all of the
# variables our project will use, and in later tutorials to handle keyboard
# input.
# The code contained in the newWorld() method is executed when we call
# the function (at the end of this file). Inside newWorld() we will first change
# the background color of the window.  We then disable the mouse-based camera
# control and set the camera position.

import nimpanda3d/direct/showbase
import nimpanda3d/panda3d/core # Contains most of Panda's modules
import nimpanda3d/direct/gui # Imports Gui objects we use for putting
import std/options # Used for putting text on the screen

# Define World object and variables we want to use in the scene
type World = ref object of DirectObject
  title: OnscreenText

# Initialize Panda and create a window
var base = ShowBase()
base.openDefaultWindow() # open the viewing window

# The initialization method for creating the World object
proc newWorld: World =
  var self = World() # Create a new World object and assign it to self

    # Create some text overlayed on our screen.
    # We will use similar commands in all of our tutorials to create titles and
    # instruction guides.
  self.title = newOnscreenText(text = "Panda3D: Tutorial 1 - Solar System",
                              style = plain,
                              pos = (-0.1, 0.1),
                              scale = option[LVecBase2]((0.07, 0.07)),
                              fg = option[LVecBase4]((1, 1, 1, 1)),
                              align = ord(TextProperties.A_right),
                              parent = option[NodePath](base.a2dBottomRight))

  # Make the background color black (R=0, G=0, B=0)
  # instead of the default grey
  base.setBackgroundColor(0, 0, 0)

  # By default, the mouse controls the camera. Often, we disable that so that
  # the camera can be placed manually (if we don't do this, our placement
  # commands will be overridden by the mouse control)
  base.disableMouse()

  # Set the camera position (x, y, z)
  base.camera.setPos(0, 0, 45)

  # Set the camera orientation (heading, pitch, roll) in degrees
  base.camera.setHpr(0, -90, 0)

  # return our newly minted world
  return self

# Now that our procedure is defined, we can call it to create the World object
let w = newWorld()

# As usual - run() must be called before anything can be shown on screen
base.run()
