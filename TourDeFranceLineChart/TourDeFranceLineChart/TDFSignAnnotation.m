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

@interface TDFSignAnnotation()

@property (nonatomic, strong) UIColor *fillColour;
@property (nonatomic, strong) UIView *signpostView;
@property (nonatomic, strong) UIView *signView;
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
    
    self.signArrowView = [[TDFSignArrowView alloc] initWithFrame:CGRectZero];
    self.signArrowView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.signArrowView];
  }
  
  return self;
}

// Draws a sign showing the stage number, either as "Stage X" or as "X"
- (void)drawStageNumberSign:(BOOL)justNumber {
  // Remove any existing labels from the sign
  for (UIView *subview in self.signView.subviews)  {
    [subview removeFromSuperview];
  }
  
  // Resize the annotation 
  CGRect frame;
  if (justNumber) {
    frame = CGRectMake(0, 0, SmallFrameSize.width, SmallFrameSize.height);
  } else {
    frame = CGRectMake(0, 0, MediumFrameSize.width, MediumFrameSize.height);
  }
  self.frame = frame;
  
  // Draw the label containing the stage number
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  if (justNumber) {
    label.text = [NSString stringWithFormat:@"%d", self.stageNumber];
    label.font = [UIFont systemFontOfSize:SmallFontSize];
  } else {
    if (self.stageNumber == 0)   {
      label.text = @"Prologue";
    } else {
      label.text = [NSString stringWithFormat:@"Stage %d", self.stageNumber];
    }
    label.font = [UIFont systemFontOfSize:LargeFontSize];
  }
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor whiteColor];
  [label sizeToFit];
  
  // Resize the sign view to contain the label
  CGRect signViewFrame = self.signView.frame;
  // If we're just showing a number, set the sign view to have a constant frame width,
  // regardless of the width of the label
  if (justNumber) {
    signViewFrame.size.width = self.frame.size.width / 2.f;
  } else {
    signViewFrame.size.width = label.frame.size.width + 2*FrameWidthPadding;
  }
  signViewFrame.size.height = label.frame.size.height * 1.2f;
  self.signView.frame = signViewFrame;
  
  // Now add the number label to the sign view, and reposition it
  [self.signView addSubview:label];
  CGRect numberLabelFrame = label.frame;
  numberLabelFrame.origin.x = signViewFrame.size.width / 2 - numberLabelFrame.size.width / 2;
  numberLabelFrame.origin.y = signViewFrame.size.height / 2 - numberLabelFrame.size.height / 2;
  label.frame = numberLabelFrame;
  
  // Resize and reposition the arrowhead to the right of the sign
  self.signArrowView.frame = CGRectMake(signViewFrame.size.width,
                                        0.f,
                                        signViewFrame.size.height * 0.6,
                                        signViewFrame.size.height);
}

