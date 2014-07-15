//
//  FeaturedLineChartViewController.m
//  FeaturedLineChart
//
//  Created by Alison Clarke on 07/07/2014.
//  Copyright (c) 2014 Alison Clarke. All rights reserved.
//

#import "TDFViewController.h"
#import "TDFDataSource.h"
#import "TDFPeakAnnotation.h"
#import "TDFSignAnnotation.h"
#import "TDFPeak.h"
#import "TDFCrosshairTooltip.h"

static float const MinXAxisRange = 5;
static float const MinYAxisRange = 5;

@interface TDFViewController ()

@property (nonatomic, strong) ShinobiChart *chart;
@property (nonatomic, strong) TDFDataSource *dataSource;
@property (nonatomic, strong) NSArray *stageAnnotations;
@property (nonatomic, strong) NSArray *peakAnnotations;

@property (nonatomic, assign) NSInteger lastXAxisSpan;
@property (nonatomic, assign) NSInteger stageNumberAxisSpanBoundary;
@property (nonatomic, assign) NSInteger stageNameAxisSpanBoundary;
@property (nonatomic, assign) NSInteger detailsAxisSpanBoundary;

@end

@implementation TDFViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [SChartiOS7Theme new].chartStyle.backgroundColor;
  [self createChart];
}

- (void)createChart {
  // Set the initial value of lastXAxisSpan to an arbitrary large value.  It will be updated each time we zoom
  self.lastXAxisSpan = 1000000;
  
  self.stageNumberAxisSpanBoundary = 1000;
  self.stageNameAxisSpanBoundary = 500;
  self.detailsAxisSpanBoundary = 100;
  
  // Create the chart
  self.chart = [[ShinobiChart alloc] initWithFrame:CGRectInset(self.view.bounds, 20, 30)];
  self.chart.title = @"Tour de France 2012";
  
  // Initialise the data source we will use for the chart
  self.dataSource = [[TDFDataSource alloc] init];
  
  // Give the chart the data source
  self.chart.datasource = self.dataSource;
  self.chart.delegate = self;
  
  // Create the x-axis
  SChartNumberRange *xRange = [[SChartNumberRange alloc] initWithMinimum:@2875 andMaximum:@2975];
  SChartNumberAxis *xAxis = [[SChartNumberAxis alloc] initWithRange:xRange];
  
  // Enable panning and zooming on the x-axis.
  xAxis.enableGesturePanning = YES;
  xAxis.enableGestureZooming = YES;
  xAxis.enableMomentumPanning = YES;
  xAxis.enableMomentumZooming = YES;
  xAxis.axisPositionValue = @0;
  
  // Add a title
  xAxis.title = @"Distance (km)";
  self.chart.clipsToBounds = NO;
  
  self.chart.xAxis = xAxis;
  
  // Create a number axis to use as the y axis.  We use a hard-coded range as we know the data we will be using.
  SChartNumberRange *yRange = [[SChartNumberRange alloc] initWithMinimum:@0 andMaximum:@2500];
  SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:yRange];
  
  // Enable panning and zooming on Y
  yAxis.enableGesturePanning = YES;
  yAxis.enableGestureZooming = YES;
  yAxis.enableMomentumPanning = YES;
  yAxis.enableMomentumZooming = YES;
  yAxis.animationEdgeBouncing = NO;
  
  // Add a title
  yAxis.title = @"Elevation (m)";
  // Add this title to the axis before we customise the label further
  self.chart.yAxis = yAxis;
  
  
  // Set double tap in main chart to reset the zoom
  self.chart.gestureDoubleTapResetsZoom = YES;
  self.chart.gestureDoubleTapEnabled = YES;
  
  // As the chart is a UIView, set its resizing mask to allow it to automatically resize when screen orientation changes.
  self.chart.autoresizingMask = ~UIViewAutoresizingNone;
  self.chart.rotatesOnDeviceRotation = NO;
  
  // Create a theme and style the line series
  SChartTheme *chartTheme = [SChartiOS7Theme new];
  SChartLineSeriesStyle *lineSeriesStyle = [chartTheme lineSeriesStyleForSeriesAtIndex:0 selected:NO];
  lineSeriesStyle.showFill = YES;
  lineSeriesStyle.areaLineWidth = @2.f;
  lineSeriesStyle.areaLineColor = [UIColor colorWithRed:48.f/255.f green:104.f/255.f blue:18.f/255.f alpha:1.f];
  lineSeriesStyle.areaColor = [UIColor colorWithRed:48.f/255.f green:104.f/255.f blue:18.f/255.f alpha:0.9f];
  lineSeriesStyle.areaColorLowGradient = [UIColor colorWithRed:92.f/255.f green:160.f/255.f blue:56.f/255.f alpha:0.7f];
  [self.chart applyTheme:chartTheme];
  
  // Add the chart to the view controller
  [self.view addSubview:self.chart];
  
  // Create some annotations
  [self createStageAnnotations];
  [self createPeakAnnotations];
  [self modifyAnnotationsIfNeeded:[self.chart.xAxis.axisRange.span intValue] currentDetailLevel:Nothing];
  
  self.chart.crosshair.tooltip = [[TDFCrosshairTooltip alloc] init];
}

