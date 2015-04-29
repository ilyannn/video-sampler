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
2. (that's it for now)



# Global operators

The following custom operators, defined in [Swift Operators.swift](https://github.com/ilyannn/video-sampler/blob/master/VideoSampler/Swift%20Operators.swift) are used throughout the project:

**Main thread** ⬆︎, an infix operator with the semantic meaning *schedule the block with the given parameters on the main thread*. Often used in delegate callbacks when lifting model events to the UI layer, for example: 

     samplingProgressView.setProgress ⬆︎ (Float(progress.fractionCompleted), true)

**Configure** ⨁, an infix operator with the semantic meaning *modify an object using a configure function*, implements an ad-hoc builder pattern. Example:

    return view.addSubview(UIImageView(frame: frame) ⨁ {
        $0.image = image
        $0.contentMode = .ScaleAspectFill
        $0.clipsToBounds = true
        $0.opaque = true
    })



# How to use 

1. Set the desired parameters
1. Add nearby devices that run the same app or a desktop companion
1. Select a video from one of the inputs
1. Wait for the (Apple-provided) video compression and (our) extraction to finish.
1. Enjoy the photos
1. Shake the iOS devices
1. Use the save button on the OS X app to save the images
