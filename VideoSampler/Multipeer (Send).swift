//
//  Video (Targets).swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

// MARK: Image sending format
private let ResizeFactor:CGFloat = 4
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


// MARK: Operation that sends images

/// This operation will not start until displayImages is set.
class DisplayOperation: NSOperation {
    
//    class func keyPathsForValuesAffectingIsReady() -> NSSet {
//        return NSSet(object: "displayImages")
//    }
    
    var displayImages: [UIImage]? { willSet {
            willChangeValueForKey("isReady")
        } didSet {
            didChangeValueForKey("isReady")
        }
    }
    
    let targetService: MultipeerService

    init(target: MultipeerService) {
        targetService = target
    }
    
    override var ready: Bool { 
        return displayImages != nil
    }
    
    override func main() {
        if let images = displayImages {
            ImageCollection(local: images).send(targetService)
        } else {
            fatalError("Called too soon")
        }
    }
}