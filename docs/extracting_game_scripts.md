# Extracting game scripts

**If you ever need to look at the game scripts directly or modify them for modding or other various purposes, you need to extract them from the zip files first. By default the game loads data and scripts from .zip compressed files as they load faster, but it also supports loading from extracted data, although loading time may increase.**

## Below are the steps to extract and load extracted scripts:

1. In the game directory, extract `data_scripts.zip`
2. Move the newly extracted `scripts` folder into `data/`
3. (*) Rename the original `data_scripts.zip` to `data_scripts.zip.backup` or any other name.
4. Restart the game if you haven't yet to make it load the new set of scripts (a simple reload is not enough).

(*) Explanation: The game prioritizes the .zip scripts by default and only load from `data/scripts` when it cant find the .zip file.

**NOTE:** the extracted scripts are not updated with the game and every time the game gets updated it will download a new `data_scripts.zip` , so you need to do these steps again. You can find some more useful info in the `scripts_readme.txt` file in `data/` writen by Klei.