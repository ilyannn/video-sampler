//
//  Multipeer (iOS).swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

func ResizeImage(image: UIImage, width: Int, height:Int) -> UIImage {
    
    let old = image.CGImage
    
    let bitmap = CGBitmapContextCreate(nil, width, height, 
        CGImageGetBitsPerComponent(old), 0, 
        CGImageGetColorSpace(old), CGImageGetBitmapInfo(old))
    
    CGContextSetInterpolationQuality(bitmap, ResizeQuality)
    let resize = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    
    CGContextDrawImage(bitmap, resize, old)
    
    let resized = CGBitmapContextCreateImage(bitmap)
    return UIImage(CGImage: resized)!
}


private let JPEGQuality: CGFloat = 0.9  // When sending.
private let ResizeQuality = CGInterpolationQuality(5) // High
private let ResizeFactor:CGFloat = 4

private func PackImage(image: UIImage) -> NSData {
    return UIImageJPEGRepresentation(image, JPEGQuality) 
}

private func ResizeImage(image: UIImage, factor: CGFloat) -> UIImage {
    let resize = CGRectIntegral(CGRectMake(0, 0, image.size.width / factor, image.size.height / factor))
    let width = Int(resize.size.width)
    let height = Int(resize.size.height)
    
    return ResizeImage(image, width, height)
}

extension ImageCollection {
    
    func send(service: MultipeerService) {
        precondition(completed)        
        service.delegate?.collectionCompleted(self, by: service)

        for image in imageList {
            let resized = ResizeImage(image, ResizeFactor)
            service.send(data: PackImage(resized))
        }
        
        service.send(data: ImageCollection.EndSentinel)
    }
}