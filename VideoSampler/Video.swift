//
//  Video.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol VideoSourceDelegate: NSObjectProtocol {
    func selectionCompleted(#source: VideoSource, URL: NSURL?)
}


class VideoSource: NSObject {
    weak var delegate: VideoSourceDelegate?
    
    func present(from source: UIViewController) {
        source.presentViewController(selectionViewController(), animated: true) {
            // do nothing
        }
    }
    
    private func selectionViewController() -> UIViewController {
        fatalError("abstract method")
    }
}

class LibraryVideoSource: VideoSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private override func selectionViewController() -> UIViewController {
        let vc = UIImagePickerController()
        vc.sourceType = .SavedPhotosAlbum
        vc.mediaTypes = [kUTTypeMovie]
        vc.videoQuality = .TypeHigh // TODO: Transcodes for some reason
        vc.delegate = self
        return vc
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        delegate?.selectionCompleted(source: self, URL: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        delegate?.selectionCompleted(source: self, URL: info[UIImagePickerControllerMediaURL] as? NSURL)
    }
}