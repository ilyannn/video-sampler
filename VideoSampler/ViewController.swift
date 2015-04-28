//
//  ViewController.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sizeStepper: UISlider!
    @IBOutlet weak var overStepper: UISlider!

    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var overLabel: UILabel!
        
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

}
