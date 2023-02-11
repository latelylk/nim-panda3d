# Original Python implementation by Shao Zhang and Phil Saltzman
# Adapted to Nim by:
# Last Updated: 2023-01-20
#
# This tutorial will cover events and how they can be used in Panda
# Specifically, this lesson will use events to capture keyboard presses and
# mouse clicks to trigger actions in the world. It will also use events
# to count the number of orbits the Earth makes around the sun. This
# tutorial uses the same base code from the solar system tutorial.

import nimpanda3d/direct/[gui, showbase]
import nimpanda3d/panda3d/core
import std/options
import nimpanda3d/direct/interval # Intervals are used for scripted actions
# import std/strutils # Used for pattern matching

# We start this tutorial with the standard class. However, the class is a
# subclass of an object called DirectObject. This gives the class the ability
# to listen for and respond to events. From now on the main class in every
# tutorial will be a subclass of DirectObject

type World = ref object of DirectObject
    title: OnscreenText
    yearscale: float
    dayscale: float
    sizescale: float
    orbitscale: float
    orbit_root_mercury: NodePath
    orbit_root_venus: NodePath
    orbit_root_mars: NodePath
    orbit_root_earth: NodePath
    orbit_root_moon: NodePath
    sky: NodePath
    sky_tex: Texture
    sun: NodePath
    sun_tex: Texture
    mercury: NodePath
    mercury_tex: Texture
    venus: NodePath
    venus_tex: Texture
    mars: NodePath
    mars_tex: Texture
    earth: NodePath
    earth_tex: Texture
    moon: NodePath
    moon_tex: Texture
    day_period_sun: CInterval
    orbit_period_mercury: CInterval
    day_period_mercury: CInterval
    orbit_period_venus: CInterval
    day_period_venus: CInterval
    orbit_period_earth: CInterval
    day_period_earth: CInterval
    orbit_period_moon: CInterval
    day_period_moon: CInterval
    orbit_period_mars: CInterval
    day_period_mars: CInterval
    mouse1EventText: OnscreenText
    skeyEventText: OnscreenText
    ykeyEventText: OnscreenText
    vkeyEventText: OnscreenText
    ekeyEventText: OnscreenText
    mkeyEventText: OnscreenText
    yearCounterText: OnscreenText
    yearCounter: int
    simRunning: bool

var base = ShowBase()
base.openDefaultWindow()

# Macro-like function used to reduce the amount to code needed to create the
# on screen instructions
proc genLabelText(self: World, text: string, i: float): OnscreenText =
    return newOnscreenText(text = text,
                        pos = (0.06, -0.06 * (i + 0.5)),
                        scale = option[LVecBase2]((0.05, 0.05)),
                        fg = option[LVecBase4]((1, 1, 1, 1)),
                        align = ord(TextProperties.A_left),
                        parent = option[NodePath](base.a2dTopLeft))

