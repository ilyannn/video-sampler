//
//  Sampling.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

// MARK: Parameters
class SamplingParameters {
    
    let initialSamples: Int
    let finalSamples: Int

    var overSamples: Int {
        return initialSamples - finalSamples
    }
    
    var oversampleRate: Float {
        return Float(overSamples) / Float(finalSamples)
    }

    init(initial: Int, final: Int) {        
        initialSamples = initial
        finalSamples = final

        precondition(finalSamples > 0)
        precondition(overSamples >= 0)
    }    
    
    private func spacedTime(#duration: CMTime) -> [NSValue] {
        var time = duration
        var step = duration.value * 2
        var array: [NSValue] = [] 
        
        time.timescale *= CMTimeScale(initialSamples * 2)

        for x in 0..<initialSamples {
            array.append(NSValue(CMTime: time))
            time.value += step
        }
        
        return array
    }
}

private extension Float {
    init(_ time: CMTime) {
        self.init(Float(time.value) / Float (time.timescale))
    }
}

// MARK: Operation
class SamplingOperation: NSOperation {
    let samplingParameters: SamplingParameters
    let samplingAsset: AVAsset
    let assetSize: Int64?
    
    let distanceComputer = CompressionDistances()
    
    let totalProgress: NSProgress
    
    private(set) var sampleFrames: [UIImage] = []
    
    enum Stage {
        case Initial
        case Extract(Int)
        case Drop(Int)
        case Completed
    }
    
    var stage = Stage.Initial
    
    init(parameters: SamplingParameters, video: NSURL) {
        samplingParameters = parameters
        samplingAsset = AVURLAsset(URL: video, options: [:])
        
        if let path = video.path {
            let attrs = NSFileManager.defaultManager().attributesOfItemAtPath(path, error: nil)!
            assetSize = (attrs[NSFileSize] as? NSNumber)?.longLongValue
        } else {
            assetSize = nil
        }
        
        let total = 2 * samplingParameters.initialSamples
        
        totalProgress = NSProgress(totalUnitCount: Int64(total))
    }
    
    override var asynchronous: Bool { 
        return true
    }
    
    override var finished: Bool {
        switch (stage) {
        case .Completed: return true
        default: return false
        }
    }
    
    override func main() {
        
        let rate = samplingAsset.tracksWithMediaType(AVMediaTypeVideo).first!.estimatedDataRate
        let mega: Float = 1024 * 1024
        let size = Float(samplingAsset.duration) * rate

        println("video size estimated as \(size / mega) Mb")        
        if let asset_size = assetSize {
            println("file size is \(Float(asset_size) / mega) MB")
        }
        
        let times = samplingParameters.spacedTime(duration: samplingAsset.duration)
        
        var tolerance = times[0].CMTimeValue
        tolerance.timescale *= 2
        
        stage = .Extract(0)        
        
        AVAssetImageGenerator(asset: samplingAsset) ⨁ {
            $0.requestedTimeToleranceBefore = tolerance
            $0.requestedTimeToleranceAfter  = tolerance        
            $0.generateCGImagesAsynchronouslyForTimes(times, completionHandler: self.saveGeneratedImage)
        }
    }    
}


// MARK: Hard stuff
private extension SamplingOperation {
    func saveGeneratedImage(requested: CMTime, image: CGImage?, actual: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) {
        println("found image \(NSValue(CMTime:requested)) -> \(NSValue(CMTime:actual))")
        switch (stage) {
        case .Extract(var count): 
            if let valid = image {
                distanceComputer.register(image: valid, index: count)
                stage = .Extract(++count)
                sampleFrames += [UIImage(CGImage: valid)!]
                totalProgress.completedUnitCount = Int64(count)
            }
            if count == samplingParameters.initialSamples {
                dropImages()
            }
        default: break;
        }
    }

    func dropImages() {        
        // Compress images first
        var frames = Array(indices(sampleFrames))
        frames.removeLast()
        
        // Compute distances between images
        let distances: [(Int, DistanceType)] = frames.map { index in 
            self.totalProgress.completedUnitCount++
            return (index, self.distanceComputer.distanceBetween(a: index, b: index+1))
        }
        
        // Find indices with the largest distances
        let found = distances.sorted { (a, b) in
            return a.1 > b.1
        }.map{ $0.0 }
        
        // Get as many indices as we need in the natural order
        let remains = Array(found[0..<samplingParameters.finalSamples]).sorted(<)
        
        // Get those as the result
        willChangeValueForKey("isFinished")
        
        sampleFrames = remains.map{ index in self.sampleFrames[index] }
        stage = .Completed

        totalProgress.completedUnitCount++
        assert(totalProgress.completedUnitCount == totalProgress.totalUnitCount)

        didChangeValueForKey("isFinished")        
    }
    
}