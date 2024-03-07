# Auto-Rename
Never get confused by generically named Fusion nodes in DaVinci Resolve again.

![AutoRename](https://github.com/neezr/Auto-Rename-Media-In-Nodes-for-DaVinci-Resolve/assets/145998491/8227b072-4e11-467e-97eb-a7eb3dfac627)


Automatically rename:

- *'MediaIn'* nodes to their file names,
- *'Background'* nodes to their colors and
- *'Text+'*/*'Text3D'* nodes to their text contents
- All layers of a *'MultiMerge'* node to the names of their input nodes

All with a single click!


## Usage:
- Open the Fusion page 
- Run this script from DaVinci Resolve's dropdown menu (Workspace > Scripts)
- This will automatically rename all unnamed *"MediaIn"*, *"Background"*, *"Text+"* and *"Text 3D"* nodes to logical display names
  - This will also rename all layers in the LayerList of a *"MultiMerge"* node to the names of their input nodes

- This works best if bound to a hotkey! (open hotkey settings with CTRL+ALT+K)

## Install:
- Copy the .lua-file into the folder "%appdata%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp"