proc loadPlanets(self: World) =
    # This is the same function that we completed in the previous step
    # It is unchanged in this version

    # Create the dummy nodes
    self.orbit_root_mercury = render.attachNewNode("orbit_root_mercury")
    self.orbit_root_venus = render.attachNewNode("orbit_root_venus")
    self.orbit_root_mars = render.attachNewNode("orbit_root_mars")
    self.orbit_root_earth = render.attachNewNode("orbit_root_earth")

    # The moon orbits Earth, not the sun
    self.orbit_root_moon = (self.orbit_root_earth.attachNewNode("orbit_root_moon"))

    # Load the sky
    self.sky = base.loader.loadModel("models/solar_sky_sphere")
    self.sky_tex = base.loader.loadTexture("models/stars_1k_tex.jpg")
    self.sky.setTexture(self.sky_tex, 1)
    self.sky.reparentTo(render)
    self.sky.setScale(40)

    # Load the Sun
    self.sun = base.loader.loadModel("models/planet_sphere")
    self.sun_tex = base.loader.loadTexture("models/sun_1k_tex.jpg")
    self.sun.setTexture(self.sun_tex, 1)
    self.sun.reparentTo(render)
    self.sun.setScale(2 * self.sizescale)

    # Load mercury
    self.mercury = base.loader.loadModel("models/planet_sphere")
    self.mercury_tex = base.loader.loadTexture("models/mercury_1k_tex.jpg")
    self.mercury.setTexture(self.mercury_tex, 1)
    self.mercury.reparentTo(self.orbit_root_mercury)
    self.mercury.setPos(0.38 * self.orbitscale, 0, 0)
    self.mercury.setScale(0.385 * self.sizescale)

    # Load Venus
    self.venus = base.loader.loadModel("models/planet_sphere")
    self.venus_tex = base.loader.loadTexture("models/venus_1k_tex.jpg")
    self.venus.setTexture(self.venus_tex, 1)
    self.venus.reparentTo(self.orbit_root_venus)
    self.venus.setPos(0.72 * self.orbitscale, 0, 0)
    self.venus.setScale(0.923 * self.sizescale)

    # Load Mars
    self.mars = base.loader.loadModel("models/planet_sphere")
    self.mars_tex = base.loader.loadTexture("models/mars_1k_tex.jpg")
    self.mars.setTexture(self.mars_tex, 1)
    self.mars.reparentTo(self.orbit_root_mars)
    self.mars.setPos(1.52 * self.orbitscale, 0, 0)
    self.mars.setScale(0.515 * self.sizescale)

    # Load Earth
    self.earth = base.loader.loadModel("models/planet_sphere")
    self.earth_tex = base.loader.loadTexture("models/earth_1k_tex.jpg")
    self.earth.setTexture(self.earth_tex, 1)
    self.earth.reparentTo(self.orbit_root_earth)
    self.earth.setScale(self.sizescale)
    self.earth.setPos(self.orbitscale, 0, 0)

    # Offest the moon dummy node so that it is positioned properly
    self.orbit_root_moon.setPos(self.orbitscale, 0, 0)

    # Load the moon
    self.moon = base.loader.loadModel("models/planet_sphere")
    self.moon_tex = base.loader.loadTexture("models/moon_1k_tex.jpg")
    self.moon.setTexture(self.moon_tex, 1)
    self.moon.reparentTo(self.orbit_root_moon)
    self.moon.setScale(0.1 * self.sizescale)
    self.moon.setPos(0.1 * self.orbitscale, 0, 0)

proc rotatePlanets(self: World) =
    self.day_period_sun = self.sun.hprInterval(20, (360, 0, 0), self.sun.getPos())

    self.orbit_period_mercury = self.orbit_root_mercury.hprInterval(
        (0.241 * self.yearscale), (360, 0, 0), self.orbit_root_mercury.getPos())
    self.day_period_mercury = self.mercury.hprInterval(
        (59 * self.dayscale), (360, 0, 0), self.mercury.getPos())

    self.orbit_period_venus = self.orbit_root_venus.hprInterval(
        (0.615 * self.yearscale), (360, 0, 0), self.orbit_root_venus.getPos())
    self.day_period_venus = self.venus.hprInterval(
        (243 * self.dayscale), (360, 0, 0), self.venus.getPos())

    # Here the earth interval has been changed to rotate like the rest of the
    # planets and send a message before it starts turning again. To send a
    # message, the call is simply messenger.send("message"). The "newYear"
    # message is picked up by the accept("newYear"...) statement earlier, and
    # calls the incYear function as a result
    # 
    self.orbit_period_earth = Sequence(
        self.orbit_root_earth.hprInterval(
            self.yearscale, (360, 0, 0),
            self.orbit_root_earth.getPos()),
        Func(proc = messenger.send("newYear")),
        name="x")
    self.day_period_earth = self.earth.hprInterval(
        self.dayscale, (360, 0, 0), self.earth.getPos())

    self.orbit_period_moon = self.orbit_root_moon.hprInterval(
        (0.0749 * self.yearscale), (360, 0, 0), self.orbit_root_moon.getPos())
    self.day_period_moon = self.moon.hprInterval((0.0749 * self.yearscale), (360, 0, 0), self.moon.getPos())

    self.orbit_period_mars = self.orbit_root_mars.hprInterval(
        (1.881 * self.yearscale), (360, 0, 0), self.orbit_root_mars.getPos())
    self.day_period_mars = self.mars.hprInterval(
        (1.03 * self.dayscale), (360, 0, 0), self.mars.getPos())

    self.day_period_sun.loop()
    self.orbit_period_mercury.loop()
    self.day_period_mercury.loop()
    self.orbit_period_venus.loop()
    self.day_period_venus.loop()
    self.orbit_period_earth.loop()
    self.day_period_earth.loop()
    self.orbit_period_moon.loop()
    self.day_period_moon.loop()
    self.orbit_period_mars.loop()
    self.day_period_mars.loop()

