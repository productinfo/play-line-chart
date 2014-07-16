//
//  SignAnnotation.m
//  ShinobiControls
//
//  Created by  on 22/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "TDFSignAnnotation.h"

static CGSize const LargeFrameSize = { 150.f, 75.f };
static CGSize const MediumFrameSize = { 100.f, 60.f };
static CGSize const SmallFrameSize = { 65.f, 40.f };
static float const FrameWidthPadding = 10.f;
static float const LargeFontSize = 16.f;
static float const SmallFontSize = 14.f;

typedef NS_ENUM(NSInteger, AnimationType) {
  None,
  Fade,
  Resize
};

@interface TDFSignAnnotation()

@property (nonatomic, strong) UIColor *fillColour;
@property (nonatomic, strong) UIView *signpostView;
@property (nonatomic, strong) UIView *signView;
@property (nonatomic, strong) UILabel *stageLabel;
@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic, strong) TDFSignArrowView *signArrowView;

@end

@implementation TDFSignAnnotation

- (instancetype)initWithStageNumber: (unsigned int)stageNumber startName:(NSString*)startName
                            endName: (NSString*)endName distance:(float)distance   {
  self = [super initWithFrame:CGRectZero];
  
  if (self) {
    self.stageNumber = stageNumber;
    self.startName = startName;
    self.endName = endName;
    self.distance = distance;
    
    self.fillColour = [UIColor darkGrayColor];
    
    self.signpostView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 3.f, self.frame.size.height)];
    self.signpostView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.signpostView.backgroundColor = self.fillColour;
    [self addSubview:self.signpostView];
    
    self.signView = [[UIView alloc] initWithFrame:CGRectZero];
    self.signView.backgroundColor = self.fillColour;
    [self addSubview:self.signView];
    
    self.stageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.stageLabel.backgroundColor = [UIColor clearColor];
    self.stageLabel.textColor = [UIColor whiteColor];
    [self.signView addSubview:self.stageLabel];
    
    self.detailsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailsLabel.backgroundColor = [UIColor clearColor];
    self.detailsLabel.textColor = [UIColor whiteColor];
    self.detailsLabel.font = [UIFont systemFontOfSize:SmallFontSize];
    [self.signView addSubview:self.detailsLabel];
    
    self.signArrowView = [[TDFSignArrowView alloc] initWithFrame:CGRectZero];
    self.signArrowView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.signArrowView];
  }
  
  return self;
}

// Works out the size of the new sign frame based on the given text
- (CGRect)calculateNewSignFrameForStageText:(NSString *)stageText detailsText:(NSString *)detailsText {
  CGSize stageTextSize;
  
  switch (self.detailLevel) {
    case Nothing:
      // No sign, so we want an empty frame
      return CGRectZero;
      
    case StageNumber:
      // Fix the width, so the flags are all the same width, but use the text height
      stageTextSize = [stageText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SmallFontSize]}];
      return CGRectMake(0, 0, SmallFrameSize.width/2, stageTextSize.height * 1.2f);
      
    case StageName:
      // Just size based on the stage text size plus some padding
      stageTextSize = [stageText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:LargeFontSize]}];
      return CGRectMake(0, 0, stageTextSize.width + 2*FrameWidthPadding, stageTextSize.height * 1.2f);
      
    case Details:
      // Size based on both stage text size and details text size: max of the widths, and total height (plus padding)
      stageTextSize = [stageText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:LargeFontSize]}];
      CGSize detailsTextSize = [detailsText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SmallFontSize]}];
      CGFloat width = MAX(stageTextSize.width, detailsTextSize.width) + 2*FrameWidthPadding;
      return CGRectMake(0, 0, width, (stageTextSize.height + detailsTextSize.height) * 1.2f);
  }
}

- (NSString *)getNewStageText {
  switch (self.detailLevel) {
    case Nothing:
      return @"";
    case StageNumber:
      return [NSString stringWithFormat:@"%d", self.stageNumber];
    case StageName:
      if (self.stageNumber == 0) {
        return @"Prologue";
      } else {
        return [NSString stringWithFormat:@"Stage %d", self.stageNumber];
      }
    case Details:
      if (self.stageNumber == 0) {
        return @"Prologue";
      } else {
        return [NSString stringWithFormat:@"Stage %d - %.0fkm", self.stageNumber, self.distance];
      }
  }
}

- (NSString *)getNewDetailsText {
  if (self.detailLevel == Details) {
    return [NSString stringWithFormat:@"%@ to %@", self.startName, self.endName];
  }
  
  return @"";
}

