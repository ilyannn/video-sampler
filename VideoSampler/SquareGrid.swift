//
//  SquareGrid.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit

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

class SquareGrid: UICollectionView {
    
}
