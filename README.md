# ColorCorrectionGUI

This toolbox implements a simplified image color correction algorithm in MATLAB Guide...
No need for deep knowledge of MATLAB programming to run the App.

To Run the GUI;
- use MATLAB command "cd ColorCorrectioGUI_directory"
- run command "color_calib_UI"

The user can be load a standard color-checker image, use standard char values to compute a color correction matrix, then save or use the color correction matrix to correct any image taken under similar lighting condition with the same camera settings.
This repository was inherited from QiuJueqin's color-correction-toolbox, https://github.com/QiuJueqin/color-correction-toolbox. Please follow the link above for further description.
Important toolboxes for smooth running of toolbox;
- image processing toolbox
- optimization toolbox

Future plans
- Auto detect color checker and respective number of patches.
- Consideration for other color spaces besides 'xyz' and 'sRGB'.
