Video sampling app that:

1. Imports a video file on an iOS device
1. Extracts a series of frames with user-specified settings
1. Attempts to select the most useful frames
1. Displays the frames in a grid on the device
1. Sends the frames for display on connected iOS devices
1. Sends the frames for saving by user via an OS X companion app
?

# How to use 

1. Set the desired parameters
1. Add nearby devices that run the same app or a desktop companion
1. Select a video from one of the inputs
1. Wait for the (Apple-provided) video compression and (our) extraction to finish.
1. Enjoy the photos
1. Shake the iOS devices
1. Use the save button on the OS X app to save the images


# Project Structure

There are **two targets**, an iOS and OS X app. 
Some code is shared between the targets, but most of the code is only available on iOS. 
The OS X app is restricted to receiving and saving the images.

All of the code is **written in Swift**. An Objective-C bridging header is installed to include the following third-party frameworks:

1. `DBChooser` for Dropbox (file open support)
2. (planned) `opencv2` for OpenCV (real-time image recognition)


# Custom Operators

The following Swift operators, defined in [Custom Operators.swift](./VideoSampler/Custom%20Operators.swift) are used throughout the project:

**Main thread** ⬆︎ (*UPWARDS BLACK ARROW*), an infix operator with the semantic meaning *schedule the block with the given parameters on the main thread*. Often used in delegate callbacks when lifting model events to the UI layer, for example: 

     samplingProgressView.setProgress ⬆︎ (Float(progress.fractionCompleted), true)

**Configure** ⨁ (*N-ARY CIRCLED PLUS OPERATOR*), an infix operator with the semantic meaning *modify an object using a configure function*, implements a kind of ad-hoc builder pattern. Example:

    return view.addSubview(UIImageView(frame: frame) ⨁ {
        $0.image = image
        $0.contentMode = .ScaleAspectFill
        $0.clipsToBounds = true
        $0.opaque = true
    })


# Video Sampling
Sampling logic is implemented in [Sampling.swift](./VideoSampler/Sampling.swift). The immutable `SamplingParameters` class describes the **sampling strategy**: how many sample frames are requested, and how many to take to improve sampling quality.

Our app uses the specific subclass of `SquareParameters` in [SquareGrid.swift](./VideoSampler/SquareGrid.swift) to manage sampling parameters. This class converts a square edge size and an oversampling rate into the parameters above.

Sampling is implemented as an `NSOperation` subclass. This has several benefits, e.g. another operation can be scheduled after its completion using the standard system approach.

The specific operation queue on which `SamplingOperation` is enqueued isn’t of great importance, as the operation is asynchronous. The high-level overview of the operation is as follows:

1. Get the sample frames from the video file using `AVAssetImageGenerator`.
1. Transform each frame into a certain *signature*: a small sequence of bytes whose main property is that visually different images should produce different signatures.
1. Compute distances between nearby samples in some simple way.
1. Drop the images which are mostly similar to their neighbours.


# Image Signatures
To generate the signature in the step 2, the image is drawn on a very small canvas (say, 7x7) and the RGB values of the pixels are used as the above mentioned sequence of bytes. 

We ask the system to use the highest available quality of interpolation, but this process is still much faster then the step 1.

These methods are implemented together with other image processing functions in [Image Utilities.swift](./VideoSampler/Image Utilities.swift).


# Multipeer Connectivity
At the user’s request we send the resulting samples to other devices. This logic is implemented in 

* [Multipeer (Service)](./VideoSampler/Multipeer%20(Service).swift): general multipeer logic
* [Multipeer (Package)](./VideoSampler/Multipeer%20(Service).swift): description of transport format
* [Multipeer (Targets)](./VideoSampler/Multipeer%20(Targets).swift): sending the data

The latter is not included into the OS X compilation target. Instead, saving is implemented in [OSX Classes.swift](./VideoSamplerCompanion/OSX%20Classes.swift).


# User Interface

We extracted as most of the view controller logic as reasonable from the `ViewController` class [View Controller.swift](./VideoSampler/View%20Controller.swift) and are left with a simple class. We organize it into sections, visually separated as extensions that describe different facets of our view controller.

Displaying the images is done through the send operation code path, when the sending service notifies `ViewController` via `collectionCompleted(collection: ImageCollection, by: MultipeerService)`. 

We implement a very simple grid view controller in [SquareGrid.swift](./VideoSampler/View%20Controller.swift) to demonstrate implementing the views directly via `loadView()`, and intercepting the motion events. An implementation of a suitable `UIColectionView` subclass should be used to display images in a production app instead.


# Code Style

We don’t use global variables (nor, more generally, a global state) but occasionally declare an object as a private, that is, file-level, singleton, which seems to me more semantically transparent compared to other solutions:

    private let SamplingQueue = NSOperationQueue()

The project is supposed to compile without any warnings. We always treat a warning as an issue to be solved.


# Swift thoughts

Swift is much stricter compared to Objective-C with type conversion, which makes doing some low-level work, especially around Core Graphics, harder, cf. 
    
    CGBitmapInfo(CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)

where Objective-C was fine with 

    kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast

The translation of these APIs into Swift is also subject to change, so this type of work is still better performed in Objective-C (or plain C). See [SecureKeys.m](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/SecureKeys.m) from the [BankExample](https://github.com/ilyannn/bank-example/) project.

`precondition` is extremely useful, as it makes some code self-documenting. 

Swift treatment of immutability, optionality, module- and file-level scope is extremely useful and it’s hard to go back to a language without those concepts.


