switch("hint", "[Name]:off") # Silence hints about variable case
switch("path", "../src")
#switch("define", "pandaDir:C:/Panda3D-1.10.13-x64")
when defined(windows):
  switch("cc", "vcc")
