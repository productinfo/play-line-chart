//
//  PeakAnnotation.m
//  ShinobiControls
//
//  Created by  on 12/07/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "TDFPeakAnnotation.h"

static float const FontSize = 14.f;

@interface TDFPeakAnnotation()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *elevationLabel;

@end

@implementation TDFPeakAnnotation

- (id)init {
  self = [super init];
  
  if (self) {
    self.nameLabel = [[UILabel alloc] initWithFrame:(CGRect){0.0f, 0.0f, 1.0f, 1.0f}];
    self.nameLabel.font = [UIFont systemFontOfSize:FontSize];
    self.nameLabel.textColor = [UIColor darkGrayColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.nameLabel];
    
    self.elevationLabel = [[UILabel alloc] initWithFrame:(CGRect){0.0f, 0.0f, 1.0f, 1.0f}];
    self.elevationLabel.font = [UIFont systemFontOfSize:FontSize];
    self.elevationLabel.textColor = [UIColor darkGrayColor];
    self.elevationLabel.textAlignment = NSTextAlignmentCenter;
    self.elevationLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.elevationLabel];
  }
  
  return self;
}

- (void)setName:(NSString *)name    {
    if (name == _name)  {
        return;
    }
    _name = name;
    
    // Update the label with the new name, and ensure that the annotation frame fits the label
    self.nameLabel.text = _name;
    [self.nameLabel sizeToFit];
    [self updateFrames];
}

- (void)setElevation:(float)elevation   {
    _elevation = elevation;
    
    self.elevationLabel.text = [NSString stringWithFormat:@"%.0f m", elevation];
    [self.elevationLabel sizeToFit];
    [self updateFrames];
}

- (void)updateFrames {
    CGPoint nameLabelOrigin = self.nameLabel.frame.origin;
    CGSize nameLabelSize = self.nameLabel.frame.size;
    CGSize elevationLabelSize = self.elevationLabel.frame.size;
    
    float largerWidth = nameLabelSize.width;
    if (elevationLabelSize.width > largerWidth)   {
        largerWidth = elevationLabelSize.width;
    }
    
    self.nameLabel.center = CGPointMake(largerWidth / 2, self.nameLabel.center.y);
    self.elevationLabel.center = CGPointMake(largerWidth / 2, nameLabelSize.height + (elevationLabelSize.height / 2));
    self.frame = CGRectMake(nameLabelOrigin.x, nameLabelOrigin.y, largerWidth, nameLabelSize.height + elevationLabelSize.height);
}

-(void)updateViewWithCanvas:(SChartCanvas *)canvas  {
    [super updateViewWithCanvas:canvas];
    
    // Move the annotation up slightly so the text is slightly above the peak rather than touching the peak
    self.center = CGPointMake(self.center.x, self.center.y - (self.frame.size.height / 2.f));
}

- (void)setShow:(BOOL)show  {
    _show = show;
    [self redraw:show];
}

- (void)redraw: (BOOL)show  {
    float endingAlpha = 0.f;
    if (show) {
        endingAlpha = 1.f;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = endingAlpha;
                     }
                     completion:^(BOOL finished){
                         // If we're out of sync at the end of the animation, set the alpha to the correct value.  Don't bother animating this change
                         if (_show != show) {
                             if (_show)     {
                                 self.alpha = 1.f;
                             } else {
                                 self.alpha = 0.f;
                             }
                         }
                     }];

}

@end