// Draw a sign with the full details of the stage
- (void)drawStageDetailsSign {
  // Remove any existing labels from the sign
  for (UIView *subview in self.signView.subviews)  {
    [subview removeFromSuperview];
  }
  
  // Resize the annotation
  CGRect frame = CGRectMake(0, 0, LargeFrameSize.width, LargeFrameSize.height);
  self.frame = frame;
  
  NSString *stageName;
  if (self.stageNumber == 0) {
    stageName = @"Prologue";
  } else {
    stageName = [NSString stringWithFormat:@"Stage %d", self.stageNumber];
  }
  
  // Draw the label containing the stage number and distance
  UILabel *stageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  stageLabel.text = [NSString stringWithFormat:@"%@ - %.0fkm", stageName, self.distance];
  stageLabel.font = [UIFont systemFontOfSize:LargeFontSize];
  stageLabel.backgroundColor = [UIColor clearColor];
  stageLabel.textColor = [UIColor whiteColor];
  [stageLabel sizeToFit];
  
  // Draw a label showing the start and end point of the stage
  UILabel *startToEndLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  startToEndLabel.text = [NSString stringWithFormat:@"%@ to %@", self.startName, self.endName];
  startToEndLabel.font = [UIFont systemFontOfSize:SmallFontSize];
  startToEndLabel.backgroundColor = [UIColor clearColor];
  startToEndLabel.textColor = [UIColor whiteColor];
  [startToEndLabel sizeToFit];
  
  // Calculate which label is wider.  We will use the wider width to resize the sign view
  NSUInteger maxLabelWidth = stageLabel.frame.size.width;
  if (startToEndLabel.frame.size.width > maxLabelWidth) {
    maxLabelWidth = startToEndLabel.frame.size.width;
  }
  
  // Resize the sign view to contain the labels
  CGRect signViewFrame = self.signView.frame;
  signViewFrame.size.width = maxLabelWidth + 2*FrameWidthPadding;
  signViewFrame.size.height = (stageLabel.frame.size.height + startToEndLabel.frame.size.height) * 1.2f;
  self.signView.frame = signViewFrame;
  
  // Now add the labels to the sign view, and position them
  [self.signView addSubview:stageLabel];
  [self.signView addSubview:startToEndLabel];
  
  CGRect stageLabelFrame = stageLabel.frame;
  stageLabelFrame.origin.x = FrameWidthPadding;
  stageLabelFrame.origin.y = signViewFrame.size.height / 2 -
                              ((stageLabelFrame.size.height + startToEndLabel.frame.size.height) / 2);
  stageLabel.frame = stageLabelFrame;
  
  CGRect startToEndFrame = startToEndLabel.frame;
  startToEndFrame.origin.x = stageLabelFrame.origin.x;
  startToEndFrame.origin.y = stageLabelFrame.origin.y + stageLabelFrame.size.height;
  startToEndLabel.frame = startToEndFrame;
  
  // Resize and reposition the arrowhead
  self.signArrowView.frame = CGRectMake(signViewFrame.size.width,
                                        0.f,
                                        signViewFrame.size.height * 0.75f,
                                        signViewFrame.size.height);
}

- (void)redrawWithAnimation:(BOOL)fade {
    
  // It is possible that previous renders set alpha to 0.  Reset it here
  self.alpha = 1.0f;
  
  switch (self.detailLevel) {
    case Nothing: {
      // Set the alpha of the annotation to 0.  If we're animating, do this within an animation block
      [self drawChanges:^{self.alpha = 0.f;} animate:fade];
      break;
    }
    case StageNumber: {
      if (fade) {
        self.alpha = 0.f;
      }
      
      [self drawChanges:^{
        [self drawStageNumberSign:YES];
        self.alpha = 1.f;
      } animate:fade];
      
      break;
    }
    case StageName: {
      [self drawChanges:^{[self drawStageNumberSign:NO];} animate:fade];
      break;
    }
    case Details: {
      [self drawChanges:^{[self drawStageDetailsSign];} animate:fade];
      break;
    }
    default: {
      break;
    }
  }
}

- (void)drawChanges:(void (^)(void))changes animate:(BOOL)animate {
  if (animate) {
    DetailLevel currentLevel = self.detailLevel;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:changes
                     completion:^(BOOL finished){
                       // If the detail level has changed during the animation, force a redraw
                       if (self.detailLevel != currentLevel) {
                         [self redrawWithAnimation:NO];
                       }
                     }];
  } else {
    changes();
  }
}

- (void)setDetailLevel:(DetailLevel)detailLevel {
  DetailLevel oldDetailLevel = _detailLevel;
  _detailLevel = detailLevel;
  
  // We only animate if we are going from a state where annotations aren't shown to showing stage numbers
  BOOL fade = NO;
  if ((self.detailLevel == StageNumber && oldDetailLevel == Nothing) || (self.detailLevel == Nothing && oldDetailLevel == StageNumber))    {
    fade = YES;
  }
  
  [self redrawWithAnimation:fade];
}

-(void)updateViewWithCanvas:(SChartCanvas *)canvas {
  [super updateViewWithCanvas:canvas];
  
  // Ensure that the bottom left corner of the annotation is touching the line series, rather than its center
  self.center = CGPointMake(self.center.x + (self.frame.size.width * 0.5f), self.center.y - (self.frame.size.height * 0.5f));
}

@end
