//
//  Multipeer (iOS).swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

private let JPEGQuality: CGFloat = 0.1  // When sending.

private func PackImage(image: UIImage) -> NSData {
    return UIImageJPEGRepresentation(image, JPEGQuality) 
}

extension ImageCollection {
    
    func send(service: MultipeerService) {
        precondition(completed)        
        service.delegate?.collectionCompleted(self, by: service)

        for image in imageList {
            service.send(data: PackImage(image))
        }
        
        service.send(data: ImageCollection.EndSentinel)
    }
}