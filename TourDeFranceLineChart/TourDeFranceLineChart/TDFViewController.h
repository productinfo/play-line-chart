//
//  FeaturedLineChartViewController.h
//  FeaturedLineChart
//
//  Created by Alison Clarke on 07/07/2014.
//  Copyright (c) 2014 Alison Clarke. All rights reserved.
//

@import UIKit;
#import <ShinobiCharts/ShinobiCharts.h>
#import "ShinobiPlayUtils/SPUGalleryManagedChartViewController.h"
#import "TDFDataSource.h"

@interface TDFViewController : SPUGalleryManagedChartViewController

@property (nonatomic, strong) TDFDataSource *dataSource;

@end
