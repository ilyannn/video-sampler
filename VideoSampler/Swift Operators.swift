//
//  Operators.swift
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 28/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

// MARK: Send to main thread
prefix operator ⬆︎ { } 

prefix func ⬆︎(block: () -> ()) -> (() -> ()) {
    return { block ⬆︎ () }
}

infix operator ⬆︎ { } 

func ⬆︎<T>(block: T -> (), args:T) {
    dispatch_async(dispatch_get_main_queue()) { block(args) }
}


// MARK: Configure an object
// Example (assuming you have a class Point): Point() ⨁ { $0.x = 10; $0.y = 12 }
infix operator  ⨁ { associativity left }
func ⨁<T>(object:T, @noescape configurator: T -> ()) -> T {
    configurator(object)
    return object
}
