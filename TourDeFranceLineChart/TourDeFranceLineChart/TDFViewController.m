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
#import "ShinobiPlayUtils/UIColor+SPUColor.h"
#import "ShinobiPlayUtils/UIFont+SPUFont.h"

static float const MinXAxisRange = 5;
static float const MinYAxisRange = 5;

@interface TDFViewController ()

@property (nonatomic, strong) NSArray *stageAnnotations;
@property (nonatomic, strong) NSArray *peakAnnotations;

@property (nonatomic, assign) NSInteger lastXAxisSpan;
@property (nonatomic, assign) NSInteger stageNumberAxisSpanBoundary;
@property (nonatomic, assign) NSInteger stageNameAxisSpanBoundary;
@property (nonatomic, assign) NSInteger detailsAxisSpanBoundary;

@end

@implementation TDFViewController

@synthesize dataSource = _dataSource;

- (TDFDataSource *)dataSource {
  return _dataSource;
}

- (void)setDataSource:(TDFDataSource *)ds {
  _dataSource = ds;
}

- (void)viewDidLoad {
  // Set the initial value of lastXAxisSpan to an arbitrary large value.  It will be updated
  // each time we zoom
  self.lastXAxisSpan = 1000000;
  
  self.stageNumberAxisSpanBoundary = 1000;
  self.stageNameAxisSpanBoundary = 500;
  self.detailsAxisSpanBoundary = 100;
  
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
}

- (void)createChart {
  self.chart = [[ShinobiChart alloc] initWithFrame:CGRectInset(self.view.bounds, 20, 30)];
}

- (void)createDataSource {
  self.dataSource = [[TDFDataSource alloc] init];
}

- (void)setupChart {
  self.chart.title = @"Tour de France 2012";
  self.chart.clipsToBounds = NO;
  
  // Create the x-axis
  SChartNumberRange *xRange = [[SChartNumberRange alloc] initWithMinimum:@2905 andMaximum:@3005];
  SChartNumberAxis *xAxis = [[SChartNumberAxis alloc] initWithRange:xRange];
  
  // Enable panning and zooming on the x-axis.
  xAxis.enableGesturePanning = YES;
  xAxis.enableGestureZooming = YES;
  xAxis.enableMomentumPanning = YES;
  xAxis.enableMomentumZooming = YES;
  xAxis.axisPositionValue = @0;
  
  // Add a title
  xAxis.title = @"Distance (km)";
  
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
  self.chart.gestureManager.doubleTapResetsZoom = YES;
  self.chart.gestureManager.doubleTapEnabled = YES;
  
  // As the chart is a UIView, set its resizing mask to allow it to automatically resize when screen orientation changes.
  self.chart.autoresizingMask = ~UIViewAutoresizingNone;
  self.chart.rotatesOnDeviceRotation = NO;
  
  // Create a theme
  SChartTheme *chartTheme = [SChartiOS7Theme new];
  UIColor *darkGrayColor = [UIColor shinobiDarkGrayColor];
  chartTheme.chartTitleStyle.font = [UIFont shinobiFontOfSize:30];
  chartTheme.chartTitleStyle.textColor = darkGrayColor;
  chartTheme.chartTitleStyle.titleCentresOn = SChartTitleCentresOnChart;
  chartTheme.chartStyle.backgroundColor = [UIColor whiteColor];
  chartTheme.legendStyle.borderWidth = 0;
  chartTheme.legendStyle.font = [UIFont shinobiFontOfSize:16];
  chartTheme.legendStyle.titleFontColor = darkGrayColor;
  chartTheme.legendStyle.fontColor = darkGrayColor;
  chartTheme.xAxisStyle.titleStyle.font = [UIFont shinobiFontOfSize:16];
  chartTheme.xAxisStyle.titleStyle.textColor = darkGrayColor;
  chartTheme.xAxisStyle.majorTickStyle.labelFont = [UIFont lightShinobiFontOfSize:14];
  chartTheme.xAxisStyle.majorTickStyle.labelColor = darkGrayColor;
  chartTheme.xAxisStyle.lineColor = darkGrayColor;
  // Set yAxisStyle to match xAxisStyle (note we can't just copy the whole style object
  // as that will make the axis label the wrong orientation)
  chartTheme.yAxisStyle.titleStyle.font = chartTheme.xAxisStyle.titleStyle.font;
  chartTheme.yAxisStyle.titleStyle.textColor = chartTheme.xAxisStyle.titleStyle.textColor;
  chartTheme.yAxisStyle.majorTickStyle = chartTheme.xAxisStyle.majorTickStyle;
  chartTheme.yAxisStyle.minorTickStyle = chartTheme.xAxisStyle.minorTickStyle;
  chartTheme.yAxisStyle.lineColor = chartTheme.xAxisStyle.lineColor;
  // Style the line series
  SChartLineSeriesStyle *lineSeriesStyle = [chartTheme lineSeriesStyleForSeriesAtIndex:0 selected:NO];
  lineSeriesStyle.showFill = YES;
  lineSeriesStyle.areaLineWidth = @2.f;
  lineSeriesStyle.areaLineColor = [UIColor shinobiPlayGreenColor];
  lineSeriesStyle.areaColor = [UIColor shinobiPlayGreenColor];
  lineSeriesStyle.areaColorLowGradient = [[UIColor shinobiPlayGreenColor] shinobiBackgroundColor];
  [self.chart applyTheme:chartTheme];
  
  SChartCrosshair *crosshair = (SChartCrosshair*)self.chart.crosshair;
  crosshair.tooltip = [[TDFCrosshairTooltip alloc] init];
}

