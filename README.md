# ColorCorrectionGUI

This toolbox implements a simplified image color correction algorithm in MATLAB Guide...
No need for deep knowledge of MATLAB programming to run the App.


**To Run the GUI;**
- use MATLAB command "cd ColorCorrectioGUI_directory"
- run command "color_calib_UI"

User can load a standard color-checker image, use standard chart values to compute a color correction matrix, then save or use the color correction matrix to correct any image taken under similar lighting conditions with the same camera settings.

![Screenshot 2021-07-14 005431](https://user-images.githubusercontent.com/49397327/125485044-9b6f5724-e2ad-4c67-a55c-d57ffdf01948.png)


This repository was inherited from **QiuJueqin's** _color-correction-toolbox_, https://github.com/QiuJueqin/color-correction-toolbox. Please follow the link above for further description.


**Important** toolboxes for smooth running of toolbox;
- image processing toolbox
- optimization toolbox

**Future plans**
- Auto detect color checker and respective number of patches.
- Consideration for other color spaces besides 'xyz' and 'sRGB'.
