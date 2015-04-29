//
//  ViewController.swift
//  VideoSamplerCompanion
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
}


class OSXViewController: NSViewController {

    @IBOutlet weak var infoLabel: NSTextField!

    let multipeerService = MultipeerService()

    override func viewDidLoad() {
        super.viewDidLoad()

        multipeerService.delegate = self
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension OSXViewController: MultipeerServiceDelegate {
    func collectionCompleted(collection: ImageCollection, by: MultipeerService) {
        infoLabel.stringValue = collection.debugDescription
    }
}

