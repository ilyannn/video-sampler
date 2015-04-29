//
//  Multipeer (Package).swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

#if os(OSX)
    import AppKit
    typealias UIImage = NSImage
#endif

// MARK: Package format for image send/retrieve
class ImageCollection {
    private(set) var imageList: [UIImage] = []
    private(set) var completed: Bool
    
    private(set) var totalDataSize = 0
    private(set) var receivedData: [NSData] = []
    
    static let EndSentinel = "end".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!    

    init() {
        completed = false
    }    
    
    init(local images: [UIImage]) {
        imageList = images
        completed = true
    }
    
    // Send invalid data to complete the image collection.
    func collect(#data: NSData) {
        if data == ImageCollection.EndSentinel {
            completed = true
        } else if let image = UIImage(data: data) {
            receivedData.append(data)
            imageList.append(image)
            totalDataSize += data.length
        } else {
            fatalError("Corrupted package")
        }
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