# toggleInterval does exactly as its name implies
# It takes an interval as an argument. Then it checks to see if it is playing.
# If it is, it pauses it, otherwise it resumes it.
proc toggleInterval(self: World, interval: CInterval) =
    if interval.isPlaying():
        discard interval.pause()
    else:
        interval.resume()

# The togglePlanet function will toggle the intervals that are given to it
# between paused and playing.
# Planet is the name to print
# Day is the interval that spins the planet
# Orbit is the interval that moves around the orbit
# Text is the OnscreenText object that needs to be updated
proc togglePlanet(self: World, planet: string, day: CInterval, orbit: CInterval = nil, text: OnscreenText) =
    var state: string

    if day.isPlaying():
        echo "Pausing " + planet
        state = " [PAUSED]"
    else:
        echo "Resuming " + planet
        state = " [RUNNING]"

    # Ok so we don't actually do this bc I'm dumb and broke something in OnscreenText
    #[
    # Update the onscreen text if it is given as an argument
    if text:
        var old = text.getText()
        # strip out the last segment of text after the last white space
        old = old[0 .. old.rfind(' ')]
        # and append the string stored in 'state'
        text.setText(old & state)
    ]#

    # toggle the day interval
    self.toggleInterval(day)
    # if there is an orbit interval, toggle it
    if orbit:
        self.toggleInterval(orbit)

proc handleMouseClick(self: World) = 
    # When the mouse is clicked, if the simulation is running pause all the
    # planets and sun, otherwise resume it
    if self.simRunning:
        echo "Pausing Simulation"
        # changing the text to reflect the change from "RUNNING" to
        # "PAUSED"
        self.mouse1EventText.setText(
            "Mouse Button 1: Toggle entire Solar System [PAUSED]")
        # For each planet, check if it is moving and if so, pause it
        # Sun
        if self.day_period_sun.isPlaying():
            self.togglePlanet("Sun",
                            self.day_period_sun, 
                            nil,
                            self.skeyEventText)
        if self.day_period_mercury.isPlaying():
            self.togglePlanet("Mercury",
                            self.day_period_mercury,
                            self.orbit_period_mercury, self.ykeyEventText)
        # Venus
        if self.day_period_venus.isPlaying():
            self.togglePlanet("Venus",
                            self.day_period_venus,
                            self.orbit_period_venus, self.vkeyEventText)
        #Earth and moon
        if self.day_period_earth.isPlaying():
            self.togglePlanet("Earth",
                            self.day_period_earth,
                            self.orbit_period_earth, self.ekeyEventText)
            self.togglePlanet("Moon",
                            self.day_period_moon,
                            self.orbit_period_moon, self.ekeyEventText)
        # Mars
        if self.day_period_mars.isPlaying():
            self.togglePlanet("Mars",
                            self.day_period_mars,
                            self.orbit_period_mars, self.mkeyEventText)
    else:
        #"The simulation is paused, so resume it
        echo "Resuming Simulation"
        self.mouse1EventText.setText(
            "Mouse Button 1: Toggle entire Solar System [RUNNING]")
        # the not operator does the reverse of the previous code
        if not self.day_period_sun.isPlaying():
            self.togglePlanet("Sun",
                            self.day_period_sun, nil,
                            self.skeyEventText)
        if not self.day_period_mercury.isPlaying():
            self.togglePlanet("Mercury",
                            self.day_period_mercury,
                            self.orbit_period_mercury, self.ykeyEventText)
        if not self.day_period_venus.isPlaying():
            self.togglePlanet("Venus",
                            self.day_period_venus,
                            self.orbit_period_venus, self.vkeyEventText)
        if not self.day_period_earth.isPlaying():
            self.togglePlanet("Earth",
                            self.day_period_earth,
                            self.orbit_period_earth, self.ekeyEventText)
            self.togglePlanet("Moon",
                            self.day_period_moon,
                            self.orbit_period_moon,
                            self.ekeyEventText)
        if not self.day_period_mars.isPlaying():
            self.togglePlanet("Mars",
                            self.day_period_mars,
                            self.orbit_period_mars, self.mkeyEventText)
    # toggle self.simRunning
    self.simRunning = not self.simRunning

# Earth needs a special buffer function because the moon is tied to it
# When the "e" key is pressed, togglePlanet is called on both the earth and
# the moon.
proc handleEarth(self: World) =
    self.togglePlanet("Earth",
                    self.day_period_earth,
                    self.orbit_period_earth, self.ekeyEventText)
    self.togglePlanet("Moon",
                    self.day_period_moon,
                    self.orbit_period_moon, self.ekeyEventText)

