//
//  distance_opencv.h
//  VideoSampler
//
//  Created by Ilya Nikokoshev on 30/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

#ifndef __VideoSampler__distance_opencv__
#define __VideoSampler__distance_opencv__

#include <stdio.h>
#include <CoreGraphics/CoreGraphics.h>

typedef double Distance;
typedef CGImageRef Image;

Distance compare_opencv(Image a, Image b);

#endif /* defined(__VideoSampler__distance_opencv__) */
