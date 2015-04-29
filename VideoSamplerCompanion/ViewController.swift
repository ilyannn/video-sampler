//
//  ViewController.swift
//  VideoSamplerCompanion
//
//  Created by Ilya Nikokoshev on 29/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

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

extension ViewController: MultipeerServiceDelegate {
    func collectionCompleted(collection: ImageCollection, by: MultipeerService) {
        println(collection.debugDescription)
    }
}

