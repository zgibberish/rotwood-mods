# Dev Tools

**Klei will not provide support for modified installations. I highly recommend backing up your save files before using DEV mode!**

Dev tools can be very useful if you're modding or inspecting elements of the game. Rotwood has lots of dev utilities built in, but they're disabled by default in production builds.

Enabling them is very easy though, make this edit in `main.lua`:

```diff
-DEV_MODE = RELEASE_CHANNEL == "dev" or IS_QA_BUILD -- For now, QA gets debug tools everywhere.
+DEV_MODE = true
```

Here are a few basic dev tools shortcuts (you can find more in the GUI menus):

- Ctrl+Q : Toggle ImGui
- Ctrl+R : Reload Scene
- Shift+\` : ImGui Console (this is overall a lot better than the other console accessible with \`)
- Ctrl+Shift+C : Debug Camera
- F1 : Select Entity under mouse
- Shift+E : Debug Entity
- Shift+W : Debug Widget
- G : Toggle god mode (+other variations by adding modifier keys)

## (Optimal) Decrypt save files

By default saves are also encrypted to prevent tampering, if you need to inspect them, edit this in `main.lua` to disable that:

```diff
-ENCODE_SAVES = RELEASE_CHANNEL ~= "dev"
+ENCODE_SAVES = false
```
