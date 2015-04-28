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
    @IBOutlet weak var sizeLabel: UILabel!
    var sizeStepperValue = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sizeUpdate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {
    
    @IBAction func sizeUpdate(sender: AnyObject) {
        let value = Int(sizeStepper.value + 0.5)
        sizeStepperValue = value
        sizeLabel.text = "\(value * value)"
    }

}
