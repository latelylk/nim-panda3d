# Original Python implementation by Shao Zhang and Phil Saltzman
# Adapted to Nim by:
# Last Updated: 2023-01-20
#
# This tutorial is intended as a initial panda scripting lesson going over
# display initialization, loading models, placing objects, and the scene graph.
#
# Step 5: Here we put the finishing touches on our solar system model by
# making the planets move. The actual code for doing the movement is covered
# in the next tutorial, but watching it move really shows what inheritance on
# the scene graph is all about.

import nimpanda3d/direct/[gui, showbase]
import nimpanda3d/panda3d/core
import std/options
import nimpanda3d/direct/interval # Intervals are used for scripted actions

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
    day_period_sun: CLerpNodePathInterval
    orbit_period_mercury: CLerpNodePathInterval
    day_period_mercury: CLerpNodePathInterval
    orbit_period_venus: CLerpNodePathInterval
    day_period_venus: CLerpNodePathInterval
    orbit_period_earth: CLerpNodePathInterval
    day_period_earth: CLerpNodePathInterval
    orbit_period_moon: CLerpNodePathInterval
    day_period_moon: CLerpNodePathInterval
    orbit_period_mars: CLerpNodePathInterval
    day_period_mars: CLerpNodePathInterval

var base = ShowBase()
base.openDefaultWindow()

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
    # rotatePlanets creates intervals to actually use the hierarchy we created
    # to turn the sun, planets, and moon to give a rough representation of the
    # solar system. The next lesson will go into more depth on intervals.
    self.day_period_sun = self.sun.hprInterval(20, (360, 0, 0), self.sun.getPos())

    self.orbit_period_mercury = self.orbit_root_mercury.hprInterval(
        (0.241 * self.yearscale), (360, 0, 0), self.orbit_root_mercury.getPos())
    self.day_period_mercury = self.mercury.hprInterval(
        (59 * self.dayscale), (360, 0, 0), self.mercury.getPos())

    self.orbit_period_venus = self.orbit_root_venus.hprInterval(
        (0.615 * self.yearscale), (360, 0, 0), self.orbit_root_venus.getPos())
    self.day_period_venus = self.venus.hprInterval(
        (243 * self.dayscale), (360, 0, 0), self.venus.getPos())

    self.orbit_period_earth = self.orbit_root_earth.hprInterval(
        self.yearscale, (360, 0, 0), self.orbit_root_earth.getPos())
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

proc newWorld: World =
    # Get a world object
    var self = World()

    # Create the title
    self.title = newOnscreenText(text = "Panda3D: Tutorial 1 - Solar System",
                                style = plain,
                                pos = (-0.1, 0.1),
                                scale = option[LVecBase2]((0.07, 0.07)),
                                fg = option[LVecBase4]((1, 1, 1, 1)),
                                align = ord(TextProperties.A_right),
                                parent = option[NodePath](base.a2dBottomRight))

    base.setBackgroundColor(0, 0, 0) # Set the background to black
    base.disableMouse() # disable mouse control of the camera
    base.camera.setPos(0, 0, 45) # Set the camera position
    base.camera.setHpr(0, -90, 0) # Set the camera orientation

    # Here again is where we put our global variables. Added this time are
    # variables to control the relative speeds of spinning and orbits in the
    # simulation
    # Number of seconds a full rotation of Earth around the sun should take
    self.yearscale = 60
    # Number of seconds a day rotation of Earth should take.
    # It is scaled from its correct value for easier visability
    self.dayscale = self.yearscale / 365.0 * 5
    self.orbitscale = 10  # Orbit scale
    self.sizescale = 0.6  # Planet size scale

    self.loadPlanets() # Load our models and make them render

    # Finally, we call the rotatePlanets function which puts the planets,
    # sun, and moon into motion.
    self.rotatePlanets()

    return self

let w = newWorld()
base.run()