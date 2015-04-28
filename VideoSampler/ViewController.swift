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
    @IBOutlet weak var recordButton: UIButton!
        
    let multipeerService = MultipeerService()
    let librarySourceUI = LibraryVideoSource()
    
    /// User-selected values.
    var samplingParameters: SamplingParameters! 
    
    override func viewDidLoad() {
        librarySourceUI.delegate = self
        
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
        let vc = multipeerService.browserViewController()
        vc.delegate = self
        presentViewController(vc, animated: true) {}
    }
        
    @IBAction func openLibrary(sender: AnyObject) {
        librarySourceUI.present(from: self)
    }
    
    @IBAction func openDropbox(sender: AnyObject) {
        // TODO: dropbox source
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

private let SamplingQueue = NSOperationQueue()

extension ViewController: VideoSourceDelegate {
    func selectionCompleted(#source: VideoSource, URL: NSURL?) {
        dismissViewControllerAnimated(true) {}
        if let video = URL {
            SamplingQueue.addOperation(SamplingOperation(parameters: samplingParameters, video: video))
        }
    }
}
