//
//  Sampling.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

class SamplingParameters {

    let initialSamples: Int
    let finalSamples: Int

    var overSamples: Int {
        return initialSamples - finalSamples
    }
    
    var oversampleRate: Float {
        return Float(overSamples) / Float(finalSamples)
    }

    init(initial: Int, final: Int) {        
        initialSamples = initial
        finalSamples = final

        precondition(finalSamples > 0)
        precondition(overSamples >= 0)
    }    
}

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