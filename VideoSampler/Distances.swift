//
//  Distances.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 30/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation


// MARK: Abstract distances 
protocol DistanceComputing {
    func register(#image: CGImage, index: Int)
    func distanceBetween(#a: Int, b: Int) -> DistanceType 
}

// MARK: - Distances using compression algorithm

class CompressionDistances: DistanceComputing {
    private var imageSignatures: [Int: Signature] = [:]

    func register(#image: CGImage, index: Int) {
        imageSignatures[index] = ImageSignature(image)
    }
    
    func distanceBetween(#a: Int, b: Int) -> DistanceType {
        let a_sign = imageSignatures[a]!
        let b_sign = imageSignatures[b]!
        return DistanceBetween(a_sign, b_sign)
    }
}

// MARK: - OpenCV distances

class OpenCVDistances: DistanceComputing {
    private var imageDict: [Int: CGImageRef] = [:]

    func register(#image: CGImage, index: Int) {
        imageDict[index] = image
    }
    
    func distanceBetween(#a: Int, b: Int) -> DistanceType {
        let ai = imageDict[a]!
        let bi = imageDict[b]!
        
        return compare_opencv(ai, bi)
    }
}