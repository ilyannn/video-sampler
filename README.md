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
Some code is shared between the targets, but most of the code is only available on iOS. 
The OS X app is restricted to receiving and saving the images.

All of the code is **written in Swift**. An Objective-C bridging header is installed to include the following third-party frameworks:

1. `DBChooser` for Dropbox (file open support)
2. `opencv2` for OpenCV (real-time image recognition)



# Custom operators

The following Swift operators, defined in [Custom Operators.swift](./VideoSampler/Custom%20Operators.swift) are used throughout the project:

**Main thread** ⬆︎, an infix operator with the semantic meaning *schedule the block with the given parameters on the main thread*. Often used in delegate callbacks when lifting model events to the UI layer, for example: 

     samplingProgressView.setProgress ⬆︎ (Float(progress.fractionCompleted), true)

**Configure** ⨁, an infix operator with the semantic meaning *modify an object using a configure function*, implements a kind of ad-hoc builder pattern. Example:

    return view.addSubview(UIImageView(frame: frame) ⨁ {
        $0.image = image
        $0.contentMode = .ScaleAspectFill
        $0.clipsToBounds = true
        $0.opaque = true
    })


# Image sampling
Basic sampling logic is described in [Sampling.swift](./VideoSampler/Sampling.swift). The immutable `SamplingParameters` class contains the description of how many samples to take initially and how many to drop.

Our app uses the specific subclass `SquareParameters` in [SquareGrid.swift](./VideoSampler/SquareGrid.swift) to manage sampling parameters. This class converts a square edge size and an oversampling rate into the parameters above.

Sampling is implemented as an `NSOperation` subclass. This has several benefits, e.g. another operation can be scheduled after its completion using the standard system approach.

The specific operation queue on which `SamplingOperation` is enqueued isn’t of great importance, as the operation is asynchronous. The high-level overview of the operation is as follows:

1. Get the samples from the video file asynchronously using `AVAssetImageGenerator`.
1. Transform each sample into a certain *signature*: a small sequence of bytes whose main property is that visually different images should produce different signatures.
1. Compute distances between nearby images in some simple way.
1. Drop the images which are mostly similar to their neighbours.

We use image interpolation in the step 2, specifically the image is drawn on a very small canvas (say, 7x7) and the RGB values of the pixels are used as the image signature.


# How to use 

1. Set the desired parameters
1. Add nearby devices that run the same app or a desktop companion
1. Select a video from one of the inputs
1. Wait for the (Apple-provided) video compression and (our) extraction to finish.
1. Enjoy the photos
1. Shake the iOS devices
1. Use the save button on the OS X app to save the images
