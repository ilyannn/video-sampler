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
        fatalError("abstract method")
    }
    
}

class LibraryVideoSource: VideoSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override func present(from source: UIViewController) {
        source.presentViewController(UIImagePickerController() ⨁ self.configurePicker, animated: true) {
        }
    }

    private func configurePicker(vc: UIImagePickerController) {
        vc.sourceType = .SavedPhotosAlbum
        vc.mediaTypes = [kUTTypeMovie]
        vc.videoQuality = .TypeHigh // TODO: Transcodes for some reason
        vc.delegate = self
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        delegate?.selectionCompleted(source: self, URL: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        delegate?.selectionCompleted(source: self, URL: info[UIImagePickerControllerMediaURL] as? NSURL)
    }
}

class DropboxVideoSource: VideoSource {
    override func present(from source: UIViewController) {
        
        DBChooser.defaultChooser().openChooserForLinkType(DBChooserLinkTypeDirect, 
            fromViewController: source) { results in
                
                let result = results.first as? DBChooserResult
                self.delegate?.selectionCompleted(source: self, URL: result?.link)
                
        }
    }
}