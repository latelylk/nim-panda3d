# Original Python implementation by Shao Zhang and Phil Saltzman
# Author: 
# Last Updated: 2022-10-24
#
# This tutorial is intended as a initial panda scripting lesson going over
# display initialization, loading models, placing objects, and the scene graph.
#
# Step 2: After initializing panda, we define a class called World. We put
# all of our code in a class to provide a convenient way to keep track of
# all of the variables our project will use, and in later tutorials to handle
# keyboard input.
# The code contained in the __init__ method is executed when we instantiate
# the class (at the end of this file).  Inside __init__ we will first change
# the background color of the window.  We then disable the mouse-based camera
# control and set the camera position.
import nimpanda3d/direct/showbase
import nimpanda3d/panda3d/core  # Contains most of Panda's modules
import nimpanda3d/direct/gui # Imports Gui objects we use for putting
# text on the screen
import std/options

# Initialize Panda and create a window
var base = ShowBase()
base.openDefaultWindow() # open the viewing window

proc newWorld =  # The initialization method for creating the World object
    # result is an implicit return variable of nim functions
    # var result = new World

    # Create some text overlayed on our screen.
    # We will use similar commands in all of our tutorials to create titles and
    # instruction guides.
    discard newOnscreenText(text = "Panda3D: Tutorial 1 - Solar System",
                                style = plain,
                                pos = (-0.1f, 0.1f),
                                scale = option[LVecBase2]((0.07, 0.07)),
                                fg = option[LVecBase4]((1f, 1f, 1f, 1f)),
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
# end class world

# Now that our class is defined, we create an instance of it.
# Doing so calls the __init__ method set up above
newWorld()

# As usual - run() must be called before anything can be shown on screen
base.run()