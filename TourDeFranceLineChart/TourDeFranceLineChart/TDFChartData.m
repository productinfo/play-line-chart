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

@property (nonatomic, strong) NSMutableArray *stageData;
@property (nonatomic, strong) NSMutableArray *distElevTrack;

@end

@implementation TDFChartData

static TDFChartData *instance = nil;

/**
 We will eagerly initialize the data.
 */
+ (void)initialize  {
  [super initialize];
  if (!instance)  {
    instance = [[TDFChartData alloc] init];
  }
}

+ (TDFChartData*)getInstance {
  @synchronized(self) {
    if (instance == nil)    {
      instance = [[TDFChartData alloc] init];
    }
    return instance;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    self.distElevTrack = [[NSMutableArray alloc] init];
    self.stageData = [[NSMutableArray alloc] init];
    self.peakData = [NSMutableArray array];
    
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
          [self.distElevTrack addObject:ptToStore];
        }
        NSUInteger endIdx = [self.distElevTrack count] - 1;
        
        NSMutableDictionary *curStageData = [[NSMutableDictionary alloc] init];
        curStageData[@"start_name"] = stage[@"start_name"];
        curStageData[@"end_name"] = stage[@"end_name"];
        curStageData[@"start_idx"] = @(startIdx);
        curStageData[@"end_idx"] = @(endIdx);
        curStageData[@"start_dist"]  = stage[@"start_dist"];
        curStageData[@"end_dist"] = @(cumDist);
        curStageData[@"start_elevation"] = stage[@"distance_elevation"][0][1];
        [self.stageData addObject:curStageData];
      }
    }
    
    // Load the peak data
    path = [[NSBundle mainBundle] pathForResource:@"tdf2012_peaks" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
      NSArray *peaks = [NSArray arrayWithContentsOfFile:path];
      for (NSDictionary *peakValues in peaks) {
        TDFPeak *peak = [[TDFPeak alloc] init];
        peak.name = peakValues[@"name"];
        peak.elevation = [peakValues[@"elevation"] floatValue];
        peak.distanceAlongRoute = [peakValues[@"distance"] floatValue];
        
        [self.peakData addObject:peak];
      }
    }
  }
  return self;
}



- (NSUInteger)numberOfDataPoints {
    return [self.distElevTrack count];
}

- (NSNumber *)getDistanceAtIndex:(NSUInteger)idx {
    return (self.distElevTrack)[idx][0];
}

- (NSNumber *)getElevationAtIndex:(NSUInteger)idx {
    return (self.distElevTrack)[idx][1];
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
    return stageNames;
}

// Return an array of start and end distances
- (NSArray *)stageStartAndEndPoints {
    NSMutableArray *startAndEndPoints = [[NSMutableArray alloc] init];
    [self.stageData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [startAndEndPoints addObject:@[obj[@"start_dist"], obj[@"end_dist"]]];
    }];
    return startAndEndPoints;
}

- (NSArray*)stageStartElevations    {
    NSMutableArray *stageStartElevations = [[NSMutableArray alloc] init];
    [self.stageData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [stageStartElevations addObject:obj[@"start_elevation"]];
    }];
    return stageStartElevations;
}

@end
