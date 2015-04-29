# video-sampler
Video sampling app that:

1. Imports a video file on an iOS device
1. Extracts a series of frames with user-specified settings
1. Attempts to select the most useful frames
1. Displays the frames in a grid on the device
1. Sends the frames for display on connected iOS devices
1. An OS X companion app can save the images in a user-selected folder

# Project structure

There are **two targets**, an iOS and OS X app. 
Some code is shared between the targets, but most of the code is only avaiable on iOS. 
The OS X app is restricted to receiving and saving the images.

All of the code is written in Swift. An Objective-C bridging header is installed to include the following third-party frameworks:

1. `DBChooser` for Dropbox support