- (void)createPeakAnnotations {
  NSMutableArray *peakAnnotations = [NSMutableArray array];
  for (TDFPeak *peak in [self.dataSource getPeaks])    {
    TDFPeakAnnotation *peakAnnotation = [[TDFPeakAnnotation alloc] init];
    peakAnnotation.xAxis = self.chart.xAxis;
    peakAnnotation.yAxis = self.chart.yAxis;
    peakAnnotation.name = peak.name;
    peakAnnotation.elevation = peak.elevation;
    peakAnnotation.xValue = @(peak.distanceAlongRoute);
    peakAnnotation.yValue = @(peak.elevation);
    
    [self.chart addAnnotation:peakAnnotation];
    [peakAnnotations addObject:peakAnnotation];
  }
  self.peakAnnotations = [peakAnnotations copy];
}

- (void)createStageAnnotations {
  NSMutableArray *stageAnnotations = [[NSMutableArray alloc] init];
  
  // Loop through the stages and add the annotations
  for(int i = 0; i < [self.dataSource numberOfStages]; i++) {
    
    float stageDistance = [[self.dataSource endDistanceForStageAtIndex:i] floatValue] - [[self.dataSource startDistanceForStageAtIndex:i] floatValue];
    TDFSignAnnotation *signAnnotation = [[TDFSignAnnotation alloc] initWithStageNumber:i startName:[self.dataSource startNameForStageAtIndex:i] endName:[self.dataSource endNameForStageAtIndex:i] distance:stageDistance];
    signAnnotation.xAxis = self.chart.xAxis;
    signAnnotation.yAxis = self.chart.yAxis;
    signAnnotation.xValue = [self.dataSource startDistanceForStageAtIndex:i];
    signAnnotation.yValue = [self.dataSource startElevationForStageAtIndex:i];
    
    [stageAnnotations addObject:signAnnotation];
    [self.chart addAnnotation:signAnnotation];
  }
  self.stageAnnotations = [stageAnnotations copy];
}

- (void)modifyAnnotationsIfNeeded:(int)currentXAxisSpan currentDetailLevel:(DetailLevel)detailLevel {
  DetailLevel expectedDetailLevel = [self expectedDetailLevelForXAxisSpan:currentXAxisSpan];
  if (detailLevel != expectedDetailLevel) {
    for (TDFSignAnnotation *annotation in self.stageAnnotations) {
      annotation.detailLevel = expectedDetailLevel;
    }
  }
}

- (void)modifyPeakAnnotationsIfNeeded:(int)currentXAxisSpan {
  TDFPeakAnnotation *firstAnnotation = self.peakAnnotations[0];
  BOOL showingPeaks = firstAnnotation.show;
  BOOL shouldShowPeaks = (currentXAxisSpan <= self.stageNameAxisSpanBoundary);
  if (shouldShowPeaks != showingPeaks)    {
    for (TDFPeakAnnotation *annotation in self.peakAnnotations) {
      annotation.show = shouldShowPeaks;
    }
  }
}

- (DetailLevel)expectedDetailLevelForXAxisSpan:(int)xAxisSpan {
  if (xAxisSpan > self.stageNumberAxisSpanBoundary)    {
    return Nothing;
  } else if (xAxisSpan > self.stageNameAxisSpanBoundary)  {
    return StageNumber;
  } else if (xAxisSpan > self.detailsAxisSpanBoundary) {
    return StageName;
  } else {
    return Details;
  }
}

- (void)adjustAxisRangeIfNeeded:(SChartAxis*)axis toRange:(float)range {
  NSNumber *axisSpan = axis.axisRange.span;
  if ([axisSpan floatValue] < range) {
    NSNumber *min = axis.axisRange.minimum;
    float center = [min floatValue] + ([axisSpan floatValue] / 2);
    
    NSNumber *newMin = @(center - (range / 2));
    NSNumber *newMax = @(center + (range / 2));
    
    [axis setRangeWithMinimum:newMin andMaximum:newMax];
    [self.chart redrawChart];
  }
}

- (void)sChartIsZooming:(ShinobiChart *)chart withChartMovementInformation:(const SChartMovementInformation *)information {
  [self adjustAxisRangeIfNeeded:chart.xAxis toRange:MinXAxisRange];
  [self adjustAxisRangeIfNeeded:chart.yAxis toRange:MinYAxisRange];
  
  NSNumber *xAxisSpan = self.chart.xAxis.axisRange.span;
  TDFSignAnnotation *firstSignAnnotation = self.stageAnnotations[0];
  DetailLevel currentDetailLevel = firstSignAnnotation.detailLevel;
  [self modifyAnnotationsIfNeeded:[xAxisSpan intValue] currentDetailLevel:currentDetailLevel];
  [self modifyPeakAnnotationsIfNeeded:[xAxisSpan intValue]];
  
  self.lastXAxisSpan = [xAxisSpan intValue];
}

@end
