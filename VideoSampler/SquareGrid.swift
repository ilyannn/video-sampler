//
//  SquareGrid.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit

// MARK: Auxiliary functions
class SquareParameters: SamplingParameters {
    let edgeSize: Int
    
    init(edge: Int, over: Float = 0.0) {
        precondition(edge > 0)
        precondition(over >= 0)
        
        edgeSize = edge
        let square = edge * edge
        let oversample = Int(Float(square) * over)
        
        super.init(initial: square + oversample, final: square)
    }
}

private func sqrt_up(number: Int) -> Int {
    let result = Int(sqrt(Float(number)))
    if result * result < number {
        return result + 1
    }
    return result
}

// MARK: Grid - construction
class SquareGridController: UIViewController {
    let gridImages: [UIImage]
    let gridSize: Int
    
    init(images: [UIImage]) {
        gridImages = images
        gridSize = sqrt_up(images.count)
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    

    override func loadView() {
        super.loadView()
        
        let width = view.bounds.width / CGFloat(gridSize)
        let height = view.bounds.height / CGFloat(gridSize)
        
        for (index, image) in enumerate(gridImages) {
            let row = index / gridSize
            let col = index - row * gridSize
            let frame = CGRectMake(CGFloat(col) * width, CGFloat(row) * height, width, height)
            let cell = UIImageView(frame: frame)
            cell.image = image
            cell.contentMode = .ScaleAspectFill
            view.addSubview(cell)
        }
    }
}

// MARK: Grid - actions
extension SquareGridController {
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            presentingViewController?.dismissViewControllerAnimated(true) {}
        }
    }
}
