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
    
    func spacedTime(#duration: CMTime) -> [NSValue] {
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

extension Float {
    init(_ time: CMTime) {
        self.init(Float(time.value) / Float (time.timescale))
    }
}

// MARK: Operation
class SamplingOperation: NSOperation {
    let samplingParameters: SamplingParameters
    let samplingAsset: AVAsset
    let assetSize: Int64?
    
    let totalProgress: NSProgress
    
    private(set) var sampleImages: [UIImage] = []
    
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
typealias DistanceType = Int64
private typealias Signature = NSData // of size SignatureEdge * SignatureEdge
private let ColorDepth = 4 // color components, don't change

let SignatureEdge = 7

private func ImageSignature(image: UIImage) -> Signature {
    let old = image.CGImage
    
    let width = SignatureEdge 
    let height = SignatureEdge
    
    let info: CGBitmapInfo = .ByteOrder32Big
    
    let bitmap = CGBitmapContextCreate(nil, width, height, 8 /*bits*/, ColorDepth * width /*per row*/, 
        CGColorSpaceCreateDeviceRGB(), info)
    
    let size = width * height * ColorDepth
    let raw = calloc(size, sizeof(Int8))
    
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh)
    let resize = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    
    CGContextDrawImage(bitmap, resize, old)
    
    return NSData(bytes: raw, length: size)
}

extension UIImage {
    func pointAt(#x: Int, y: Int) -> UIColor {
        return .redColor()
    }
}


private func DistanceBetween(a: Signature, b: Signature) -> DistanceType {
    var distance: Int64 = 0 // can't exceed 2^16 * SignatureEdge^2 * ColorDepth
    
    for row in 1..<SignatureEdge-1 {
        for col in 1..<SignatureEdge-1 {
            for comp in 0..<ColorDepth {
                let offset = ColorDepth * (SignatureEdge * row + col) + comp
                let abyte = Int64(a.bytes[offset])
                let bbyte = Int64(b.bytes[offset])
                distance += (abyte - bbyte) * (abyte - bbyte)
            }
        }
    }
    
    return distance
}

private extension SamplingOperation {
    func saveGeneratedImage(requested: CMTime, image: CGImage?, actual: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) {
        println("found image \(NSValue(CMTime:requested)) -> \(NSValue(CMTime:actual))")
        switch (stage) {
        case .Extract(var count): 
            if let valid = image {
                stage = .Extract(++count)
                sampleImages.append(UIImage(CGImage: valid)!)
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
        let signatures = sampleImages.map(ImageSignature)

        var ix = Array(indices(signatures))
        ix.removeLast()
        
        // Compute distances between images
        let distances: [(Int, DistanceType)] = ix.map { index in 
            self.totalProgress.completedUnitCount++
            return (index, DistanceBetween(signatures[index], signatures[index + 1]))
        }
        
        // Find indices with the largest distances
        let found = distances.sorted { (a, b) in
            return a.1 > b.1
        }.map{ $0.0 }
        
        // Get as many indices as we need in the natural order
        let remains = Array(found[0..<samplingParameters.finalSamples]).sorted(<)
        
        // Get those as the result
        willChangeValueForKey("isFinished")
        
        sampleImages = remains.map{ index in self.sampleImages[index] }
        stage = .Completed

        totalProgress.completedUnitCount++
        assert(totalProgress.completedUnitCount == totalProgress.totalUnitCount)

        didChangeValueForKey("isFinished")        
    }
    
}