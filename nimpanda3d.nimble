# Package
version     = "0.0.2"
author      = "RDB"
description = "Proof of concept nim binding for Panda3D"
license     = "N/A" # No license in repo rn. -- issue this
srcdir      = "src"
skipDirs    = @["samples", "scripts", "tests"]

# Dependencies
requires "nim >= 1.6.8"

# If including panda in install
#  before install:
#    exec "nimble buildFromSrc"

# Tests
task test, "Runs the basic test":
  exec "nim cpp -r tests/pandasequence"

# Scripts
task buildFromSrc, "Builds panda3d from source":
  exec "nim e scripts/build_p3d.nims"