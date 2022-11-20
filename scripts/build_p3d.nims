# Intended to be run from nimble
import std/[os, strformat]

# Directory structures
const basePath = currentSourcePath().parentDir().parentDir()
const outputDir = basePath / "src" / "built_panda"
const tempPandaDir = basePath / "p3dSrc"
const thirdPartyZip = tempPandaDir / "thirdparty.zip"
const thirdPartyDir = tempPandaDir / "thirdparty"

# Construct the urls for prebuilt third party tools
when defined(macosx):
  # Mac build instructions were updated to use 1.10.13 thirdparty tools
  const thirdPartyBaseUrl = "https://www.panda3d.org/download/panda3d-1.10.13/panda3d-1.10.13-tools-"
else:
  const thirdPartyBaseUrl = "https://www.panda3d.org/download/panda3d-1.10.12/panda3d-1.10.12-tools-"

const x86Append = "win32.zip"
const x64Append = "win64.zip"
const macAppend = "mac.tar.gz"

# Check if panda exists and clone if it doesn't
proc clone() =
  if not dirExists(tempPandaDir):
    # Nimble requires git so this should be safe on any system
    exec fmt"git clone https://github.com/panda3d/panda3d --branch release/1.10.x {tempPandaDir}"
  else:
    echo "Panda3D already cloned. Skipping."

# Check if third party tools are already downloaded
# and download them if needed
proc getThirdPartyTools() =
  when defined(linux):
    # Ubuntu ?
    # Seems like we shouldn't be doing these commands for the user?
    # exec "sudo apt-get install build-essential pkg-config fakeroot python3-dev libpng-dev libjpeg-dev libtiff-dev zlib1g-dev libssl-dev libx11-dev libgl1-mesa-dev libxrandr-dev libxxf86dga-dev libxcursor-dev bison flex libfreetype6-dev libvorbis-dev libeigen3-dev libopenal-dev libode-dev libbullet-dev nvidia-cg-toolkit libgtk2.0-dev libassimp-dev libopenexr-dev"
    return
  elif defined(freebsd):
    # Seems like we shouldn't be doing these commands for the user?
    # exec "pkg install pkgconf bison png jpeg-turbo tiff freetype2 harfbuzz eigen squish openal opusfile libvorbis libX11 mesa-libs ode bullet assimp openexr"
    return
  else:
    # Check if zip exists and if it doesn't, curl
    if not fileExists(thirdPartyZip):
      # Output the downloaded zip to thirdPartyZip
      when defined(windows):
        when defined x86:
          exec fmt"curl -o {thirdPartyZip} {thirdPartyBaseUrl}{x86Append}"
        elif defined amd64:
          exec fmt"curl -o {thirdPartyZip} {thirdPartyBaseUrl}{x64Append}"
      elif defined(macosx):
        exec fmt"curl -o {thirdPartyZip} {thirdPartyBaseUrl}{macAppend}"
      else:
        echo "No third party tool support for this OS."
        return
    else:
      echo "Third party zip found. Skipping."
    
    # Only reached by mac / windows
    echo fmt"Unzipping thirdparty files to {thirdPartyDir}"
    if not dirExists(thirdPartyDir):
      mkDir(thirdPartyDir)
      exec fmt"tar -C {thirdPartyDir} --strip-components=2 -xf {thirdPartyZip}"
    else:
      echo "Third party tools found. Skipping."

# Runs makepanda and builds it to src/built_panda
proc make() =
  # Open the downloaded source folder
  withDir tempPandaDir:
    when defined(windows):
      # If using outputdir, you must use --no-python
      # or convert outputDir to a path relative to tempPandaDir relativePath()
      # Unsure if this affects other operating systems
      exec fmt"makepanda\makepanda.bat --everything --msvc-version=14.3 --windows-sdk=10 --no-eigen --threads=2 --no-pandatool --no-python --optimize=4 --outputdir={outputDir}"
    # ------------------------------
    # None of these platforms tested:
    elif defined(linux):
      exec fmt"python3 makepanda/makepanda.py --everything --no-egl --no-gles --no-gles2 --no-opencv  --no-pandatool --no-python --optimize=4 --outputdir={outputDir}"
      return
    elif defined(macosx):
      exec fmt"python makepanda/makepanda.py --everything --no-pandatool --no-python --optimize=4 --outputdir={outputDir}"
      return
    elif defined (freebsd):
      exec fmt"python3.7 makepanda/makepanda.py --everything --no-egl --no-gles --no-gles2 --no-pandatool --no-python --optimize=4 --outputdir={outputDir}"
      return

proc build() = 
  if dirExists(outputDir):
    echo "Panda3D already installed"
    return
  
  echo "Cloning Panda3D"
  clone()
  
  echo "Downloading third party tools"
  getThirdPartyTools()

  echo fmt"Making Panda3D in nimble package: {outputDir}"
  make()

  echo "Cleaning up"
  if dirExists(tempPandaDir) and dirExists(outputDir):
    try:
      rmDir(tempPandaDir)
      return
    except:
      echo fmt"Warning: {tempPandaDir} was not removed."

# Not sure of the specifics for non windows atm so skip
when defined(windows):
  build()
else:
  echo "Unsupported OS"
