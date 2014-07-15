//
//  TDFChartData.h
//  ShinobiControls
//
//  Created by Sam Davies on 12/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

@import UIKit;

@interface TDFChartData : NSObject

@property (nonatomic, strong) NSArray *peakData;

+ (instancetype) getInstance;

- (NSUInteger)numberOfDataPoints;
- (NSNumber *)getDistanceAtIndex:(NSUInteger)idx;
- (NSNumber *)getElevationAtIndex:(NSUInteger)idx;

- (NSUInteger)numberOfStages;
- (NSArray *)stageNames;
- (NSArray *)stageStartAndEndPoints;
- (NSArray *)stageStartElevations;

@end
