# Linux Discord Rich Presence

This is not a thing specific to Rotwood but it's useful info that I think should be included.

Ever since the release of Early Access, Rotwood has had built-in Discord rich presence status support that displays various infos about your current game. But on Linux many Steam games may not display Discord RPC correctly because they run inside Wine. The most common way to get around this is to have a bridge that sends the RPC data from inside the Wine environment to the Discord client running on the host environment, I found that this one works pretty good and is pretty easy to set up

https://github.com/EnderIce2/rpc-bridge?tab=readme-ov-file#steam

(rpc-bridge by EnderIce2)
