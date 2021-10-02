# Visualizer
The visualizer this year has Web, MacOS, and Windows builds. See the [releases](https://github.com/MechMania-27/Visualizer/releases) list for the most recent builds.

# Installation
We recommend using the web build which will be regularly updated at <https://mechmania.io/visualizer/MechMania27.html>. However, we have provided Windows and MacOS builds as well.

## Windows Build
Download and unzip the `Windows.zip` file below. You should be able to run `MechMania27.exe` as normal. Make sure not to rename the `.pck` or `.exe` files, and make sure they stay in the same folder.

## MacOS Build
Download and unzip the `MacOSX.zip` folder. You'll probably need to disable the Apple quarantine security feature by running `xattr -dr com.apple.quarantine MechMania27.app`.

This build should work on both Intel and M1 Macs, but we haven't been able to test it thoroughly!

## Web Build
Download and unzip the `Web.zip` folder. Run a local HTTP server to use locally. The most common way is to run `python -m http.server` from that folder.

# Usage
The engine, when run locally, will create a `game.json` file. This is the file you should upload to Visualizer (after starting it up, you will be prompted for a file). To visualize games run non-locally retrieve the game log via `mm logs`.

You can click and drag to pan the camera and scroll to zoom in or out. Pressing ESC will open up a menu allowing you to exit. Pressing TAB will switch which character you are following (panning the camera manually automatically turns off following).
