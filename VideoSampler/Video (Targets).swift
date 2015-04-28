//
//  Video (Targets).swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

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
    
    var targetViewController: UIViewController? 
    var targetMultipeerService: MultipeerService?
    
    override var ready: Bool { 
        return displayImages != nil
    }
    
    override func main() {
        if let images = displayImages {
            
            if let target = targetViewController {
                let vc = SquareGridController(images: images)
                target.presentViewController ⬆︎ (vc, true, {})
            }
            
            if let service = targetMultipeerService {
                for package in ImageCollection(local: images).packageRepresentation {
                    service.send(data: package)
                }                
            }
            
        } else {
            fatalError("Called too soon")
        }
    }
}