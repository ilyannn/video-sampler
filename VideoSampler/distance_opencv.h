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

typedef int64_t DistanceType;
typedef CGImageRef Image;

DistanceType compare_opencv(Image a, Image b);

#endif /* defined(__VideoSampler__distance_opencv__) */

