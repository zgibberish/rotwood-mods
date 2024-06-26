# Enabling dev tools

**PLEASE READ: (May 25th 2024) Since the last couple of EA versions, there have been some changes that made your save files incompatible once DEV_MODE is enabled or when playing with mods, causing crashes with no meaningful errors or making the game prompts you to delete your saves to continue playing. Please proceed with caution and make backups of your saves (located in AppData/Roaming/Klei/Rotwood)**

Dev tools can be very useful if you're modding or inspecting elements of the game. Rotwood has lots of dev utilities built in, but they're disabled by default in production builds.


Enabling them is very easy though, all you need is to do the following edit in `main.lua`:

**NOTE:** For easier game script modifications you'd want extracted scripts (see [Extracting game scripts](extracting_game_scripts.md))

```diff
-DEV_MODE = RELEASE_CHANNEL == "dev" or IS_QA_BUILD -- For now, QA gets debug tools everywhere.
+DEV_MODE = true
```

Here are a few basic dev tools shortcuts (you can find more in the GUI menus):
- shift+\` : dev mode console (this is different from the ingame console accessible when you press \` and is much more advanced)
- ctrl+q : main dev mode UI (this includes almost all the tools in dev 
mode)
- ctrl+r : reload the game
- ctrl+shift+c : debug camera tools
- f1 : select entity to debug
- shift+e : debug entity tool
- g : toggle god mode (adding modifier keys to g will give you additional tiers of god mode)
- shift+w : widget inspector

## (Optimal) Disabling save file encryption

By default saves are also encrypted to prevent tampering, if you need to inspect them, make this edit in `main.lua` to disable that:

```diff
-ENCODE_SAVES = RELEASE_CHANNEL ~= "dev"
+ENCODE_SAVES = false
```
