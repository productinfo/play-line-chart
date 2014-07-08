//
//  SignArrowView.m
//  ShinobiControls
//
//  Created by  on 26/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "TDFSignArrowView.h"

@interface TDFSignArrowView()

@property (nonatomic, strong) UIColor *fillColour;

@end

@implementation TDFSignArrowView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.fillColour = [UIColor darkGrayColor];
  }
  return self;
}


- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, self.fillColour.CGColor);
  
  CGContextBeginPath(context);
  CGContextMoveToPoint(context, 0, 0);
  CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height / 2);
  CGContextAddLineToPoint(context, 0, self.frame.size.height);
  CGContextAddLineToPoint(context, 0, 0);
  
  CGContextClosePath(context);
  
  CGContextFillPath(context);
}


@end
