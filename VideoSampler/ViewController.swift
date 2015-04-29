//
//  ViewController.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: Construction
class ViewController: UIViewController {

    @IBOutlet weak var sizeStepper: UISlider!
    @IBOutlet weak var overStepper: UISlider!

    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var overLabel: UILabel!
    
    @IBOutlet weak var targetButton: UIButton!
    
    @IBOutlet weak var samplingProgressView: UIProgressView!
    
    let multipeerService = MultipeerService()
    
    let librarySourceUI = LibraryVideoSource() // Held strongly
    let dropboxSourceUI = DropboxVideoSource()
    
    /// User-selected values.
    var samplingParameters: SamplingParameters! 
    
    override func viewDidLoad() {
        librarySourceUI.delegate = self
        dropboxSourceUI.delegate = self
        multipeerService.delegate = self
        
        super.viewDidLoad()
        parametersUpdate(self)
    }
}


// MARK: - User actions
extension ViewController {
    
    @IBAction func parametersUpdate(sender: AnyObject) {
        let size = Int(sizeStepper.value + 0.5)        
        samplingParameters = SquareParameters(edge: size, over: overStepper.value)
        
        sizeLabel.text = "\(samplingParameters.finalSamples)"

        let over = samplingParameters.overSamples
        overLabel.text = over == 0 ? "no" : "+\(over)"
    }

    @IBAction func changeTarget(sender: AnyObject) {
        presentViewController(multipeerService.browserViewController() ⨁ {
            $0.delegate = self
        }, animated: true) {}
    }
        
    @IBAction func openLibrary(sender: AnyObject) {
        librarySourceUI.present(from: self)
    }
    
    @IBAction func openDropbox(sender: AnyObject) {
        dropboxSourceUI.present(from: self)
    }
}


// MARK: - Delegates
extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(vc: MCBrowserViewController!) {
        dismissViewControllerAnimated(true) {}
    }
    
    func browserViewControllerWasCancelled(vc: MCBrowserViewController!) {
        dismissViewControllerAnimated(true) {}
    }
}

extension ViewController: MultipeerServiceDelegate {
    func collectionCompleted(collection: ImageCollection, by: MultipeerService) {
        dismissViewControllerAnimated ⬆︎ (false, { 
            println(collection.debugDescription)
            self.presentViewController ⬆︎ (SquareGridController(collection: collection), true, {})
        })
    }
}

extension ViewController { // Key-Value Observing
    
    override func observeValueForKeyPath(keyPath: String, 
        ofObject object: AnyObject, 
        change: [NSObject : AnyObject], 
        context: UnsafeMutablePointer<Void>) 
    {
        if let progress = object as? NSProgress { 
            samplingProgressView.setProgress ⬆︎ (Float(progress.fractionCompleted), true)
        }
    }
}    


// MARK: - Sampling Operation
private let SamplingQueue = NSOperationQueue()

extension ViewController: VideoSourceDelegate {
    func selectionCompleted(#source: VideoSource, URL: NSURL?) {
        dismissViewControllerAnimated(true) {}
        
        if let video = URL {
            samplingProgressView.hidden = false
            samplingProgressView.progress = 0
            
            SamplingQueue.addOperations(prepareSamplingOperations(video), waitUntilFinished: false)
        }
    }        
}

extension ViewController {
    func prepareSamplingOperations(video: NSURL) -> [NSOperation] {
        
        let display = DisplayOperation(target: multipeerService)
        let sample = SamplingOperation(parameters: samplingParameters, video: video)
        
        sample.totalProgress.addObserver(self, forKeyPath: "fractionCompleted", 
            options: .New, context: nil)
        
        sample.completionBlock = {
            display.displayImages = sample.sampleImages
        } 
        
        return [sample, display]
    }

}
