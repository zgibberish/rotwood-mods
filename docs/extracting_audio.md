# Extracting Audio

Rotwood uses FMOD .bank files to store audio used in the game, you can use Wouldubeinta's [Fmod Bank Tools](https://gamebanana.com/tools/12100) to extract them.

## Usage

First extract the `.7z` file you downloaded from the link above.
  
Included there are 3 folders that we are interested in:

- `bank/` : This is the default source folder, you can put the source `.bank` files that you want to extract in here.
- `wav/` : This is the default output folder, extracted sound files from the program will be put in here.
- *`fsb/` : During the extraction process `.fsb` files will also be spat out here, so if you have a need for them you can find them here (I'm not sure if they even work tho).

To extract bank files:

- Place the source `.bank` files in your source folder (`bank/` by default).
- Open `Fmod Bank Tools.exe`.
- You should check the profile options first. On the menu bar, Go to `Options -> Fmod Bank Profile`, you can leave `Format` as its default option, but for the best output quality you should change `Quality` to 100.
- Select a different source/output path if you want to (default will be `bank/` and `wav/`).
- Press `Extract` and wait. Output `.wav` files  will be in your output folder.

**NOTE for Linux:** When running this in Wine, it might fail midway or be a bit unreliable sometimes. If that happens, you can try converting 1 bank file at a time.