- (void)setupAfterDataLoad {
  // Create some annotations
  [self createStageAnnotations];
  [self createPeakAnnotations];
  [self modifyAnnotationsIfNeeded:[self.chart.xAxis.range.span intValue] currentDetailLevel:Nothing];
  [self modifyPeakAnnotations:[self.chart.xAxis.range.span intValue] forceUpdate:YES];
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
    TDFSignAnnotation *signAnnotation = [[TDFSignAnnotation alloc] initWithStageNumber:i
                                                                             startName:[self.dataSource startNameForStageAtIndex:i]
                                                                               endName:[self.dataSource endNameForStageAtIndex:i] distance:stageDistance];
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
  [self modifyPeakAnnotations:currentXAxisSpan forceUpdate:NO];
}

- (void)modifyPeakAnnotations:(int)currentXAxisSpan forceUpdate:(BOOL)forceUpdate {
  BOOL shouldShowPeaks = (currentXAxisSpan <= self.stageNameAxisSpanBoundary);
  BOOL needsUpdate = YES;
  
  if (!forceUpdate) {
    TDFPeakAnnotation *firstAnnotation = self.peakAnnotations[0];
    needsUpdate = firstAnnotation.show != shouldShowPeaks;
  }
  
  if (needsUpdate) {
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
  NSNumber *axisSpan = axis.range.span;
  if ([axisSpan floatValue] < range) {
    NSNumber *min = axis.range.minimum;
    float center = [min floatValue] + ([axisSpan floatValue] / 2);
    
    NSNumber *newMin = @(center - (range / 2));
    NSNumber *newMax = @(center + (range / 2));
    
    [axis setRange:[[SChartRange alloc] initWithMinimum:newMin andMaximum:newMax]];
    [self.chart redrawChart];
  }
}

- (void)sChartIsZooming:(ShinobiChart *)chart withChartMovementInformation:(const SChartMovementInformation *)information {
  [self adjustAxisRangeIfNeeded:chart.xAxis toRange:MinXAxisRange];
  [self adjustAxisRangeIfNeeded:chart.yAxis toRange:MinYAxisRange];
  
  NSNumber *xAxisSpan = self.chart.xAxis.range.span;
  TDFSignAnnotation *firstSignAnnotation = self.stageAnnotations[0];
  DetailLevel currentDetailLevel = firstSignAnnotation.detailLevel;
  [self modifyAnnotationsIfNeeded:[xAxisSpan intValue] currentDetailLevel:currentDetailLevel];
  [self modifyPeakAnnotationsIfNeeded:[xAxisSpan intValue]];
  
  self.lastXAxisSpan = [xAxisSpan intValue];
}

@end
