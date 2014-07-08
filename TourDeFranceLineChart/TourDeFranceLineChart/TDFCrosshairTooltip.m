//
//  DiscoverCrosshairTooltip.m
//  ShinobiControls
//
//  Created by  on 21/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "TDFCrosshairTooltip.h"

@implementation TDFCrosshairTooltip

/**
 We override the default behaviour to display the units for our x and y values.
 */
- (void)setDataPoint:(id<SChartData>)dataPoint fromSeries:(SChartSeries *)series fromChart:(ShinobiChart *)chart    {
    SChartDataPoint *dp = dataPoint;
    self.label.text = [NSString stringWithFormat:@"%.0f km, %.0f m", [dp.xValue floatValue], [dp.yValue floatValue]];
}

@end
