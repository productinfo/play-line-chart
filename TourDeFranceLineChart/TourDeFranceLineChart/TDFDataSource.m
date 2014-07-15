//
//  LineChartDataSource.m
//  ShinobiControls
//
//  Created by Sam Davies on 16/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "TDFDataSource.h"

@interface TDFDataSource()

@property (nonatomic, strong) TDFChartData *chartData;

@end


@implementation TDFDataSource

- (instancetype)init {
  self = [super init];
  if (self) {
    self.chartData = [TDFChartData getInstance];
  }
  
  return self;
}


#pragma mark -
#pragma mark TDFSignAnnotation data functions
- (NSUInteger)numberOfStages {
  return [self.chartData numberOfStages];
}

- (NSString *)startNameForStageAtIndex:(NSUInteger)idx {
  NSArray *names = [self.chartData stageNames][idx];
  return names[0];
}

- (NSString *)endNameForStageAtIndex:(NSUInteger)idx {
  NSArray *names = [self.chartData stageNames][idx];
  return names[1];
}

- (NSNumber *)startDistanceForStageAtIndex:(NSUInteger)idx {
  return [self.chartData stageStartAndEndPoints][idx][0];
}

- (NSNumber *)endDistanceForStageAtIndex:(NSUInteger)idx {
  return [self.chartData stageStartAndEndPoints][idx][1];
}

- (NSNumber*)startElevationForStageAtIndex:(NSUInteger)idx {
  return [self.chartData stageStartElevations][idx];
}

- (NSArray*)getPeaks    {
  return [self.chartData peakData];
}

#pragma mark -
#pragma mark Datasource Protocol Functions

// Returns the number of points for a specific series in the specified chart
- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
  return [self.chartData numberOfDataPoints];
}

// Returns the series at the specified index for a given chart
- (SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index {
  SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
  lineSeries.baseline = @0;    
  lineSeries.crosshairEnabled = YES;
  return lineSeries;
}

// Returns the number of series in the specified chart
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
  return 1;
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
    
  // Construct a data point to return
  SChartDataPoint *datapoint = [[SChartDataPoint alloc] init];
  
  datapoint.xValue = [self.chartData getDistanceAtIndex:dataIndex];
  datapoint.yValue = [self.chartData getElevationAtIndex:dataIndex];
  
  return datapoint;
}

- (NSArray *)sChart:(ShinobiChart *)chart dataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
  NSMutableArray *datapoints = [NSMutableArray array];
  for(int i=0; i<[self sChart:chart numberOfDataPointsForSeriesAtIndex:seriesIndex]; i++) {
    SChartDataPoint *datapoint = [[SChartDataPoint alloc] init];
    
    datapoint.xValue = [self.chartData getDistanceAtIndex:i];
    datapoint.yValue = [self.chartData getElevationAtIndex:i];
    [datapoints addObject:datapoint];
  }
  return [datapoints copy];
}

@end
