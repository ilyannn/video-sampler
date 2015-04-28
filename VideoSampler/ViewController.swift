//
//  ViewController.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var sizeStepper: UISlider!
    @IBOutlet weak var overStepper: UISlider!

    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var overLabel: UILabel!
    
    @IBOutlet weak var targetButton: UIButton!
        
    let multipeerService = MultipeerService()

    /// User-selected values.
    var samplingParameters: SamplingParameters! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parametersUpdate(self)
    }
}

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
}

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(vc: MCBrowserViewController!) {
        dismissViewControllerAnimated(true) {}
    }
    
    func browserViewControllerWasCancelled(vc: MCBrowserViewController!) {
        dismissViewControllerAnimated(true) {}
    }
}
