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
    @IBOutlet weak var saveButton: NSButton!

    let multipeerService = MultipeerService()
    var lastCollection: ImageCollection? { didSet {
        
        saveButton.enabled = lastCollection != nil
        infoLabel.stringValue = lastCollection?.debugDescription ?? ""

    }}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        multipeerService.delegate = self
    }

    func inputSaveDirectory() -> NSURL? {
        let panel = NSOpenPanel() ⨁ {
            $0.allowsMultipleSelection = false
            $0.canChooseFiles = false
            $0.canChooseDirectories = true
        }
        panel.runModal() 
        return panel.URLs.last as? NSURL
    }
    
    @IBAction func savePhotos(sender: AnyObject) {
        if let collection = lastCollection, URL = inputSaveDirectory() {
            for (index, data) in enumerate(collection.receivedData) {
                let file = URL.URLByAppendingPathComponent("\(index).jpeg")
                data.writeToFile(file.path!, atomically: false)
            }
            lastCollection = nil
        }
    }
    
}

extension OSXViewController: MultipeerServiceDelegate {
    func collectionCompleted(collection: ImageCollection, by: MultipeerService) {
        
        { self.lastCollection = $0 } ⬆︎ collection
    }
    
}

