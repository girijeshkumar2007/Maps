//
//  RMFoundation.h
//  TestFMDB
//
//  Created by mac on 15/05/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

#ifndef RMFoundation_h
#define RMFoundation_h

#include <stdio.h>

/*! \struct RMProjectedPoint
 \brief coordinates, in projected meters, paralleling CGPoint */
typedef struct {
    double easting, northing;
} RMProjectedPoint;

/*! \struct RMProjectedSize
 \brief width/height struct, in projected meters, paralleling CGSize */
typedef struct {
    double width, height;
} RMProjectedSize;

/*! \struct RMProjectedRect
 \brief location and size, in projected meters, paralleling CGRect */
typedef struct {
    RMProjectedPoint origin;
    RMProjectedSize size;
} RMProjectedRect;

RMProjectedPoint RMScaleProjectedPointAboutPoint (RMProjectedPoint point, float factor, RMProjectedPoint pivot);
RMProjectedRect  RMScaleProjectedRectAboutPoint(RMProjectedRect rect,   float factor, RMProjectedPoint pivot);
RMProjectedPoint RMTranslateProjectedPointBy (RMProjectedPoint point, RMProjectedSize delta);
RMProjectedRect  RMTranslateProjectedRectBy (RMProjectedRect rect,   RMProjectedSize delta);

RMProjectedPoint  RMMakeProjectedPoint (double easting, double northing);
RMProjectedRect  RMMakeProjectedRect (double easting, double northing, double width, double height);
#endif /* RMFoundation_h */
