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
    
    private(set) var totalDataSize = 0
    
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
            totalDataSize += data.length
        } else {
            fatalError("Corrupted package")
        }
    }
    
    var packageRepresentation: [NSData] {
        precondition(completed)
        return imageList.map { UIImageJPEGRepresentation($0, JPEGQuality) } + [EndSentinel]
    }
    
}

extension ImageCollection: DebugPrintable {
    var debugDescription: String { 
        let size = imageList.last?.size ?? CGSize()
        
        return "\n".join(["A collection of \(imageList.count) images.", 
            "A representative image is of size \(Int(size.width))⨉\(Int(size.height))",
            "\(totalDataSize / 1024) kB were transmitted",
        ])
    }
}