# the function incYear increments the variable yearCounter and then updates
# the OnscreenText 'yearCounterText' every time the message "newYear" is
# sent
proc incYear(self: World) =
    self.yearCounter += 1
    self.yearCounterText.setText($self.yearCounter & " Earth years completed")

proc newWorld: World =
    # Get a world object
    var self = World()

    # The standard camera position and background initialization
    base.setBackgroundColor(0, 0, 0)
    base.disableMouse()
    base.camera.setPos(0, 0, 45)
    base.camera.setHpr(0, -90, 0)

    # The global variables we used to control the speed and size of objects
    self.yearscale = 60
    self.dayscale = self.yearscale / 365.0 * 5
    self.sizescale = 0.6
    self.orbitscale = 10

    self.loadPlanets()  # Load, texture, and position the planets
    self.rotatePlanets()  # Set up the motion to start them moving

    # The standard title text that's in every tutorial
    # Things to note:
    #-fg represents the forground color of the text in (r,g,b,a) format
    #-pos  represents the position of the text on the screen.
    #      The coordinate system is a x-y based wih 0,0 as the center of the
    #      screen
    #-align sets the alingment of the text relative to the pos argument.
    #      Default is center align.
    #-scale set the scale of the text
    #-mayChange argument lets us change the text later in the program.
    #       By default mayChange is set to 0. Trying to change text when
    #       mayChange is set to 0 will cause the program to crash.
    self.title = newOnscreenText(text = "Panda3D: Tutorial 3 - Events",
                                style = plain,
                                pos = (-0.1, 0.1),
                                scale = option[LVecBase2]((0.07, 0.07)),
                                fg = option[LVecBase4]((1, 1, 1, 1)),
                                align = ord(TextProperties.A_right),
                                parent = option[NodePath](base.a2dBottomRight))

    # TODO: Fix text updating
    self.mouse1EventText = self.genLabelText(
        "Mouse Button 1: Toggle entire Solar System [RUNNING]", 1)
    self.skeyEventText = self.genLabelText("[S]: Toggle Sun [RUNNING]", 2)
    self.ykeyEventText = self.genLabelText("[Y]: Toggle Mercury [RUNNING]", 3)
    self.vkeyEventText = self.genLabelText("[V]: Toggle Venus [RUNNING]", 4)
    self.ekeyEventText = self.genLabelText("[E]: Toggle Earth [RUNNING]", 5)
    self.mkeyEventText = self.genLabelText("[M]: Toggle Mars [RUNNING]", 6)
    self.yearCounterText = self.genLabelText("0 Earth years completed", 7)

    self.yearCounter = 0  # year counter for earth years
    self.simRunning = true  # boolean to keep track of the
    # state of the global simulation
    
    # Events
    # Each self.accept statement creates an event handler object that will call
    # the specified function when that event occurs.
    # Certain events like "mouse1", "a", "b", "c" ... "z", "1", "2", "3"..."0"
    # are references to keyboard keys and mouse buttons. You can also define
    # your own events to be used within your program. In this tutorial, the
    # event "newYear" is not tied to a physical input device, but rather
    # is sent by the function that rotates the Earth whenever a revolution
    # completes to tell the counter to update
    # Exit the program when escape is pressed
    self.accept("escape", proc = quit(QuitSuccess))
    self.accept("mouse1", proc = self.handleMouseClick())
    self.accept("e", proc = self.handleEarth)
    self.accept("s",  # message name
                proc = self.togglePlanet(
                        "Sun",
                        self.day_period_sun,
                        nil,
                        self.skeyEventText))
    # Repeat the structure above for the other planets
    self.accept("y", proc = self.togglePlanet("Mercury",
                                            self.day_period_mercury,
                                            self.orbit_period_mercury,
                                            self.ykeyEventText))
    self.accept("v", proc = self.togglePlanet("Venus",
                                            self.day_period_venus,
                                            self.orbit_period_venus,
                                            self.vkeyEventText))
    self.accept("m", proc = self.togglePlanet("Mars",
                                            self.day_period_mars,
                                            self.orbit_period_mars,
                                            self.mkeyEventText))
    self.accept("newYear", proc = self.incYear)

    return self

let w = newWorld()
base.run()