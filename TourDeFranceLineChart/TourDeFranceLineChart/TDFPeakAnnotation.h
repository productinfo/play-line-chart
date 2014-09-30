//
//  PeakAnnotation.h
//  ShinobiControls
//
//  Created by  on 12/07/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <ShinobiCharts/ShinobiCharts.h>

@interface TDFPeakAnnotation : SChartAnnotation

@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) CGFloat elevation;
@property (nonatomic, assign) BOOL show;

@end
