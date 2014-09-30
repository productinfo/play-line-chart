//
//  LineChartDataSource.h
//  ShinobiControls
//
//  Created by Sam Davies on 16/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

@import Foundation;
#import <ShinobiCharts/ShinobiCharts.h>
#import "TDFChartData.h"

@interface TDFDataSource : NSObject<SChartDatasource>

- (NSUInteger)numberOfStages;
- (NSString *)startNameForStageAtIndex:(NSUInteger)idx;
- (NSString *)endNameForStageAtIndex:(NSUInteger)idx;
- (NSNumber *)startDistanceForStageAtIndex:(NSUInteger)idx;
- (NSNumber *)endDistanceForStageAtIndex:(NSUInteger)idx;
- (NSNumber *)startElevationForStageAtIndex:(NSUInteger)idx;
- (NSArray *)getPeaks;

@end
