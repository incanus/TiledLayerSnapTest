//
//  DSMRViewController.h
//  TiledLayerSnapTest
//
//  Created by Justin Miller on 2/2/12.
//  Copyright (c) 2012 Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSMRViewController : UIViewController

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIView *containerView;

- (void)changedSegment:(id)sender;
- (IBAction)tappedGetSnapshot:(id)sender;

@end