# ~ Auto-Rename MediaIn to file name ~
Never get confused by generically named Media In-nodes again.



## Usage:
- Open the Fusion page 
- Run this script from DaVinci Resolve's dropdown menu (Workspace > Scripts)
- This will automatically rename all unnamed MediaIn-nodes in a Fusion composition to their respective file names
	- Note: Nodes with purely numeric file names ('0001.mp4') are skipped, because these are not valid names for nodes in Fusion
- This works best if bound to a hotkey (open hotkey settings with CTRL+ALT+K)

## Install:
- Copy the .lua-file into the folder "%appdata%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp"