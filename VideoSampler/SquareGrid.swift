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

/// The smallest number X such that X * X >= N.
private func sqrt_up(n: Int) -> Int {
    let result = Int(sqrt(Float(n)))
    if result * result < n {
        return result + 1
    }
    return result
}

// MARK: Grid - construction
class SquareGridController: UIViewController {
    let gridImages: [UIImage]
    let gridSize: Int
        
    init(collection: ImageCollection) {
        let images = collection.imageList
        gridImages = images
        gridSize = sqrt_up(images.count)
        
        super.init(nibName: nil, bundle: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        for sub in view.subviews {
            sub.removeFromSuperview
        }
        createViews(size)
    }
        
    override func loadView() {
        super.loadView()
        createViews(view.bounds.size)
    }
    
    func createViews(size: CGSize) {
        
        let width = size.width / CGFloat(gridSize)
        let height = size.height / CGFloat(gridSize)
        
        for (index, image) in enumerate(gridImages) {
            let row = index / gridSize
            let col = index - row * gridSize
            let frame = CGRectMake(CGFloat(col) * width, CGFloat(row) * height, width, height)
                        
            view.addSubview(UIImageView(frame: frame) ⨁ {
                $0.image = image
                $0.contentMode = .ScaleAspectFill
                $0.clipsToBounds = true
                $0.opaque = true
            })
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
