//
//  DSMRViewController.m
//  TiledLayerSnapTest
//
//  Created by Justin Miller on 2/2/12.
//  Copyright (c) 2012 Development Seed. All rights reserved.
//

#import "DSMRViewController.h"

#import "RMMapView.h"

#import <QuartzCore/QuartzCore.h>

#import "/Developer/SDKs/MacOSX10.7.sdk/System/Library/Frameworks/Foundation.framework/Versions/C/Headers/NSTask.h"

@implementation DSMRViewController

@synthesize segmentedControl;
@synthesize containerView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSAssert([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"], @"must run in simulator in order to use NSTask");
    
    [self.segmentedControl addTarget:self action:@selector(changedSegment:) forControlEvents:UIControlEventValueChanged];

    [self changedSegment:self];
}

- (void)changedSegment:(id)sender
{
    UIView *newView = nil;
    
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        // switch to normal UIView
        //
        newView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        
        newView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
    }
    else
    {
        // switch to UIScrollView-based map view
        //
        newView = [[RMMapView alloc] initWithFrame:self.containerView.bounds];
        
        ((RMMapView *)newView).decelerationMode = RMMapDecelerationFast;
    }

    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [self.containerView addSubview:newView];
}

- (IBAction)tappedGetSnapshot:(id)sender
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile:[NSString stringWithFormat:@"/tmp/snapshot.png"] atomically:YES];

    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject:@"/tmp/snapshot.png"]];
}

@end