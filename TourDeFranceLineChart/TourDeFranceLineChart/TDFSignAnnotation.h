//
//  SignAnnotation.h
//  ShinobiControls
//
//  Created by  on 22/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <ShinobiCharts/ShinobiChart.h>
#import "TDFSignArrowView.h"

typedef NS_ENUM(NSInteger, DetailLevel) {
  Nothing,
  StageNumber,
  StageName,
  Details
};

@interface TDFSignAnnotation : SChartAnnotation

@property (nonatomic, assign) NSUInteger stageNumber;
@property (nonatomic, strong) NSString *startName;
@property (nonatomic, strong) NSString *endName;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) DetailLevel detailLevel;

- (instancetype)initWithStageNumber:(NSUInteger)stageNumber startName:(NSString*)startName endName:(NSString*)endName distance:(CGFloat)distance;

@end
