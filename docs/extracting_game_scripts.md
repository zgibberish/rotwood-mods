# Extracting game scripts

By default, Rotwood loads assets and scripts from `.zip` compressed files for better performance, but it also supports loading them straight from the `data/` folder. Loading time will increase, but it gives you the convenience of inspecting assets/scripts more easily and modifying them while running the game.

1. In the game directory, extract `data_scripts.zip`.
2. Move the newly extracted `scripts` folder into `data/`.
3. (*) Rename the original `data_scripts.zip` to some other name (e.g: `data_scripts.zip.backup`).
4. Restart Rotwood.

The game prioritizes the `.zip` scripts by default and will only load from `data/scripts` when it cant find the `.zip` file.

**NOTE:** the extracted scripts are not updated with the game. After every new update, it will download a new `data_scripts.zip`, so you need to do these steps again. You can find read more about this in `data/scripts_readme.txt`.

The same process can be done with `data.zip`.
