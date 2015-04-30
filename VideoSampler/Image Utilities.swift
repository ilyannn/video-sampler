//
//  Signatures.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//


// MARK: - Image signatures
typealias Signature = NSData   // consists of SignatureEdge * SignatureEdge * ColorDepth bytes

private let ColorDepth = 4    // color components in RGBA, don't change
private let SignatureEdge = 7 // best value to be determined experimentally

func ImageSignature(image: CGImage) -> Signature {
    let width = SignatureEdge 
    let height = SignatureEdge
    
    let info: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue
    let size = width * height * ColorDepth
    let raw = calloc(size, sizeof(Int8))
    
    let bitmap = CGBitmapContextCreate(raw, width, height, 8 /*bits*/, ColorDepth * width /*per row*/, 
        CGColorSpaceCreateDeviceRGB(), CGBitmapInfo(info))
    
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh)
    let resize = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    
    CGContextDrawImage(bitmap, resize, image)
    
    return NSData(bytes: raw, length: size)
}

func DistanceBetween(a: Signature, b: Signature) -> DistanceType {
    var distance: Int64 = 0 // can't exceed 2^16 * SignatureEdge^2 * ColorDepth
    
    var unsafe_a = UnsafePointer<UInt8>(a.bytes)
    var unsafe_b = UnsafePointer<UInt8>(b.bytes)
    
    for row in 1..<SignatureEdge-1 {
        for col in 1..<SignatureEdge-1 {
            for comp in 0..<ColorDepth {
                let offset = ColorDepth * (SignatureEdge * row + col) + comp
                let abyte = Int64(unsafe_a[offset])
                let bbyte = Int64(unsafe_b[offset])
                distance += (abyte - bbyte) * (abyte - bbyte)
            }
        }
    }
    
    return distance
}


// MARK: - Make image smaller
private let JPEGQuality: CGFloat = 0.9  // When sending.

func PackImage(image: UIImage) -> NSData {
    return UIImageJPEGRepresentation(image, JPEGQuality) 
}

func ResizeImage(image: UIImage, factor: CGFloat) -> UIImage {
    let resize = CGRectIntegral(CGRectMake(0, 0, image.size.width / factor, image.size.height / factor))
    let width = Int(resize.size.width)
    let height = Int(resize.size.height)
    
    return ResizeImage(image, width, height)
}

func ResizeImage(image: UIImage, width: Int, height:Int) -> UIImage {
    
    let old = image.CGImage
    
    let bitmap = CGBitmapContextCreate(nil, width, height, 
        CGImageGetBitsPerComponent(old), 0, 
        CGImageGetColorSpace(old), CGImageGetBitmapInfo(old))
    
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh)
    let resize = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    
    CGContextDrawImage(bitmap, resize, old)
    
    let resized = CGBitmapContextCreateImage(bitmap)
    return UIImage(CGImage: resized)!
}