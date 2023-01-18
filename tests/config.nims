# Get the src in path
switch("path", "../src")

# Silence hints about variable case
switch("hint", "[Name]:off")

# Point to local Panda install
switch("define", "pandaDir:C:/Panda3D-1.10.13-x64")

# Windows specific args
when defined(windows):
  switch("cc", "vcc")

# Linux specific args
when defined(linux):
  switch("clibdir", "/usr/lib/panda3d")
  switch("cincludes", "/usr/include/panda3d")