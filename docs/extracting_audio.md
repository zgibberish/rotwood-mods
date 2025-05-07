# Extracting Audio

Rotwood uses FMOD .bank files to store audio used in the game, you can use this tool to extract them: https://gamebanana.com/tools/12100 (Fmod Bank Tools by Wouldubeinta)

# How to use Fmod Bank Tools

Download the tool from the link above (there will be a 7z file), then extract it.
  
Included there are 3 folders that we are interested in:
   - `bank/` : This is the default source folder, you can put the source `.bank` files that you want to extract in here.
   - `wav/` : This is the default output folder, extracted sound files from the program will be put in here.
   - *`fsb/` : During the extraction process `.fsb` files will also be spat out here, so if you have a need for them you can find them here.
   
These are just the default paths and you can use other directories if you like.

Start by placing the source `.bank` files in your source folder (`bank/` by default).

Then open `Fmod Bank Tools.exe`.

First things you would want to check out is the profile options. On the menu bar, hit `Options -> Fmod Bank Profile`, you can leave `Format` as its default option, but for the best output quality you should change `Quality` to 100.

Now select your source folder and output folder in the 2 boxes in the center, or leave them as default which is `bank/` and `wav/` as I mentioned earlier.

Finally press `Extract` and the process willl be done all automatically. Output `.wav` files  will be in your output folder.

**As of the time I'm writing this (May 11th 2024) and using the latest Early Access version (rev 606127), I can confirm that this works and can extract all audio for all banks, except Master.strings, also works on linux through Wine.**
