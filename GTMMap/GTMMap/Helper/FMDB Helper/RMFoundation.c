//
//  RMFoundation.c
//  TestFMDB
//
//  Created by mac on 15/05/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

#include "RMFoundation.h"
RMProjectedPoint RMScaleProjectedPointAboutPoint(RMProjectedPoint point, float factor, RMProjectedPoint pivot)
{
    point.easting = (point.easting - pivot.easting) * factor + pivot.easting;
    point.northing = (point.northing - pivot.northing) * factor + pivot.northing;
    
    return point;
}

RMProjectedRect  RMScaleProjectedRectAboutPoint (RMProjectedRect rect,   float factor, RMProjectedPoint pivot)
{
    rect.origin = RMScaleProjectedPointAboutPoint(rect.origin, factor, pivot);
    rect.size.width *= factor;
    rect.size.height *= factor;
    
    return rect;
}

RMProjectedPoint RMTranslateProjectedPointBy(RMProjectedPoint point, RMProjectedSize delta)
{
    point.easting += delta.width;
    point.northing += delta.height;
    return point;
}

RMProjectedRect  RMTranslateProjectedRectBy(RMProjectedRect rect,   RMProjectedSize delta)
{
    rect.origin = RMTranslateProjectedPointBy(rect.origin, delta);
    return rect;
}

RMProjectedPoint  RMMakeProjectedPoint (double easting, double northing)
{
    RMProjectedPoint point = {
        easting, northing
    };
    
    return point;
}

RMProjectedRect  RMMakeProjectedRect (double easting, double northing, double width, double height)
{
    RMProjectedRect rect = {
        {easting, northing},
        {width, height}
    };
    
    return rect;
}