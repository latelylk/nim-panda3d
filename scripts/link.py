# Used for testing whether builds were failing because of botched panda install
# or because of problems relating to the directory

# Probably not useful in general for linking your installed panda
# into the project bc you can just define pandaDir

import os, sys
import pathlib
import subprocess

try:
    import pandac
except:
    print("Could not find Panda3D on system.")
    sys.exit(1)

installed_panda_dir = pathlib.Path(pandac.__file__).resolve().parents[1]
panda_link_path = pathlib.Path(__file__).resolve().parents[1] / "src" / "built_panda"

# Check if installed panda is the wheel b/c if so we do not support
if os.path.exists(installed_panda_dir / "deploy_libs"):
    # If there is a "deploy_libs" we're in a python site packages dir
    print("Found Panda3D was installed with pip and is not supported.")
    sys.exit(1)

# Check if dir exist already. If not, make a symlink
if not os.path.exists(panda_link_path):
    try:
        os.symlink(src = installed_panda_dir, dst = panda_link_path, target_is_directory = True)
        print("Linked!")
    except:
        # Symlink didn't work. If windows, it might be b/c of permissions issues
        if os.name == 'nt':
            # Have to make a call with /J otherwise users would need to enable developer mode
            subprocess.check_call('mklink /J "%s" "%s"' % (panda_link_path, installed_panda_dir), shell=True)
        else:
            print("Panda3D found on system, but python could not create a link.")
            sys.exit(1)
else:
    # Panda3D directory found, so let the build script deal with that
    print("Panda3D directory already exists at " + str(panda_link_path))
