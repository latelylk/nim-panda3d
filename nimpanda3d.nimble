# Package
version     = "0.0.1"
author      = "RDB"
description = "Proof of concept nim binding for Panda3D"
license     = "N/A" # No license in repo rn. -- issue this
srcdir      = "src"
skipDirs    = @["samples", "tests"]

# Dependencies
requires "nim >= 1.6.8"

# Tests
task test, "Runs the test file":
  exec "nim cpp -r tests/test"