// Updates the labels' text and frames
- (void)updateLabelsWithStageText:(NSString *)stageText detailsText:(NSString *)detailsText
                      detailLevel:(DetailLevel)detailLevel {
  self.stageLabel.text = stageText;
  self.stageLabel.font = (detailLevel == StageNumber) ? [UIFont systemFontOfSize:SmallFontSize]
                                                      : [UIFont systemFontOfSize:LargeFontSize];
  [self.stageLabel sizeToFit];
  
  self.detailsLabel.text = detailsText;
  if (self.detailLevel == Details) {
    [self.detailsLabel sizeToFit];
  } else {
    self.detailsLabel.frame = CGRectZero;
  }
  
  CGRect stageLabelFrame = self.stageLabel.frame;
  stageLabelFrame.origin.x = FrameWidthPadding;
  stageLabelFrame.origin.y = self.signView.frame.size.height / 2 -
    ((stageLabelFrame.size.height + self.detailsLabel.frame.size.height) / 2);
  self.stageLabel.frame = stageLabelFrame;
  
  CGRect detailsLabelFrame = self.detailsLabel.frame;
  detailsLabelFrame.origin.x = stageLabelFrame.origin.x;
  detailsLabelFrame.origin.y = stageLabelFrame.origin.y + stageLabelFrame.size.height;
  self.detailsLabel.frame = detailsLabelFrame;
}

- (void)updateFrames:(CGRect)newSignFrame detailLevel:(DetailLevel)detailLevel {
  self.signView.frame = newSignFrame;
  
  // Size main frame based on detail level
  CGSize newFrameSize;
  switch (detailLevel) {
    case Nothing:
      newFrameSize = CGSizeZero;
      break;
    case StageNumber:
      newFrameSize = SmallFrameSize;
      break;
    case StageName:
      newFrameSize = MediumFrameSize;
      break;
    case Details:
      newFrameSize = LargeFrameSize;
  }
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          newFrameSize.width, newFrameSize.height);
  
  // Resize and reposition the arrowhead to the right of the sign
  self.signArrowView.frame = CGRectMake(newSignFrame.size.width,
                                        0.f,
                                        newSignFrame.size.height * 0.6,
                                        newSignFrame.size.height);
}

- (void)redrawWithAnimationType:(AnimationType)animationType {
  NSString *stageText = [self getNewStageText];
  NSString *detailsText = [self getNewDetailsText];
  CGRect newSignFrame = [self calculateNewSignFrameForStageText:stageText detailsText:detailsText];
  
  if (animationType == Fade) {
    DetailLevel currentLevel = self.detailLevel;
    if (currentLevel == Nothing) {
      // Fading to Nothing: simply animate alpha to 0
      [UIView animateWithDuration:0.4
                            delay:0.0
                          options:UIViewAnimationOptionCurveEaseIn
                       animations:^{
                         self.alpha = 0.f;
                       }
                       completion:nil];
    } else {
      // Fading from nothing to a new label
      // First update the frames and labels
      [self updateFrames:newSignFrame detailLevel:currentLevel];
      [self updateLabelsWithStageText:stageText detailsText:detailsText detailLevel:currentLevel];
      // Now animate alpha to 1
      [UIView animateWithDuration:0.4
                            delay:0.0
                          options:UIViewAnimationOptionCurveEaseIn
                       animations:^{
                         self.alpha = 1.f;
                       }
                       completion:nil];
    }
  } else if (animationType == Resize) {
    // Make sure we're visible
    self.alpha = 1.f;
    
    DetailLevel currentLevel = self.detailLevel;
    
    // Animation 1/3: fade out the text labels
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       self.stageLabel.alpha = 0.f;
                       self.detailsLabel.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                       // Animation 2/3: resize the sign
                       [UIView animateWithDuration:0.2
                                             delay:0.0
                                           options:UIViewAnimationOptionCurveEaseIn
                                        animations:^{
                                          [self updateFrames:newSignFrame detailLevel:currentLevel];
                                        }
                                        completion:^(BOOL finished) {
                                          // Update the labels
                                          [self updateLabelsWithStageText:stageText
                                                              detailsText:detailsText
                                                              detailLevel:currentLevel];
                                          
                                          // Animation 3/3: fade the updated label text back in
                                          [UIView animateWithDuration:0.1
                                                                delay:0.0
                                                              options:UIViewAnimationOptionCurveEaseIn
                                                           animations:^{
                                                             self.stageLabel.alpha = 1.f;
                                                             self.detailsLabel.alpha = 1.f;
                                                           }
                                                           completion:nil];
                                        }];
                     }];
  } else {
    // No animations; just make sure we're visible and update the frames and the text
    self.alpha = 1.f;
    [self updateFrames:newSignFrame detailLevel:self.detailLevel];
    [self updateLabelsWithStageText:stageText detailsText:detailsText detailLevel:self.detailLevel];
  }
}

- (void)setDetailLevel:(DetailLevel)detailLevel {
  DetailLevel oldDetailLevel = _detailLevel;
  _detailLevel = detailLevel;
  
  AnimationType animationType = Resize;
  if (CGRectIsEmpty(self.frame)) {
    // Don't animate if it's the first time we've been drawn
    animationType = None;
  } else if (oldDetailLevel == Nothing || self.detailLevel == Nothing)    {
    // Use fade not resize if we're switching to/from a detailLevel of Nothing
    animationType = Fade;
  }
  
  [self redrawWithAnimationType:animationType];
}

-(void)updateViewWithCanvas:(SChartCanvas *)canvas {
  [super updateViewWithCanvas:canvas];
  
  // Ensure that the bottom left corner of the annotation is touching the line series, rather than its center
  self.center = CGPointMake(self.center.x + (self.frame.size.width * 0.5f), self.center.y - (self.frame.size.height * 0.5f));
}

@end
