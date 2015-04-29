//
//  Multipeer (Package).swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

// MARK: Package format for image send/retrieve
private let JPEGQuality: CGFloat = 0.03  // When sending.
private let EndSentinel = "end".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!


class ImageCollection: PackageRepresentation {
    private(set) var imageList: [UIImage] = []
    private(set) var completed: Bool
    
    init() {
        completed = false
    }    
    
    init(local images: [UIImage]) {
        imageList = images
        completed = true
    }
    
    // Send invalid data to complete the image collection.
    func collect(#data: NSData) {
        if data == EndSentinel {
            completed = true
        } else if let image = UIImage(data: data) {
            imageList.append(image)
        } else {
            fatalError("Corrupted package")
        }
    }
    
    var packageRepresentation: [NSData] {
        precondition(completed)
        return imageList.map { UIImageJPEGRepresentation($0, JPEGQuality) } + [EndSentinel]
    }
    
}