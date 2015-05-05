//
//  TDFChartData.m
//  ShinobiControls
//
//  Created by Sam Davies on 12/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "TDFChartData.h"
#import "TDFPeak.h"

@interface TDFChartData ()

@property (nonatomic, strong) NSArray *stageData;
@property (nonatomic, strong) NSArray *distElevTrack;

@end

@implementation TDFChartData

static TDFChartData *instance = nil;
static dispatch_once_t pred;

+ (TDFChartData*)getInstance {
  dispatch_once(&pred, ^{
    instance = [[TDFChartData alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self initializeDistElevData];
    [self initializePeakData];
  }
  return self;
}

- (void)initializeDistElevData {
  NSMutableArray *distElevTrack = [NSMutableArray array];
  NSMutableArray *stageData = [NSMutableArray array];
  
  // Load the Tour De France data
  NSString *path = [[NSBundle mainBundle] pathForResource:@"tdf2012_distElev" ofType:@"plist"];
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSArray *rawData = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    // Munge the data to get a track array, without stage info
    for(NSDictionary *stage in rawData) {
      NSUInteger startIdx = [self.distElevTrack count];
      double cumDist = 0;
      for(NSArray *trackPoint in stage[@"distance_elevation"]) {
        cumDist = [trackPoint[0] doubleValue] + [stage[@"start_dist"] doubleValue];
        NSArray *ptToStore = @[@(cumDist), trackPoint[1]];
        [distElevTrack addObject:ptToStore];
      }
      
      // Add an extra datapoint to the end of each stage, with a null elevation. This will
      // show up in the chart as a discontinuity in the series
      [distElevTrack addObject:@[@(cumDist), [NSNull null]]];
      
      NSUInteger endIdx = [self.distElevTrack count] - 1;
      
      NSDictionary *curStageData = @{@"start_name": stage[@"start_name"],
                                     @"end_name": stage[@"end_name"],
                                     @"start_idx": @(startIdx),
                                     @"end_idx": @(endIdx),
                                     @"start_dist": stage[@"start_dist"],
                                     @"end_dist": @(cumDist),
                                     @"start_elevation": stage[@"distance_elevation"][0][1]};
      [stageData addObject:curStageData];
    }
  }
  
  self.distElevTrack = [distElevTrack copy];
  self.stageData = [stageData copy];
}


- (void)initializePeakData {
  NSMutableArray *peakData = [NSMutableArray array];
  NSString * path = [[NSBundle mainBundle] pathForResource:@"tdf2012_peaks" ofType:@"plist"];
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSArray *peaks = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *peakValues in peaks) {
      TDFPeak *peak = [[TDFPeak alloc] init];
      peak.name = peakValues[@"name"];
      peak.elevation = [peakValues[@"elevation"] floatValue];
      peak.distanceAlongRoute = [peakValues[@"distance"] floatValue];
      
      [peakData addObject:peak];
    }
  }
  self.peakData = [peakData copy];
}

- (NSUInteger)numberOfDataPoints {
  return [self.distElevTrack count];
}

- (NSNumber *)getDistanceAtIndex:(NSUInteger)idx {
  return self.distElevTrack[idx][0];
}

- (NSNumber *)getElevationAtIndex:(NSUInteger)idx {
  NSNumber * elevation = self.distElevTrack[idx][1];
  return [elevation isEqual:[NSNull null]] ? nil : elevation;
}

// Returns the total number of stages
- (NSUInteger)numberOfStages {
  return [self.stageData count];
}

// Returns an array of start and end stage names
- (NSArray *)stageNames {
    NSMutableArray *stageNames = [[NSMutableArray alloc] init];
    [self.stageData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [stageNames addObject:@[obj[@"start_name"], obj[@"end_name"]]];
    }];
    return [stageNames copy];
}

// Return an array of start and end distances
- (NSArray *)stageStartAndEndPoints {
    NSMutableArray *startAndEndPoints = [[NSMutableArray alloc] init];
    [self.stageData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [startAndEndPoints addObject:@[obj[@"start_dist"], obj[@"end_dist"]]];
    }];
    return [startAndEndPoints copy];
}

- (NSArray*)stageStartElevations    {
    NSMutableArray *stageStartElevations = [[NSMutableArray alloc] init];
    [self.stageData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [stageStartElevations addObject:obj[@"start_elevation"]];
    }];
    return [stageStartElevations copy];
}

@end
