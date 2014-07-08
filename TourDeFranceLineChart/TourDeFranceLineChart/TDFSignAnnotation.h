//
//  SignAnnotation.h
//  ShinobiControls
//
//  Created by  on 22/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <ShinobiCharts/ShinobiChart.h>
#import "TDFSignArrowView.h"

typedef enum {
  Nothing,
  StageNumber,
  StageName,
  Details
} DetailLevel;

@interface TDFSignAnnotation : SChartAnnotation

@property (nonatomic, assign) NSUInteger stageNumber;
@property (nonatomic, strong) NSString *startName;
@property (nonatomic, strong) NSString *endName;
@property (nonatomic, assign) float distance;
@property (nonatomic, assign) DetailLevel detailLevel;

- (id)initWithStageNumber:(NSUInteger)stageNumber startName:(NSString*)startName endName:(NSString*)endName distance:(float)distance;

@end
